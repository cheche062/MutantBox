package game.module.relic
{
	import MornUI.friend.FriendMainViewUI;
	import MornUI.relic.EscortMainViewUI;
	import MornUI.relic.GoodsCellUI;
	import MornUI.relic.PlanDotCellUI;
	
	import game.commo;
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.util.TimeUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.relic.TransportBaseInfo;
	import game.global.vo.relic.TransportPlanInfoVo;
	import game.global.vo.relic.TransportPlanpriceVo;
	import game.global.vo.relic.TransportPrice1Vo;
	import game.global.vo.relic.TransportVehicleInfo;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Timer;
	
	public class EscortMainView extends BaseDialog
	{
		private var m_data:TransportBaseInfo;
		private var m_selectPlan:int;
		private var m_planArr:Array;
		private var m_transportMainView:TransportMainView;
		private var m_buyType:int;
		private var m_selectVehicle:TransportVehicleInfo;
		private var m_buyVehicle:TransportVehicleInfo;
		
		private var m_goodEffXY:Array=[-27,182,227,73,658,176];
		private var m_lineEffXY:Array=[212,130,534,142,660,247];
		private var m_PlanDotEffXY:Array=[195,84,590,110,604,214];
		
		private var m_goodEffList:Array;
		
		private var m_planEff:Animation;
		private var m_planEffList:Array=[170,59,565,85,579,188];
		private var m_selectPlanData:TransportPlanInfoVo;
		private var isgoNextWin:Boolean;

		public function EscortMainView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new EscortMainViewUI();
			this.addChild(_view);
			this.closeOnBlank=true;
			UIRegisteredMgr.AddUI(view.Plan0,"TransPlan");
			UIRegisteredMgr.AddUI(view.SelectCarrierBtn,"VechicieBtn");
			UIRegisteredMgr.AddUI(view.SelectTroopsBtn,"ChooseTripBtn");
			UIRegisteredMgr.AddUI(view.StartBtn, "ShipBtn");
			UIRegisteredMgr.AddUI(view.BattleBtn,"GoTechBtn");
			cacheAsBitmap = true;
		}
		
		override public function show(...args):void
		{
			super.show(args);
			m_data=args[0];
			if(m_data.isAnimation==true)
			{
				AnimationUtil.flowIn(this);
			}
			isgoNextWin=false;
			m_goodEffList=new Array();
			GameConfigManager.intance.getTransport();
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTRANMAP,[]);
			if(m_data.state==3)
			{
				selectTrainType(3);
				
			}
			
			// 关闭该功能
			view.BattleBtn.visible = false;
		}
		
		override public function dispose():void{
			UIRegisteredMgr.DelUi("TransPlan");
			UIRegisteredMgr.DelUi("VechicieBtn");
			UIRegisteredMgr.DelUi("ChooseTripBtn");
			UIRegisteredMgr.DelUi("ShipBtn");
			UIRegisteredMgr.DelUi("GoTechBtn");
			UIRegisteredMgr.DelUi("GoTechBtn");
			Laya.loader.clearRes("appRes/atlas/effects/plan_round_s.json");
			Laya.loader.clearRes("appRes/atlas/effects/plan_round.json");
			if(isgoNextWin==false)
			{
				super.dispose();
			}
			
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			this.view.TrainBtn.text.text=GameLanguage.getLangByKey("L_A_34098");
			this.view.PlunderBtn.text.text=GameLanguage.getLangByKey("L_A_34099");
			view.LogDotImage.visible=m_data.isLog;
			//this.view.StartBtn.text.text="Free:"+m_data.transTimes;
			this.view.TitleText.text=GameLanguage.getLangByKey("L_A_603");
			
//			this.view.RefreshBtn.text=GameLanguage.getLangByKey("L_A_34094");
			this.view.SelectCarrierBtn.text.text=GameLanguage.getLangByKey("L_A_59001");
			this.view.SelectTroopsText.text=GameLanguage.getLangByKey("L_A_34002");
			this.view.GroupHelpBtn.text.text=GameLanguage.getLangByKey("L_A_34091");
			this.view.StartBtn.text.text=GameLanguage.getLangByKey("L_A_34016");
			this.view.LogBtn.text.text=GameLanguage.getLangByKey("L_A_34106");
			this.view.TrainBtn.selected=true;
			if(m_planEff!=null)
			{
				m_planEff.visible=false;
			}
			createFoodsList();
			setCarrier();
			selectTrainType(1);
		}		
		
		private function createFoodsList():void
		{
			for (var i:int = 0; i < 3; i++) 
			{
				var l_ui:GoodsCellUI=this.view.getChildByName("Plan"+i) as GoodsCellUI;
//				var l_PlanDot:PlanDotCellUI=this.view.getChildByName("PlanDot"+i)as PlanDotCellUI;
//				var l_Line:Image=this.view.getChildByName("Line"+i)as Image;
				var l_itemCell:GoodsCell=new GoodsCell(l_ui,m_data.planList[i],m_data.vehicle);
//				var l_planDotCell:PlanDotCell=new PlanDotCell(l_PlanDot,m_data,i);
				var l_skin:String="";
				switch(i)
				{
					case 0:
					{
						l_skin="a";
						break;
					}
					case 1:
					{
						l_skin="b";
						break;
					}
					case 2:
					{
						l_skin="c";
						break;
					}
				}
				l_itemCell.setFreeNum(m_data.freePlanSelectedTimes);
				if(m_data.planList[i].status==3)
				{
					m_selectPlan=m_data.status;
					l_itemCell.selectType(true);
//					setGoodsEffects(i);
				}
				else
				{
					l_itemCell.selectType(false);
				}
			}
			//setGoodsEffects();
		}
		
		/**
		 * 载具选择
		 */
		private function setCarrier():void
		{
			m_data.getISUseVehicle(GlobalRoleDataManger.instance.user.level);
			this.view.CarrierImage.skin="";
			for (var i:int = 0; i < m_data.canUseVehicle.length; i++) 
			{
				var l_transportVehicleInfo:TransportVehicleInfo=m_data.canUseVehicle[i];
				if(l_transportVehicleInfo.status==2)
				{
					m_selectVehicle=l_transportVehicleInfo;
					this.view.CarrierImage.skin="appRes/Transport/"+l_transportVehicleInfo.baseVo.tupian+".png";
					this.view.SelectCarrierBtn.text.text="";
				}
			}
		}
		
		/**
		 *增加监听 
		 */
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			this.on(Event.CLICK,this,this.onClickHander);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,closeHandler);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_BATTLELOG,this,onBattleLogHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTRANMAP),this,onResult,[ServiceConst.TRAN_ENTERTRANMAP]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTEREMBATTLE),this,onResult,[ServiceConst.TRAN_ENTEREMBATTLE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_GROUPHELP),this,onResult,[ServiceConst.TRAN_GROUPHELP]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTHECOPY),this,onResult,[ServiceConst.TRAN_ENTERTHECOPY]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_REFRESHPAN),this,onResult,[ServiceConst.TRAN_REFRESHPAN]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYPLAN),this,onResult,[ServiceConst.TRAN_BUYPLAN]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYPLAN),this,onResult,[ServiceConst.TRAN_SELECTBUYPLAN]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_STARTRANSPORT),this,onResult,[ServiceConst.TRAN_STARTRANSPORT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYVEHICLE),this,onResult,[ServiceConst.TRAN_BUYVEHICLE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYVEHICLE),this,onResult,[ServiceConst.TRAN_SELECTBUYVEHICLE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYTRANSTIMES),this,onResult,[ServiceConst.TRAN_BUYTRANSTIMES]);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYVEHICLE),this,onResult,[ServiceConst.TRAN_SELECTBUYVEHICLE]);	
		}
		
		private function closeHandler():void
		{
			// TODO Auto Generated method stub
			m_data.status=0;
			m_goodEffList=new Array();
			GameConfigManager.intance.getTransport();
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
		}
		
		/**
		 *点击事件 
		 */
		private function onClickHander(e:Event):void
		{
			switch(e.target)
			{
				case this.view.StartBtn:
					if(m_data.myPlan!=null)
					{
						m_selectPlanData =m_data.myPlan;
						var l_arr:Array=m_selectPlanData.baseVo.cost.split("=");
						var user:User = GlobalRoleDataManger.instance.user;
						var itemD:ItemData=new ItemData();
						itemD.iid=l_arr[0];
						itemD.inum=l_arr[1];
						if(m_selectPlanData.baseVo.type==1 && m_data.freePlanSelectedTimes<parseInt(GameConfigManager.transportParam.freePlanBuyTime))
						{
							
							if(user.getResNumByItem(l_arr[0])<parseInt(l_arr[1]))
							{
								ConsumeHelp.Consume([itemD],Handler.create(this,gotoSendStartBack));
							}
							else
							{
								WebSocketNetService.instance.sendData(ServiceConst.TRAN_STARTRANSPORT,[]);
							}
						}
						else
						{
							if(parseInt(l_arr[0])!=1)
							{
								if(user.getResNumByItem(l_arr[0])<parseInt(l_arr[1]))
								{
									ConsumeHelp.Consume([itemD],Handler.create(this,gotoSendStartBack));
								}
								else
								{
									onBuyHandler(5,1,m_selectPlanData);
								}
							}
							else
							{
								if(parseInt(l_arr[0])==1&&(l_arr[1]>user.water))
								{
//									if(GameSetting.IsRelease)
//									{
//										XFacade.instance.openModule(ModuleName.FaceBookChargeView);
//									}
//									else
//									{
										XFacade.instance.openModule(ModuleName.ChargeView);
//									}
								}
								else
								{
									onBuyHandler(5,1,m_selectPlanData);
								}
							}
						}
					}
					break;
				case this.view.SelectCarrierBtn:
					XFacade.instance.openModule(ModuleName.EscortSelectView,m_data);
					break;
				case this.view.BattleBtn:
					//XFacade.instance.openModule("LevelUpView");
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					clear();
					this.close();
					break;
				case this.view.SelectTroopsBtn:
					var l_num:int=0;
					if(m_selectVehicle!=null)
					{
						FightingManager.intance.getSquad(111,null,Handler.create(this,fightBackHandler));
					}
					else
					{
						XTip.showTip("L_A_914025");
					}
					break;
				case this.view.GroupHelpBtn:
					if(User.getInstance().guildID!=null&&User.getInstance().guildID!="")
					{
						WebSocketNetService.instance.sendData(ServiceConst.TRAN_GROUPHELP,[]);
					}
					else
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_34104"));
					}
					break
				case this.view.CloseBtn:
					clear();
					this.close();
					break;
				case this.view.Plan0.BuyBtn:
					selectPlan(0)
					break;
				case this.view.Plan1.BuyBtn:
					selectPlan(1)
					break;
				case this.view.Plan2.BuyBtn:
					selectPlan(2);
					break;
				case this.view.Plan0.CostImage:
					var l_str:String=e.target.name;
					var l_arr:Array=l_str.split("_");
					var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[1]];
					ItemTips.showTip(itemvo.id);
					break;
				case this.view.Plan1.CostImage:
					var l_str:String=e.target.name;
					var l_arr:Array=l_str.split("_");
					var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[1]];
					ItemTips.showTip(itemvo.id);
					break;
				case this.view.Plan2.CostImage:
					var l_str:String=e.target.name;
					var l_arr:Array=l_str.split("_");
					var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[1]];
					ItemTips.showTip(itemvo.id);
					break;
				case this.view.LogBtn:
					selectTrainType(3);
