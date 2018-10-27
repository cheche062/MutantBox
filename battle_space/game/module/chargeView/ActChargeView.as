package game.module.chargeView 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.GameLanguageMgr;
	import game.common.ResourceManager;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.vo.facebookPay.CountriesVo;
	import game.global.vo.facebookPay.FaceBookPayVo;
	import game.global.vo.facebookPay.PackVo;
	import game.global.vo.facebookPay.PayWayVo;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Handler;
	import MornUI.chargeView.ActChargeViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ActChargeView extends BaseDialog 
	{
		
		private var m_payList:Array;
		private var m_itemList:Array;
		private var m_currencyList:Array;
		private var m_data:FaceBookPayVo;
		private var m_countriesVo:CountriesVo;
		private var m_selectPayVo:PayWayVo;
		private var m_goodData:Object;
		
		/**
		 * 物品关键字
		 * 从后台数据中根据关键字索引出需要购买的物品信息
		 */
		private var m_keyWord:String;
		
		private var m_canBuy:Boolean = false;
		
		public function ActChargeView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			
			var str:String = "";
			var cost:String = "";
			var id:int = e.target.name.split("_")[1];
			switch(e.target)
			{
				case this.view.closeBtn:
					close();
					break;
				case view.buyBtn:
					if (!m_canBuy)
					{
						return;
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL, [m_countriesVo.country_code,
																						m_selectPayVo.id,
																						m_goodData.id,
																						m_goodData.pack_currency_id,
																						m_countriesVo.id,1,"bs"]);
					break;
				default:
					break;
				
			}
		}
		
		override public function show(...args):void
		{
			
			super.show();
			trace("打开活动支付界面：", args);
			m_canBuy = false;
			switch(args[0][0])
			{
				case "lvFundation":
					m_keyWord = "_fund";
					view.adImg.skin = "chargeView/ad1.png";
					view.actTitle.text = GameLanguage.getLangByKey("L_A_56089");
					view.actInfo.text = GameLanguage.getLangByKey("L_A_56091");
					break;
				case "ThreeGift":
					m_keyWord = args[0][1];
					view.adImg.skin = "chargeView/ad" + (parseInt(args[0][2]) + 2) + ".png";
					view.actTitle.text = GameLanguage.getLangByKey("L_A_86101");
					view.actInfo.text = GameLanguage.getLangByKey("L_A_86112");
					break;
				case "weekCard":
					m_keyWord = "_7";
					view.adImg.skin = "chargeView/ad5.png";
					view.actTitle.text = GameLanguage.getLangByKey("L_A_86101");
					view.actInfo.text = GameLanguage.getLangByKey("L_A_86112");
					break;
				default:
					break;
			}
			
			
			getPayItemDataByWeb();
		}
		
		private function getPayItemDataByWeb():void
		{
//			临时注释
			__JS__("getProductlist('https://pay.movemama.com/v1/game/getdata?appid=9',back)");
			
			/*var data = ResourceManager.instance.getResByURL("config/getPayItemDataByWeb.json");
			back(data);*/
			
			function back(data){
				trace("back::"+JSON.stringify(data))
				trace("back::", data)
				m_data = new FaceBookPayVo();
				if(data.status==1)
				{
					m_data.selectId=data.data["default"].id;
					m_data.region_name=data.data["default"].idregion_name;
					m_data.country_code=data.data["default"].country_code;
					m_data.setCountries(data.data.countries);
					m_data.setCurrencyList(data.data.currency);
					m_data.setPayWay(data.data.payway);
					m_data.setPack(data.data.packs);
					m_data.setPayInfo(data.data.country_currency_payway);
				}
				
				// FB没有选择国家 默认选择为美国 235 32
				/*var data:Array = m_data.getPackListByPayId(235, 32);
				var len:int = data.length;
				
				// 选择基金
				var td:Object;
				for (var i:int; i < len; i++)
				{
					if (data[i].name.indexOf("_fund") > -1)
					{
						td = data.splice(i, 1);
						break;
					}
				}*/
				initData();
				m_canBuy = true;
			}
		}
		
		private function initData()
		{
			
			this.view.PayList.itemRender=PayChannelItem;
			this.view.PayList.hScrollBarSkin="";
			this.view.PayList.selectEnable=true;
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
				view.FaceBookTipsText.visible=true;
				view.FaceBookTipsText.text=GameLanguageMgr.instance.getLanguage("L_A_52031");
			}
			else
			{
				view.CountryCombo.visible=true;
				view.PayList.visible=true;
				view.FaceBookTipsText.visible=false;
			}
			
			// 初始化
			view.CountryCombo.selectedIndex = m_data.getCountyIndex(m_data.region_name);
			view.PayList.selectedIndex = 1;
			view.PayList.selectedIndex = 0;
		}
		
		/**确认购买*/
		private function onSelectChargeHandler(p_index:int, isWeekCard:Boolean = false):void
		{
			
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
			
			
			// 235 32
			var data:Array = m_data.getPackListByPayId(m_countriesVo.id,l_data.id);
			
			var _this = this;
			
			for(var i:int=0; i < data.length; i++){
				if(data[i].name.indexOf(m_keyWord) > -1){
					m_goodData = data[i];
					break;
				}
			}
			trace("物品关键词：", m_keyWord);
			trace("购买的物品信息：", m_goodData);
			/*data.forEach(function(item, index){
				// 给每个子项添加回调（由于子项有个单独的帮助小按钮所以需要分离）
				item.onSelectChargeHandler = onSelectChargeHandler.bind(_this, index);
				
				item["isAbleBuy"] = isAbleBuy;
			})*/
			
			
			
		}
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				
				case ServiceConst.GET_WEBPAY_URL:
				{
					var url:String=args[1]["url"];
					trace("打开支付页面：", url, m_goodData.name);
					
					var voName:String = m_goodData.name;
					
					__JS__("openurl(url,voName, GameSetting.Platform, payCallBackHandler)");
					close();
					
				}
				default:
				{
					break;
				}
				
				function payCallBackHandler(obj:Object):void
				{
					if(obj.status=="completed")
					{
						GlobalRoleDataManger.instance.WebItemPayHandler();
					}
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
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void {
			this.closeOnBlank = true;
			
			this._view = new ActChargeViewUI();
			this.addChild(_view);
			
			
		}
		
		private function get view():ActChargeViewUI{
			return _view;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult, [ServiceConst.GET_WEBPAY_URL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
//			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
//			
			super.removeEvent();
		}
	}

}