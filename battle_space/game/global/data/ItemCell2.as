package game.global.data
{
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.module.bag.cell.BaseItemCell;
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	public class ItemCell2 extends BaseItemCell
	{
		
		public static const itemWidth:Number = 87;
		public static const itemHeight:Number = 87;
		private var _flag:Image;
		
		public function ItemCell2()
		{
			super();
			size(itemWidth,itemHeight);
			showTip = true;
		}
		
		public override function bindIcon():void{
			_itemIcon.graphics.clear();
//			var url:String = "appRes/icon/itemIcon/"+this.data.vo.icon+".png"
			var url:String = GameConfigManager.getItemImgPath(this.data.iid);
			_itemIcon.loadImage(url, 0,0,0,0,Handler.create(this, this.onLoaded));
			Laya.loader.on(Event.ERROR, this, this.onErr);
		}
		
		private function onLoaded():void{
			Laya.loader.off(Event.ERROR, this, this.onErr);
		}
		private function onErr(e:*):void{
			_itemIcon.skin = "bag\/0.png";
			Laya.loader.off(Event.ERROR, this, this.onErr);
		}
		
		override public function set data(value:ItemData):void{
			super.data = value;
			if(value && value.vo){
				this._flag.skin = "common/i"+(value.vo.quality-1)+".png";
			}else{
				this._flag.skin = "";
			}
		}
		
		
		protected override function init():void
		{
			_flag = new Image();
			this._flag.skin = "";
			this.addChild(this._flag);
			 
			
			_itemIcon = new Image();
			this.addChild(_itemIcon);
			_itemIcon.pos(-6,-6);
		
			_itemNumLal = new Label();
			this.addChild(_itemNumLal);
			_itemNumLal.font = "BigNoodleToo";
			_itemNumLal.color = "#ffffff";
			_itemNumLal.fontSize = 14;
			_itemNumLal.width = itemWidth - 6;
			_itemNumLal.align = "right";
			_itemNumLal.y = itemHeight - 16 - 6;
			_itemNumLal.stroke = 1;
		}
	}
}