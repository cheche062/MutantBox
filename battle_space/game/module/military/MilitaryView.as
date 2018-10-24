package game.module.military
{
	import MornUI.military.MilitaryViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.ItemTips;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.DBMilitary;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.mainui.MainMenuView;
	import game.module.replay.ReplayView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	
	/**
	 * MilitaryView 军衔系统
	 * author:huhaiming
	 * MilitaryView.as 2017-4-28 上午11:11:20
	 * version 1.0
	 *
	 */
	public class MilitaryView extends BaseDialog
	{
		private var _mainCom:MainCom;
		private var _rankCom:RankCom;
		private var _defCom:DefendCom;
		private var _infoCom:MilitaryCom;
		private var _rewardCom:Rewardcom
		private var _selectedView:IMilitaryCom;
		private var _redDot:Image;
		/**记录数buff到期时间,理论上需要一个数据来支撑*/
		public static var buy_buff_time:Number
		/**tab 序列*/
		private static const ATTACK:int = 0;
		private static const DEFEND:int = 1;
		private static const INFO:int = 2;
		private static const RANK:int = 3;
		private static const REWARD:int = 4;
		/**打开时带的参数*/
		private var _exData:Object;
		/**数据存储*/
		public static var data:Object;
		/**关闭--*/
		public static const CLOSE:String = "M_CLOSE";
		/**更新*/
		public static const UPDATE:String = "M_UPDATE"
		public function MilitaryView()
		{
			super();
		}
		
		private function onResult(...args):void{
			data = args[1];
			buy_buff_time = args[1].base_rob_info.buy_buff_time;
			
			if(_exData && _exData[0]){
				_selectedView = _mainCom;
				XFacade.instance.openModule("ReplayView", ReplayView.T_DEFEND);
			}
			_redDot.visible = _rewardCom.check();
			this._selectedView && this._selectedView.show();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				default:
					if(e.target.name == "dbIcon"){
						ItemTips.showTip(DBItem.DB);
					}else if(e.target.name == "kpiIcon"){
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_737"));
					}
					break;
			}
		}
		
		private function onChange(e:Event):void{
			switch(view.tab.selectedIndex){
				case ATTACK:
					this.selectedView = _mainCom;
					break;
				case DEFEND:
					this.selectedView = _defCom;
					break;
				case INFO:
					if(DefendCom.onShow){
						this.selectedView = _defCom;
					}else{
						this.selectedView = _infoCom;
					}
					break;
				case RANK:
					this.selectedView = _rankCom;
					break;
				case REWARD:
					this.selectedView = _rewardCom;
					break;
			}
		}
		
		private function update():void{
			_redDot.visible = _rewardCom.check();
		}
		
		override public function show(...args):void{
			_exData = args;
			super.show();
			if (!User.getInstance().isInGuilding)
			{
				AnimationUtil.flowIn(this);
			}
			
			WebSocketNetService.instance.sendData(ServiceConst.IN_INFO, null);
			
			var vo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 1);
			this.view.icon.skin = "appRes\\icon\\military\\"+vo.icon+".png";
			this.view.icon2.skin = "appRes\\icon\\military\\"+vo.icon+".png";
		}
		
		override public function close():void{
			_exData = null;
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function dispose():void{
			Laya.loader.clearRes("military/bg7.png");
			Laya.loader.clearRes("military/bg12.png");
			Laya.loader.clearRes("military/bg8.png");
			Laya.loader.clearRes("military/bg12_1.png");
			Laya.loader.clearRes("military/bg12_2.png");
			Laya.loader.clearRes("military/bar_1.png");
			Laya.loader.clearRes("military/bar_2.png");
			super.dispose();
		}
		
		override public function createUI():void{
			this._view  = new MilitaryViewUI();
			this.addChild(_view);
			_mainCom = new MainCom(view.attackBox, view);
			_infoCom = new MilitaryCom(view.infoBox, view);
			_rankCom = new RankCom(view.rankBox, view);
			_defCom = new DefendCom(view.defendBox, view);
			_rewardCom = new Rewardcom(view.rewardBox, view)
			_infoCom.close();
			this._rankCom.close();
			this._defCom.close();
			_rewardCom.close();
			
			_redDot = new Image("common/redot.png");
			_redDot.visible = false;
			this.view.tab.items[4].addChild(_redDot);
			
			var btns:Array = view.tab.items;
			for(var i:int=0; i<btns.length; i++){
				Button(btns[i]).labelFont = XFacade.FT_BigNoodleToo;
			}
			
			this.selectedView = _mainCom;
			this.closeOnBlank = true;
			this.cacheAsBitmap = true;
		}
		
		private function set selectedView(v:IMilitaryCom):void{
			if(_selectedView){
				this._selectedView.close();
			}
			this._selectedView = v;
			if(this._selectedView){
				this._selectedView.show();
			}
		}
		
		private function get selectedView():IMilitaryCom{
			return this._selectedView;
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.tab.on(Event.CHANGE, this, this.onChange);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_INFO), this, onResult);
			
			Signal.intance.on(CLOSE, this, this.close);
			Signal.intance.on(UPDATE, this, this.update);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("MilitaryAtkBtn");
			super.destroy(destroyChild);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.tab.off(Event.CHANGE, this, this.onChange);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_INFO), this, onResult);
			
			Signal.intance.off(CLOSE, this, this.close);
			Signal.intance.off(UPDATE, this, this.update);
		}
		
		private function get view():MilitaryViewUI{
			return this._view as MilitaryViewUI;
		}
		
		
		/**对外统一处理领取奖励---------------------*/
		public static function getDailyReward(target:*=null, callback:Function=null):void{
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.Get_Military_Reward),null,onGetReward);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),null,onErr);
			WebSocketNetService.instance.sendData(ServiceConst.Get_Military_Reward,null);
			
			function onGetReward(...args):void{
				Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),null,onErr);
				User.getInstance().day_box_reward = false;
				User.getInstance().event();
				
				var ar:Array=[];
				var list:Array=args[1];
				var len:int=list.length;
				for (var i:int=0; i < len; i++)
				{
					var itemD:ItemData=new ItemData();
					itemD.iid=list[i][0];
					itemD.inum=list[i][1];
					ar.push(itemD);
				}
				XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
				
				if(callback){
					callback.apply(target);
				}
			}
			
			
			function onErr(...args):void{
				var cmd:Number = args[1];
				var errStr:String = args[2];
				switch(cmd){
					case ServiceConst.Get_Military_Reward:
						Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.Get_Military_Reward),null,onGetReward);
						Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),null,onErr);
						XTip.showTip( GameLanguage.getLangByKey(errStr));
						break;
				}
			}
		}
	}
}