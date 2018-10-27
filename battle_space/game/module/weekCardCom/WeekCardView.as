package game.module.weekCardCom
{
	import game.global.GameConfigManager;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.vo.facebookPay.FaceBookPayVo;
	import game.global.vo.reVo;
	import laya.utils.Browser;
	import MornUI.weekCardCom.weekCardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.module.activity.WelfareMainView;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 周卡
	 * @author hejianbo
	 * 2018-01-11
	 */
	public class WeekCardView extends BaseView
	{
		/**总倒计时时间(秒)*/
		private var totalTime:int = 0;
		/**奖励数据*/
		private var _reward2_data:Object = null;
		/**数据表*/
		private var JSON_PAY_CARD:String = "config/pay_card.json";
		/**天数类型 7or其它*/
		private var CARD_TYPE:int = "7";
		
		private var m_data:reVo;
		private var _fundationArr:Array = [];
		private var m_FBdata:FaceBookPayVo;
		private var m_targeData:Object
		
		public function WeekCardView()
		{
			super();
			
			ResourceManager.instance.load(ModuleName.WeekCardView,Handler.create(this, resLoader));
		}
		
		public function resLoader():void
		{
			this.addChild(view);
			
			var str:String = GameLanguage.getLangByKey("L_A_56084");
			var strList:Array = str.split("##");
			
			view.dom_icons.destroyChildren();
			var totalWidth:int = 0;
			reward2Data.forEach(function(item, index){
				// 添加小icon
				var child:ItemContainer = new ItemContainer();
				child.setData(item["id"], item["num"]);
				totalWidth += child.width;
				view.dom_icons.addChild(child);
			});
			
			view.dom_icons.x = (view.dom_icons.parent.width - totalWidth) / 2;
			
			// 领取按钮的坐标更新
//			view.btn_claim.x = view.dom_icons.x + view.dom_icons.numChildren * (80 + view.dom_icons.space) + 10;
			
			addEvent();
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function onClick(event:Event):void
		{
//			trace("onClick:", onClick);
			switch(event.target){
				
				// 打开购买充值界面
				case view.btn_buy:
					/*XFacade.instance.closeModule(WelfareMainView);
					XFacade.instance.openModule(ModuleName.ChargeView);*/
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
							XFacade.instance.openModule(ModuleName.ActChargeView, ["weekCard"]);
							XFacade.instance.closeModule(WelfareMainView);
						}
						else
						{
							getPayItemDataByWeb();
						}
					}
					break;
				// 领取
				case view.btn_claim:
					sendData(ServiceConst.CLAIM_WEEK_CARD, [7]);
					
					break;
			}
		}
		
		private function getMobileGoodData():void
		{
			var gName:String = Browser.onAndriod?"android_7":"ios_7";
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
				trace("周卡fb商品列表：", JSON.stringify(data));
				var len:int = data.length;
				
				// 选择基金
				for (var i:int; i < len; i++)
				{
					if (data[i].name.indexOf("_7") > -1)
					{
						m_targeData = data.splice(i, 1)[0];
						break;
					}
				}
				
				trace("周卡", m_targeData);
				
				WebSocketNetService.instance.sendData(ServiceConst.GET_WEBPAY_URL,["US",32,m_targeData.id,1,235,1,"facebok"]);
				
			}
		}
		
		/**
		 * 开启时间倒计时 
		 * 
		 */
		private function startTimeLoop(num:int):void{
			stopTimeLoop();
			
			totalTime = parseInt(num) - parseInt(TimeUtil.now / 1000);
			timeCountHandler();
			this.timerLoop(1000, this, timeCountHandler);
		}
		
		/**停止倒计时*/
		private function stopTimeLoop():void{
			this.clearTimer(this, timeCountHandler);
			totalTime = 0;
		}
		
		/**计数*/
		private function timeCountHandler():void{
			totalTime--;
			// 倒计时结束后可以重新购买  && 当天的福利不可领了
			if(totalTime <= 0){
				stopTimeLoop();
				
				view.btn_buy.disabled = false;
				view.btn_claim.disabled = true;
			}
			view.dom_time.text = TimeUtil.getTimeCountDownStr(totalTime, true);
			
//			trace(totalTime)
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			switch(args[0])
			{
				//打开周卡
				case ServiceConst.OPEN_WEEK_CARD:
				{
					view.btn_claim.visible = true;
					//是否购买
					if(args[1].card_last_time[CARD_TYPE]){
						view.btn_buy.disabled = true;
						view.btn_claim.visible = (args[1].card_get_log[CARD_TYPE] !== 1);
						
						startTimeLoop(args[1].card_last_time[CARD_TYPE]);
						
					}else{
						view.btn_buy.disabled = false;
						view.btn_claim.disabled = true;
						stopTimeLoop();
					}
					
					//trace("周卡", "open", args);
					break;
				}
					
				case ServiceConst.CLAIM_WEEK_CARD:
				{
					var childList = reward2Data.map(function(item, index){
						var child:ItemData = new ItemData();
						child.iid = item["id"];
						child.inum = item["num"];
						
						return child;
					})
					
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					// 领取成功后禁用按钮
					view.btn_claim.disabled = true;
					//trace("周卡", "claim", args);
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		
		/**
		 *  
		 * @param noAni 不做动画
		 * 
		 */
		override public function close(noAni:Boolean = false):void{
			stopTimeLoop();
			_reward2_data = null;
			
			// 问题： 弹窗关闭是异步动画后的回调，且事件没来的级移除，外部模块触发了该事件
			if(noAni){
				onClose();
			}else{
				AnimationUtil.flowOut(this, onClose);
			}
		}
		
		private function onClose():void{
			super.close();
			
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.OPEN_WEEK_CARD);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_WEEK_CARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CLAIM_WEEK_CARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_WEEK_CARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CLAIM_WEEK_CARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
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
		
		/**根据数据表处理出数据对象*/
		private function dealWithData():void{
			// 读取数据  渲染领取的小奖励id & 数量num
			var pay_card_data = ResourceManager.instance.getResByURL(JSON_PAY_CARD);
			var reward2:String = pay_card_data["7"]["reward2"];
			CARD_TYPE = pay_card_data["7"]["DAY"];
			
			return reward2.split(";").map(function(item, index){
				var result:Array = item.split("=");
				return {
					id: result[0],
					num: result[1]
				}
			})
		}
		
		/**奖励数据*/
		private function get reward2Data():Object{
			_reward2_data = _reward2_data || dealWithData();
			return _reward2_data;
		}
		
		public function get view():weekCardViewUI{
			_view = _view || new weekCardViewUI();
			return _view;
		}
		
	}
}