package game.module.fighting.panel
{
	import MornUI.fightingChapter.SaoDangRewardView2UI;
	import MornUI.fightingChapter.SaoDangRewardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.ModuleName;
	import game.global.data.bag.ItemCell;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.cell.SaoDangRewardCell;
	
	import laya.events.Event;
	
	public class SaoDangRewardView2 extends BaseDialog
	{
		
		private var allItem:Array = [];
		
		public function SaoDangRewardView2()
		{
			super();
			closeOnBlank = true;
		}
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			allItem = [];
			
			var ar:Array = args[0][0];
			var ar2:Array = [];
			for (var i:int = 0; i < ar.length; i++) 
			{
//				ar[i] = ItemManager.StringToReward("1=100;2=105;2=105");
				ar2.push([i+1 , ar[i] , true]);
				ItemManager.merge(allItem,ar[i]);
			}
		
			view.list1.array = [];
			additem(ar2);
		} 
	
		
		public function additem(ar:Array):void
		{
			if(!bg || !bg.parent)
				return ;
			view.list1.mouseEnabled = false;
			var d:* = ar.shift();
			view.list1.addItem(d);
			
			if(view.list1.scrollBar)
				view.list1.scrollBar.value = view.list1.scrollBar.max;
			
			if(ar.length)
				timer.once(1000,this,additem,[ar]);
			else
				timer.once(1000,this,function(){
					view.list1.mouseEnabled = true;
				});
		}
		
		
		
		
		public function get view():SaoDangRewardView2UI{
			if(!_view){
				_view = new SaoDangRewardView2UI();
			}
			return _view as SaoDangRewardView2UI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			
			view.list1.itemRender = SaoDangRewardCell;
			view.list1.scrollBar.sizeGrid = "6,0,6,0";
			view.list1.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			view.list1.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
		}
		
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,closeFun);
			view.close2.on(Event.CLICK,this,close);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,closeFun);
			view.close2.off(Event.CLICK,this,close);
		}
		
		public function closeFun():void
		{
			if(allItem)
			{
				XFacade.instance.openModule(ModuleName.ShowRewardPanel,[allItem]);
				allItem = null;
			}
			this.close();
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy SaoDangRewardView2");
			allItem = null;
			
			super.destroy(destroyChild);
		}
		
	}
}