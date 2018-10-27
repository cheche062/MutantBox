package game.module.camp
{
	import MornUI.componets.UnitItemUI;
	
	import game.common.starBar;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBBuilding;
	import game.global.data.DBUnitStar;
	import game.global.data.bag.BagManager;
	import game.global.util.TimeUtil;
	import game.global.util.UnitPicUtil;
	import game.global.vo.AwakenEqVo;
	import game.global.vo.User;
	import game.module.camp.data.JueXingData;
	import game.module.camp.data.JueXingMange;
	import game.module.fighting.FightUtil;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	/**
	 * UnitItem
	 * author:huhaiming
	 * UnitItem.as 2017-5-16 上午11:05:47
	 * version 1.0
	 *
	 */
	public class UnitItem extends UnitItemUI
	{
		protected var _starLv:starBar;
		/**升星动画*/
		private var _ani:Animation;
		public var data:UnitItemVo;
		public var rebornTime:Number;
		private var _unitInfo:Object;
		public function UnitItem()
		{
			super();
		}
		
		override public function set selected(value:Boolean):void{
			super.selected = value;
			if(value){
				this.addChildAt(selectedFrame, this.getChildIndex(numTF));
			}else{
				if(this.contains(selectedFrame)){
					selectedFrame.removeSelf();
				}
			}
		}
		
		/**value Object类型 ，必须有key——"id/unitId/unit_id"*/
		override public function set dataSource(value:*):void{
			this.data = value;
			if(data){
				//状态回收
				this.stateTF.text = this.timeTF.text = "";
				this.rebornBtn.visible = false;
				Laya.timer.clear(this, updateState);
				
				//start 数据兼容--
				if(data.hasOwnProperty("unitId")){
					this.data.id = data["unitId"]
				}else if(data.hasOwnProperty("unit_id")){
					this.data.id = data["unit_id"]
				}
				//end 数据兼容
				if(data.se){
					this.minusBtn.visible = this.mPic.visible = true;
				}else{
					this.minusBtn.visible = this.mPic.visible = false;
				}
				this.numTF.text = "";
				if(this._ani){
					this._ani.stop();
					this._ani.visible = false;
				}
				this.FightingText.visible=false;
				this.FightingImage.visible=false;
				this.FightingBgImage.visible=false;
				this.AddBtn.visible=false;
				CampData.getUnitInfo(data.id, this, this.onGetInfo);
				
				// 选中状态
				selected = data["isSelected"];
			}
		}
		
		private function onGetInfo(unitInfo:Object):void{
			var vo:Object = GameConfigManager.unit_json[data.id]
			if(!unitInfo){
				unitInfo = vo;
			}
			/*if(vo.unit_type == DBUnit.TYPE_HERO){
				bg.skin = "common/bg6_hero.png";
			}else{*/
				bg.skin = "common/bg6_"+(vo.rarity)+".png";
			//}
				iconCamp.skin = "common/icons/camp_1"+vo.camp+".png"
			_unitInfo = unitInfo;
			_starLv.maxStar = vo.star;
			if(_starLv.maxStar > 5){
				this._starLv.y = 126;
			}else{
				this._starLv.y = 130;
			}
			NameText.text=vo.name;
			LevelText.text=GameLanguage.getLangByKey("L_A_73")+(unitInfo.level || 1);
			HeroImage.skin=UnitPicUtil.getUintPic(data.id,UnitPicUtil.PIC_HALF);
			if(unitInfo.unitId){//客户端标记，表示是否已经激活的卡牌
				HeroImage.gray = false;
				//HeroImage.filters = null
			}else{
				HeroImage.gray = true;
				//HeroImage.filters = [XUtils.blackFilter];
			}
			if(unitInfo.power)
			{
				this.FightingText.text=unitInfo.power;
			}
			
			
			attackIcon.skin = "common/icons/a_"+vo.attack_type+".png"
			defendIcon.skin = "common/icons/b_"+vo.defense_type+".png"
			qPic.skin = "common/l"+(vo.rarity-1)+"_1.png"
			//是否需要显示数量
			if(data.sn && unitInfo.have_number){
				this.numTF.text = ""+unitInfo.have_number;
			}else if(data.num && vo.unit_type != 1){
				this.numTF.text = ""+data.num;
			}
			
			if(data.se){
				if(unitInfo.have_number > 0){
					this.minusBtn.disabled = false;
				}else{
					this.minusBtn.disabled = true;
				}
			}
			
			var starId:String = (unitInfo.starId || unitInfo.star_id);
			var starVo:Object = (DBUnitStar.getStarData(starId) || {});
			
			//是否需要显示升级动画
			if(data.su){
				var tmp:Array;
				var canDo:Boolean = true;
				if(unitInfo == vo){//碎片状态，需要合成
					tmp = (vo.condition+"").split("|");
					for(var i:String in tmp){
						if((tmp[i]+"").indexOf("B") == -1){
							tmp = (tmp[i]+"").split("=");
							break;
						}
					}
				}else{
					tmp = (starVo.star_cost+"").split("=");
					if(starVo.star_level >= vo.star){
						canDo = false;
					}
				}
//				trace("adkladla;");
//				checkJx();
				
				if((tmp.length > 1 && BagManager.instance.getItemNumByID(tmp[0]) >= tmp[1] && canDo)){
//					trace("UID:"+data.id+"显示特效");
//					trace("starVo:"+starVo);
					if(!_ani){
						_ani = new Animation();
						_ani.loadAtlas("appRes/atlas/camp/effect.json");
						_ani.pos(106,-24);
						this.addChild(_ani);
					}
					_ani.visible = true;
					_ani.play();
				}
			}
			
			//星级
			if(unitInfo.hasOwnProperty("starId")){//服务端传过来的数据
				vo = DBUnitStar.getStarData(unitInfo.starId);
				if(vo){
					_starLv.barValue = vo.star_level;
				}
			}else if(unitInfo.hasOwnProperty("initial_star")){
				_starLv.barValue = unitInfo.initial_star
			}
			
			/**
			* 英雄状态
			*/
			if(!data.hs && unitInfo.used && unitInfo.used > 0){
				this.mPic.visible = true;
				this.stateTF.text = GameConfigManager.heroUseds[unitInfo.used].value;
				this.stateIcon.skin = "common/icons/icon_s"+unitInfo.used+".png";
			}else if(unitInfo.cdTime){
				rebornTime = unitInfo.cdTime*1000 - TimeUtil.now;
				if(rebornTime > 0){
					this.stateTF.text = TimeUtil.getTimeStr(rebornTime);
					this.mPic.visible = true;
					this.rebornBtn.visible = true;
					this.stateIcon.skin = "common/icons/icon_s0.png";
					Laya.timer.loop(1000, this, this.updateState);
				}
			}else{
				this.stateIcon.skin = "";
			}
			
			this.cacheAsBitmap = true;
		}
		
		private function checkJx(uid:uint):Boolean
		{
			// TODO Auto Generated method stub
//			var uid:Number = data.id;
			if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) < 2)
			{
				trace("兵营等级小于2级");
				return false;
			}
			var _jxd:JueXingData;
			var ifJx:Boolean = true;
			if(CampData.getUintById(uid))
			{
				_jxd= JueXingMange.intance.getJueXingDataByUid(uid);	
				var max:Boolean = _jxd.isMax;
				var ifFull:Boolean = _jxd.isFull;
				var ar:Array =  _jxd.eqList;
				var vo1:AwakenEqVo;
//				trace("ar:"+JSON.stringify(ar));
				var curUitOk:Boolean = true;
				trace("uid:"+uid+"max:"+max);
				var isExitNext = _jxd.awakenVo.costList;
				if (isExitNext) 
				{
					var costData = _jxd.awakenVo.costList[0];
					var itemNum:Number = User.getInstance().getResNumByItem(costData.iid);
					if(itemNum < costData.inum)
					{
//						trace("uid"+uid+"觉醒道具数量不足");
						//							continue;
						ifJx = false;
					}
				}else 
				{
//					trace("uid:"+uid+"达到最大觉醒等级");
					ifJx = false;
				}
				if(!ifFull)
				{
					for each(var data:Array in ar)
					{
						vo1 = data[1];
						var states:Array = vo1.getStates(uid);
						if(states.length>0)//必须都满足条件，才可能存在兵种觉醒
						{//不满足
							//								trace("uid:"+uid+"不满足");
							ifJx = false;
							break;
						}
					}
				}
			}else
			{
				ifJx = false;
			}
			return ifJx;
		}
		
		private function updateState():void{
			rebornTime = _unitInfo.cdTime*1000 - TimeUtil.now;
			if(rebornTime > 0){
				this.stateTF.text = TimeUtil.getTimeStr(rebornTime);
				this.mPic.visible = true;
				this.rebornBtn.visible = true;
			}else{
				this.stateIcon.skin = "";
				this.mPic.visible = false;
				this.rebornBtn.visible = false;
				Laya.timer.clear(this, updateState);
			}
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			this.rebornBtn.off(Event.CLICK, this, this.onClick);
			if(this.contains(selectedFrame)){
				selectedFrame.removeSelf();
			}
			super.destroy(destroyChild);
		}
		
		private function onClick():void{
			var handler:Handler = Handler.create(this, onReborn);
			FightUtil.outArmyCd(data.id,rebornTime, handler);
		}
		
		private function onReborn():void{
			var info:Object = CampData.getUintById(data.id);
			info && (info.cdTime = 0);
			//重新格式化
			dataSource = data;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			this._starLv = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10,5);
			this.addChildAt(this._starLv, this.getChildIndex(mPic));
			this._starLv.scaleX = this._starLv.scaleY = 0.6;
			this._starLv.x = 16;
			this._starLv.y = 126;
			this.minusBtn.visible = false;
			this.mPic.visible = false;
			this.LevelText.text = this.NameText.text = this.numTF.text = "";
			this.stateTF.text = this.timeTF.text = "";
			this.rebornBtn.visible = false;
			
			this.rebornBtn.on(Event.CLICK, this, this.onClick);
		}
		
		/**静态选中框*/
		private static var _selectedFrame:Image;
		private static function get selectedFrame():Image{
			if(!_selectedFrame){
				_selectedFrame = new Image("common/bg6_select.png");
				_selectedFrame.pos(3,-4);
			}
			return _selectedFrame
		}
	}
}