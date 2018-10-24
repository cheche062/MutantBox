/***
 *作者：罗维
 */
package game.module.fighting.cell
{
	import MornUI.fightingView.SelectUnitCellUIUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.CountdownLabel;
	import game.common.FilterTool;
	import game.common.MaskProgressBar;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.util.TimeUtil;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Sprite;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.ProgressBar;
	import laya.ui.UIUtils;
	import laya.webgl.canvas.BlendMode;
	
	public class SelectUnitCell extends Box implements ISelectUnitCell
	{
		private var _faceImg:Image;
		private var _numLabel:Label;
		private var _rkLabel:Label; 
		private var _flag:Image;
		private var _bgImg:Image;
//		private var _idLabel:Label = new Label();
		
		private var _timerText:CountdownLabel;
		private var _stateText:Label;
		
		public var hpBarBg:Image;
		public var hpBar:ProgressBar ;
		
		private var _uiView:SelectUnitCellUIUI;
		
		private var topSp:Box;
		private var stateText:Label;
		private var _data:ArmyData;
		
		
		public function SelectUnitCell()
		{
			super();
		}
		
		
		public function get data():ArmyData
		{
			return _data;
		}

		
//		public function getName(s:String,max:Number = 10):String
//		{
//			s = GameLanguage.getLangByKey(s);
//			if(s.length <= max) return s;
//			return s.substring(0,max - 3) + "...";
//		}
		
		public function set data(value:ArmyData):void
		{
			_data = value;
			
			if(data)
			{
//				if(data.unitVo.isHero)
//					_bgImg.skin ="common/bg6_hero.png";
//				else
					_bgImg.skin = "common/bg6_"+data.unitVo.rarity+".png";
				
//				_faceImg.graphics.clear();
//				_faceImg.loadImage();
					_faceImg.skin = UnitPicUtil.getUintPic(data.unitVo.model,UnitPicUtil.PIC_SEL);
					_uiView.camp.skin = "common/icons/camp_1"+data.unitVo.camp+".png";
				_numLabel.text= data.num;
//				_numLabel.text= 999;
				_uiView.xLbl.x = _numLabel.x  - _numLabel.textField.textWidth - _uiView.xLbl.width + _numLabel.width + 5;
				_rkLabel.text = data.unitVo.population;
				_uiView.maxLb.text = data.unitVo.num_limit;
				
				_uiView.rkBox.visible = _uiView.numBox.visible = !data.unitVo.isHero;  //英雄不显示数量  
//				_uiView.heroName.text = getName(data.unitVo.name);
				_uiView.heroName.text = data.unitVo.name;
					
				_uiView.gjTypeImg.skin = "common/icons/a_"+data.unitVo.attack_type+".png"
				_uiView.fsTypeImg.skin = "common/icons/b_"+data.unitVo.defense_type+".png";
				_flag.skin = "common/l"+(data.unitVo.rarity - 1)+"_1.png";
				//				_idLabel.text = String(data.unitId);
				bindStage();
				
				hpBarBg.visible = false;
				if(data.hp && data.maxHp && data.hp != data.maxHp)
				{
					hpBarBg.visible = true;
					hpBar.value = data.hp / data.maxHp;
				}
			}
		}

		public function get timerText():CountdownLabel
		{
			if(!_timerText)
			{
				_timerText = new CountdownLabel(_uiView.timerText);
			}
			
			return _timerText;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			_uiView = new SelectUnitCellUIUI();
			addChild(_uiView);
			
			_faceImg = _uiView.faceImg;
			
			_numLabel = _uiView.numLbl;
			_rkLabel = _uiView.rkLbl;
			_flag = _uiView.flag;
			
			hpBarBg = _uiView.hpBarBg
			hpBar = _uiView.hpBar;
			hpBar.bg.visible = false;
			hpBarBg.visible =false;
			
			topSp = _uiView.topSp;
			
			_bgImg = _uiView.bgImg;
			
			stateText = _uiView.stateText;
			this.size( _uiView.width , _uiView.height);
			this.mouseEnabled = this.mouseThrough = true;
			_uiView.mouseEnabled = _uiView.mouseThrough = true;
			_uiView.bgImg.mouseEnabled = _uiView.bgImg.mouseThrough = true;
			_uiView.bgBox.mouseEnabled = _uiView.bgBox.mouseThrough = true;
			_uiView.rebornBtn.on(Event.CLICK,this,rebornClick);
			_uiView.infoBtn.on(Event.CLICK,this,infoBtnClick);
		}
		
		private function infoBtnClick(e:Event):void
		{
			if (!data || !User.getInstance().hasFinishGuide)
			{
				
				return ;
			}
			var item:Object = {
				unitId:data.unitId
			};
			XFacade.instance.openModule("UnitInfoView", [item]);

			e.stopPropagation();
		}
		
		private function rebornClick(e:Event):void
		{
			if(data && data.save * 1000 > TimeUtil.now)
			{
				var n:Number = data.save * 1000 - TimeUtil.now;
				FightingManager.intance.fightOutArmyCd(data.unitId,n);
			}
		}
		
		public function getEnabled(showError:Boolean = false):Boolean{
			if(topSp.visible){
				
				return false;
			}
			if(data && data.lcState)
			{
				if(showError)
				{
					switch(data.lcState)
					{
						case 1:
						{
							XTip.showTip("L_A_65");
							break;
						}
					}
				}
				
				return false;
			}
			return true;
			
		}
		
		
		
		public override function set dataSource(value:*):void{
			super.dataSource = data = value;
		} 
		
		
		public function bindStage():void{
			if(data)
			{
				var b1:Boolean = data.state || data.state2;
				var b2:Boolean;
				if(data.save){
					b2 = data.save * 1000 > TimeUtil.now;
				}
				timerText.stop();
				stateText.text = timerText.textLbl.text = "";
				
				_uiView.rebornBtn.visible = b2;
				this.filters = [];
				if( b1 || b2)
				{
					topSp.visible = true;
					if(b2)
					{
						_uiView.stypeIcon.skin = "common/icons/icon_s0.png";
						var n:Number = data.save * 1000 - TimeUtil.now ;
						this.timer.once(n + 100 ,this,bindStage);
						stateText.text = "L_A_911";
						timerText.timerValue = n;
					}else{
						trace("data.state",data.state,data.state2);
						var _state:Number = data.state ? data.state : data.state2;
						if(_state == ArmyData.STATE_NOT_NUMBER)
						{
							_uiView.stypeIcon.skin = "";
							topSp.visible = false;
							this.filters = [UIUtils.grayFilter];
						}else
						{
							_uiView.stypeIcon.skin = "common/icons/icon_s"+_state+".png";
						}
						stateText.text = GameConfigManager.heroUseds[_state].value;
					}
					
				}else
				{
					if(topSp) 
						topSp.visible = false;
				}
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_uiView.rebornBtn.off(Event.CLICK,this,rebornClick);
			_uiView.infoBtn.off(Event.CLICK,this,infoBtnClick);
			if(_timerText)
				_timerText.destroy();
			_timerText = null;
			_faceImg = null;
			_numLabel = null;
			_rkLabel = null;
			_flag = null;
			_bgImg = null;
			_stateText = null;
			hpBarBg = null;
			hpBar = null;
			_uiView = null;
			topSp = null;
			stateText = null;
			_data = null;
			
			
			super.destroy(destroyChild);
			trace("SelectUnitCell ~~~~  destroy");
			
		}
	
	}
}