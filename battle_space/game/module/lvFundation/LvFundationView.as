package game.module.lvFundation 
{
	import MornUI.LvFundation.LvFundationViewUI;
	
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.reVo;
	import game.global.vo.facebookPay.FaceBookPayVo;
	import game.module.activity.WelfareMainView;
	import game.module.chargeView.MobileChargeView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LvFundationView extends BaseView 
	{
		private var m_data:reVo;
		private var _fundationArr:Array = [];
		private var m_FBdata:FaceBookPayVo;
		private var m_targeData:Object
		
		
		public function LvFundationView() 
		{
			super();
			ResourceManager.instance.load(ModuleName.LvFundationView,Handler.create(this, resLoader));
		}
		
		public function resLoader():void
		{
			
			//GameSetting.Platform = GameSetting.P_GW;
			
			this._view = new LvFundationViewUI();
			this.addChild(_view);
			
			GameConfigManager.intance.initFundationInfo();
			
			for (var data in GameConfigManager.fundationInfo)
			{
				_fundationArr.push(GameConfigManager.fundationInfo[data]);
			}
			
			view.rewardLIst.itemRender = LvFunItem;
			view.rewardLIst.array = [];// _fundationArr;
			
			/*m_data = GameConfigManager.re_list[33];
			trace("re_list:", GameConfigManager.re_list);
			trace("m_data:", m_data);*/
			
			addEvent();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var id:int = parseInt(e.target.name.split("_")[1]);
			
			switch(e.target)
			{
				
				case view.chargeBtn:
					//XFacade.instance.openModule(ModuleName.ActChargeView,["lvFundation"]);
					if (GameSetting.isApp)
					{
						getMobileGoodData();
						trace("m_data:", m_data);
						if (!m_data)
						{
							XTip.showTip("Item Missing");
							return;
						}
						
						GlobalRoleDataManger.instance.ItemPayHandler(m_data);
						XFacade.instance.closeModule(WelfareMainView);
					}
					else
					{
						
						if(GameSetting.Platform==GameSetting.P_GW)
						{
							XFacade.instance.openModule(ModuleName.ActChargeView, ["lvFundation"]);
							XFacade.instance.closeModule(WelfareMainView);
						}
						else
						{
							getPayItemDataByWeb();
						}
					}
					break;
				default:
					break;
			}
		}
		
		private function getMobileGoodData():void
		{
			var gName:String = Browser.onAndriod?"android_fund":"ios_fund";
			var i:int = 0;
			var len:int = GameConfigManager.re_list.length;
			m_data = null;
			for (i = 0; i < len; i++ )
			{
				if (GameConfigManager.re_list[i].item_id.indexOf(gName) > -1)
				{
					
					m_data = GameConfigManager.re_list[i];
					return;
				}
			}
			
		}
		
		private function getPayItemDataByWeb():void
		{
			
			__JS__("getProductlist('https://pay.movemama.com/v1/game/getdata?appid=9',back)");
			
			/*var data = ResourceManager.instance.getResByURL("config/getPayItemDataByWeb.json");
			back(data);*/
			
			function back(data){
				trace("back::",JSON.stringify(data))
				
				m_FBdata = new FaceBookPayVo();
				if(data.status==1)
				{
					m_FBdata.selectId=data.data["default"].id;
					m_FBdata.region_name=data.data["default"].idregion_name;
					m_FBdata.country_code=data.data["default"].country_code;
					m_FBdata.setCountries(data.data.countries)
					m_FBdata.setCurrencyList(data.data.currency);
					m_FBdata.setPayWay(data.data.payway);
					m_FBdata.setPack(data.data.packs);
					m_FBdata.setPayInfo(data.data.country_currency_payway);
				}
				
				// FB没有选择国家 默认选择为美国 235 32
				var data:Array = m_FBdata.getPackListByPayId(235, 32);
				trace("fb商品列表：", JSON.stringify(data));
				var len:int = data.length;
				
				// 选择基金
				for (var i:int; i < len; i++)
				{
					if (data[i].name.indexOf("_fund") > -1)
					{
						m_targeData = data.splice(i, 1)[0];
						break;
					}
				}
				
				trace("基金商品", m_targeData);
				
				WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL,["US",32,m_targeData.id,1,235,1,"facebok"]);
				
			}
		}
		
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("lvfundation:", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.LVFUNDATION_INIT:
					//trace("jijinInit:", args);
					_fundationArr = [];
					for (var data in GameConfigManager.fundationInfo)
					{
						if (args[1].get_log[data])
						{
							GameConfigManager.fundationInfo[data].statue = 1;
						}
						else
						{
							GameConfigManager.fundationInfo[data].statue = 0;
						}
						_fundationArr.push(GameConfigManager.fundationInfo[data]);
					}
					view.rewardLIst.array = _fundationArr;
					
					view.chargeBtn.disabled = false;
					if (parseInt(args[1].fund_pay) > 0)
					{
						view.chargeBtn.disabled = true;
					}
					
					break;
				case ServiceConst.LVFUNDATION_GETREWARD:
					//trace("LVFUNDATION_GETREWARD:", args);
					var ar:Array = [];
					var list:Array = args[1]
					len = list.length;
					for (i = 0; i < len; i++)
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i][0];
						itemD.inum = list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					
					WebSocketNetService.instance.sendData(ServiceConst.LVFUNDATION_INIT);
					break;
				case ServiceConst.GET_WEBPAY_URL:
					var url:String=args[1]["url"];
					trace("打开基金支付页面：", url, m_targeData);
					
					var voName:String = m_targeData.name;
					
					__JS__("openurl(url,voName, GameSetting.Platform, payCallBackHandler)");
					
					function payCallBackHandler(obj:Object):void
					{
						if(obj.status=="completed")
						{
							GlobalRoleDataManger.instance.WebItemPayHandler();
						}
					}
					
					XFacade.instance.closeModule(WelfareMainView);
					break;
				default:
					break;
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.LVFUNDATION_INIT);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, serviceResultHandler, [ServiceConst.GET_WEBPAY_URL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LVFUNDATION_INIT), this, serviceResultHandler, [ServiceConst.LVFUNDATION_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LVFUNDATION_GETREWARD), this, serviceResultHandler, [ServiceConst.LVFUNDATION_GETREWARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LVFUNDATION_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LVFUNDATION_GETREWARD),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
		
		
		
		private function get view():LvFundationViewUI{
			return _view;
		}
	}

}