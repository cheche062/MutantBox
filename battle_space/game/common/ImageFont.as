/***
 *作者：罗维
 */
package game.common
{
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.mgr.SkillManager;
	
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.resource.Texture;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Timer;
	import laya.utils.Tween;
	
	public class ImageFont
	{
		public static const ImageFont_sign:String = "IMAGEFONT_SIGN";
		
		
		private static var _instance:ImageFont;
		public function ImageFont()
		{
			if(_instance){				
				throw new Error("ImageFont是单例,不可new.");
			}
			_instance = this;
		}
		
		public static function get intance():ImageFont
		{
			if(_instance)
				return _instance;
			_instance = new ImageFont();
			return _instance;
		}
		
		public function floatingHp(v:String , fontName:String , goPoint:Point , toPoint:Point,jj:Number = -7):void
		{
//			var mapPoint:Point = new Point();
			if(!FightingManager.intance.Scence)
			{
				return ;
			}
//			mapPoint = FightingManager.intance.Scence.localToGlobal(mapPoint);
			
			var jsonStr:String = ResourceManager.instance.setResURL("imageFont/"+fontName+".json");
			var _fontData:* = Loader.getAtlas(jsonStr);
			if(!_fontData)
			{
				Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,floatingHp,[v,fontName,goPoint,toPoint,jj]));
				return;
			}
			
			var ly:Sprite = FightingManager.intance.Scence.tSkillLayer;
			var sp:Sprite = createBitmapFont(v,fontName,jj);
			ly.addChild(sp);
			sp.x = goPoint.x - sp.width / 2;
			sp.y = goPoint.y - sp.height / 2;
			var f:Function = function(s:Sprite):void{
				if(s)
				{
					ly.removeChild(s);
					Pool.recover(ImageFont_sign,s);
				}
			};
			Tween.to(sp,{x:toPoint.x - sp.width / 2 ,y:toPoint.y - sp.height / 2},500,null,Handler.create(this,f,[sp]));
		}
		
		// 创建位图字体
		public static function createBitmapFont(v:String , fontName:String , jj:Number = -7 ):Sprite{
			v = v+"";
			var jsonStr:String = ResourceManager.instance.setResURL("imageFont/"+fontName+".json");
			var _fontData:* = Loader.getAtlas(jsonStr);
			if(!_fontData)
			{
				return null;
			}
			var _jsonData:* = Loader.getRes(jsonStr);
			
			if(!v || v == ""){
				return null;
			}
			var charTotal:uint = v.length;
			var charSps:Array = [];
			
			var charSp:Sprite = Pool.getItemByClass(ImageFont_sign,Sprite);
			charSp.size(0,0);
			charSp.graphics.clear();
			for(var i:uint =0;i<charTotal;i++){
				var targetChar:String = v.substr(i,1);
				drawTexture(targetChar,fontName ,charSp,jj);
			}
			return charSp;
		}
		// 从图集上面抠图
		private static function drawTexture(char:String ,fontName:String, charSp:Sprite,jj:Number = -7):Boolean{
			var fontS:String = "imageFont/"+fontName+"/"+char+".png";
			var tx:Texture = Loader.getRes(fontS);
			if(!tx)
			{
				trace("Imgfont 读图失败",fontS);
				return false;
			}
			var pX:Number = charSp.width;
			if(pX) pX += jj;
			charSp.graphics.drawTexture(tx,pX,0,tx.sourceWidth,tx.sourceHeight);
			charSp.size(pX + tx.sourceWidth ,charSp.height + tx.sourceHeight);
			return true;
		}
	}
}