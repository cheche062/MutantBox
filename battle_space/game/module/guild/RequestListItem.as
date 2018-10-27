package game.module.guild
{
	import MornUI.guild.GuildGoodItemUI;
	import MornUI.guild.RequireListItemUI;
	
	import laya.display.Sprite;
	import laya.ui.Box;
	
	public class RequestListItem extends Box
	{
		private var itemMC:RequireListItemUI;
		private var _data:Object;
		
		private var _goodImg:Sprite;
		
		public function RequestListItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new RequireListItemUI();
			this.addChild(itemMC);
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			
			if(!data||!data.name)
			{
				return;
			}
			
			if(!_goodImg)
			{
				_goodImg = new Sprite();
				_goodImg.scaleX = _goodImg.scaleY = 0.75;
				_goodImg.x = 185;
				_goodImg.y = -5;
				_goodImg.loadImage("appRes/icon/itemIcon/" + data.item_id + ".png");
				itemMC.addChild(_goodImg);
			}
			_goodImg.loadImage("appRes/icon/itemIcon/" + data.item_id + ".png");
			itemMC.requireNameTF.text = data.name;
			itemMC.holdNumTF.text = "11";
			itemMC.getNumTF.text = data.getted+"/"+data.target;
			
			itemMC.proccessBar.width=108*parseInt(data.getted)/parseInt(data.target);
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():RequireListItemUI{
			return itemMC;
		}
	}
}