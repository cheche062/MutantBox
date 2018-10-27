package game.module.pvp
{
	import MornUI.pvpFight.pvpLogViewUI;
	
	import game.common.AnimationUtil;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.GlobalRoleDataManger;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.PvpLevelVo;
	import game.module.pvp.cell.PvpLogCell;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class pvpLogPanel extends BaseDialog
	{
		public function pvpLogPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		
		public function get view():pvpLogViewUI{
			if(!_view)
				_view = new pvpLogViewUI();
			return _view as pvpLogViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			
			
			view.logList.repeatX = 1;
			view.logList.repeatY = 5;
			view.logList.itemRender = PvpLogCell;
			//			view.shopList.spaceX = 3;
			view.logList.spaceY = 10;
			view.logList.array = [];
			view.logList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			view.logList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			
			var fightTimes:Number = Number(PvpManager.intance.userInfo.fightTimes);
			var winTimes:Number = Number(PvpManager.intance.userInfo.winTimes);
			view.maxFNumLbl.text = fightTimes;
			view.winLbl.text =  winTimes;
			view.loseLbl.text =  fightTimes - winTimes;
			if(fightTimes && winTimes)
				view.shenglvLbl.text = Math.ceil(winTimes / fightTimes * 100) + "%";
			else
				view.shenglvLbl.text = "0%";
//			view.nameLbl.text = GlobalRoleDataManger.instance.user.name;
			var levelVo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
				Number(PvpManager.intance.userInfo.integral)
			);
			if(levelVo)
			{
				view.levelLbl.text = levelVo.name;
				view.rankeFace.skin = levelVo.rankIcon;
				view.nameLbl.text = GlobalRoleDataManger.instance.user.name;
			}
			else
				view.levelLbl.text = "--";
			view.pointLbl.text= PvpManager.intance.userInfo.integral;
			
			WebSocketNetService.instance.sendData(ServiceConst.getEventLog,[1,"dfzb"]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.getEventLog),this,onResult);
		}
		
		private function onResult(...args):void
		{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,onResult);
			var ar:Array = [];
			var ar2:Array = args[1];
			for (var i:int = 0; i < ar2.length; i++) 
			{
				ar.push(JSON.parse(ar2[i]));
			}
			
			view.logList.array = ar;
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
		}
		
	}
}