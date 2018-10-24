package game.module.chargeView 
{
	import game.common.ResourceManager;
	import game.global.GlobalRoleDataManger;
	import game.global.vo.facebookPay.FaceBookPayVo;
	import laya.events.Event;
	import MornUI.chargeView.MobilChargeViewUI;
	
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.reVo;
	import game.module.mainui.ReItemView;
	
	/**
	 * 充值弹窗
	 * @author ...
	 */
	public class MobileChargeView extends BaseView 
	{
		/**周卡是否可买*/ 
		private var isAbleBuyWeekCard = null;
		/**基金卡是否可买*/ 
		private var isAbleBuyFunCard = null;
		
		private var m_data:FaceBookPayVo;
		
		public function MobileChargeView() 
		{
			super();
			
		}
		
		override public function show(...args):void{
			super.show();
			
			
		}
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				
				case ServiceConst.GET_WEBPAY_URL:
				{
					var url:String=args[1]["url"];
					//trace("打开支付args：", args);
					//trace("打开支付页面：", url);
					
					var voName:String = args[1]["packid"];
					/*var voName:String = m_packVo.name;
					for (var i:int = 0; i < view.chargeList.array.length; i++)
					{
						var l_cell:FaceBookReItem=view.chargeList.getCell(i);
						if(l_cell!=null)
						{
							l_cell.mouseEnabled=true;
						}
					}*/
					
					
					
					trace("voName:", voName);
					trace("=========================");
					
					__JS__("openurl(url,voName, GameSetting.Platform, payCallBackHandler)");
					
					break;
				}
				default:
				{
					break;
				}
			}
			
			function payCallBackHandler(obj:Object):void
			{
				if(obj.status=="completed")
				{
					GlobalRoleDataManger.instance.WebItemPayHandler();
				}
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function refreshVipInfo():void
		{
			view.nowVip.text = "VIP" + User.getInstance().VIP_LV;
			view.nextVIP.text = "VIP" + (User.getInstance().VIP_LV + 1);
			
			view.vipBar.value = User.getInstance().chargeNum / GameConfigManager.vip_info[(User.getInstance().VIP_LV + 1)].amount;
			view.chargeInfoTxt.text = User.getInstance().chargeNum + "/" + GameConfigManager.vip_info[(User.getInstance().VIP_LV + 1)].amount;
			
			view.needTxt.text = (GameConfigManager.vip_info[(User.getInstance().VIP_LV + 1)].amount - User.getInstance().chargeNum) + GameLanguage.getLangByKey("L_A_76014");
			
			view.nextVIP.x = view.needTxt.x + view.needTxt.textWidth;
			
			view.nextInfo.x = (view.width - view.nextInfo.width) / 2;
			
			// 没有周卡时可买
			/*isAbleBuyWeekCard = !User.getInstance().hasWeekCard;
			isAbleBuyFunCard = !User.getInstance().hasBuyFun;*/
			
			//在判断周卡是否可买之后再去获取平台充值
			
			
			/*trace("判断周卡是否可买", isAbleBuyWeekCard);
			trace("判断基金卡是否可买", isAbleBuyFunCard);*/
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
			
		}
		
		override public function createUI():void{
			this._view = new MobilChargeViewUI();
			
			this.addChild(_view);
			addEvent();
		}
		
		/**渲染列表数据    是否可买*/
		private function renderListArray():void {
			
			this.view.chargeList.itemRender = ReItemView;
			this.view.chargeList.vScrollBarSkin = "";
			//this.view.chargeList.spaceX = -20;
			var cList:Array = [];
			
			if (GameSetting.isApp)
			{
				cList = GameConfigManager.re_list.concat();
				
				
				for (var i:int = 0; i < cList.length; i++) 
				{
					if (cList[i].type > 1)
					{
						cList.splice(i, 1);
						i--;
					}
				}
				
				/*trace("re_list:】",GameConfigManager.re_list)
				trace("【chargeList:】",cList)*/
				this.view.chargeList.array = cList;
			}
			else
			{
				getPayItemDataByWeb();
			}
			
		}
		
		private function getPayItemDataByWeb():void
		{
			
			__JS__("getProductlist('https://pay.movemama.com/v1/game/getdata?appid=9',back)");
			
			/*var data = ResourceManager.instance.getResByURL("config/getPayItemDataByWeb.json");
			back(data);*/

			
			function back(data){
				//trace("back::",JSON.stringify(data))
				
				m_data = new FaceBookPayVo();
				if(data.status==1)
				{
					m_data.selectId=data.data["default"].id;
					m_data.region_name=data.data["default"].idregion_name;
					m_data.country_code=data.data["default"].country_code;
					m_data.setCountries(data.data.countries)
					m_data.setCurrencyList(data.data.currency);
					m_data.setPayWay(data.data.payway);
					m_data.setPack(data.data.packs);
					m_data.setPayInfo(data.data.country_currency_payway);
				}
				
				// FB没有选择国家 默认选择为美国 235 32
				var data:Array = m_data.getPackListByPayId(235, 32);
				var len:int = data.length;
				
				// 把周卡/基金的数据剔除
				for (var i:int; i < len; i++)
				{
					if (data[i].name.indexOf("_7") > -1 || 
						data[i].name.indexOf("dailygift") > -1 || 
						data[i].name.indexOf("_fund") > -1 || 
						data[i].name.indexOf("49.99") > -1)
					{
						data.splice(i, 1);
						i--;
						len--;
					}
				}
				trace("finalList:", data);
				this.view.chargeList.array = data;
			}
		}
		
		/**判断周卡是否可买*/
/*		private function weekCardHandler(...args):void{
			//是否购买过
			var isBuyed = args[1].card_last_time["7"];
			// 是否可购买
			var result:Boolean = false;
			//购买过
			if(isBuyed){
				// 未过期
				if(parseInt(isBuyed) - parseInt(TimeUtil.now / 1000) > 0){
					result = false;
				}else{
					result = true;
				}
			}else{
				result = true;
			}
			
			isAbleBuyWeekCard = result;
			renderListArray();
			trace("判断周卡是否可买", args);
		}*/
		
		/**判断基金卡是否可买*/
/*		private function funCardHandler(...args):void{
			var result = false;
			if (parseInt(args[1].fund_pay) > 0)
			{
				result = true;
			}
			
			isAbleBuyFunCard = !result;
			renderListArray();
		}*/
		
		override public function addEvent():void{
			
			this.view.vipBar.visible=false;
			this.view.nextInfo.visible=false;
			this.view.chargeInfoTxt.visible=false;
			this.view.nowVip.visible=false;
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			/*sendData(ServiceConst.OPEN_WEEK_CARD);
			sendData(ServiceConst.LVFUNDATION_INIT);*/			
		}
		
		private function addToStageEvent():void 
		{
			renderListArray();
			
			Signal.intance.on(User.PRO_CHANGED, this, this.refreshVipInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult, [ServiceConst.GET_WEBPAY_URL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(User.PRO_CHANGED, this, this.refreshVipInfo);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function removeEvent():void {
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			
		}
		
		private function get view():MobilChargeViewUI{
			return _view;
		}
	}

}