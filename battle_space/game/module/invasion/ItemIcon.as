package game.module.invasion
{
	import MornUI.componets.ItemIcon2UI;
	
	import game.global.data.DBItem;
	import game.global.vo.ItemVo;
	
	/**
	 * ItemIcon
	 * author:huhaiming
	 * ItemIcon.as 2017-5-17 下午5:04:29
	 * version 1.0
	 *
	 */
	public class ItemIcon extends ItemIcon2UI
	{
		public var data:Object;
		public function ItemIcon()
		{
			super();
		}
		
		/**
		 * 生成一个道具图标
		 * 数据格式{id:1,num:1},num为非必须key
		 */
		override public function set dataSource(value:*):void{
			if(value){
				var db:ItemVo = DBItem.getItemData(value.id);
				data = db;
				if(db){
					if(value.hasOwnProperty("num")){
						this.numTF.text = value.num+"";
					}else{
						this.numTF.text = "";
					}
					this.icon.skin = "appRes/icon/itemIcon/"+db.icon+".png";
					this.qPic.skin = "common/item_bar"+(db.quality-1)+".png"
					this.bg.skin = "common/item_bg0.png"
				}
			}
		}
	}
}