//					XFacade.instance.openModule("TrainLogView",1);
					break;
				case this.view.TrainBtn:
					selectTrainType(1);
					break;
				case this.view.PlunderBtn:
					selectTrainType(2);
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
									m_buyVehicle=l_trainvo;
									onBuyHandler(3,1,l_trainvo);
								}
								else if(l_trainvo.status==0)
								{
									WebSocketNetService.instance.sendData(ServiceConst.TRAN_BUYVEHICLE,[l_trainvo.baseVo.id]);
								}
								else
								{
									WebSocketNetService.instance.sendData(ServiceConst.TRAN_SELECTBUYVEHICLE,[l_trainvo.baseVo.id]);
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
			// TODO Auto Generated method stub
		}
		
		private function selectTrainType(p_type:int):void
		{
			// TODO Auto Generated method stub
			if(p_type==1)
			{
				this.view.TrainBtn.selected=true;
				this.view.PlunderBtn.selected=false;
				this.view.LogBtn.selected=false;
				if(m_data.status==0)
				{
					this.view.Plan0.visible=true;
					this.view.Plan1.visible=true;
					this.view.Plan2.visible=true;
					this.view.Plan4.visible=false;
					this.view.TrainTipsText.visible=false;
					this.view.TrainTimeText.visible=false;
					this.view.SelectCarrierBtn.gray=false;
					this.view.GroupHelpBtn.gray=false;
					this.view.SelectTroopsBtn.gray=false;
					this.view.SelectCarrierBtn.mouseEnabled=true;
					this.view.GroupHelpBtn.mouseEnabled=true;
					this.view.SelectTroopsBtn.mouseEnabled=true;
					this.view.StartBtn.gray=false;
					this.view.StartBtn.mouseEnabled=true;
					this.view.TrainTimeTipsText.visible=false;
					this.view.TrainTimeTipsText.text=GameLanguage.getLangByKey("L_A_34072");
					this.timer.clear(this,updateTime);
				}
				else
				{
					this.view.Plan0.visible=false;
					this.view.Plan1.visible=false;
					this.view.Plan2.visible=false;
					this.view.Plan4.visible=true;
					this.view.TrainTipsText.visible=true;
					this.view.TrainTimeText.visible=true;
					this.view.TrainTimeTipsText.visible=true;
					this.view.TrainTimeTipsText.text=GameLanguage.getLangByKey("L_A_34072");
					this.view.TrainTipsText.text=GameLanguage.getLangByKey("L_A_34100");
					var l_itemCell:GoodsCell=new GoodsCell(this.view.Plan4,m_data.myPlan,m_data.vehicle);
					l_itemCell.setFreeNum(m_data.freePlanSelectedTimes);
					this.view.SelectCarrierBtn.gray=true;
					this.view.GroupHelpBtn.gray=true;
					this.view.SelectTroopsBtn.gray=true;
					this.view.StartBtn.gray=true;
					this.view.TrainTimeText.text="";
					if(m_data.endTime-m_data.nowTime>0)
					{
						this.timer.loop(1000,this,updateTime);
					}
					this.view.SelectCarrierBtn.mouseEnabled=false;
					this.view.GroupHelpBtn.mouseEnabled=false;
					this.view.SelectTroopsBtn.mouseEnabled=false;
					this.view.StartBtn.mouseEnabled=false;
				}
			}
			else if(p_type==2)
			{
				this.view.TrainBtn.selected=false;
				this.view.PlunderBtn.selected=true;
				this.view.LogBtn.selected=false;
				isgoNextWin=true;
				XFacade.instance.openModule("PlunderMainView",m_data);
				close();
			}
			else if(p_type==3)
			{
				this.view.TrainBtn.selected=false;
				this.view.PlunderBtn.selected=false;
				this.view.LogBtn.selected=true;
				isgoNextWin=true;
				XFacade.instance.openModule("TrainLogView",m_data);
				close();
			}
		}
		
		private function updateTime():void
		{
			// TODO Auto Generated method stub
			if((m_data.endTime-m_data.nowTime)>0)
			{
				m_data.nowTime++;
				var l_time:Number=m_data.endTime-m_data.nowTime;
				this.view.TrainTimeText.text=TimeUtil.getTimeCountDownStr(l_time,false);
				this.view.TrainTimeTipsText.text=GameLanguage.getLangByKey("L_A_34072");
			}
			else
			{
				this.view.TrainTimeText.text="";
			}
		}
		
		private function gotoSendStartBack():void
		{
			// TODO Auto Generated method stub
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_STARTRANSPORT,[]);
//			WebSocketNetService.instance.sendData(ServiceConst.TRAN_BUYPLAN,[m_selectPlanData.baseVo.id]);
		}
		
		private function fightBackHandler():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			var l_data:TransportBaseInfo=new TransportBaseInfo();
			l_data.status=0;
			l_data.endTime=0;
			XFacade.instance.openModule("EscortMainView",l_data);
		}
		
		/**
		 * 购买界面
		 */
		private function onBuyHandler(p_type:int,p_num:int,p_data:*)
		{			
			XFacade.instance.openModule(ModuleName.TransportMainView,[p_type,p_data]);
		}
		
		/**
		 * 选择方案
		 */
		private function selectPlan(p_selectPlan:int):void
		{
			if(m_data.planList[p_selectPlan].status==0)
			{
				m_selectPlan=p_selectPlan;
				m_selectPlanData =m_data.planList[p_selectPlan];
				var user:User = GlobalRoleDataManger.instance.user;
				var l_arr:Array=m_selectPlanData.baseVo.cost.split("=");
				var itemD:ItemData=new ItemData();
				itemD.iid=l_arr[0];
				itemD.inum=l_arr[1];
				m_selectPlan=p_selectPlan;
				WebSocketNetService.instance.sendData(ServiceConst.TRAN_SELECTBUYPLAN,[m_data.planList[p_selectPlan].baseVo.id]);
			}
			else if(m_data.planList[p_selectPlan].status==1)
			{
				m_selectPlan=p_selectPlan;
				WebSocketNetService.instance.sendData(ServiceConst.TRAN_SELECTBUYPLAN,[m_data.planList[p_selectPlan].baseVo.id]);
			}
			
			createFoodsList();
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
			this.off(Event.CLICK,this,this.onClickHander);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTRANMAP),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_GROUPHELP),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTHECOPY),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_REFRESHPAN),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYPLAN),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYPLAN),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_STARTRANSPORT),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYVEHICLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYVEHICLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYVEHICLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYTRANSTIMES),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTEREMBATTLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTBUYVEHICLE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,closeHandler);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_BATTLELOG,this,onBattleLogHandler);
			this.timer.clearAll(this);
		}
		
		private function onBattleLogHandler():void
		{
			// TODO Auto Generated method stub
			m_data.isLog=true;
			view.LogDotImage.visible=true;
		}
		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.TRAN_GROUPHELP:
					XFacade.instance.openModule(ModuleName.ItemAlertView,[GameLanguage.getLangByKey("L_A_34103")]);
					break;
				case ServiceConst.TRAN_ENTERTHECOPY:
					var l_info:Object=args[1];
					m_data.plan=l_info.plan;
					m_data.vehicle=l_info.vehicle;
					m_data.freePlan=l_info.freePlan;
					m_data.transTimes=l_info.transTimes;
					m_data.flushTimes=l_info.flushTimes;
					m_data.vehicleList=l_info.vehicleList;
					m_data.freePlanSelectedTimes=l_info.freePlanSelectedTimes;
					m_data.setPlanList(l_info.planList);
					initUI();
					break;
				case ServiceConst.TRAN_BUYVEHICLE:
					XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
					break;
				case ServiceConst.TRAN_SELECTBUYVEHICLE:
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
					break;
				case ServiceConst.TRAN_REFRESHPAN:
