package game.module.tips.itemTip
{
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.module.tips.itemTip.base.BaseItemTipCell;
	
	import laya.display.Stage;
	import laya.ui.Label;
	
	public class ItemTipTileCell extends BaseItemTipCell
	{
		private var itemNameLbl:Label;
		private var equipedLbl:Label;
	
		public function ItemTipTileCell()
		{
			super();
			size(232,50);
		}
		
		
		public override function bindData():void{
			if(!itemNameLbl)
			{
				itemNameLbl = new Label();
				itemNameLbl.font = XFacade.FT_Futura;
				itemNameLbl.fontSize = 18;
				itemNameLbl.color = "#ffffff";
				itemNameLbl.width = width;
				itemNameLbl.align = Stage.ALIGN_CENTER;
				addChild(itemNameLbl);
			}
			if(!equipedLbl)
			{
				equipedLbl = new Label();
				equipedLbl.font = XFacade.FT_Futura;
				equipedLbl.fontSize = 14;
				equipedLbl.color = "#5de590";
				equipedLbl.width = width;
				equipedLbl.align = Stage.ALIGN_CENTER;
				equipedLbl.text = "("+GameLanguage.getLangByKey("L_A_48006")+")";
				equipedLbl.y = 27;
				addChild(equipedLbl);
			}
			
			var obj:Object = JSON.parse(data);
			itemNameLbl.text = obj.iname;
			equipedLbl.visible = obj.isEquiped;
			itemNameLbl.y = equipedLbl.visible ? 10 : 18;
		} 
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy ItemTipTileCell");
			itemNameLbl = null;
			equipedLbl = null;
			super.destroy(destroyChild);
		}
	}
}