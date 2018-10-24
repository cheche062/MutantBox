package game.module.relic
{
	import MornUI.relic.CarrierMapCellUI;
	import MornUI.relic.PlunderMainViewUI;
	import MornUI.relic.TransportCellUI;
	import MornUI.relic.TransportDotCellUI;
	
	import game.common.AnimationUtil;
	import game.common.GameLanguageMgr;
	import game.common.ItemTips;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.ItemVo;
	import game.global.vo.relic.EnemieVo;
	import game.global.vo.relic.TransportBaseInfo;
	import game.global.vo.relic.TransportPrice1Vo;
	import game.global.vo.relic.TransportPriceVo;
	import game.module.chests.ChestsMainView;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class PlunderMainView extends BaseDialog
	{
		private var m_data:TransportBaseInfo;
		private var m_randomList:Array=[];
		private var m_selfNum:int;
		private var m_cell:TransportDotCell;
		private var m_plunderTips:PlunderTipsView;
		private var m_transportMainView:TransportMainView;
		private var m_selfData:EnemieVo;
		private var m_selectData:EnemieVo;
		private var m_oldX:Number;
		private var m_oldY:Number;
		private var m_buyType:int;
		private var m_oldXList:Array;
		private var m_oldYList:Array;
		private var m_RewardTips:Boolean=false;

		private var m_isOpenWin:Boolean=true;
		private var isgoNextWin:Boolean;
		//private var 
		public function PlunderMainView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new PlunderMainViewUI();
			this.addChild(_view);
			
			
			this.closeOnBlank=true;
		}
		
		override public function dispose():void{
			
			this.destroy();
			//super.dispose();
		}
		
		override public function show(...args):void
		{
			super.show(args);
			if(args==null)
			{
				AnimationUtil.flowIn(this);
			}
			
			m_data=args[0];
			m_RewardTips=false;
			isgoNextWin=false;
			GameConfigManager.intance.getTransport();
			m_oldXList=[488,414,265,811,891,440,61,273,198,291,546,563];
			m_oldYList=[216,143,154,115,349,285,122,433,264,337,294,267];
			this.view.TitleText.text=GameLanguage.getLangByKey("L_A_603");
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_ENTERTRANMAP,[]);
		}
		
		private function initUI():void
		{
			view.LogDotImage.visible=m_data.isLog;
			this.view.TrainBtn.text.text=GameLanguage.getLangByKey("L_A_34098");
			this.view.PlunderBtn.text.text=GameLanguage.getLangByKey("L_A_34099");
			this.view.LogBtn.text.text=GameLanguage.getLangByKey("L_A_34106");
			this.view.RefreshBtn.visible=false;
			m_randomList=[];
			this.view.PlunderBtn.selected=true;
			for (var i:int = 0; i < 12; i++) 
			{
				var p_ui:TransportCellUI=this.view.getChildByName("Transport"+i)as TransportCellUI;
				var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+i)as TransportDotCellUI;
				var p_carrier:CarrierMapCellUI=this.view.getChildByName("Carrier_"+i) as CarrierMapCellUI;
				var p_uiLine:Image=this.view.getChildByName("Line"+i)as Image;
				p_ui.visible=p_uiDot.visible=p_uiLine.visible=p_carrier.visible=false;
			}
			
			// TODO Auto Generated method stub
			for (var i:int = 0; i < m_data.Enemies.length; i++) 
			{
				var l_random:int=Math.ceil(Math.random())+i*2;
				if(l_random>12)
				{
					l_random=12;
				}
				m_randomList[l_random]=i;
				var p_ui:TransportCellUI=this.view.getChildByName("Transport"+l_random)as TransportCellUI;
				var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+l_random)as TransportDotCellUI;
				var p_carrier:CarrierMapCellUI=this.view.getChildByName("Carrier_"+l_random) as CarrierMapCellUI;
				var p_uiLine:Image=this.view.getChildByName("Line"+l_random)as Image;
				p_uiLine.skin="relic/reliline_1.png";
				p_ui.visible=p_uiDot.visible=p_uiLine.visible=p_carrier.visible=true;
				var l_cell:TransportCell=new TransportCell(p_ui,m_data.Enemies[i]);
				var l_dotCell:TransportDotCell=new TransportDotCell(p_uiDot,m_data.Enemies[i]);
				var l_carrierCell:CarrierMapCell=new CarrierMapCell(p_carrier,m_data.Enemies[i]);
			}
			if(m_data.status==1)
			{
				setSelfTransportInfo();
			}
			
			setPlunderNum();
			var p_carrier:TransportDotCellUI=this.view.getChildByName("DotCell"+m_selfNum) as TransportDotCellUI;
			m_oldX=488;
			m_oldY=216;
			setTransport();
			
			if(m_data.status==1)
			{
				if(m_data.endTime-m_data.nowTime>0)
				{
					this.timer.loop(1000,this,updateTime);
				}
				else
				{
					if(m_RewardTips==false)
					{
						m_data.nowTime=m_data.endTime+1;
						//this.view.PlunderTips.visible=true;
						m_selectData=m_selfData;
						m_selfData.nowTime=m_data.endTime;
						//m_plunderTips=new PlunderTipsView(view.PlunderTips,m_selfData);
						if(m_isOpenWin==true)
						{
							XFacade.instance.openModule(ModuleName.PlunderTipsView,m_selfData);
							m_RewardTips=true;
						}
					}
				}
			}
			else
			{
				this.timer.loop(1000,this,updateOtherTime);
			}
		}		
		
		private function updateOtherTime():void
		{
			// TODO Auto Generated method stub
			m_data.nowTime++;
			setTransport();
		}
		
		/**
		 *倒计时 
		 * @return 
		 */
		private function updateTime()
		{
			m_data.nowTime++;
			if((m_data.endTime-m_data.nowTime)>0)
			{
				
				var l_time:Number=m_data.endTime-m_data.nowTime;
				var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+m_selfNum)as TransportDotCellUI;
				m_cell.setTime(l_time);
				setTransport();
			}
			else
			{
				m_cell.setTime(0);
				setTransport();
				if(m_RewardTips==false)
				{
					m_data.nowTime=m_data.endTime+1;
					m_selectData=m_selfData;
					m_selfData.nowTime=m_data.endTime;
					if(m_isOpenWin==true)
					{
						XFacade.instance.openModule(ModuleName.PlunderTipsView,m_selfData);
						m_RewardTips=true;
					}
				}
				if(m_plunderTips!=null)
				{
					m_plunderTips.setTime();
				}
			}
		}
		
		/**
		 * 
		 */
		public function setSelfTransportInfo():void
		{
			for (var i:int = 0; i < 12; i++) 
			{
				if(m_randomList[i]==null)
				{
					m_selfNum=i;
					var p_ui:TransportCellUI=this.view.getChildByName("Transport"+i)as TransportCellUI;
					var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+i)as TransportDotCellUI;
					var p_carrier:CarrierMapCellUI=this.view.getChildByName("Carrier_"+i) as CarrierMapCellUI;
					var p_uiLine:Image=this.view.getChildByName("Line"+i)as Image;
					p_uiLine.skin="relic/reliline_2.png";
					m_selfData=new EnemieVo();
					p_ui.visible=p_uiDot.visible=p_uiLine.visible=p_carrier.visible=true;
					m_selfData.Uid=GlobalRoleDataManger.instance.user.uid
					m_selfData.userName=GlobalRoleDataManger.instance.user.name;
					m_selfData.userLevel=GlobalRoleDataManger.instance.user.level;
					m_selfData.getItem=m_data.rewards;
					m_selfData.Plan=m_data.PlanId;
					m_selfData.Vehicle=m_data.VehicleId;
					m_selfData.startTime=m_data.startTime;
					m_selfData.nowTime=m_data.nowTime;
					m_selfData.endTime=m_data.endTime;
					m_selfData.lostItems=m_data.lostItems;
					m_selfData.plunderTimes=m_data.plunderTimes;
					m_selfData.totalPower = m_data.totalPower;
					m_selfData.vipItems = m_data.vipRewards;
					m_selfData.isSelf=true;
					//var l_cell:TransportCell=new TransportCell(p_ui,m_selfData);
					m_cell=new TransportDotCell(p_uiDot,m_selfData);
					var l_carrierCell:CarrierMapCell=new CarrierMapCell(p_carrier,m_selfData);
					return;
				}
			}
			setTransport();
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			this.on(Event.CLICK,this,onClickHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTRANMAP),this,onResult,[ServiceConst.TRAN_ENTERTRANMAP]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYPLUNDERTIME),this,onResult,[ServiceConst.TRAN_BUYPLUNDERTIME]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTPLUNDER),this,onResult,[ServiceConst.TRAN_SELECTPLUNDER]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_STARPLUNDER),this,onResult,[ServiceConst.TRAN_STARPLUNDER]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETREWARD),this,onResult,[ServiceConst.TRAN_GETREWARD]);
			Signal.intance.on(TrainBattleLogEvent.PLUNDERBTN_EVENT_CLICK,this,onPlunderHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,closeHandler);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_BATTLELOG,this,onBattleLogHandler);
		}
		
		private function onBattleLogHandler():void
		{
			// TODO Auto Generated method stub
			m_data.isLog=true;
			view.LogDotImage.visible=true;
		}
		
		/**
		 * 掠夺次数
		 */
		private function setPlunderNum():void
		{
			this.view.NumText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_33003"),m_data.fightTimes);
		}
		
		/**
		 * 
		 */
		private function setTransport():void
		{
			for (var i:int = 0; i < 12; i++) 
			{
				if(m_randomList[i]!=null&&i!=m_selfNum)
				{
					var p_ui:TransportCellUI=this.view.getChildByName("Transport"+i)as TransportCellUI;
					var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+i)as TransportDotCellUI;
					var p_carrier:CarrierMapCellUI=this.view.getChildByName("Carrier_"+i) as CarrierMapCellUI;
					//trace("i "+i+"  "+"m_randomList[i] "+m_randomList[i]);
					var l_EnemieVo:EnemieVo=m_data.Enemies[m_randomList[i]];
					if(l_EnemieVo!=null)
					{
						var l_maxTime:Number=l_EnemieVo.endTime-l_EnemieVo.startTime;
						var l_time:Number=l_EnemieVo.endTime-m_data.nowTime;
						var l_nowTime:Number=m_data.nowTime-l_EnemieVo.startTime;
						var l_time1:Number=l_maxTime/2;
						var l_type:int;
						if(l_maxTime>l_nowTime&&l_time1>=l_nowTime)
						{
							l_type=1;
						}
						else
						{
							l_type=2;
						}
						var l_n:Number;
						
						if(l_type==1)
						{
							l_n=(l_nowTime)/l_time1;
						}
						else
						{
							l_n=(l_nowTime-l_time1)/l_time1;
						}
						if(l_n<0)
						{
							l_n=0;	
						}
						if(l_n>=1)
						{
							l_n=1;
						}
						if(l_type==1)
						{
							p_carrier.x=(m_oldXList[i]+(p_ui.x-m_oldXList[i])*l_n);
							p_carrier.y=(m_oldYList[i]+(p_ui.y-m_oldYList[i])*l_n);
						}
						else
						{
							p_carrier.x=(p_ui.x+(m_oldXList[i]-p_ui.x)*l_n);
							p_carrier.y=(p_ui.y+(m_oldYList[i]-p_ui.y)*l_n);
						}	
					}
				}
			}
			var p_ui:TransportCellUI=this.view.getChildByName("Transport"+m_selfNum)as TransportCellUI;
			var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+m_selfNum)as TransportDotCellUI;
			var p_carrier:CarrierMapCellUI=this.view.getChildByName("Carrier_"+m_selfNum) as CarrierMapCellUI;
			var l_maxTime:Number=m_data.endTime-m_data.startTime;
			var l_time:Number=m_data.endTime-m_data.nowTime;
			var l_nowTime:Number=m_data.nowTime-m_data.startTime;
			var l_time1:Number=l_maxTime/2;
			var l_type:int;
			if(l_maxTime>l_nowTime&&l_time1>=l_nowTime)
			{
				l_type=1;
			}
			else
			{
				l_type=2;
			}
			var l_n:Number;
			
			if(l_type==1)
			{
				l_n=(l_nowTime)/l_time1;
			}
			else
			{
				l_n=(l_nowTime-l_time1)/l_time1;
			}
			if(l_n<0)
			{
				l_n=0;	
			}
			if(l_n>=1)
			{
				l_n=1;
			}
			if(l_type==1)
			{
				p_carrier.x=(m_oldX+(p_ui.x-m_oldX)*l_n);
				p_carrier.y=(m_oldY+(p_ui.y-m_oldY)*l_n);
			}
			else
			{
				p_carrier.x=(p_ui.x+(m_oldX-p_ui.x)*l_n);
				p_carrier.y=(p_ui.y+(m_oldY-p_ui.y)*l_n);
			}
		}
		
		
		/**
		 * 按键事件
		 */
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
				{
					this.close();
					break;
				}
				case this.view.AddBtn:
				{
					for (var i:int = 0; i < GameConfigManager.TransportPriceList.length; i++) 
					{
						var l_vo:TransportPriceVo=GameConfigManager.TransportPriceList[i];
						if((m_data.totalBoughtTimes1)<l_vo.attempts)
						{
							onBuyHandler(4,m_data.totalBoughtTimes1,l_vo);
							return;
						}
					}
					break;
				}
				case this.view.BattleBtn:
					m_isOpenWin=false;
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					this.close();
					break;
				case this.view.LogBtn:
				{
					isgoNextWin=true;
					XFacade.instance.openModule("TrainLogView",m_data);
					close();
					break;
				}
				case this.view.TrainBtn:
				{
					isgoNextWin=true;
					m_data.isAnimation=false;
					XFacade.instance.openModule("EscortMainView",m_data);
					close();
					break;
				}
				case this.view.PlunderBtn:
				{
					
					break;
				}
				default:
				{
					if(e.target.name.indexOf("Carrier_")!=-1)
					{
						var l_str:String=e.target.name;
						var l_arr:Array=l_str.split("_");
						if(m_selfNum!=l_arr[1])
						{
							m_selectData=m_data.Enemies[m_randomList[l_arr[1]]];
							m_selectData.nowTime=m_data.nowTime;
							XFacade.instance.openModule(ModuleName.PlunderTipsView,m_selectData);
						}
						else
						{
							m_selfData.nowTime=m_data.nowTime;
							m_selectData=m_selfData;
							XFacade.instance.openModule(ModuleName.PlunderTipsView,m_selfData);
						}
					}
					if(e.target.name.indexOf("RewardImage_")!=-1)
					{
						var l_str:String=e.target.name;
						var l_arr:Array=l_str.split("_");
						var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[1]];
						ItemTips.showTip(itemvo.id);
					}
					break;
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
		
		private function fightHander():void
		{
			// TODO Auto Generated method stub
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETTRANSPORTTYPE,[]);
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
			this.off(Event.CLICK,this,onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_ENTERTRANMAP),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_BUYPLUNDERTIME),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_SELECTPLUNDER),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_STARPLUNDER),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETREWARD),this,onResult);
			Signal.intance.off(TrainBattleLogEvent.PLUNDERBTN_EVENT_CLICK,this,onPlunderHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,closeHandler);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_BATTLELOG,this,onBattleLogHandler);
			this.timer.clearAll(this);
		}
		
		private function onPlunderHandler(p_data:EnemieVo):void
		{
			// TODO Auto Generated method stub
			if(m_data.fightTimes>0)
			{
				FightingManager.intance.getSquad(7,m_selectData.Uid,Handler.create(this,fightHander));
				XFacade.instance.closeModule(PlunderTipsView);
			}
			else
			{
				for (var i:int = 0; i < GameConfigManager.TransportPriceList.length; i++) 
				{
					var l_vo:TransportPriceVo=GameConfigManager.TransportPriceList[i];
					if((m_data.totalBoughtTimes1+1)<l_vo.attempts)
					{
						onBuyHandler(4,m_data.plunderTimes+1,l_vo);
						return;
					}
				}
			}
		}
		
		private function onResult(cmd:int,...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
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
					m_data.totalBoughtTimes1 = l_info.totalBoughtTimes1;
					m_data.vipRewards = l_info.vipRewards;
					
					if(l_info.totalPower!=null)
					{
						m_data.totalPower=l_info.totalPower;
					}
					m_data.setEnemieList(l_info.enemies);
					initUI();
					break;
				}
				case ServiceConst.TRAN_BUYPLUNDERTIME:
				{
					XTip.showTip(GameLanguage.getLangByKey("L_A_68"));
					m_data.fightTimes++;
					setPlunderNum();
					m_data.totalBoughtTimes1 ++;
					break;
				}
				case ServiceConst.TRAN_SELECTPLUNDER:
				{	
					break;
				}
				case ServiceConst.TRAN_STARPLUNDER:
				{
					break;
				}
				case ServiceConst.TRAN_GETREWARD:
				{
					var l_obj:Array=args[1];
					var l_arr:Array=new Array();
					for(var i:int=0;i<l_obj.length;i++)
					{
						var l_vo:ItemData=new ItemData();
						l_vo.iid=l_obj[i].id;
						l_vo.inum=l_obj[i].num;
						l_arr.push(l_vo);
					}
					closeHandler();
					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[l_arr]);
					break;
				}
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function closeHandler()
		{
			var p_ui:TransportCellUI=this.view.getChildByName("Transport"+m_selfNum)as TransportCellUI;
			var p_uiDot:TransportDotCellUI=this.view.getChildByName("DotCell"+m_selfNum)as TransportDotCellUI;
			var p_carrier:CarrierMapCellUI=this.view.getChildByName("Carrier_"+m_selfNum) as CarrierMapCellUI;
			var p_uiLine:Image=this.view.getChildByName("Line"+m_selfNum)as Image;
			p_ui.visible=p_uiDot.visible=p_uiLine.visible=p_carrier.visible=false;
			m_data.status=0;
//			XFacade.instance.openModule("EscortMainView",m_data);
//			this.close();
		}
		
		override public function dispose():void
		{
			if(isgoNextWin==false)
			{
				super.dispose();
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
		
		
		private function get view():PlunderMainViewUI{
			return _view;
		}
	}
}