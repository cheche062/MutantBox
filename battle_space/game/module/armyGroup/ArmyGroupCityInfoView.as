package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupCityInfoViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.armyGroup.newArmyGroup.StarVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.display.Sprite;

	/**
	 * 星球信息弹层
	 * @author ...
	 */
	public class ArmyGroupCityInfoView extends BaseDialog
	{
		private var _plantData:StarVo;
		
		private var _goldImage:Image;
		private var _guildIcon:Image;

		private var _protectTime:int = 0;
		private var _justLook:Boolean = false;
		/**是否可宣战*/
		private var _canDeclare:Boolean = true;
		/**公会职位*/
		private var _guild_position:String;
		/**玩家已使用的公会资金*/
		private var _user_guild_cash_used:int;
		/**剩余可放弃城池的次数*/
		private var _giveUpTime:int = 0;
		/**公会资金id*/
		private const GUILD_CASH_ID:int = 93201;
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		
		public function ArmyGroupCityInfoView()
		{
			super();

		}
		
		override public function createUI():void
		{
			this._view=new ArmyGroupCityInfoViewUI();
			this.addChild(_view);
			view.mouseEnabled = true;
			this._closeOnBlank = true;
			
			var cost_icon_skin:String = GameConfigManager.getItemImgPath(GUILD_CASH_ID);
			view.ItemImage.skin = view.dom_zj_icon.skin = view.dom_protect_icon.skin = cost_icon_skin;
			
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			_plantData = args[0][0];
			
			_justLook = args[0][1];
			_guild_position = args[0][2];
			
			view.dom_viewstack.selectedIndex = -1;
			view.btn_enter.visible = false;
			
			view.StarImage.skin = _plantData.getStarSkinByIcon();
			view.CityName.text = _plantData.name;
			
			// 是否属于某公会
			view.dom_belong_sprite.visible = !!_plantData.guideName;
			if (!!_plantData.guideName) {
				view.guideName.text=_plantData.guideName;
				GameConfigManager.setGuildLogoSkin(view.dom_guildLogo, _plantData.guideIcon, 0.5);
			}
			
			var arr_time:Array = _plantData.access_time.split(",");
			var bool_time = true;
			for(var j = 0;j<arr_time.length;j++){
				var nowData = TimeUtil.getLocalTime(-7);
				var nowH = nowData.getHours();
				var num= Number(arr_time[j]);
				var str = 'rewardTime_' + (j+1);
				var text:Text = view.getChildByName(str);
				text.text = arr_time[j] + ':00';
				var maxH = Number(arr_time[arr_time.length-1]);
				if(nowH<maxH){
					if(nowH<num && bool_time){
						text.color = '#febe62';
						bool_time = false;
					}
					else{
						text.color = '#c28b44';
					}
				}
				else{
					if(j==0){
						text.color = '#febe62';
					}
					else{
						text.color = '#c28b44';
					}
				}
			}
			
//			var straaa:String = '1=1';
			view.dom_rewardsBox.x=590;
//			ToolFunc.createRewardsDoms(straaa).forEach(function(item) {
//				view.dom_rewardsBox.addChild(item);
//				view.dom_rewardsBox.x-=42;
//			});
			view.dom_rewardsBox.destroyChildren();
			ToolFunc.createRewardsDoms(_plantData.award).forEach(function(item) {
				view.dom_rewardsBox.addChild(item);
				view.dom_rewardsBox.x-=42;
			});
			view.boxReward.visible = false;
//			var awardArray:Array = _plantData.award.split(";");
//			for(var j = 0;j<view.boxReward.numChildren;j++){
//				var strSp = 'sp_' + (j+1);
//				var sp:Sprite = view.boxReward.getChildByName(strSp);
//				if(j<awardArray.length){
//					var item = awardArray[j];
//					var _index = item.indexOf("=");
//					var iid = item.slice(0, _index);
//					var inum = item.slice(_index + 1);	
//					var lbNum = sp.getChildByName('num');
//					var img = sp.getChildByName('img');
//					img.width=img.height =40;
//					img.skin = GameConfigManager.getItemImgPath(iid);
//					lbNum.text = inum;
//					sp.visible = true;
//				}
//				else{
//					sp.visible = false;
//				}
//			}
			
			// 宣战花费
			view.declarPriceTxt.text = "x" + _plantData.cost;
			// 保护花费
			view.dom_protect_num.text = "x" + StarVo.getProtectCostByPosition(ArmyGroupMapView._guild_position);
			//召集花费
			view.dom_zj_num.text = "x" + StarVo.getZhaojiCost();
			
			view.btn_zhaoji.visible = false;
			
			view.btn_declare.visible = false;
			view.btn_enter.visible = false;
			view.btn_giveup.visible = false;
			view.btn_protect.visible = false;
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_CITY_INFO, [_plantData.id]);
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.CloseBtn:
					close();
					break;
				
				// 望远镜
				case view.DefindInfoBtn:
					XFacade.instance.openModule(ModuleName.ArmyGroupDefinderList, [_plantData, view.bossBRTxt.text]);
					break;
				case view.btn_enter:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_ENTER_CITY, [_plantData.id]);
					break;
				case view.btn_giveup:
					if (_giveUpTime <= 0)
					{
						AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, GameLanguage.getLangByKey("L_A_20957"));
						return;
					}
					
					var giveUpStr:String=GameLanguage.getLangByKey("L_A_20939");
					giveUpStr = giveUpStr.replace("{0}", _giveUpTime);
					
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, giveUpStr, 0, function(v:int){
						if (v == AlertType.RETURN_YES){
							WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GIVE_UP_PLANT, [_plantData.id]);
							close();
						}
					});
					break;
				
				case view.btn_declare:
					if (!User.getInstance().guildID) {
						return XTip.showTip("L_A_3019");
					}
					if (ArmyGroupMapView._guild_cash < Number(_plantData.cost)) {
						return XTip.showTip("L_A_921075");
					}
					
					var totalCanUseMoney = StarVo.getPlayerCanUseMoney(ArmyGroupMapView._guild_position);
					if (totalCanUseMoney - ArmyGroupMapView._user_guild_cash_used < Number(_plantData.cost)) {
						return XTip.showTip("L_A_21027");
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_DECLARE_WAR);
					
					break;
				
				// 购买保护
				case view.btn_protect:
					if (_plantData.attempts - _plantData.buy_protection_number == 0) {
						return XTip.showTip("L_A_21025");
					}
					
					var protect_cost:int = Number(StarVo.getProtectCostByPosition(ArmyGroupMapView._guild_position));
					// "公会资金不足"
					if (ArmyGroupMapView._guild_cash < protect_cost) {
						return XTip.showTip("L_A_921075");
					}
					// 玩家可使用的公会资金不足
					var totalCanUseMoney = StarVo.getPlayerCanUseMoney(ArmyGroupMapView._guild_position);
					if (totalCanUseMoney - ArmyGroupMapView._user_guild_cash_used < protect_cost) {
						return XTip.showTip("L_A_21027");
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_BUY_PROTECTED, [_plantData.id]);
					
					break;
				
				// 召集
				case view.btn_zhaoji:
					if (!User.getInstance().guildID) {
						return XTip.showTip("L_A_3019");
					}
					
					view.btn_zhaoji.disabled = true;
					timerOnce(1500, this, function() {
						view.btn_zhaoji.disabled = false;
					});
					
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_ZHAOJI_WAR, [_plantData.id]);
					
					break;
				
				default:
					break;
			}
		}

		private function serviceResultHandler(... args):void
		{
			trace("【国战信息】", args[0], args[1]);
			switch (args[0]) {
				case ServiceConst.ARMY_GROUP_ENTER_CITY:
					XFacade.instance.closeModule(ArmyGroupChatView);
					XFacade.instance.openModule("ArmyGroupFightView", args[1]);
					
					var armyGroupMap:ArmyGroupMapView = XFacade.instance.getView(ArmyGroupMapView);
					armyGroupMap && armyGroupMap.closeByOuter();
					close();
					break;
				
				case ServiceConst.ARMY_GROUP_DECLARE_WAR:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_ENTER_CITY, [_plantData.id]);
					break;
				
				case ServiceConst.ARMY_GROUP_BUY_PROTECTED:
					XTip.showTip("L_A_21026");
					close();
					break;2
				
				case ServiceConst.ARMY_GROUP_ZHAOJI_WAR:
					XTip.showTip("L_A_3041");
					close();
					break;
				
				case ServiceConst.ARMY_GROUP_GET_CITY_INFO:
					_plantData.getCityInfoUpdate(args[1]);
					
					view.bossBRTxt.text = "Defender Lv." + _plantData.level;
					var juntuan_npc_defender = ResourceManager.instance.getResByURL("config/juntuan/juntuan_npc_defender.json");
					var npcNumArr:Array = ToolFunc.objectValues(juntuan_npc_defender).filter(function(item) {
						return _plantData.npc_num.indexOf(item["id"]) > -1;
					}).map(function(item) {
						return Number(item["num"]);
					});
					var totalNpcNum = ToolFunc.reduceArrayFn(npcNumArr, function(a, b) {
						return a + b;
					}, 0);
					
					view.dom_progress.value = args[1].BossNum / totalNpcNum;
					view.dom_remain.text = "Remain: " + args[1].BossNum;
					
					_giveUpTime = args[1].residue_quit_city_number;
					
					view.dom_viewstack.selectedIndex = -1;
					
					switch (_plantData.getCityState()) {
						case 0:
							view.btn_zhaoji.visible = false;
							
							view.btn_declare.visible = !_plantData.isMyGuilde;
							view.btn_enter.visible = false;
							view.btn_giveup.visible = _plantData.isMyGuilde;
							view.btn_protect.visible = _plantData.isMyGuilde;
							
							break;
						
						// 已宣战
						case 1:
							fightingHandler(args[1]);
							
//							view.btn_zhaoji.visible = true;
							
							view.btn_declare.visible = false;
							view.btn_enter.visible = true;
							view.btn_giveup.visible = false;
							view.btn_protect.visible = false;
							
							break;
						
						// 保护中
						case 2:
							protectHandler(_plantData.getProtectCountDownTime());
							
							view.btn_zhaoji.visible = false;
							
							view.btn_declare.visible = false;
							view.btn_enter.visible = false;
							view.btn_giveup.visible = _plantData.isMyGuilde;
							view.btn_protect.visible = _plantData.isMyGuilde;
							
							break;
					}
					
					if (_justLook) {
						view.btn_declare.visible = false;
						view.btn_enter.visible = false;
					}
					
					buttonsAlignHandler();
					
					break;
			}
		}
		
		/**战斗中处理*/
		private function fightingHandler(data):void {
			view.dom_viewstack.selectedIndex = 0;
			
			var info = StarVo.getGuildNameAndIconByGuildId(data.declare_war_guild_id, {name: data.guild_name, icon: data.guild_icon});
			view.dom_guild_name.text = info[0];
			GameConfigManager.setGuildLogoSkin(view.dom_guild_icon, info[1], 0.4);
			view.declarGNameTxt.text = data.declare_war_uname ? data.declare_war_uname + " (" + data.declare_war_guild_postion + ")" : "";
			
			// 有公会
			if (User.getInstance().guildID) {
				// 我方城池  或者  我方宣战
				if (data.declare_war_guild_id == User.getInstance().guildID || _plantData.isMyGuilde) {
					view.btn_zhaoji.visible = true;
				}
			}
		}
		
		/**保护中处理*/
		private function protectHandler(time):void {
			view.dom_viewstack.selectedIndex = 1;
			doClearTimerHandler();
			clearTimerHandler = ToolFunc.limitHandler(Math.abs(time), function(time) {
				var detailTime = TimeUtil.toDetailTime(time);
				view.dom_protect_time.text = TimeUtil.timeToText(detailTime);
			}, function() {
				view.dom_viewstack.selectedIndex = -1;
				clearTimerHandler = null;
				trace('倒计时结束：：：');
			}, false);
		}
		
		private function buttonsAlignHandler():void {
			var _w:int = 0;
			view.dom_bottom_box._childs.filter(function(item:Button) {
				return item.visible;
			}).forEach(function(item:Button, index:int) {
				item.x = _w;
				_w += item.width + 10;
			});
			
			view.dom_bottom_box.x = (view.width - _w) / 2
			
		}
		
		private function doClearTimerHandler():void {
			clearTimerHandler && clearTimerHandler();
			clearTimerHandler = null;
		}

		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			if (errStr == "L_A_933008")
			{
				errStr = GameLanguage.getLangByKey(errStr)
				errStr = errStr.replace("{0}", _plantData.level - GameConfigManager.ArmyGroupBaseParam.declarCityLv);
				errStr = errStr.replace("{1}", GameConfigManager.ArmyGroupBaseParam.declarPlayerNum);
				XTip.showTip(errStr);
			}
			else
			{
				XTip.showTip(GameLanguage.getLangByKey(errStr));
			}
		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}

		private function onClose():void
		{
			super.close();
			_plantData = null;
			doClearTimerHandler();
		}

		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);

			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_ENTER_CITY), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DECLARE_WAR), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_CITY_INFO), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this,serviceResultHandler);

			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			super.addEvent();
		}


		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);

			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_ENTER_CITY), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_DECLARE_WAR), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_CITY_INFO), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_BUY_PROTECTED), this,serviceResultHandler);

			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			super.removeEvent();
		}

		private function get view():ArmyGroupCityInfoViewUI
		{
			return _view;
		}

	}

}
