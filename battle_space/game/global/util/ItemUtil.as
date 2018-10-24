package game.global.util
{
	import MornUI.componets.ItemIconUI;
	
	import game.global.GameConfigManager;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	import game.module.invasion.ItemIcon;
	
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.Tab;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;

	/**
	 * ItemUtil
	 * author:huhaiming
	 * ItemUtil.as 2017-4-20 下午3:26:24
	 * version 1.0
	 *
	 */
	public class ItemUtil
	{
		public function ItemUtil()
		{
		}
		
		/**
		 * 格式话一个icon
		 * */
		public static function format(itemId:*, item:ItemIconUI):void{
			item.icon.graphics.clear();
			//item.icon.loadImage("appRes/icon/itemIcon/"+itemId+".png");
			item.icon.loadImage(GameConfigManager.getItemImgPath(itemId));
			
			var db:Object = GameConfigManager.items_dic[itemId];
			var q:Number = db?db.quality:1;
			item.itemBG.skin = "common\/i"+(q-1)+".png";
		}
		
		/**
		 * 格式化一个小icon图标
		 * @param icon 图标
		 * @param mStr 资源配置形如"2=100"
		 * */
		public static function formatIcon(icon:Image, mStr:String):void{
			var tmp:Array = (mStr+"").split("=")
			if(tmp.length > 1){
				var db:ItemVo = GameConfigManager.items_dic[tmp[0]]
				icon.skin = "common/icons/"+db.icon+".png";
			}else{
				icon.skin = "";
			}
		}
		
		/**
		 * 加载图标
		 * @param icon 图标
		 * @param mStr 资源配置形如"2=100"
		 * */
		public static function loadIcon(icon:Image, mStr:String):void{
			var tmp:Array = (mStr+"").split("=")
			if(tmp.length > 1){
				var url:String = GameConfigManager.getItemImgPath(tmp[0]);
				trace("URL:::",url)
				icon.skin = url;
			}else{
				icon.skin = "";
			}
		}
		
		private static function getVPoint(v:*):Point{
			var rp:Point;
			if(v is Point)
			{
				return v;
			}
			if(v is Sprite  && Sprite(v).displayedInStage)
			{
				rp = new Point();
				Sprite(v).localToGlobal(rp);
				return rp;
			}
			return null;
		}
		
		/**
		 *  显示道具收取效果
		 * itemsInfo  [itemData,itemData]  或 [[itemid,itemnum],[itemid,itemnum]]
		 * start     Point   或   Sprite   不传则为舞台正中央
		 * end       Point   或   Sprite   不传则为背包ICON位置
		 * speed     100像素单位时间
		 * interval  飞行间隔时间
		 **/
		public static function showItems(itemsInfo:Array, start:* = null, end:* = null ,speed:Number = 70 , interval:Number = 100):void{
			var item:ItemIcon
			var nextHandler:Handler;
			var startPi:Point;
			var endPi:Point;
			
			start ||=  new Point(Laya.stage.width >> 1 , Laya.stage.height >> 1);
			end ||= new Point(160, 524);
			
			startPi = getVPoint(start);
			endPi = getVPoint(end);
			
			if(!startPi || !endPi) return ;
			
			var dx:Number=startPi.x-endPi.x;
			var dy:Number=startPi.y-endPi.y;
			var dist:Number=Math.sqrt(dx*dx+dy*dy);
			var flyTimer:Number = dist / 100 * speed;
			
			for(var i:int=0; i<itemsInfo.length; i++){
				item = Pool.getItemByClass("ItemIcon", ItemIcon);
				item.bg.visible = item.qPic.visible = false;
				var idata:* = itemsInfo[i];
				if(idata is Array)
				{
					item.dataSource = {id:idata[0], num:idata[1]};
				}
				else if(idata is ItemData)
				{
					item.dataSource = {
						id: ItemData(idata).iid,
						num : ItemData(idata).inum
					};
				}
				
				Laya.stage.addChild(item);
//				item.pos(i*item.width+startPi.x , startPi.y);
				item.pos(startPi.x - (item.width / 2) , startPi.y);
				
				nextHandler = Handler.create(null, next,[item,endPi,flyTimer]);
				Tween.to(item,{y:item.y+0.1},i*interval, null, nextHandler)
			}
		}
		private static function next(item:ItemIcon,endPi:Point,flyTimer:Number):void{
			var handler:Handler = Handler.create(null, onRecyle,[item]);
			Tween.to(item,{x:endPi.x,y:endPi.y, scaleX:0.5, scaleY:0.5},flyTimer, null, handler)
		}
		/***/
		private static function onRecyle(item:ItemIcon):void{
			item.removeSelf();
			Pool.recover("ItemIcon", item);
		}
		
		/**
		 * 显示收获动画
		 * @param skin 道具皮肤
		 * */
		public static function showHarvestAni(skin:String, startPoint:Point):void{
			var image:Image = new Image(skin);
			Laya.stage.addChild(image);
			image.pivot(50,50);
			image.pos(startPoint.x+50, startPoint.y+50);
			Tween.to(image, {y:startPoint.y-150,scaleX:1.5,scaleY:1.5, alpha:0.5}, 300,null, Handler.create(null, onComplete));
			
			function onComplete():void{
				image.removeSelf();
			}
		}
	}
}