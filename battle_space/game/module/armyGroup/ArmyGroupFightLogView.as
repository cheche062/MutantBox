package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupFightLogViewUI;
	
	import game.common.AnimationUtil;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	
	/**
	 * 战斗记录
	 * @author douchaoyang
	 *
	 */
	public class ArmyGroupFightLogView extends BaseDialog
	{
		// 战争记录渲染数据
		private var fightListArr:Array=[];
		// 个人记录渲染数据
		private var personalListArr:Array=[];
		
		private const GET_WAR_REPORT:int=1;
		private const GET_OWN_REPORT:int = 2;
		
		
		private var _npcHeadVec:Vector.<ArmyNpcHead> = new Vector.<ArmyNpcHead>(6);
		private var _npcItemVec:Vector.<ArmyNpcItem> = new Vector.<ArmyNpcItem>(6);
		
		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>(3);
		
		private var _npcListArr:Array = [];
		private var _diffcultyWord:Array = [0, "L_A_23008", "L_A_23009", "L_A_23010"];
		private var _diffcultyWordColor:Array = [0, "#ffffff", "#00ff00", "#ff0000"];
		private var _timeCount:int = 0;
		
		private var _attackCityID:int = 1;
		
		private var _nextOpenTime:int = 9999999999;
		
		private var _showNPC:Boolean = true;
		
		public function ArmyGroupFightLogView()
		{
			super();
		}
		
		override public function show(... args):void
		{
			super.show(args);
			AnimationUtil.flowIn(this);
			
			_showNPC = args[0];
			// 初始化数据
			view.logCtrl.selectedIndex = 0;
			view.npcCtrl.selectedIndex = 0;
			if (_showNPC)
			{
				initNpcHandler();
			}
			else
			{
				initListHandler();
			}
			
			view.logCtrl.visible = !_showNPC
			view.npcCtrl.visible = _showNPC;
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onCloseHandler);
		}
		
		private function onCloseHandler():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}
		
		
		private function onResultHandler(cmd:int,... args):void
		{
			switch(cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_CITY_REPORT:
					switch (view.logCtrl.selectedIndex)
					{
						case 0:
							// trace("接收到的战争数据是：", args);
							fightListArr=args[1];
							view.fightList.array=fightListArr;
							break;
						case 1:
							// trace("接收到的个人数据是：", args);
							personalListArr=args[1];
							view.personalList.array=personalListArr;
							break;
						default:
							break;
					}
					break;
				case ServiceConst.ARMY_GROUP_NPC_INFO:
					trace("npcInfo", args);
					_npcListArr = args[1].npc_info;
					view.npcOver.visible = false;
					view.titleBar.visible = true;
					//trace("_npcListArr", _npcListArr);
					_nextOpenTime = 9999999999;
					if (_npcListArr.length == 0)
					{
						view.npcOver.visible = true;
						view.titleBar.visible = false;
						view.lbTips_NPC.text = GameLanguage.getLangByKey("L_A_21009");
						_nextOpenTime = args[1].last_time- parseInt(TimeUtil.now / 1000);
						view.nextOpenTxt.visible = true;
					} else {
						var currArr = [];
						for (var i=0; i < _npcListArr.length; i++){
							if(_npcListArr[i].war_time - TimeUtil.nowServerTime<= 60*60*4){
								currArr.push(_npcListArr[i]);
							}
						}
						if(currArr.length == 0){
							view.npcOver.visible = true;
							view.titleBar.visible = false;
							view.lbTips_NPC.text = GameLanguage.getLangByKey("L_A_30604");
							view.nextOpenTxt.visible = false;
						}
						currArr.sort(function(a,b){
							//							var sss = User.getInstance().guildID;
							//							if(a.guild_id == User.getInstance().guildID){
							//								var asa = 1;
							//							}
							//							asa = a.guild_id;
							var a_id = Number(a.guild_id == User.getInstance().guildID);
							var b_id = Number(b.guild_id == User.getInstance().guildID);
							if(a_id > b_id){
								return -1;
							}
							else if(a_id < b_id){
								return 1;
							}
							else{
								return 0;
							}
						});
						view.npcList.array = currArr;
						view.npcList.refresh();
					}
					
					break;
			}
		}
		
		override public function createUI():void
		{
			this._view=new ArmyGroupFightLogViewUI();
			this.addChild(_view);
			this._closeOnBlank=true;
			// 手动设置logCtrl字体
			var btns:*= view.logCtrl.items;
			var i:int = 0;
			for (i=0; i < btns.length; i++)
			{
				Button(btns[i]).labelFont = XFacade.FT_BigNoodleToo;
				Button(btns[i]).width = 245;
			}
			
			btns= view.npcCtrl.items;
			i = 0;
			for (i=0; i < btns.length; i++)
			{
				Button(btns[i]).labelFont = XFacade.FT_BigNoodleToo;
				Button(btns[i]).width = 245;
			}
			
			view.nextOpenTxt.text = "00:00:00";
			view.npcList.itemRender = ArmyGroupNPCItem;
			view.npcList.vScrollBarSkin = "";
			view.npcList.spaceY = 5;
			view.npcList.array = [];
			
			
			// 设置每个列表的渲染项
			view.fightList.itemRender=FightLogListItemAi;
			view.fightList.array = null;
			view.personalList.itemRender=FightLogListItemBi;
			view.personalList.array = null;
			view.fightList.vScrollBarSkin="";
			view.personalList.vScrollBarSkin="";
			
			// 初始化
			view.logCtrl.selectedIndex = 0;
			view.npcCtrl.selectedIndex = 0;
			
			view.npcOver.visible = false;
			
			UIRegisteredMgr.AddUI(view.closeBtn, "AG_lCloseBtn");
		}
		
		private function timeCountHandler():void
		{
			
			_nextOpenTime--;
			if (_nextOpenTime <= 0)
			{
				_nextOpenTime = 0;
				//				WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_NPC_INFO);
			}
			view.nextOpenTxt.text = GameLanguage.getLangByKey("L_A_21010")+" "+TimeUtil.getTimeCountDownStr(_nextOpenTime, false);
			
		}
		/**
		 * 切换list
		 *
		 */
		private function initListHandler():void
		{
			view.fightList.visible = false;
			view.personalList.visible = false;
			view.npcInfo.visible = false;
			switch (view.logCtrl.selectedIndex)
			{
				case 0:
					// 选择的是战争记录
					view.fightList.visible = true;
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_CITY_REPORT, [GET_WAR_REPORT]);
					break;
				case 1:
					// 选择的是个人记录
					view.personalList.visible = true;
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_CITY_REPORT, [GET_OWN_REPORT]);
					break;
				default:
					break;
			}
		}
		
		/**
		 * 切换list
		 *
		 */
		private function initNpcHandler():void
		{
			view.fightList.visible = false;
			view.personalList.visible = false;
			view.npcInfo.visible = false;
			switch (view.logCtrl.selectedIndex)
			{
				case 0:
					view.npcInfo.visible = true;
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_NPC_INFO);
					break;
				default:
					break;
			}
		}
		
		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					this.close();
					break;
				
				default:
					break;
			}
		}
		
		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
			view.logCtrl.on(Event.CHANGE, this, this.initListHandler);
			view.npcCtrl.on(Event.CHANGE, this, this.initNpcHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_CITY_REPORT), this, this.onResultHandler,[ServiceConst.ARMY_GROUP_GET_CITY_REPORT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_NPC_INFO), this, this.onResultHandler, [ServiceConst.ARMY_GROUP_NPC_INFO]);
			timeCountHandler();
			Laya.timer.loop(1000, this, timeCountHandler);
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
			view.logCtrl.off(Event.CHANGE, this, this.initListHandler);
			view.npcCtrl.off(Event.CHANGE, this, this.initNpcHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_CITY_REPORT), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_NPC_INFO), this, this.onResultHandler);
			
			Laya.timer.clear(this, timeCountHandler);
			
		}
		
		private function get view():ArmyGroupFightLogViewUI
		{
			return _view as ArmyGroupFightLogViewUI;
		}
	}
}
