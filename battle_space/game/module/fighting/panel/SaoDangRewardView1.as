package game.module.fighting.panel
{
	import MornUI.fightingChapter.SaoDangRewardViewUI;
	import MornUI.fightingChapter.ShaoDangViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.UIHelp;
	import game.common.base.BaseDialog;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.module.bag.cell.needItemCell;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class SaoDangRewardView1 extends BaseDialog
	{
		
		private var _rList:RewardList;
		private var _levelId:Number;
		private var _fightNum:Number;
		private var _needAr:Array;
		private var _sType:Number;
		protected var needCell:needItemCell;
		
		public function SaoDangRewardView1()
		{
			super();
			closeOnBlank = true;
		}
		
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			_levelId = Number(ar[0]);
			_fightNum = Number(ar[1]);
			_rList.array = ar[2];
			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
			_needAr = ar[3];
			_sType = ar[4];
			needCell.data = _needAr[0];
			UIHelp.crossLayout(view.needBox);
			view.needBox.x = view.nBox.width - view.needBox.width >> 1;
			
			view.zaiciSaoDang.disabled = _fightNum <= 0;
		} 
		
		public function get view():SaoDangRewardViewUI{
			if(!_view){
				_view = new SaoDangRewardViewUI();
			}
			return _view as SaoDangRewardViewUI;
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
			
			needCell = new needItemCell();
			view.needBox.addChild(needCell);
		}
		
		
		public override function addEvent():void{
			super.addEvent();
			view.close2.on(Event.CLICK,this,close);
			view.closeBtn.on(Event.CLICK,this,close);
			view.zaiciSaoDang.on(Event.CLICK,this,saodangFun);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.close2.off(Event.CLICK,this,close);
			view.zaiciSaoDang.off(Event.CLICK,this,saodangFun);
		}
		
		private function saodangFun(e:Event):void{
			FightingManager.intance.saoDangStage(_needAr,1,_levelId,_sType);
			this.close();
		}
		
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_rList = null;
			_needAr = null;
			needCell = null;
			super.destroy(destroyChild);
		}
		
	}
}