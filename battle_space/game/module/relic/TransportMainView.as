package game.module.relic
{
	import MornUI.relic.EscortMainViewUI;
	import MornUI.relic.EscortSelectViewUI;
	import MornUI.relic.TransportMainViewUI;
	
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class TransportMainView extends BaseDialog
	{
		private var m_data:*;
		private var m_num:int;
		private var m_type:int;
		
		
		public function TransportMainView()
		{
			super();
//			m_type=p_type;
//			m_ui=p_ui;
//			m_data=p_data;
//			m_num=p_num;
//			initUI();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new TransportMainViewUI();
			this.addChild(_view);
		}
		
		override public function show(...args):void
		{
			super.show(args);
			m_type=args[0][0];
			m_data=args[0][1];
			initUI();
		}
		
		private function get view():TransportMainViewUI
		{
			return _view as TransportMainViewUI;
		}

		private function initUI():void
		{
			var user:User = GlobalRoleDataManger.instance.user;
			var itemvo:ItemVo=null;
			if(m_type==1)
			{
				view.LabelText.text=GameLanguage.getLangByKey("L_A_34085");
				view.BuyBtn.text.text=m_data.getPrice();
				itemvo=GameConfigManager.items_dic[1];
			}
			else if(m_type==2)
			{
				view.LabelText.text=GameLanguage.getLangByKey("L_A_34101");
				view.BuyBtn.text.text=m_data.getPrice();
				itemvo=GameConfigManager.items_dic[1];
			}
			else if(m_type==3)
			{
				view.LabelText.text=GameLanguage.getLangByKey("L_A_34008");
				view.BuyBtn.text.text=m_data.baseVo.getPrice();
				itemvo=GameConfigManager.items_dic[1];
			}
			else if(m_type==4)
			{
				trace("m_data:::___",m_data);
				view.LabelText.text=GameLanguage.getLangByKey("L_A_34031");
				view.BuyBtn.text.text=m_data.getPrice();
				var itemId:int=m_data.getItemId();
				itemvo=GameConfigManager.items_dic[itemId];
			}
			else if(m_type==5)
			{
				view.LabelText.text=GameLanguage.getLangByKey("L_A_34008");
				view.BuyBtn.text.text=m_data.baseVo.getCostNum();
				var l_arr:Array=m_data.baseVo.cost.split("=");
				itemvo=GameConfigManager.items_dic[l_arr[0]];
			}
			view.ItemImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
			if(user.water<view.BuyBtn.text.text)
			{
				this.view.BuyBtn.text.color="#2d3c4d,#2d3c4d,#2d3c4d";
			}
			else
			{
				this.view.BuyBtn.text.color="#ff0000,#ff0000,#ff0000";
			}
		}
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			this.on(Event.CLICK,this,this.onClickHander);
		}
		
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
				{
					this.close();
					break;
				}
				case this.view.BuyBtn:
				{
					var user:User = GlobalRoleDataManger.instance.user;
					if(m_type==1)
					{
						WebSocketNetService.instance.sendData(ServiceConst.TRAN_REFRESHPAN,[]);
						
					}
					else if(m_type==2)
					{
						WebSocketNetService.instance.sendData(ServiceConst.TRAN_BUYTRANSTIMES,[]);
					}
					else if(m_type==3)
					{
						if(user.water<parseInt(view.BuyBtn.text.text))
						{
//							if(GameSetting.IsRelease)
//							{
//								XFacade.instance.openModule(ModuleName.FaceBookChargeView);
//							}
//							else
//							{
								XFacade.instance.openModule(ModuleName.ChargeView);
//							}
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.TRAN_BUYVEHICLE,[m_data.baseVo.id]);
						}
					}
					else if(m_type==4)
					{
						WebSocketNetService.instance.sendData(ServiceConst.TRAN_BUYPLUNDERTIME,[]);
					}
					else if(m_type==5)
					{
						
						var l_arr:Array=m_data.baseVo.cost.split("=");
						var itemD:ItemData=new ItemData();
						itemD.iid=l_arr[0];
						itemD.inum=l_arr[1];
						if(user.getResNumByItem(l_arr[0])<parseInt(l_arr[1]))
						{
							ConsumeHelp.Consume([itemD],Handler.create(this,gotoSendStartBack));
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.TRAN_STARTRANSPORT,[]);
						}
					}
					this.close();
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function gotoSendStartBack():void
		{
			// TODO Auto Generated method stub
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_STARTRANSPORT,[]);
		}
		
		private function get view():EscortSelectViewUI{
			return _view;
		}
	}
}