//					GoodsEffects();
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
					break;
				case ServiceConst.TRAN_BUYPLAN:
					XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
					break;
				case ServiceConst.TRAN_SELECTBUYPLAN:
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTHECOPY,[]);
					
					break;
				case ServiceConst.TRAN_STARTRANSPORT:
					m_data.status=1;
					isgoNextWin=true;
					XFacade.instance.openModule("PlunderMainView",m_data);
					clear();
					this.close();
					break;
				case ServiceConst.TRAN_BUYTRANSTIMES:
					m_data.transTimes++;
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_STARTRANSPORT,[]);
					XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					break;
				case ServiceConst.TRAN_ENTERTRANMAP:
				{
					var l_info:Object=args[1];
					m_data.fightTimes=l_info.fightTimes;
					m_data.PlanId=l_info.Plan;
					m_data.VehicleId=l_info.vehicle;
					m_data.nowTime=l_info.nowTime;
					m_data.startTime=l_info.startTime;
					m_data.plunderTimes=l_info.plunderTimes;
					m_data.lostItems=l_info.lostItems;
					m_data.rewards=l_info.rewards;
					m_data.endTime=l_info.endTime;
					m_data.setEnemieList(l_info.enemies);
					selectTrainType(1);
					if(m_data.status==1)
					{
						if(m_data.endTime-m_data.nowTime<0)
						{
							this.view.TrainBtn.selected=false;
							this.view.PlunderBtn.selected=true;
							this.view.LogBtn.selected=false;
							isgoNextWin=true;
							XFacade.instance.openModule("PlunderMainView",m_data);
							close();
						}
					}
					break;
				}
			}
		}		
		
		private function clear():void
		{
			if(m_planEff!=null)
			{
				view.removeChild(m_planEff);
				m_planEff.clear();
				m_planEff.destroy(true);
				m_planEff=null
			}
			for (var i:int = 0; i < m_goodEffList.length; i++) 
			{
				view.removeChild(m_goodEffList[i]);
				m_goodEffList[i].destroy(true);
			}	
			m_goodEffList=null;
		}
		
		private function setGoodsEffects(p_index:int):void
		{
			if(m_planEff==null)
			{
				m_planEff=new Animation();
				m_planEff.autoPlay = true;
				m_planEff.mouseEnabled = m_planEff.mouseThrough = false;
				var jsonStr:String = "appRes/atlas/effects/plan_round_s.json";
				m_planEff.loadAtlas(jsonStr);
				view.addChildAt(m_planEff,15);	
			}
			if(m_planEff!=null)
			{
				m_planEff.visible=true;
				m_planEff.x = m_planEffList[0+p_index*2];
				m_planEff.y = m_planEffList[1+p_index*2];
			}
		}
		
		private function GoodsEffects():void
		{
			if(m_planEff!=null)
			{
				m_planEff.visible=false;
			}
			
			for (var i:int = 0; i < 3; i++) 
			{
				var l_ui:GoodsCellUI=this.view.getChildByName("Plan"+i) as GoodsCellUI;
//				var l_PlanDot:PlanDotCellUI=this.view.getChildByName("PlanDot"+i)as PlanDotCellUI;
//				var l_Line:Image=this.view.getChildByName("Line"+i)as Image;
				l_ui.visible=false;
			}
			for (var i:int = 0; i < 3; i++) 
			{
				var l_effect=new Animation();
				var l_effect1=new Animation();
				var jsonStr:String = "appRes/atlas/effects/bg1_1.json";
				var jsonStr1:String="appRes/atlas/effects/plan_round.json"
				l_effect.play(0,false);
				l_effect1.play(0,false);
				l_effect.loadAtlas(jsonStr);
				l_effect1.loadAtlas(jsonStr1);
				view.addChild(l_effect);
				view.addChild(l_effect1);
				l_effect.x = m_goodEffXY[0+i*2];
				l_effect.y = m_goodEffXY[1+i*2];
				l_effect1.x=m_PlanDotEffXY[0+i*2];
				l_effect1.y=m_PlanDotEffXY[1+i*2];
				m_goodEffList.push(l_effect);
				m_goodEffList.push(l_effect1);
			}
			for (var i:int = 0; i < 3; i++) 
			{
				var l_effect=new Animation();
				var jsonStr:String = "appRes/atlas/effects/bg1_1.json";
				if(i==0)
				{
					jsonStr="appRes/atlas/effects/line_a.json";
				}
				else if(i==1)
				{
					jsonStr="appRes/atlas/effects/line_b.json";
				}
				else
				{
					jsonStr="appRes/atlas/effects/line_c.json";
				}
				l_effect.play(0,false);
				l_effect.loadAtlas(jsonStr);
				view.addChild(l_effect);
				l_effect.x = m_lineEffXY[0+i*2];
				l_effect.y = m_lineEffXY[1+i*2];
				m_goodEffList.push(l_effect);
			}
			timer.once(1000,this,clearEff);
		}

		private function clearEff():void
		{
			for (var i:int = 0; i < m_goodEffList.length; i++) 
			{
				view.removeChild(m_goodEffList[i]);
			}
			for (var i:int = 0; i < 3; i++)
			{
				var l_ui:GoodsCellUI=this.view.getChildByName("Plan"+i) as GoodsCellUI;
//				var l_PlanDot:PlanDotCellUI=this.view.getChildByName("PlanDot"+i)as PlanDotCellUI;
//				var l_Line:Image=this.view.getChildByName("Line"+i)as Image;
				l_ui.visible=true;
//				l_PlanDot.visible=true;
//				l_Line.visible=true;
			}
		}

		override public function close():void{
			if(isgoNextWin==false)
			{
				AnimationUtil.flowOut(this, this.onClose);
			}
			else
			{
				onClose();
			}
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		private function get view():EscortMainViewUI
		{
			return _view as EscortMainViewUI;
		}
	}
}