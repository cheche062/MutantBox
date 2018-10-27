package game.module.camp
{
	import MornUI.camp.UnitInfoViewUI;
	import MornUI.componets.SkillItemUI;
	
	import game.common.AnimationUtil;
	import game.common.ModuleManager;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.starBar;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ItemConst;
	import game.global.consts.ServiceConst;
	import game.global.data.DBSkill2;
	import game.global.data.DBUintUpgradeExp;
	import game.global.data.DBUnitStar;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	import game.module.mainui.MainView;
	import game.module.tips.PropertyTip;
	import game.module.tips.SkillTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.net.Loader;
	
	/**
	 * UnitInfoView
	 * author:huhaiming
	 * UnitInfoView.as 2017-5-17 上午10:26:30
	 * version 1.0
	 *
	 */
	public class UnitInfoView extends BaseDialog
	{
		private var _ids:Array;
		private var _curId:*;
		//索引
		private var _idx:int;
		private var _db:Object;
		private var _data:Object;
		private var _skillArr:Array;
		private var _starLv:starBar;
		private var _starVo:Object;
		private var _ani:Animation;
		public static const AttDic:Object = 
			{
				1:"L_A_706",
				2:"L_A_708",
				3:"L_A_704",
				4:"L_A_710"
			};
		public static const DefDic:Object = 
			{
				1:"L_A_718",
				2:"L_A_716",
				3:"L_A_714",
				4:"L_A_712"
			}
		public function UnitInfoView()
		{
			super();
		}
		
		override public function show(...args):void{ 
			super.show();
			var id:* = (args[0][0].id || args[0][0].unitId || args[0][0].unit_id);
			_ids = args[0][1];
			_idx = 0;
			if(_ids){
				_idx = _ids.indexOf(id);
			}
			if(_ids){
				this.view.prevBtn.visible = this.view.nextBtn.visible  = true;
			}else{
				this.view.prevBtn.visible = this.view.nextBtn.visible  = false;
			}
			showInfo(id);
			AnimationUtil.flowIn(this);
			
			
			if (!User.getInstance().hasFinishGuide)
			{
				
				Laya.timer.once(500, this, function() { 
					Signal.intance.event(NewerGuildeEvent.ENTER_CAMP_VIEW);
					} );
				
			}
		}
		
		override public function dispose():void{
			Laya.loader.clearRes(view.pic.skin);
			Laya.loader.clearRes("unitInfo/bg0_1.png");
			super.dispose();
		}
		
		private function showInfo(id:*):void{
//			trace("show............................",id);
			_curId = id;
			if(id){
				var db:Object = GameConfigManager.unit_json[id];
				this._db = db;
				this.view.titleTF.text = _db.name
				_starLv.maxStar = _db.star;
				if(_starLv.maxStar > 5){
					this._starLv.y = 436;
				}else{
					this._starLv.y = 442;
				}
				
				
				view.dataInfo.attackTF.innerHTML = Math.ceil(_db.ATK)+"";
				view.dataInfo.critTF.innerHTML = Math.ceil(_db.crit) +"";
				view.dataInfo.critDamageTF.innerHTML = Math.ceil(_db.CDMG)+"";
				view.dataInfo.critDamReductTF.innerHTML = Math.ceil(_db.CDMGR)+"";
				view.dataInfo.defenseTF.innerHTML = Math.ceil(_db.DEF)+"";
				view.dataInfo.dodgeTF.innerHTML = Math.ceil(_db.dodge)+"";
				view.dataInfo.hitTF.innerHTML = Math.ceil(_db.hit)+"";
				view.dataInfo.hpTF.innerHTML = Math.ceil(_db.HP)+"";
				view.dataInfo.resilienceTF.innerHTML = Math.ceil(_db.RES)+"";
				view.dataInfo.speedTF.innerHTML = Math.ceil(_db.SPEED)+"";
				
				
				//头像
				var url:String = UnitPicUtil.getUintPic(id,UnitPicUtil.PIC_FULL);
				if(url != view.pic.skin){
					Laya.loader.clearRes(view.pic.skin);
				}
				view.pic.skin = url;
				if(db.population > 0){
					view.popTF.text = db.population+"";
					view.poIcon.visible = true;
					view.maxTF.text = db.num_limit+"";
					view.maxIcon.visible = true;
				}else{
					view.popTF.text = "";
					view.poIcon.visible = false;
					view.maxTF.text = "";
					view.maxIcon.visible = false;
				}
				view.attackIcon.skin = "common/icons/a_"+db.attack_type+".png"
				view.defendIcon.skin = "common/icons/b_"+db.defense_type+".png";
				view.attackTF.text = AttDic[db.attack_type];
				view.defendTF.text = DefDic[db.defense_type];
				
				//
				view.numTF.text = ""
				
				if(db){
					view.nameTF.text = GameLanguage.getLangByKey(db.name)+"";
				}
			}
			
			//获取数据源信息
			CampData.getUnitInfo(db.unit_id, this, this.onGetUnitInfo)
		}
		
		private function formatSkill(item:SkillItemUI, skillId:*, starLv:int=-1):void{
			if(skillId && skillId != "undefined"){
				item.visible = true;
				var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId];
				//兼容被动技能
				if(starLv != -1){
					vo = DBSkill2.getSkillInfo(skillId);
					item.skillBg.skin = "common/skill_bg1.png";
					item.lvBG.skin = "common/skill_bg1_1.png";
				}else{
					item.skillBg.skin = "common/skill_bg.png";
					item.lvBG.skin = "common/skill_bg_1.png";
				}
				item.lvTF.text = vo.skill_level+"";
				if(vo){
					item.nameTF.text = vo.skill_name+"";
					item.icon.skin = "appRes/icon/skillIcon/"+vo.skill_icon+".png";
				}else{
					item.nameTF.text = "NoDataSource"
				}
				if(CampData.hasUnit(_curId) && this._starVo && this._starVo.star_level >= starLv){
					item.gray = false
				}else{
					item.gray = true;
				}
			}else{
				item.visible = false;
			}
		}
		
		/***/
		private function onGetUnitInfo(data:Object):void{
			if(!data){
				data = _db;
				this.view.upgradeBtn.label = GameLanguage.getLangByKey("L_A_701");
				//view.pic.filters = [XUtils.blackFilter2];
				view.pic.gray = true;
				view.powerTF.text = data.br;
			}else{
				this.view.upgradeBtn.label = GameLanguage.getLangByKey("L_A_702");
				//view.pic.filters = null;
				view.pic.gray = false;
				view.powerTF.text = data.power;
			}
			_data = data;
			var starId:String = (data.starId || data.star_id);
			var vo:Object = (DBUnitStar.getStarData(starId) || {});
			this._starVo = vo;
			//星级
			if(data.hasOwnProperty("starId")){//服务端传过来的数据
				_starLv.barValue = vo.star_level;
			}else if(data.hasOwnProperty("initial_star")){
				_starLv.barValue = data.initial_star
			}
			
			//兼容原始数据
			view.dataInfo.attackTF.innerHTML = Math.ceil(data.attack || vo.ATK)+"";
			view.dataInfo.critTF.innerHTML = Math.ceil(data.crit || vo.crit) +"";
			view.dataInfo.critDamageTF.innerHTML = Math.ceil(data.critDamage || vo.CDMG)+"";
			view.dataInfo.critDamReductTF.innerHTML = Math.ceil(data.critDamReduct|| vo.CDMGR)+"";
			view.dataInfo.defenseTF.innerHTML = Math.ceil(data.defense || vo.DEF)+"";
			view.dataInfo.dodgeTF.innerHTML = Math.ceil(data.dodge || vo.dodge)+"";
			view.dataInfo.hitTF.innerHTML = Math.ceil(data.hit || vo.hit)+"";
			view.dataInfo.hpTF.innerHTML = Math.ceil(data.hp || vo.HP)+"";
			view.dataInfo.resilienceTF.innerHTML = Math.ceil(data.resilience || vo.RES)+"";
			view.dataInfo.speedTF.innerHTML = Math.ceil(data.speed || vo.SPEED)+"";
			
			view.lvTF.text = GameLanguage.getLangByKey("L_A_73")+(data.level || 1);
			ProTipUtil.addTip(view.dataInfo, data)
				
			//技能
			//主动技能
			var tmp:Array = (_starVo.skill_id+"").split("|");
			if(_skillArr){
				_skillArr.length = 0;
			}else{
				_skillArr = [];
			}
			formatSkill(view.skillCom.item_0, tmp[0]);
			formatSkill(view.skillCom.item_1, tmp[1]);
			_skillArr.push(tmp[0], tmp[1]);
			//被动技能
			if(_starVo.skill2_id > 0){
				tmp = (_starVo.skill2_id+"").split(";");
				tmp[1] = 0;
			}else{
				tmp = (_db.skill2_id+"").split(";");
				tmp = (tmp[0]+"").split("|")
			}
			formatSkill(view.skillCom.item_2, tmp[0],tmp[1]);
			if(tmp.length && tmp[0]+"" != "undefined"){
				_skillArr.push(tmp[0]);
			}
			setSkillPosition();
			//获取背包数据
			var list:Array = BagManager.instance.getItemListByIid((_starVo.star_cost+"").split("=")[0]);
			if(list){
				onBagInit(list)
			}else{
				Signal.intance.on(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			}
		}
		
		/**设定位置*/
		private function setSkillPosition():void{
			if(view.skillCom.item_1.visible){
				view.skillCom.item_0.x = 7;
				view.skillCom.item_2.x = 245;
			}else{
				view.skillCom.item_0.x = 50;
				view.skillCom.item_2.x = 210;
			}
		}
		
		private function onBagInit(arr:Array = null):void{
			if(!arr){
				arr = BagManager.instance.getItemListByIid((_starVo.star_cost+"").split("=")[0])
			}
			var num:Number = 0;
			for(var i:int=0; i<arr.length; i++){
				num += parseInt(ItemData(arr[i]).inum+"")
			}
			
			var actNum:Number = (_starVo.star_cost+"").split("=")[1];
			if(_data == _db){//是需要激活
				var tmp:Array = (_db.condition+"").split("|");
				for(var j:String in tmp){
					if((tmp[j]+"").indexOf("B") == -1){
						tmp = (tmp[j]+"").split("=");
						actNum = tmp[1]
						break;
					}
				}
			}
			if(actNum){
				if(num < actNum){
					view.upgradeBtn.disabled = true;
				}else{
					view.upgradeBtn.disabled = false;
				}
				this.view.numTF.text = num+"/"+actNum
				view.addBtn.visible = true;
			}else{
				this.view.numTF.text = "MAX";
				view.upgradeBtn.disabled = true;
				view.addBtn.visible = false;
			}
			
		}
		
		override public function close():void{
			this._db = null;
			_skillArr = null;
			this._data = null;
			Laya.loader.clearRes(view.pic.skin)
			view.pic.skin = "";
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			Loader.clearRes("appRes/atlas/effects/heroEffect.json");
			Loader.clearRes("appRes/atlas/effects/soliderEffect.json");
			super.close();
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.closeBtn:
					this.close();
					break;
				case view.upgradeBtn:
					if(_data != _db){
						WebSocketNetService.instance.sendData(ServiceConst.C_Star,[_db.unit_id]);
					}else {
						
						WebSocketNetService.instance.sendData(ServiceConst.C_COMPOSE, [_data.unit_id]);
						
					}
					break;
				case view.prevBtn:
					_idx--;
					if(_idx < 0){
						_idx = _ids.length-1;
					}
					showInfo(_ids[_idx]);
					break;
				case view.nextBtn:
					_idx++;
					if(_idx > _ids.length-1){
						_idx = 0;
					}
					showInfo(_ids[_idx]);
					break;
				case view.addBtn:
					XFacade.instance.showModule(UnitSrcView, [_curId, function() {
						XFacade.instance.closeModule(CampView);
						XFacade.instance.closeModule(UnitInfoView);
						XFacade.instance.closeModule(NewUnitInfoView);
					}]);
					break;
				default:
					if(XUtils.checkHit(view.skillCom.item_0)){
						_skillArr[0] && XTipManager.showTip([_skillArr[0]],SkillTip, false);
					}else if(XUtils.checkHit(view.skillCom.item_1)){
						_skillArr[1] && XTipManager.showTip([_skillArr[1]],SkillTip, false);
					}else if(XUtils.checkHit(view.skillCom.item_2)){
						_skillArr[2] && XTipManager.showTip([_skillArr[2],true,_db.unit_id],SkillTip, false);
					}else if(XUtils.checkHit(view.attackIcon)){
						ProTipUtil.showAttTip(_curId);
					}else if(XUtils.checkHit(view.defendIcon)){
						ProTipUtil.showDenTip(_curId);
					}else if(XUtils.checkHit(view.kpiIcon)){
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_908"));
					}else if(XUtils.checkHit(view.poIcon)){
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_909"));
					}else if(XUtils.checkHit(view.maxIcon)){
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_919"));
					}
					break;
			}
		}
		
		private function onUpdate():void{
			showInfo(_curId)
		}
		
		private function onResult():void{
			this._ani.clear();
			if(_db.unitType == 1){
				this._ani.loadAtlas("appRes/atlas/effects/heroEffect.json");
			}else{
				this._ani.loadAtlas("appRes/atlas/effects/soliderEffect.json");
			}		
			this._ani.play(1, false);
		}
		
		override public function createUI():void{
			this._view = new UnitInfoViewUI();
			this.addChild(this._view);
			
			for(var i:String in view.dataInfo){
				if(view.dataInfo[i] is HTMLDivElement){
					view.dataInfo[i].style.fontFamily = XFacade.FT_Futura;
					view.dataInfo[i].style.fontSize = 16;
					view.dataInfo[i].style.color = "#ffffff";
					view.dataInfo[i].style.align = "right";
				}
			}
			
			this._starLv = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10, 5);
			_starLv.scaleX = _starLv.scaleY = 0.8;
			this.view.upBox.addChild(this._starLv);
			this._starLv.x = 216 - this.view.upBox.x;
			this._starLv.y = 436 - this.view.upBox.y;
							
			view.skillCom.item_0.mouseEnabled = true;
			view.skillCom.item_1.mouseEnabled = true;
			view.skillCom.item_2.mouseEnabled = true;
			this.closeOnBlank = true;
			
			this._ani = new Animation();
			this._ani.pos(0,0);
			this._ani.scale(1.5,1.5);
			this._view.addChildAt(_ani, this.view.getChildIndex(this.view.pic)+1);
			
			
			//UIRegisteredMgr.AddUI(this.view.upgradeBtn,"ComposeBtn");
			view.upgradeBtn['clickSound'] = ResourceManager.getSoundUrl("ui_unit_upgrade",'uiSound')
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			//UIRegisteredMgr.DelUi("ComposeBtn");
			
			super.destroy(destroyChild);
			
		}
		
		override public function addEvent():void{
			super.addEvent();
			this.view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(CampData.UPDATE, this, this.onUpdate);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			this.view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			Signal.intance.off(CampData.UPDATE, this, this.onUpdate);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			ProTipUtil.removeTip(view.dataInfo)
		}
		
		private function get view():UnitInfoViewUI{
			return this._view as UnitInfoViewUI;
		}
	}
}