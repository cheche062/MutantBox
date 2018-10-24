/***
 *作者：罗维
 */
package game.global.data.bag
{
	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.module.bag.cell.BaseItemCell;
	import game.module.tips.itemTip.ItemTipManager;
	import game.module.tips.itemTip.base.BaseItemTip;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	public class ItemCell extends BaseItemCell
	{
		
		public static const itemWidth:Number = 79;
		public static const itemHeight:Number = 79;
		
		
		protected var _selectEff:Animation;
		//
		protected var _bg:Image;
		//颜色标志
		protected var _flag:Image;
		
		public function ItemCell()
		{
			super();
			size(itemWidth,itemHeight);
			showTip = true;
		}
		
		public function get selectEff():Animation
		{
			if(!_selectEff)
			{
				_selectEff = new Animation();
				_selectEff.autoPlay = true;
				_selectEff.mouseEnabled = _selectEff.mouseThrough = false;
				var jsonStr:String = "appRes/effects/bag_select.json";
				_selectEff.loadAtlas(jsonStr);
//				_selectEff.name = "selectBox";
				_selectEff.interval = 100;
				addChild(_selectEff);
				_selectEff.x = itemWidth - 100 >> 1;
				_selectEff.y = itemHeight - 100 >> 1;
			}
			return _selectEff;
		}

		public override function bindNum():void{
			_itemNumLal.text = data.inum <= 1 ? "" : String(XUtils.formatResWith(data.inum));
//			if(data.inum<=0)
//			{
//				_itemIcon.gray=true;
//			}
//			else
//			{
//				_itemIcon.gray=false;
//			} 
//			_itemNumLal.text = 9999;
		}
		
		public override function bindIcon():void{
			_itemIcon.graphics.clear();
			
			if(this.data && !this.data.vo)
			{
				trace("找不到道具"+data.iid);
				return ;
			}
			
//			var url:String = "appRes/icon/itemIcon/"+this.data.vo.icon+".png"
			var url:String = GameConfigManager.getItemImgPath(this.data.iid);
			
			_itemIcon.loadImage(url, 0,0,0,0/*,Handler.create(this, this.onLoaded)*/);
			//Laya.loader.on(Event.ERROR, this, this.onErr);
		}
		
		/*private function onLoaded():void{
			Laya.loader.off(Event.ERROR, this, this.onErr);
		}
		private function onErr(e:*):void{
			_itemIcon.skin = "bag\/0.png";
			Laya.loader.off(Event.ERROR, this, this.onErr);
		}*/
		
		override public function set data(value:ItemData):void{
//			selectEff;
			super.data = value;
			if(value && value.vo){
				this._bg.skin = "common/item_bg0.png";
				this._flag.skin = "common/item_bar"+(value.vo.quality-1)+".png";
//				selected = value.select
			}else{
				this._bg.skin = "common/item_bg0.png";
				this._flag.skin = "";
//				selected = false;
			}
		}
		
		
		public override function set selected(value:Boolean):void{
			super.selected = value;
			//trace("selected========================================");
			if(value)
			{
				selectEff.visible = value;
				
				//测试
				
//				var tipCp:BaseItemTip = ItemTipManager.getTips(this.data,this.data);
				
				//测试
			}
			else
			{
				if(_selectEff)
					selectEff.visible = value;
			}
		}
		
		public function setShader(p_isGray:Boolean=true):void
		{
			_itemIcon.filters=[];
			_itemIcon.gray=p_isGray;
			
		}
		
		
		protected override function init():void
		{
			this._bg = new Image();
			this._bg.skin = "common/item_bg0.png";
			this.addChild(this._bg);
			_flag = new Image();
			this._flag.skin = "";
			this.addChild(this._flag);
			this._flag.pos(0,0);
			
			_itemIcon = new Image();
			this.addChild(_itemIcon);
			_itemIcon.pos(-10,-10);
			
			
			_itemNumLal = new Label();
			this.addChild(_itemNumLal);
			_itemNumLal.font = XFacade.FT_Futura;
			_itemNumLal.color = "#ffffff";
			_itemNumLal.fontSize = 18;
			_itemNumLal.width = 60;
			_itemNumLal.align = "right";
			_itemNumLal.stroke = 1;
			_itemNumLal.pos(8,53);
			
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			//trace(1,"destroy ItemCell");
			_selectEff = null;
			_bg = null;
			_flag = null;
			
			super.destroy(destroyChild);
		}
		
	}
}