package game.common
{
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.net.Loader;
	import laya.ui.AutoBitmap;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	/**
	 * XItemTip 简单提示类
	 * author:huhaiming
	 * XItemTip.as 2017-3-7 上午9:59:44
	 * version 1.0
	 *
	 */
	public class XItemTip extends BaseView
	{
		private var _msgTF:Text;
		public function XItemTip()
		{
			this._m_iLayerType = LayerManager.M_POP;
			this._m_iPositionType = LayerManager.CENTER;
		}
		
		/**显示一个tip*/
		public function showTip(str:String):void{
			this._msgTF.text = str;
			this.show();
		}
		
		override public function show(...args):void{
			super.show();
			this.alpha = 1;
			LayerManager.instence.addToLayer(this, this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
		}
		
		override public function close():void{
			Pool.recover("XItemTip", this);
			super.close();
		}
		
		//
		override public function createUI():void{
			this._msgTF = new Text();
			this._msgTF.fontSize = 36;
			this.addChild(_msgTF);
			_msgTF.width = 260;
			_msgTF.color = "#ffffff"
			_msgTF.align = "center";
			_msgTF.font = XFacade.FT_BigNoodleToo;
			_msgTF.strokeColor = "#000000";
			_msgTF.stroke = 3;
		}
		
		/**
		 * 显示一个tip
		 * @param itemInfoStr 类似"92003=1"
		 * */
		public static function showTip(itemInfoStr:String):void{
			if(!itemInfoStr){
				return;
			}
			
			var tmp:Array = (itemInfoStr).split("=");
			var db:Object = GameConfigManager.items_dic[tmp[0]];
			var tipStr = GameLanguage.getLangByKey(db.abbreviation)+" x";
			tipStr += tmp[1];
			
			var tip:XItemTip = Pool.getItemByClass("XItemTip", XItemTip);
			tip.showTip(tipStr);
			
			Tween.to(tip,{y:tip.y-180, alpha:0}, 500,null, Handler.create(tip, tip.close),1200);
		}
		
		/***/
		public static function showStr(tipStr:String):void{
			var tip:XItemTip = Pool.getItemByClass("XItemTip", XItemTip);
			tip.showTip(tipStr);
			
			Tween.to(tip,{y:tip.y-180, alpha:0}, 500,null, Handler.create(tip, tip.close),1200);
		}
	}
}