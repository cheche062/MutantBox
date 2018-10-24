package game.module.equipFight.panel
{
	import MornUI.equipFight.EquipFightLuckyCellUI;
	
	import game.global.data.ItemCell2;
	import game.global.data.bag.ItemData;
	
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class EquipFightLuckyCell extends EquipFightLuckyCellUI
	{
		
		private var ic:ItemCell2 = new ItemCell2();
		public var open:Boolean = true;
		private var _iconPath:String;
		
		public function EquipFightLuckyCell()
		{
			super();
			size(140,184);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			var mk:Sprite = new Sprite();
			mk.size(width,height);
			mk.graphics.drawRect(0,10,width,height-20,"#ffffff");
			mk.cacheAsBitmap = true;
			this.menBox.mask = mk;
			this.bgImg.mouseEnabled = true;
			if(pzImg.parent)
			{
				pzImg.parent.addChild(ic);
				ic.pos(pzImg.x,pzImg.y);
				pzImg.removeSelf();
			}
			
		}
		
		
		public function feyItem():void
		{
			if(_iconPath)
			{
				var iface:Image = new Image();
				iface.loadImage(_iconPath);
				var pi:Point = new Point();
				pi = ic.localToGlobal(pi);
				Laya.stage.addChild(iface);
				iface.pos(pi.x , pi.y);
				Tween.to(iface ,{x:0,y:Laya.stage.height},1000,null,Handler.create(null,feyOver,[iface]));
				
				var feyOver:Function = function(iiface:Image):void
				{
					iiface.removeSelf();
					iiface.destroy();
				}
			}
		}
		
//		private function feyOver(iface:Image):void
//		{
//			iface.removeSelf();
//			iface.destroy();
//		}
		
		public function bindDataAndFey(d:ItemData):void
		{
			bindData(d,true,Handler.create(this,feyItem));
		}
		
	
		public function bindData(d:ItemData ,isMover:Boolean = false , back:Handler = null ):void{
			open = d != null;
			_iconPath = null;
			ic.showTip = d != null;
			if(d)
			{
				_iconPath = d.vo.iconPath;
//				this.itemFace.loadImage(d.vo.iconPath);
//				this.pzImg.skin = "common/i"+(d.vo.quality-1)+".png";
				ic.data = d;
			}
			
			var toY1:Number = !d ? 0 : -60;
			var toY2:Number = !d ? 0 : 60;
			
			if(isMover)
			{
				Tween.to(tImg,{y:toY1},500,null,back);
				Tween.to(bImg,{y:toY2},500);
			}else
			{
				tImg.y = toY1;
				bImg.y = toY2;
			}
			
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy EquipFightLuckyCell");
			ic = null;
			
			super.destroy(destroyChild);
		}
	}
}