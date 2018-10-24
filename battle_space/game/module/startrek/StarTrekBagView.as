package game.module.startrek
{
	import MornUI.startrek.StarTrekBagViewUI;

	import game.common.LayerManager;
	import game.common.base.BaseView;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;

	import laya.events.Event;
	import laya.ui.Box;

	/**
	 * 星际迷航背包
	 * @author douchaoyang
	 *
	 */
	public class StarTrekBagView extends BaseView
	{
		private var _maskBg:Box;

		public function StarTrekBagView()
		{
			super();
			this._m_iLayerType=LayerManager.M_POP;
		}

		override public function show(... args):void
		{
			super.show();
			if (!maskBg.displayedInStage)
			{
				this.parent.addChildAt(maskBg, this.parent.getChildIndex(this));
				maskBg.alpha=0;
			}
			maskBg.size(Laya.stage.width, Laya.stage.height);
			maskBg.graphics.clear();
			maskBg.graphics.drawRect(0, 0, Laya.stage.width, Laya.stage.height, "#000000");
			onResultHandler(args[0]);
		}

		override public function close():void
		{
			super.close();
			maskBg.removeSelf();
			view.itemList.array=[];
		}

		override public function addEvent():void
		{
			maskBg.on(Event.CLICK, this, this.close);
			Laya.stage.on(Event.RESIZE, this, this.setMaskHandler);
			super.addEvent();
		}

		override public function removeEvent():void
		{
			maskBg.off(Event.CLICK, this, this.close);
			Laya.stage.on(Event.RESIZE, this, this.setMaskHandler);
			super.removeEvent();
		}

		private function onResultHandler(data:Object):void
		{
			var arr:Array=[];
			var item:ItemData;
			for (var attr in data)
			{
				item=new ItemData();
				item.iid=attr;
				item.inum=data[attr];
				arr.push(item);
			}
			// 策划说非要3*3
			arr.length=(arr.length < 9 ? 9 : arr.length);
			view.itemList.array=arr;
			view.itemList.repeatX=Math.ceil(Math.sqrt(arr.length)) || 1;
			view.itemList.repeatY=Math.ceil(arr.length / view.itemList.repeatX) || 1;
			view.itemList.width=view.itemList.repeatX * (ItemCell.itemWidth + view.itemList.spaceX);
			view.itemList.height=view.itemList.repeatY * (ItemCell.itemHeight + view.itemList.spaceY);
			view.width=view.mainBg.width=(view.itemList.width + 30);
			view.height=view.mainBg.height=(view.itemList.height + 30);

			this.x=view.stage.mouseX - view.width - 20;
			this.y=(Laya.stage.height - view.height) / 2;
		}

		override public function createUI():void
		{
			this._view=new StarTrekBagViewUI();
			this.addChild(this._view);

			view.itemList.itemRender=ItemCell;
		}

		private function get view():StarTrekBagViewUI
		{
			return _view as StarTrekBagViewUI;
		}

		private function setMaskHandler():void
		{
			maskBg.size(Laya.stage.width, Laya.stage.height);
			maskBg.graphics.clear();
			maskBg.graphics.drawRect(0, 0, Laya.stage.width, Laya.stage.height, "#000000");
		}

		private function get maskBg():Box
		{
			if (!this._maskBg)
			{
				this._maskBg=new Box();
				this._maskBg.mouseEnabled=true;
			}
			return this._maskBg;
		}
	}
}
