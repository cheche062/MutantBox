package game.module.relic
{
	import MornUI.relic.PlunderMainViewUI;
	import MornUI.relic.TrainLogViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.EquipEvent;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.relic.TransportBaseInfo;
	import game.module.equip.EquipHeroCell;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class TrainLogView extends BaseDialog
	{
		private var m_cellList:Array;
		private var m_logList:Array;
		private var m_type:int;
		private var isgoNextWin:Boolean;
		private var m_data:TransportBaseInfo;
		public function TrainLogView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new TrainLogViewUI();
			this.addChild(_view);
			this.closeOnBlank=true;
		}
		
		override public function show(...args):void
		{
			super.show(args);
			if(args==null)
			{
				AnimationUtil.flowIn(this);
			}
			
			m_data=args[0];
			initUI();
			m_logList=new Array();
			m_cellList=new Array();
			view.LogPanel.selected=true;
			view.LogPanel.vScrollBarSkin="";
			
			WebSocketNetService.instance.sendData(ServiceConst.getEventLog,[1,"transport"]);
		}
		
		private function initUI():void
		{
			view.AttackBtn.selected=true;
			view.DefenceBtn.selected=false;
			this.view.LogBtn.selected=true;
			this.view.TitleText.text=GameLanguage.getLangByKey("L_A_603");
			this.view.TrainBtn.text.text=GameLanguage.getLangByKey("L_A_34098");
			this.view.PlunderBtn.text.text=GameLanguage.getLangByKey("L_A_34099");
			this.view.LogBtn.text.text=GameLanguage.getLangByKey("L_A_34106");
			if(m_data.state==3)
			{
				m_type=2;
				view.AttackBtn.selected=false;
				view.DefenceBtn.selected=true;
				WebSocketNetService.instance.sendData(ServiceConst.getEventLog,[2,"transport"]);
			}
			m_data.state=0;
			
			
			clearCell();
		}
		
		private function initLogList():void
		{
			var maxy:int=0;
			for (var i:int = 0; i < m_logList.length; i++) 
			{
				var l_cell:TrainLogCell;
				if((m_cellList.length)>i)
				{
					l_cell=m_cellList[i];
					l_cell.visible=true;
				}
				else
				{
					l_cell=new TrainLogCell();
					view.LogPanel.addChild(l_cell);
					l_cell.dataSource=m_logList[i];
					m_cellList.push(l_cell);
				}
				l_cell.updateInfo(m_logList[i]);
				l_cell.setType(m_type);
				l_cell.y=maxy;
				if(l_cell.isClick==true)
				{
					maxy+=85;	
				}
				else
				{
					maxy+=161;	
				}
			}
			view.LogPanel.refresh();
		}
		
		private function clear():void
		{
			for (var i:int = 0; i < m_cellList.length; i++) 
			{
				var l_cell:TrainLogCell=m_cellList[i];
				l_cell.visible=false;
			}
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		
		override public function addEvent():void
		{
			super.addEvent();
			this.on(Event.CLICK,this,onClickHandler);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_LOG_EVENT_CLICK,this,onSelectHeroCell);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_REPLAY_EVENT_CLICK,this,onReplayHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.getEventLog),this,onResult,[ServiceConst.getEventLog]);
		}
		
		private function onSelectHeroCell():void
		{
			// TODO Auto Generated method stub
			initLogList();
		}
		
		private function onResult(cmd:int,...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.getEventLog:
				{
					m_logList=args[1];
					clear();
					initLogList();
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function createLogCell()
		{
			
		}

		override public function removeEvent():void
		{
			super.removeEvent();
			this.off(Event.CLICK,this,onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.getEventLog),this,onResult);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_LOG_EVENT_CLICK,this,onSelectHeroCell);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_REPLAY_EVENT_CLICK,this,onReplayHandler);
		}
		
		private function onReplayHandler(p_data:Object):void
		{
			// TODO Auto Generated method stub
//			DataLoading.instance.show();
//			clearCell();
			FightingManager.intance.getFightReport([p_data.reportId],null,Handler.create(this,completeReplayHandler),null,ServiceConst.getFightReport);
//			WebSocketNetService.instance.sendData(ServiceConst.getFightReport,[p_data.reportId]);
		}
		
		private function completeReplayHandler():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			timer.once(1000,this,function():void
			{
				WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETTRANSPORTTYPE,[]);
				XFacade.instance.openModule("TrainLogView",1);
			});
		}
		
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case view.AttackBtn:
				{
					m_type=1;
					view.AttackBtn.selected=true;
					view.DefenceBtn.selected=false;
					WebSocketNetService.instance.sendData(ServiceConst.getEventLog,[1,"transport"]);
					break;
				}
				
				case view.DefenceBtn:
				{
					m_type=2;
					view.AttackBtn.selected=false;
					view.DefenceBtn.selected=true;
					WebSocketNetService.instance.sendData(ServiceConst.getEventLog,[2,"transport"]);
					break;
				}
				case view.LogBtn:
				{
					
					
					break;
				}
				case view.PlunderBtn:
				{
					isgoNextWin=true;
					m_data.isAnimation=false;
					XFacade.instance.openModule("PlunderMainView",m_data);
					close();
					break;
				}
				case view.TrainBtn:
				{
					
					isgoNextWin=true;
					m_data.isAnimation=false;
					XFacade.instance.openModule("EscortMainView",m_data);
					close();
					break;
				}
				
				case view.CloseBtn:
				{
					clearCell();
					this.close();
					break;
				}
				case this.view.BattleBtn:
					//XFacade.instance.openModule("LevelUpView");
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					clear();
					this.close();
					break;
				default:
				{
					break;
				}
			}
		}

		private function clearCell():void
		{
			if(m_cellList!=null)
			{
				for (var i:int = 0; i < m_cellList.length; i++) 
				{
					var l_cell:TrainLogCell=m_cellList[i];
					view.LogPanel.removeChild(l_cell);
				}
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
		
		private function get view():TrainLogViewUI{
			return _view;
		}
	}
}