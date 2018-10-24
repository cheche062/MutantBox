package game.module.camp.avatar
{
	import MornUI.camp.avatar.AvatarProItemUI;
	import MornUI.camp.avatar.HeroAvatarUpUI;
	import MornUI.componets.SkillItemUI;
	
	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.XItemTip;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBSkill2;
	import game.global.data.bag.BagManager;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.SkillVo;
	import game.module.camp.CampData;
	import game.module.camp.CampView;
	import game.module.camp.NewUnitInfoView;
	import game.module.camp.UnitInfoView;
	import game.module.camp.UnitSrcView;
	import game.module.tips.SkillTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.net.URL;
	
	/**
	 * AvatarLvUpView
	 * author:huhaiming
	 * AvatarLvUpView.as 2018-3-30 下午6:16:30
	 * version 1.0
	 *
	 */
	public class AvatarLvUpView extends BaseDialog
	{
		private var _item:AvatarItem;
		private var _data:SkinVo;
		private var _curItemId:*;
		private static const POS:Array = [385,335];
		private static const MAX_LV:int = 50;
		private static const STR_ITEM:int = 47000;
		public function AvatarLvUpView()
		{
			super();
			view.skillSp.visible = false;
			view.pro.x = POS[0];
			view.lbMax.visible = false;
			view.breakthrough.visible = false;
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			_data = args[0];
			_item.dataSource = _data;
			format();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
			Signal.intance.event(Event.CLOSE);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function format():void{
			var arr:Array;
			if(_data.value){
				arr = _data.value.split("|");
			}else{
				arr = [];
			}
			for(var i:int=0; i<2; i++){
				formatPro(arr[i], view["basePro_"+i])
			}
			var costArr:Array;
			ItemUtil.loadIcon(view.myIcon_0,_data.cost);
			ItemUtil.loadIcon(view.myIcon_1,STR_ITEM+"=0");
			
			
			if(_data.cost){
				costArr = _data.cost.split("=")
				var itemNum:int = BagManager.instance.getItemNumByID(costArr[0]);
				view.tfMyNum_0.text = itemNum+""
			}
			itemNum = BagManager.instance.getItemNumByID(STR_ITEM);
			view.tfMyNum_1.text = itemNum+"";
			
			
			var skinLv:int=0;
			var heroVo:Object = CampData.getUintById(_data.unit);
			if(heroVo){
				var skins:Object = heroVo.skins;
				var skinInfo:Object = skins[_data.ID];
				if(skinInfo){
					skinLv = skinInfo[0];
				}
			}
			
			view.curLv.text = GameLanguage.getLangByKey("L_A_73")+skinLv;
			var pro:SkinProVo = DBSkin.getSkinPro(skinLv, _data.node);
			if(pro){
				var proList:Array = pro.value2.split("|");
				for(var i:int=0; i<4; i++){
					formatPro(proList[i], view["cur_"+i], true);
				}
			}
			
			var cost:String = pro.cost;
			if(cost){
				costArr = cost.split("=")
				_curItemId = costArr[0];
				ItemUtil.loadIcon(view.itemIcon_0,cost);
				ItemUtil.loadIcon(view.itemIcon_1,cost);
				ItemUtil.loadIcon(view.breakIcon,cost);
			}
			
			view.tfNum_0.text = "X"+costArr[1];
			var totalNum:int = DBSkin.getResToNine(_data.ID);
			view.tfNum_1.text = "X"+totalNum
			view.tfBreak.text = "X"+costArr[1];
			
			if(skinLv >= MAX_LV){
				view.lbMax.visible = true;
				view.spNext.visible = false;
				view.skillSp.visible  =false;
				view.lvUp.visible = view.breakthrough.visible = false;
				view.tfTip.visible = false;
			}else{
				view.lbMax.visible = false;
				view.tfTip.visible = true;
				
				view.nextLv.text = GameLanguage.getLangByKey("L_A_73")+(skinLv+1);
				var nextPro:SkinProVo = DBSkin.getSkinPro(skinLv+1, _data.node);
				if(nextPro){
					proList = nextPro.value2.split("|");
					for(var i:int=0; i<4; i++){
						formatPro(proList[i], view["next_"+i], true, "#9bffbc");
					}
				}
				
				if(skinLv > 0 && skinLv % 10 == 0){
					view.spNext.visible = true;
					view.lvUp.visible =  false;
					view.breakthrough.visible = true;
					if(nextPro.skill){
						view.skillSp.visible = true;
						view.pro.x = POS[1];
						formatSkill(view.skillItem, nextPro.skill);
					}
					trace(pro, skinInfo)
					view.tfRate.text = Math.round((parseFloat(pro.rate) + skinInfo[1]*pro.chance)*100)+"%";
					view.tfTip.text = "L_A_84566";
				}else{//升级
					view.tfTip.text = "L_A_84565";
					view.pro.x = POS[0]
					view.spNext.visible = true;
					view.skillSp.visible = false;
					view.lvUp.visible =  true;
					view.breakthrough.visible = false;
					if(itemNum < costArr[1]){
						view.btnEnhance.disabled = view.btnEnhance10.disabled = true;
					}else{
						view.btnEnhance.disabled = view.btnEnhance10.disabled = false;
					}
				}
			}
		}
		
		private function onStr(...args):void{
			trace("onStr:::",args)
			var heroVo:Object = CampData.getUintById(_data.unit);
			if(heroVo){
				var arr:Array = heroVo.skins[args["2"]];
				arr[0] = args[4];
				if(args[3] == 1){
					arr[1] = 0;
//					XTip.showTip(GameLanguage.getLangByKey("L_A_84570"));
				}else{
					arr[1] = parseInt(arr[1])+1;
					XTip.showTip(GameLanguage.getLangByKey("L_A_84571"));
				}
				format();
			}
		}
		
		private function onStrOnce(...args):void{
			trace("onStrOnce:::",args)
			var heroVo:Object = CampData.getUintById(_data.unit);
			if(heroVo){
				var arr:Array = heroVo.skins[args["2"]];
				arr[0] = args[3];
				arr[1] = 0;
				format();
			}
		}
		
		private function formatSkill(item:SkillItemUI, skillId:*):void{
			if(skillId && skillId != "undefined"){
				skillId = (skillId+"").split("=")[1];
				item.visible = true;
				var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId];
				item.skillBg.skin = "common/skill_bg.png";
				item.lvBG.skin = "common/skill_bg_1.png";
				item.lvTF.text = vo.skill_level+"";
				
				if(vo){
					item.nameTF.text = vo.skill_name+"";
					item.icon.skin = URL.formatURL("appRes/icon/skillIcon/"+vo.skill_icon+".png");
				}else{
					item.nameTF.text = ""
				}
				item.name = skillId;
			}else{
				item.visible = false;
			}
		}
		
		private function onItemChange():void{
			if(_data.cost){
				var costArr:Array = _data.cost.split("=")
				var itemNum:int = BagManager.instance.getItemNumByID(costArr[0]);
				view.tfMyNum_0.text = itemNum+""
			}
			itemNum = BagManager.instance.getItemNumByID(STR_ITEM);
			view.tfMyNum_1.text = itemNum+"";
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
					break;
				case view.btnEnhance:
				case view.btnBreak:
					//升级
					WebSocketNetService.instance.sendData(ServiceConst.SKIN_STRENGTH,[_data.unit, _data.ID]);
					Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.SKIN_STRENGTH),this,onStr);
					break;
				case view.btnEnhance10:
					WebSocketNetService.instance.sendData(ServiceConst.SKIN_STRENGTH_ONCE,[_data.unit, _data.ID]);
					Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.SKIN_STRENGTH_ONCE),this,onStrOnce);
					break;
				case view.btnHelp:
					var alertStr:String = GameLanguage.getLangByKey("L_A_84557");
					alertStr = alertStr.replace(/##/g, "\n");
					XTipManager.showTip(alertStr)
					break;
				case view.btnAdd_0:
					XFacade.instance.showModule(SkinSrcView, _data, function() {
						XFacade.instance.closeModule(CampView);
						XFacade.instance.closeModule(UnitInfoView);
						XFacade.instance.closeModule(NewUnitInfoView);
						XFacade.instance.closeModule(AvatarLvUpView);
					});
					break;
				case view.btnAdd_1:
					XFacade.instance.showModule(SkinSrcView, DBSkin.getMInfo(STR_ITEM), function() {
						XFacade.instance.closeModule(CampView);
						XFacade.instance.closeModule(UnitInfoView);
						XFacade.instance.closeModule(NewUnitInfoView);
						XFacade.instance.closeModule(AvatarLvUpView);
					});
					break;
				case view.myIcon_0:
					ItemTips.showTip(_data.cost.split("=")[0]);
					break;
				case view.myIcon_1:
					ItemTips.showTip(STR_ITEM);
					break;
				case view.itemIcon_0:
				case view.itemIcon_1:
					ItemTips.showTip(_curItemId);
					break;
				default:
					if(view.skillItem.visible && view.skillSp.visible && XUtils.checkHit(view.skillItem)){
						XTipManager.showTip([view.skillItem.name],SkillTip, false);
					}
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, onClick);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, onItemChange);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, onItemChange);
		}
		
		override public function createUI():void{
			this._view = new HeroAvatarUpUI();
			this.addChild(_view);
			this.closeOnBlank = true;
			
			_item = new AvatarItem(false);
			view.spItem.addChild(_item);
		}
		
		private function get view():HeroAvatarUpUI{
			return this._view;
		}
		
		/***/
		public static function formatPro(proStr:String, ui:AvatarProItemUI, hideEmptyPro:Boolean = false, color:String='#ffffff'):void{
			ui.tfPro.color = color;
			if(proStr && proStr.indexOf("=") != -1){
				ui.visible = true;
				var arr:Array = proStr.split("=");
				ui.proIcon.skin = "common/icons/"+XUtils.getIconName(arr[0])+".png";
				ui.tfPro.text = arr[1];
			}else{
				ui.proIcon.skin = "";
				ui.tfPro.text = "";
				if(hideEmptyPro){
					ui.visible = false;
				}
			}
			
		}
	}
}