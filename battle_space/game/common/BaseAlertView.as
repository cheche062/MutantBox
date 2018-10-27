package game.common
{
	
	import MornUI.baseAlert.BaseAlertViewUI;
	
	import game.common.base.BaseAlert;
	import game.global.GameLanguage;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.View;
	
	public class BaseAlertView extends BaseAlert
	{
		public var _alertView:View;
		public var bgImg:Image;
		public var okBtn					:Button;
		public var cancleBtn				:Button;
		public var descTf					:Label;
		public var descBox:Box;
		private var _flag					:int;
		private var _message				:String;
		protected var _callBack				:Function;
		
		/**
		 *<code>BaseAlertView</code> 
		 * 弹出框基类
		 * 
		 */		
		public function BaseAlertView()
		{
			super();
			super.canClickMask = false;
		}
		
		override public function addEvent():void
		{
			bgImg   = _alertView.getChildByName("bgImg") as Image;
			okBtn 		=  _alertView.getChildByName("okBtn") as Button;
			cancleBtn	= _alertView.getChildByName("cancleBtn") as Button;
			descBox  = _alertView.getChildByName("alertBox") as Box;
			descTf		= descBox.getChildByName("alertDesc") as Label;
			descBox.pos(textLeft,textTop);
			this.on(Event.CLICK,this ,onClickEvent);
		}
		
		override public function createUI():void
		{
			createAlert();
		}
		
		
		/**
		 * 布局需重新
		 * 
		 */		
		public function createAlert():void
		{
			if(!_alertView)_alertView = new BaseAlertViewUI();
			this.addChild(_alertView);
		}
		
		
		public function onClickEvent(e:Event):void
		{
			var target:Sprite = e.target;
			//trace("点击。。。。");
			if(target.name == "okBtn")
			{
				_callBack(AlertType.RETURN_YES);
				this.close()
			}else if(target.name == "cancleBtn" || target == this.bg)
			{
				if(!cancleBtn || cancleBtn.visible == false){//只显示一个按钮的情况下，执行按钮操作
					_callBack(AlertType.RETURN_YES);
				}else{
					_callBack(AlertType.RETURN_NO);
				}
				this.close()
			}
			
		}
		
		/**
		 *弹出提示框 
		 * @param message 弹出文字
		 * @param flag	
		 * @param callBack 回掉函数
		 * @param isBackBlack 
		 * 
		 */		
		
		private var textMinW:Number = 350;  //文字内容最小宽度
		private var textMaxW:Number = 500;  //文字内容最大宽度
		private var textMinH:Number = 50;   //文字内容最小高度
		private var textTop:Number = 64;     //顶边距
		private var textLeft:Number = 56;    //左边距
		private var textRight:Number = 56;   //右边距
		private var textBottom:Number = 160;   //下边距
		
		private var buttonSpacing:Number = 30;  //按钮中间距
		
		
		public function alert( flag:int,callBack:Function, isBackBlack:Boolean = false,data:*=null):void
		{       
			_callBack = callBack;
			
			var alertStr:String = "";
			if(data is String && descTf){
				alertStr = GameLanguage.getLangByKey(data);
				alertStr = data.replace(/##/g, "\n");
			}
			
			descTf.width = Number.MAX_VALUE;
			descTf.text = alertStr;
			
			if(descTf.textField.textWidth > textMaxW)
			{
				descTf.width = textMaxW;
				descTf.text = alertStr;
			}else
			{
				descTf.width = descTf.textField.textWidth;
			}
			
			descBox.size(
				Math.max(descTf.textField.textWidth , textMinW) ,
				Math.max(descTf.textField.textHeight , textMinH) 
			);
			
			descTf.pos(
				descBox.width - descTf.textField.textWidth >> 1,
				descBox.height - descTf.textField.textHeight >> 1
			);
			
			_alertView.size(
				descBox.width + textLeft + textRight,
				descBox.height + textTop + textBottom
			);
			
			
			bgImg.size(_alertView.width , _alertView.height);
			
			okBtn.y = cancleBtn.y = descBox.y + descBox.height + (textBottom - okBtn.height * okBtn.scaleY)/2;
			
			okBtn.label = "L_A_33017";
			cancleBtn.label = "L_A_33018";
			if(flag & AlertType.YES && !(flag & AlertType.NO))
			{
				okBtn.x = (_alertView.width - okBtn.width*okBtn.scaleX) >> 1;
				cancleBtn.visible = false;
				var str:String = GameLanguage.getLangByKey("L_A_29");
				if(str == "L_A_29"){
					str = "CONFIRM"
				}
				okBtn.label = str;
			}else if((flag & AlertType.NO) && !(flag & AlertType.YES))
			{
				okBtn.visible	= false;
			}else if(flag & AlertType.YES && flag & AlertType.NO)
			{
				okBtn.x = (_alertView.width - okBtn.width*okBtn.scaleX - buttonSpacing - cancleBtn.width*cancleBtn.scaleX) /2 ;
				cancleBtn.x = okBtn.x + okBtn.width*okBtn.scaleX + buttonSpacing;
			}
			
			this.bg.size(Laya.stage.width, Laya.stage.height);
			this.bg.graphics.clear();
			this.bg.mouseEnabled = true;
			this.bg.graphics.drawRect(0,0,Laya.stage.width, Laya.stage.height, _bgColor);
			_alertView.pos(bg.width - _alertView.width >> 1, bg.height - _alertView.height >> 1);
		}
		
	}
}