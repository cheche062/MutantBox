package game.module.bag
{
	import MornUI.fightingChapter.SaoDangRewardViewUI;
	import MornUI.panels.ShowRewardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	
	import laya.events.Event;
	
	public class ShowRewardPanel extends BaseDialog
	{
		public function ShowRewardPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		/**
		 * 参数1为 物品数组
		 * 参数2为 是否隐藏确认按钮
		 * @param	...args
		 */
		public override function show(...args):void{
			super.show(args);
			//AnimationUtil.popIn(this);
			var ar:Array = args[0];
			var items:Array = ar[0];
			if(!items)
			{
				view.rList.array = [];
				return ;
			}
			view.rList.spaceX = view.rList.spaceY = 10;
			view.rList.repeatY = Math.ceil( items.length / 4);
			if(view.rList.repeatY > 1)
			{
				view.rList.repeatX = 4;
			}else
			{
				view.rList.repeatX = items.length;
			}
			//trace("显示等级奖励数据"+JSON.stringify(args));
			view.rList.array = ar[0];
			
			view.rList.width = (view.rList.repeatX - 1) * (ItemCell.itemWidth + view.rList.spaceX) + ItemCell.itemWidth;
			view.rList.height = (view.rList.repeatY - 1) * (ItemCell.itemHeight + view.rList.spaceY) + ItemCell.itemHeight;
			
			view.rList.pos( view.rBox.width - view.rList.width >> 1, view.rBox.height - view.rList.height >> 1);
			
			view.closeBtn.visible = true;
			if (args[0][1])
			{
				view.closeBtn.visible = false;
			}
		} 
		
		public function get view():ShowRewardViewUI{
			if(!_view){
				_view = new ShowRewardViewUI();
			}
			return _view as ShowRewardViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			view.rList.itemRender = ItemCell;
			view.closeBtn['clickSound'] = ResourceManager.getSoundUrl("ui_collect_resource",'uiSound')
			UIRegisteredMgr.AddUI(view.closeBtn,"CheckItemBtn");
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("CheckItemBtn");
			super.destroy(destroyChild);
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			view.rList.array = [];
			Signal.intance.event(TrainBattleLogEvent.TRAIN_SHOWREWARD);
			super.close();
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