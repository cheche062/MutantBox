package game.module.relic
{
	import MornUI.relic.EscortMainViewUI;
	import MornUI.relic.EscortSelectViewUI;
	
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.ItemVo;
	import game.global.vo.relic.TransportBaseInfo;
	import game.global.vo.relic.TransportVehicleInfo;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.css.TransformInfo;
	import laya.events.Event;
	
	public class EscortSelectView extends BaseDialog
	{
		private var m_data:TransportBaseInfo;
		public function EscortSelectView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new EscortSelectViewUI();
			this.addChild(_view);
		}
		
		override public function show(...args):void
		{
			super.show(args);
			m_data=args[0];
			initUI();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			setCarrier();
		}		
		
		/**
		 * 载具选择
		 */
		private function setCarrier():void
		{
			m_data.getISUseVehicle(GlobalRoleDataManger.instance.user.level);
			this.view.SelectList.itemRender=CarrierCell;
			this.view.SelectList.array=m_data.canUseVehicle;
			this.view.SelectList.refresh();
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			this.on(Event.CLICK,this,this.onClickHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTHECOPY),this,onResult,[ServiceConst.TRAN_ENTERTHECOPY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYVEHICLE),this,onResult,[ServiceConst.TRAN_BUYVEHICLE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYVEHICLE),this,onResult,[ServiceConst.TRAN_BUYVEHICLE]);
		}
		
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
					this.close();
					break;
				default:
				{
					if(e.target.name.indexOf("SelectBtn_")!=-1)
					{
						var l_str:String=e.target.name;
						var l_arr:Array=l_str.split("_");
						for (var i:int = 0; i < m_data.canUseVehicle.length; i++) 
						{
							var l_trainvo:TransportVehicleInfo=m_data.canUseVehicle[i] as TransportVehicleInfo;
							if(l_trainvo.baseVo.id==l_arr[1])
							{
								if(l_trainvo.status==0 && l_trainvo.baseVo.getPrice()>0)
								{
									onBuyHandler(3,1,l_trainvo);
								}
								else if(l_trainvo.status==0)
								{
									WebSocketNetService.instance.sendData(ServiceConst.TRAN_BUYVEHICLE,[l_trainvo.baseVo.id]);
									close();
								}
								else
								{
									WebSocketNetService.instance.sendData(ServiceConst.TRAN_SELECTBUYVEHICLE,[l_trainvo.baseVo.id]);
									close();
								}
								break;
							}
						}
					}
					if(e.target.name.indexOf("RewardImage_")!=-1)
					{
						var l_str:String=e.target.name;
						var l_arr:Array=l_str.split("_");
						var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[1]];
						ItemTips.showTip(itemvo.id);
					}
					
					var l_str:String="";
					if(e.target.name=="ProtectImage")
					{
						l_str=GameLanguage.getLangByKey("L_A_34003")
						XTipManager.showTip(l_str);
						
					}
					else if(e.target.name=="PopulationImage")
					{
						l_str=GameLanguage.getLangByKey("L_A_34004")
						XTipManager.showTip(l_str);
						
					}
					else if(e.target.name=="TimeImage")
					{
						l_str=GameLanguage.getLangByKey("L_A_34005")
						XTipManager.showTip(l_str);
					}
				}
			}
		}
		
		/**
		 * 购买界面
		 */
		private function onBuyHandler(p_type:int,p_num:int,p_data:*)
		{
			XFacade.instance.openModule(ModuleName.TransportMainView,[p_type,p_data]);
		}
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.TRAN_BUYVEHICLE:
				case ServiceConst.TRAN_SELECTBUYVEHICLE:
					//WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
					this.close();
					break;
				case ServiceConst.TRAN_ENTERTHECOPY:
					var l_info:Object=args[1];
					m_data.plan=l_info.plan;
					m_data.vehicle=l_info.vehicle;
					m_data.transTimes=l_info.transTimes;
					m_data.flushTimes=l_info.flushTimes;
					m_data.vehicleList=l_info.vehicleList;
					m_data.setPlanList(l_info.planList);
					initUI();
					break;
				default:
				{
					break;
				}
			}
		}		
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYVEHICLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYVEHICLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTHECOPY),this,onResult);
		}
		
		private function get view():EscortSelectViewUI{
			return _view;
		}

	}
}