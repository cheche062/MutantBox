package game.common
{
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.data.DBItem;
	import game.global.vo.ItemVo;
	import game.global.vo.VoHasTool;
	import game.module.mainui.MainView;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.net.Loader;
	import laya.ui.AutoBitmap;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	/**
	 * XTip 简单提示类
	 * author:huhaiming
	 * XTip.as 2017-3-7 上午9:59:44
	 * version 1.0
	 *
	 */
	public class XTip extends BaseView
	{
		private var _bg:Image;
		private var _msgTF:Text;
		public function XTip()
		{
			this._m_iLayerType = LayerManager.M_TIP;
			this._m_iPositionType = LayerManager.CENTER;
		}
		
		/**显示一个tip*/
		public function showTip(str:String):void{
			this.alpha = 1;
			this._msgTF.text = str;
			_msgTF.x = (_bg.width - _msgTF.width)/2;
			_msgTF.y = (_bg.height - _msgTF.height)/2;
			this.show();
		}
		
		override public function show(...args):void{
			super.show();
			LayerManager.instence.addToLayer(this, this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
		}
		
		override public function close():void{
			Pool.recover("XTip", this);
			super.close();
		}
		
		//
		override public function createUI():void{
			this._bg = new Image();
			this._bg.sizeGrid = "26,26,26,24,0";
			this.addChild(this._bg);
			this._bg.skin = "common\/tipBG.png";
			this._bg.width = 300;
			this._bg.height = 140;
			
			this._msgTF = new Text();
			this._msgTF.fontSize = 18;
			this.addChild(_msgTF);
			_msgTF.width = 260;
			_msgTF.wordWrap = true;
			_msgTF.color = "#ffffff"
			_msgTF.align = "center";
		}
		
		/**显示一个tip*/
		public static function showTip(tipStr:String):void{
			var tip:XTip = Pool.getItemByClass("XTip", XTip);
			tip.showTip(tipStr);
			
			Tween.to(tip,{y:tip.y-180, alpha:0}, 500,null, Handler.create(tip, tip.close), 2000);
		}
		
		/**显示奖励名称和数量动画*/
		public static function showAwardNameAndNumAni(arr:Array):void {
			if(!arr) return;
			
			var itemId:Number = arr[0];
			var itemNum:Number = arr[1];
			var dataItem:ItemVo = DBItem.getItemData(itemId);
			trace("收获:"+dataItem.name+"*"+itemNum);
			var view:* = Laya.stage;
			var dom_text:Text = new Text();
			dom_text.text = GameLanguage.getLangByKey(dataItem.name) + "  x  " + itemNum;
			view.addChild(dom_text);
			dom_text.x = view.width/2-100;
			dom_text.y = view.height/2;
			dom_text.font="Futura";
			dom_text.color="#ffffff";
			dom_text.height=20;
			dom_text.fontSize=30;
			dom_text.strokeColor = "#000000";
			dom_text.stroke = 2;
			Tween.to(dom_text, {y:dom_text.y-200,alpha:0}, 1000, Ease.circIn, Handler.create(null, function() {
				dom_text.destroy();	
			}));
			
		}
	}
}