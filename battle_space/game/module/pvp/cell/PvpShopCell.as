package game.module.pvp.cell
{
	import MornUI.pvpFight.PvpShopCellUI;
	
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.global.GameLanguage;
	import game.global.data.bag.ItemCell;
	import game.global.vo.pvpShopItemVo;
	import game.module.bag.cell.needItemCell;
	import game.module.pvp.PvpManager;
	
	import laya.events.Event;
	import laya.ui.UIUtils;
	
	public class PvpShopCell extends PvpShopCellUI
	{
		private var itemC:ItemCell = new ItemCell();
		private var needCell:needItemCell ;
		private var _data:pvpShopItemVo;
		
		public function PvpShopCell()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			this.bg.addChild(itemC);
			itemC.pos(p1.x , p1.y);
			p1.removeSelf();
			
			needCell = new needItemCell();
			this.needBox.addChild(needCell);
			var mp3Url = ResourceManager.getSoundUrl('ui_dialog_buy','uiSound');
			this.buyBtn['clickSound'] = mp3Url;
			
			this.buyBtn.on(Event.CLICK,this,thisBuyClick);
		}
		
		private function thisBuyClick(e:Event):void{
			if(_data)
				PvpManager.intance.shopBuy(_data.id);
		}
		
		
	
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			if(_data)
			{
				itemC.dataSource = _data.showItems[0];
//				this.buyNum.text = _data.showCosts[0].inum;
				needCell.data = _data.showCosts[0];
				needCell.x = needBox.width - needCell.width >> 1;
				var sy:Number = _data.num - PvpManager.intance.getShopCountBySid(_data.id);
				if(sy < 0)sy = 0;
				this.buyBtn.label = sy + "/" + _data.num;
				var state:Number = _data.state ;
				this.buyBtn.disabled = state == 0 || state == -1;
				this.bg.filters = _data.state == -2 ? [UIUtils.grayFilter]:null;
				this.errLbl.visible = state == -2;
				this.buyBtn.visible = !this.errLbl.visible;
				if(this.errLbl.visible)
				{
					var s:String = GameLanguage.getLangByKey(_data.lg);
					this.errLbl.text =  s.replace(/##/g, "\n");
				}
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			super.destroy(destroyChild);
			itemC.removeSelf();
			itemC.destroy();
			itemC = null;
			needCell = null;
			this.buyBtn.off(Event.CLICK,this,thisBuyClick);
		}
	}
}