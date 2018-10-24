package game.module.startrek
{
	import MornUI.startrek.StarTrekFinalViewUI;
	
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;

	/**
	 * 星际迷航，格子全部打开后奖励
	 * @author douchaoyang
	 *
	 */
	public class StarTrekFinalView extends BaseDialog
	{
		private var items:Vector.<ItemContainer>=new Vector.<ItemContainer>();

		public function StarTrekFinalView()
		{
			super();
		}

		override public function show(... args):void
		{
			super.show(args);
			if(args[0].passReward){
				view.disTxt.text= GameLanguage.getLangByKey("L_A_76217");
			}else{
				view.disTxt.text= GameLanguage.getLangByKey("L_A_76216");
			}
			
			setRewardHandler(args[0].rewardStr);
			AnimationUtil.popIn(this);
		}

		private function setRewardHandler(str:String)
		{
			if (!str)
			{
				return false;
			}
			var data:Array=str.split(";");
			var len:int=data.length;
			for (var i:int=0; i < len; i++)
			{
				items[i]=items[i] ? items[i] : new ItemContainer();
				view.rewardBox.addChild(items[i]);
				items[i].setData(data[i].split("=")[0], data[i].split("=")[1]);
				items[i].y=0;
				items[i].x=i * 100 + 10;
			}
			view.rewardBox.width=len * 100;
			view.rewardBox.x=(view.width - view.rewardBox.width) / 2;
		}

		override public function close():void
		{
			AnimationUtil.popOut(this, this.onCloseHandler);
		}

		private function onCloseHandler():void
		{
			super.close();
			while (view.rewardBox.numChildren)
			{
				view.rewardBox.removeChildAt(0);
			}
		}

		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
		}

		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
				case view.confirmBtn:
					close();
					break;
				default:
					break;
			}
		}

		override public function createUI():void
		{
			this.closeOnBlank=true;
			this._view=new StarTrekFinalViewUI();
			this.addChild(this._view);
		}

		private function get view():StarTrekFinalViewUI
		{
			return this._view as StarTrekFinalViewUI;
		}
	}
}
