package game.module.threeGift 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.vo.facebookPay.FaceBookPayVo;
	import game.global.vo.reVo;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.utils.Browser;
	import MornUI.threeGift.ThreeGiftViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ThreeGiftView extends BaseDialog 
	{
		
		private var _actID:String = "";
		
		private var _item1Vec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		private var _item2Vec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		private var _item3Vec:Vector.<ItemContainer> = new Vector.<ItemContainer>();		
		private var _btnArr:Array = [];
		private var _labelArr:Array = [];
		
		private var _iosItem:Array = [];
		private var _andriodItem:Array = [];
		private var _fbItem:Array = [];
		private var _gwItem:Array = [];
		private var _progressInfo:Object = { };
		private var _buyInfo:Object = { };
		
		
		private var _mobileData:reVo;
		private var m_FBdata:FaceBookPayVo;
		private var m_targeData:Object
		
		private var _currentItem:Array = [];
		private var channelType:int;
		
		public function ThreeGiftView() 
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
				case this.view.helpBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_86113"));
					break;
				case this.view.reward_0:
				case this.view.reward_1:
				case this.view.reward_2:
					if (e.target.label == GameLanguage.getLangByKey("L_A_56018"))
					{
						if ( _progressInfo[_iosItem[id].id]  && parseInt(_progressInfo[_iosItem[id].id]))
						{
							WebSocketNetService.instance.sendData(ServiceConst.THREE_GIFT_GET, [_actID,_iosItem[id].id]);
						}
						else if ( _progressInfo[_andriodItem[id].id]  && parseInt(_progressInfo[_andriodItem[id].id]))
						{
							WebSocketNetService.instance.sendData(ServiceConst.THREE_GIFT_GET, [_actID,_andriodItem[id].id]);
						}
						else if ( _progressInfo[_gwItem[id].id]  && parseInt(_progressInfo[_gwItem[id].id]))
						{
							WebSocketNetService.instance.sendData(ServiceConst.THREE_GIFT_GET, [_actID,_gwItem[id].id]);
						}
						else if ( _progressInfo[_fbItem[id].id]  && parseInt(_progressInfo[_fbItem[id].id]))
						{
							WebSocketNetService.instance.sendData(ServiceConst.THREE_GIFT_GET, [_actID,_fbItem[id].id]);
						}
						return;
					}
					
					if (GameSetting.isApp)
					{
						getMobileItemData(_currentItem[id].id);
						//trace("m_data:", _mobileData);
						if (!_mobileData)
						{
							XTip.showTip("Item Missing");
							return;
						}
						
						GlobalRoleDataManger.instance.ItemPayHandler(_mobileData);
						close();
					}
					else
					{
						
						if(GameSetting.Platform==GameSetting.P_GW)
						{
							XFacade.instance.openModule(ModuleName.ActChargeView, ["ThreeGift",_currentItem[id].id,id]);
							close();
						}
						else
						{
							
							//forTest
							//XFacade.instance.openModule(ModuleName.ActChargeView, ["ThreeGift",_currentItem[id].id,id]);
							getPayItemDataByWeb(_currentItem[id].id);
						}
					}
					
					break;
					
				default:
					break;
				
			}
		}
		
		private function getPayItemDataByWeb(keywrod:String):void
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
				//trace("fb商品列表：", JSON.stringify(data));
				var len:int = data.length;
				
				// 查询商品
				for (var i:int; i < len; i++)
				{
					if (data[i].name.indexOf(keywrod) > -1)
					{
						m_targeData = data.splice(i, 1)[0];
						break;
					}
				}
				
				trace("礼包商品", m_targeData);
				
				WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL,["US",32,m_targeData.id,1,235,1,"facebok"]);
				
			}
		}
		
		private function getMobileItemData(keyWord:String):void
		{
			
			var i:int = 0;
			var len:int = GameConfigManager.re_list.length;
			_mobileData = null;
			for (i = 0; i < len; i++ )
			{
				if (GameConfigManager.re_list[i].item_id.indexOf(keyWord) > -1)
				{
					
					_mobileData = GameConfigManager.re_list[i];
					return;
				}
			}
			
		}
		
		override public function show(...args):void
		{
			super.show();
			_actID = args[0];
			channelType = 1;
			if (GameSetting.isApp)
			{
				if (Browser.onAndriod)
				{
					channelType = 1;
				}
				else
				{
					channelType = 2;
				}
			}
			else
			{
				if(GameSetting.Platform==GameSetting.P_GW)
				{
					channelType = 3;
				}
				else
				{
					channelType = 4;
				}
			}
			
			WebSocketNetService.instance.sendData(ServiceConst.THREE_GIFT_INIT, [_actID,channelType]);
		}
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			trace("threegiftInfo:", args);
			var len:int = 0;
			var i:int = 0;
			switch(cmd)
			{
				
				case ServiceConst.THREE_GIFT_INIT:
					
					_iosItem = [];
					_andriodItem = [];
					_fbItem = [];
					_gwItem = [];
					
					for each(var re in args[1].draw_config)
					{
						switch(parseInt(re.channel))
						{
							case 1:
								_andriodItem.push(re);
								break;
							case 2:
								_iosItem.push(re);
								break;
							case 3:
								_gwItem.push(re);
								break;
							case 4:
								_fbItem.push(re);
								break;
							default:
								break;
						}
					}
					
					_andriodItem.sort(sortByPrice);
					_iosItem.sort(sortByPrice);
					_gwItem.sort(sortByPrice);
					_fbItem.sort(sortByPrice);
					
					if (GameSetting.isApp)
					{
						if (Browser.onAndriod)
						{
							_currentItem = _andriodItem;
						}
						else
						{
							_currentItem = _iosItem;
						}
					}
					else
					{
						if(GameSetting.Platform==GameSetting.P_GW)
						{
							_currentItem = _gwItem;
						}
						else
						{
							_currentItem = _fbItem;
						}
					}
					
					_progressInfo = args[1].my_info.state;
					_buyInfo = args[1].my_info.buy_number;
					
					//trace("当前列表：", _currentItem);
					refreshItem();
					dealBuyInfo();
					
					
					
					break;
				case ServiceConst.GET_WEBPAY_URL:
					var url:String=args[1]["url"];
					trace("打开直购礼包页面：", url, m_targeData);
					
					var voName:String = m_targeData.name;
					
					__JS__("openurl(url,voName, GameSetting.Platform, payCallBackHandler)");
					
					function payCallBackHandler(obj:Object):void
					{
						if(obj.status=="completed")
						{
							GlobalRoleDataManger.instance.WebItemPayHandler();
						}
					}
					
					close();
					break;
				case ServiceConst.THREE_GIFT_GET:
					var list:Array = args[1];
					var len:int = list.length;
					var ar:Array = [];
					for (var i:int = 0; i < len; i++) 
					{
						var itemD:ItemData = new ItemData();
						itemD.iid = list[i][0];
						itemD.inum = list[i][1];
						ar.push(itemD);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					WebSocketNetService.instance.sendData(ServiceConst.THREE_GIFT_INIT, [_actID,channelType]);
					break;
				default:
					break
			}
		}
		
		private function dealBuyInfo():void
		{
			/**
			 * 匹配四个平台的购买信息
			 */
			for (var i:int = 0; i < 3; i++) 
			{
				_btnArr[i].disabled = false;
				
				if (!_progressInfo[_iosItem[i].id] &&
					!_progressInfo[_andriodItem[i].id] &&
					!_progressInfo[_gwItem[i].id] &&
					!_progressInfo[_fbItem[i].id])
				{
					_btnArr[i].label = "$" + _currentItem[i].price;
					_labelArr[i].text = GameLanguage.getLangByKey("L_A_86107").replace("{0}", 1);
					continue;
				}
				
				
				if(parseInt(_progressInfo[_iosItem[i].id]) == 2 ||
					parseInt(_progressInfo[_andriodItem[i].id]) == 2 ||
					parseInt(_progressInfo[_gwItem[i].id]) == 2 ||
					parseInt(_progressInfo[_fbItem[i].id]) == 2	)
				{
					_btnArr[i].disabled = true;
					_btnArr[i].label = GameLanguage.getLangByKey("L_A_32005");//已领
					_labelArr[i].text = GameLanguage.getLangByKey("L_A_86107").replace("{0}", 0);
				}
				else if(parseInt(_progressInfo[_iosItem[i].id]) == 1 ||
					parseInt(_progressInfo[_andriodItem[i].id]) == 1 ||
					parseInt(_progressInfo[_gwItem[i].id]) == 1 ||
					parseInt(_progressInfo[_fbItem[i].id]) == 1	)
				{
					_btnArr[i].label = GameLanguage.getLangByKey("L_A_56018");//领取
					_labelArr[i].text = GameLanguage.getLangByKey("L_A_86107").replace("{0}", 0);
				}
				else if (parseInt(_progressInfo[_iosItem[i].id]) == 0 ||
					parseInt(_progressInfo[_andriodItem[i].id]) == 0 ||
					parseInt(_progressInfo[_gwItem[i].id]) == 0 ||
					parseInt(_progressInfo[_fbItem[i].id]) == 0	)
				{
					_btnArr[i].label = "$" + _currentItem[i].price;
					_labelArr[i].text = GameLanguage.getLangByKey("L_A_86107").replace("{0}", 1);
				}
			}
		}
		
		private function sortByPrice(a:Object, b:Object):int
		{
			if (a.price < b.price)
			{
				return -1;
			}
			return 1;
		}
		
		private function refreshItem():void
		{
			var reList:Array = _currentItem[0].reward.split(";");
			var len:int = Math.max(reList.length, _item1Vec.length);
			var ll:int = reList.length;
			var i:int = 0;
			for (i = 0; i < len; i++ )
			{
				
				if (!_item1Vec[i])
				{
					_item1Vec[i] = new ItemContainer();
					_item1Vec[i].scaleX = _item1Vec[i].scaleY = 0.9;
					view.addChild(_item1Vec[i]);
				}
				
				if (ll == 3)
				{
					_item1Vec[i].x = 180 - parseInt((i +1) % 3) * 33 + 70 * (i + 1) % 2;
					_item1Vec[i].y = 220 - parseInt((ll+1) / 2) * 30 + 70 * parseInt((i+1) / 2);
				}
				else
				{
					_item1Vec[i].x = 180 - parseInt(ll / 2) * 33 + 70 * (i % 2);
					_item1Vec[i].y = 220 - parseInt(ll / 2) * 30 + 70 * parseInt(i / 2);
				}
				
				
				if (!reList[i])
				{
					_item1Vec[i].visible = false;
				}
				else
				{
					_item1Vec[i].visible = true;
					_item1Vec[i].setData(reList[i].split("=")[0], reList[i].split("=")[1]);
				}
			}
			
			reList = _currentItem[1].reward.split(";");
			len = Math.max(reList.length, _item2Vec.length);
			ll = reList.length;
			i = 0;
			for (i = 0; i < len; i++ )
			{
				
				if (!_item2Vec[i])
				{
					_item2Vec[i] = new ItemContainer();
					_item2Vec[i].scaleX = _item2Vec[i].scaleY = 0.9;
					view.addChild(_item2Vec[i]);
				}
				
				if (ll == 3)
				{
					_item2Vec[i].x = 390 - parseInt((i +1) % 3) * 33 + 70 * (i + 1) % 2;
					_item2Vec[i].y = 220 - parseInt((ll+1) / 2) * 30 + 70 * parseInt((i+1) / 2);
				}
				else
				{
					_item2Vec[i].x = 390 - parseInt(ll / 2) * 33 + 70 * (i % 2);
					_item2Vec[i].y = 220 - parseInt(ll / 2) * 30 + 70 * parseInt(i / 2);
				}
				
				if (!reList[i])
				{
					_item2Vec[i].visible = false;
				}
				else
				{
					_item2Vec[i].visible = true;
					_item2Vec[i].setData(reList[i].split("=")[0], reList[i].split("=")[1]);
				}
			}
			
			
			reList = _currentItem[2].reward.split(";");
			len = Math.max(reList.length, _item2Vec.length);
			ll = reList.length;
			i = 0;
			for (i = 0; i < len; i++ )
			{
				
				if (!_item3Vec[i])
				{
					_item3Vec[i] = new ItemContainer();
					_item3Vec[i].scaleX = _item3Vec[i].scaleY = 0.9;
					view.addChild(_item3Vec[i]);
				}
				
				if (ll == 3)
				{
					_item3Vec[i].x = 590 - parseInt((i +1) % 3) * 33 + 70 * (i + 1) % 2;
					_item3Vec[i].y = 220 - parseInt((ll+1) / 2) * 30 + 70 * parseInt((i+1) / 2);
				}
				else
				{
					_item3Vec[i].x = 590 - parseInt(ll / 2) * 33 + 70 * (i % 2);
					_item3Vec[i].y = 220 - parseInt(ll / 2) * 30 + 70 * parseInt(i / 2);
				}
				
				if (!reList[i])
				{
					_item3Vec[i].visible = false;
				}
				else
				{
					_item3Vec[i].visible = true;
					_item3Vec[i].setData(reList[i].split("=")[0], reList[i].split("=")[1]);
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
			
			this._view = new ThreeGiftViewUI();
			this.addChild(_view);
			
			_btnArr[0] = view.reward_0;
			_btnArr[1] = view.reward_1;
			_btnArr[2] = view.reward_2;
			
			_labelArr[0] = view.remain_0;
			_labelArr[1] = view.remain_1;
			_labelArr[2] = view.remain_2;
		}
		
		private function get view():ThreeGiftViewUI{
			return _view;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.THREE_GIFT_INIT), this, onResult, [ServiceConst.THREE_GIFT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.THREE_GIFT_GET), this, onResult, [ServiceConst.THREE_GIFT_GET]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult, [ServiceConst.GET_WEBPAY_URL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
//			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.THREE_GIFT_INIT), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.THREE_GIFT_GET), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_WEBPAY_URL), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
//			
			super.removeEvent();
		}
		
	}

}