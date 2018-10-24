package game.module.chargeView
{
	import laya.events.Event;
	import MornUI.fackBookChange.FaceBookChargeViewUI;
	
	import game.common.AlertManager;
	import game.common.GameLanguageMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.global.vo.facebookPay.CountriesVo;
	import game.global.vo.facebookPay.FaceBookPayVo;
	import game.global.vo.facebookPay.PackVo;
	import game.global.vo.facebookPay.PayWayVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Handler;
	
	
	public class FaceBookChargeView extends BaseView
	{
		private var m_payList:Array;
		private var m_itemList:Array;
		private var m_currencyList:Array;
		private var m_data:FaceBookPayVo;
		private var m_countriesVo:CountriesVo;
		private var m_selectPayVo:PayWayVo;
		private var m_packVo:PackVo;
		
		/**周卡是否可买*/
		private var isAbleBuyWeekCard = null;
		/**基金卡是否可买*/
		private var isAbleBuyFunCard = null;
		public function FaceBookChargeView()
		{
			super();
		}
		
		override public function createUI():void {
			
			this._view = new FaceBookChargeViewUI();
			this.addChild(_view);
			
			addEvent();
			
		}
		
		override public function show(...args):void
		{
			/**不开放充值*/
			if(!DBBuilding.isChargeOn){
				super.close();
				return;
			}
			super.show(args);
			
			
			
		}
		
		private function initUI()
		{
			this.view.chargeList.itemRender = FaceBookReItem;
			//this.view.chargeList.spaceX = 50;
			this.view.chargeList.vScrollBarSkin = "";
			
			this.view.PayList.itemRender=PayChannelItem;
			this.view.PayList.hScrollBarSkin="";
			this.view.PayList.selectEnable=true;
			this.view.chargeList.selectEnable=true;
			view.CountryCombo.labels=m_data.getCountriesList();
			view.CountryCombo.selectedLabel=m_data.region_name;
			view.CountryCombo.selectHandler=new Handler(this,onSelectCourtryHandler);
			this.view.PayList.selectHandler=new Handler(this,onSelectPayTypeHandler);
			
			// 由于子项有帮助小按钮，但该小按钮不能触发list的selectHandler
//			this.view.chargeList.selectHandler=new Handler(this,onSelectChargeHandler);
			if(GameSetting.Platform==GameSetting.P_FB)
			{
				view.CountryCombo.visible=false;
				view.PayList.visible=false;
				//view.GwTipsText.visible=false;
				view.FaceBookTipsText.visible=true;
				view.FaceBookTipsText.text=GameLanguageMgr.instance.getLanguage("L_A_52031");
				//view.BgImage.skin="fackBookChange/bg3_11.png";
				//view.BgImage.size(762,449);
				
			}
			else
			{
				view.CountryCombo.visible=true;
				view.PayList.visible=true;
				//view.GwTipsText.visible=true;
				view.FaceBookTipsText.visible=false;
				//view.BgImage.skin="fackBookChange/bg3.png";
				
			}
			
			// 初始化
			view.CountryCombo.selectedIndex = m_data.getCountyIndex(m_data.region_name);
			view.PayList.selectedIndex = 0;
			
			
		}
		
		/**确认购买*/
		private function onSelectChargeHandler(p_index:int, isWeekCard:Boolean = false):void
		{
			// TODO Auto Generated method stub
			if(p_index>=0)
			{
				for (var i:int = 0; i < view.chargeList.array.length; i++) 
				{
					var l_cell:FaceBookReItem=view.chargeList.getCell(i);
					if(l_cell!=null)
					{
						l_cell.mouseEnabled=false;
					}
				}
				timer.once(2000,this,unlockBtnHandler);

				m_packVo=view.chargeList.getItem(p_index);
				if(GameSetting.Platform==GameSetting.P_FB)
				{
					WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL,[m_countriesVo.country_code,m_selectPayVo.id,m_packVo.id,m_packVo.pack_currency_id,m_countriesVo.id,1,"facebok"]);
				}
				else
				{
					WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL,[m_countriesVo.country_code,m_selectPayVo.id,m_packVo.id,m_packVo.pack_currency_id,m_countriesVo.id,1,"bs"]);
				}
				
				this.view.chargeList.selectedIndex = -1;
				
				//trace("确认购买", p_index, m_packVo);
			}
		}
		
		private function unlockBtnHandler():void
		{
			// TODO Auto Generated method stub
			for (var i:int = 0; i < view.chargeList.array.length; i++) 
			{
				var l_cell:FaceBookReItem=view.chargeList.getCell(i);
				if(l_cell!=null)
				{
					l_cell.mouseEnabled=true;
				}
			}
		}		
		
		private function onSelectCourtryHandler(p_index:int):void
		{
			// TODO Auto Generated method stub
			
			if(p_index>=0)
			{
				m_countriesVo=m_data.getCurrencyData(view.CountryCombo.selectedLabel);
				var l_arr:Array=m_data.getPayWayListByCountry(m_countriesVo.id);
				if(l_arr.length<=0)
				{
					view.CountryCombo.selectedIndex=m_data.getCountyIndex("United States");	
				}
				else
				{
					this.view.PayList.array=l_arr;
				}
			}
		}
		
		private function onSelectPayTypeHandler(p_index:int):void
		{
			
			// TODO Auto Generated method stub
			for (var i:int = 0; i < this.view.PayList.array.length; i++) 
			{
				var l_cell:PayChannelItem=this.view.PayList.getCell(i);
				if(l_cell!=null)
				{	
					l_cell.setSelected(false);
				}
			}
			var l_selectCell:PayChannelItem=this.view.PayList.getCell(p_index);
			var l_data:PayWayVo=this.view.PayList.getItem(p_index);
			l_selectCell.setSelected(true);
			m_selectPayVo = l_data;
			this.view.chargeList.itemRender = FaceBookReItem;
			
			// 235 32
			var data:Array = m_data.getPackListByPayId(m_countriesVo.id, l_data.id);
			var len:int = data.length;
			
			// 把周卡/基金的数据剔除
			for (var i:int; i < len; i++)
			{
				if (data[i].name.indexOf("_7") > -1 || 
					data[i].name.indexOf("_fund") > -1 || 
					data[i].name.indexOf("dailygift") > -1 || 
					data[i].name.indexOf("49.99") > -1)
				{
					data.splice(i, 1);
					i--;
					len--;
				}
			}
			
			var _this = this;
			
			/*// 把周卡的数据挑出来放到数组的最前面 || 基金卡
			var filterArr:Array = [];
			for(var i:int; i < data.length; i++){
				if(data[i].name.indexOf("_7") > -1 || data[i].name.indexOf("_fund") > -1){
					filterArr.push(data.splice(i, 1)[0]);
					i--;
				}
			}
			for(var i:int; i < filterArr.length; i++){
				data.unshift(filterArr[i]);
			}*/
			
			data.forEach(function(item, index){
				// 给每个子项添加回调（由于子项有个单独的帮助小按钮所以需要分离）
				item.onSelectChargeHandler = onSelectChargeHandler.bind(_this, index);
				
				item["isAbleBuyWeekCard"] = isAbleBuyWeekCard;
				item["isAbleBuyFunCard"] = isAbleBuyFunCard;
			})
			
			this.view.chargeList.array = data;
			
			unlockBtnHandler();
			
			/*trace("re_list.json数据", GameConfigManager.re_list)
			trace("chargeList数据", data);*/
		}
		
		
		private function getPayItemDataByWeb():void
		{
//			临时注释
			__JS__("getProductlist('https://pay.movemama.com/v1/game/getdata?appid=9',back)");
			
//			var data = ResourceManager.instance.getResByURL("config/getPayItemDataByWeb.json");
//			back(data);
			
			function back(data){
				trace("back::"+JSON.stringify(data))
				trace("back::", data)
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
				initUI();
			}
		}
		
		
		private function processHandler(data:Object):void
		{
			trace("process"+data);
		}
		
		private function errorHandler(e:Object):void
		{
			trace("errorHandler"+e);
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		/**监听玩家数据*/
		private function refreshVipInfo():void
		{
			view.VipText.text = "VIP" + User.getInstance().VIP_LV;
			if(User.getInstance().VIP_LV < VIPVo.MAX_LV){
				view.NextVipText.text = "VIP" + (User.getInstance().VIP_LV + 1);
				
				view.VipBar.value = User.getInstance().chargeNum / GameConfigManager.vip_info[(User.getInstance().VIP_LV + 1)].amount;
				view.chargeInfoTxt.text = User.getInstance().chargeNum + "/" + GameConfigManager.vip_info[(User.getInstance().VIP_LV + 1)].amount;
				
				view.NextChargeText.text = (GameConfigManager.vip_info[(User.getInstance().VIP_LV + 1)].amount - User.getInstance().chargeNum) + GameLanguage.getLangByKey("L_A_76014");
				
				view.NextVipText.x = view.NextChargeText.x + view.NextChargeText.textWidth;
			}
			
			// 没有周卡时可买
			/*isAbleBuyWeekCard = !User.getInstance().hasWeekCard;
			isAbleBuyFunCard = !User.getInstance().hasBuyFun;*/
			
//			在判断周卡  && 基金   是否可买之后再去获取平台充值
			getPayItemDataByWeb();
			
			/*trace("判断周卡是否可买", isAbleBuyWeekCard);
			trace("判断基金卡是否可买", isAbleBuyFunCard);*/
		}
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				
				case ServiceConst.GET_WEBPAY_URL:
				{
					var url:String=args[1]["url"];
					trace("打开支付页面：", url, m_packVo.name);
					
					var voName:String = m_packVo.name;
					for (var i:int = 0; i < view.chargeList.array.length; i++)
					{
						var l_cell:FaceBookReItem=view.chargeList.getCell(i);
						if(l_cell!=null)
						{
							l_cell.mouseEnabled=true;
						}
					}
					__JS__("openurl(url,voName, GameSetting.Platform, payCallBackHandler)");
					
					//判断是否是周卡则关闭充值弹层
					if(m_packVo.name.indexOf("_7") > -1){
						XFacade.instance.closeModule(ChargeView);
						
						var text:String = GameLanguage.getLangByKey("L_A_52037").replace(/##/g, "\n");
						AlertManager.instance().AlertByType('BaseAlertView', text, 1);
					}
					
					//判断是否是基金卡则关闭充值弹层
					if(m_packVo.name.indexOf("_fund") > -1){
						XFacade.instance.closeModule(ChargeView);
						
						var text:String = GameLanguage.getLangByKey("L_A_52037").replace(/##/g, "\n");
						AlertManager.instance().AlertByType('BaseAlertView', text, 1);
					}
					
					
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
		}*/
		
		override public function addEvent():void
		{
			super.addEvent();
			
			view.vipBox.visible = false;
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			
		}
		
		private function addToStageEvent():void 
		{
			getPayItemDataByWeb();
			
			Signal.intance.on(User.PRO_CHANGED, this, this.refreshVipInfo);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult, [ServiceConst.GET_WEBPAY_URL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			/*sendData(ServiceConst.OPEN_WEEK_CARD);
			sendData(ServiceConst.LVFUNDATION_INIT);*/
		}
		
		private function removeFromStageEvent():void
		{
			// 重置
			view.CountryCombo.selectedIndex = -1;
			view.PayList.array = [];
			view.chargeList.array = [];
			
			
			Signal.intance.off(User.PRO_CHANGED, this, this.refreshVipInfo);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
		}
		
		override public function removeEvent():void{
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			
			super.removeEvent();
		}
		
		override public function close():void{
			super.close();
			
			
		}
		
		private function get view():FaceBookChargeViewUI{
			return _view;
		}
		
	}
}