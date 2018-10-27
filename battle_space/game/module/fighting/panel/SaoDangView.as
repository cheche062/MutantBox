package game.module.fighting.panel
{
	import MornUI.fightingChapter.ShaoDangViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.StageLevelVo;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class SaoDangView extends BaseDialog
	{
		private var _rList:RewardList;
		private var vo:StageLevelVo;
		private var adHander:Handler;
		private var _sType:Number = 0;
		
		public function SaoDangView()
		{
			super();
			closeOnBlank = true;
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			_rList.array = ar[0];
			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
			vo = ar[1];
			view.xhLbl1.text = String( (vo.stageCost[0] as ItemData).inum );
			view.xhLbl2.text = String( (vo.stageCost[0] as ItemData).inum * 5 );
			bindNum(ar[2]);
			adHander = ar[3];
			_sType = ar[4];
			
			//UIRegisteredMgr.AddUI(view.btn2,"SweepFiveBtn");
		} 
		
		public function bindNum(num:Number):void
		{
			view.btn1.disabled = num < 1;
			view.btn2.disabled = num < 5;
			view.numLbl.text = num;
		}
		
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
			adHander = null;
			//UIRegisteredMgr.DelUi("SweepFiveBtn");
		}
		
		
		public function get view():ShaoDangViewUI{
			if(!_view){
				_view = new ShaoDangViewUI();
			}
			return _view as ShaoDangViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			view.rBox.addChild(_rList);
			
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.btn1.on(Event.CLICK,this,saodangFun);
			view.btn2.on(Event.CLICK,this,saodangFun);
			view.addBtn.on(Event.CLICK,this,addClick);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.btn1.off(Event.CLICK,this,saodangFun);
			view.btn2.off(Event.CLICK,this,saodangFun);
			view.addBtn.off(Event.CLICK,this,addClick);
		}
		
		private  function addClick(e:Event = null):void
		{
			if(adHander)
			{
				adHander.runWith(e);
			}
		}
		
		private function saodangFun(e:Event):void{
			var nm:Number = 1;
			if(e.target == view.btn2)
				nm = 5;
			var ar:Array = [];
			for (var i:int = 0; i < vo.stageCost.length; i++) 
			{
				var itemD:ItemData = vo.stageCost[i];
				var itemD2:ItemData = new ItemData();
				itemD2.iid = itemD.iid;
				itemD2.inum = itemD.inum * nm;
				ar.push(itemD2);
			}
			
			FightingManager.intance.saoDangStage(ar,nm,vo.id,_sType);
			this.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy SaoDangView");
			_rList = null;
			vo = null;
			adHander = null;
			super.destroy(destroyChild);
		}
		
	}
}