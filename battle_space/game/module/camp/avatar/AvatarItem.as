package game.module.camp.avatar
{
	import MornUI.camp.avatar.SkinItemUI;
	
	import game.global.GameLanguage;
	import game.global.data.bag.BagManager;
	import game.global.util.UnitPicUtil;
	import game.module.camp.CampData;
	
	import laya.display.Animation;
	import laya.ui.Image;
	
	/**
	 * AvatarItem
	 * author:huhaiming
	 * AvatarItem.as 2018-3-30 下午4:38:36
	 * version 1.0
	 *
	 */
	public class AvatarItem extends SkinItemUI
	{
		/**动画*/
		private var _ani:Animation;
		private var _canCompose:Boolean = false;
		private var _canLvup:Boolean;
		private var _showState:Boolean;
		public function AvatarItem(showState:Boolean = true)
		{
			super();
			_showState = showState;
			spState.visible = false;
		}
		
		/***/
		override public function set dataSource(value:*):void{
			super.dataSource = value;
			var vo:SkinVo = value;
			
			
			
			spState.visible = false;
			_canCompose = false;
			_canLvup = false;
			FightingText.text = "0";
			if(_ani){
				_ani.stop();
				_ani.visible = false;
			}
			if(vo){
				bg.skin = "common/bg6_"+(Math.max(vo.garde, 1))+".png";
				trace("vo.ID============",vo)
				HeroImage.skin=UnitPicUtil.getUintPic(vo.unit,UnitPicUtil.PIC_HALF, vo.ID);
				NameText.text = vo.name;
				LevelText.text = GameLanguage.getLangByKey("L_A_73")+"0";
				this.btnInfo.visible = vo.garde>0
				
				var heroVo:Object = CampData.getUintById(vo.unit);
				trace("heroVo:"+JSON.stringify(heroVo));
				if(heroVo){
					if(vo.ID == heroVo.skin){
						spState.visible = true;
						stateTF.text = "L_A_84553"
					}
					
					var skins:Object = (heroVo.skins || {});
					var skinInfo:Object = skins[vo.ID];
					
					if(skinInfo){
						this.HeroImage.gray = false;
						var lv:int = skinInfo[0]
						LevelText.text = GameLanguage.getLangByKey("L_A_73")+lv;
						//升级
						var skinVo:SkinProVo = DBSkin.getSkinPro(lv, vo.node);
						if(skinVo){
							trace("skinVo:"+skinVo);
							FightingText.text = skinVo.all_br+"";
							itemInfo = vo.cost.split("=");
							var itemNum:int = BagManager.instance.getItemNumByID(itemInfo[0]);
							if(lv < DBSkin.MAX_LV && itemNum >= parseInt(itemInfo[1])){
								if(!_ani){
									_ani = new Animation();
									_ani.loadAtlas("appRes/atlas/camp/effect.json");
									_ani.pos(106,-24);
									this.addChild(_ani);
								}
								_ani.visible = true;
								_ani.play();
								_canLvup = true;
							}
						}
					}else{
						trace("dakdjll");
						this.HeroImage.gray = true;
						var skinVo:SkinProVo = DBSkin.getSkinPro(0, vo.node);
						skinVo && (FightingText.text = skinVo.all_br+"");
						//合成---------
						trace("vo--------"+JSON.stringify(vo));
						var itemInfo:Array= vo.cost.split("=");
						spState.visible = true;
						itemNum = BagManager.instance.getItemNumByID(itemInfo[0]);
						stateTF.text = itemNum+"/"+itemInfo[1];
						if(itemNum >= parseInt(itemInfo[1])){
							this.HeroImage.gray = false;
							if(!_ani){
								_ani = new Animation();
								_ani.loadAtlas("appRes/atlas/camp/effect.json");
								_ani.pos(106,-24);
								this.addChild(_ani);
							}
							_ani.visible = true;
							_ani.play();
							_canCompose = true;
						}
					}
				}else{
//					trace("mmmmmmmmmmm");
					this.HeroImage.gray = true;
				}
			}
			
			if(FightingText.text == "0"){
				FightingText.text = "----"
			}
			
			if(!_showState){
				spState.visible = false;
				btnInfo.visible = false;
				_ani && (_ani.visible = false)
			}
		}
		
		override public function set selected(value:Boolean):void{
			super.selected = value;
			if(value){
				if(!this.contains(selectedFrame)){
					this.addChildAt(selectedFrame, getChildIndex(FightingImage));
				}
			}else{
				if(this.contains(selectedFrame)){
					selectedFrame.removeSelf();
				}
			}
		}
		
		public function get canCompose():Boolean{
			return this._canCompose;
		}
		
		public function get canLvup():Boolean{
			return this._canLvup;
		}
		
		/**静态选中框*/
		private static var _selectedFrame:Image;
		private static function get selectedFrame():Image{
			if(!_selectedFrame){
				_selectedFrame = new Image("newUnitInfo/frame_2.png");
				_selectedFrame.pos(3,-4);
			}
			return _selectedFrame
		}
	}
}