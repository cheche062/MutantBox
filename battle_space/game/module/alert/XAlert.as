package game.module.alert
{
	import MornUI.componets.XAlertUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ModuleManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.Button;
	import laya.utils.Handler;

	/**
	 * 警告类，使用方法:
	 * XAlert.showAlert("JustDoIt");
	 * @author xiaohuzi999@163.com
	 */
	public class XAlert extends BaseDialog
	{
		/**确定回调*/
		private var _yesHandler:Handler;
		/**取消回调*/
		private var _noHandler:Handler;
		/**原始确定按钮x坐标*/
		private var _oriYesPos:Number;
		/**原始取消按钮x坐标*/
		private var _oriNoPos:Number;
		/**确定按钮默认label-静态常量*/
		public static const DEFAULT_YES_LABEL:String = "YES";
		/**取消按钮默认label-静态常量*/
		public static const DEFAULT_NO_LABEL:String = "NO";
		
		public function XAlert()
		{
			super();
		}
		
		override public function createUI():void{
			_view = new XAlertUI();
			this.addChild(_view);
			
			this._oriYesPos = view.yesBtn.x;
			this._oriNoPos = view.noBtn.x;
			
			view.msgTF.style.fontFamily = XFacade.FT_Futura;
			view.msgTF.style.fontSize = 20;
			view.msgTF.style.color = "#ffffff";
			view.msgTF.style.align = "center";
		}
		
		/**加事件*/
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
		}
		
		/**删除事件*/
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.yesBtn:
					this._yesHandler && _yesHandler.run();
					this.close();
					break;
				case view.noBtn:
					this._noHandler && _noHandler.run();
					this.close();
					break;
				case this.view.closeBtn:
					this.close();
					break;
			}
		}
		
		public function showAlert(message:String, yesHandler:Handler=null,noHandler:Handler=null,showYesBtn:Boolean = true,showNoBtn:Boolean = true,yesBtnLabel:String = null, noBtnLabel:String = null):void
		{
			_yesHandler = yesHandler;
			_noHandler = noHandler;
			
			if(yesBtnLabel == null || yesBtnLabel == ""){
				yesBtnLabel = DEFAULT_YES_LABEL;
			}
			if(noBtnLabel == null || noBtnLabel == ""){
				noBtnLabel = DEFAULT_NO_LABEL;
			}
			
			view.msgTF.innerHTML = message;
			view.msgTF.y = (_view.height - view.msgTF.contextHeight ) * 0.5;
				
			var btnNum:int = 0;
			if(showYesBtn){
				btnNum++;
				view.yesBtn.visible = true;
				view.yesBtn.label = yesBtnLabel;
			}else{
				view.yesBtn.visible = false;
			}
			if(showNoBtn){
				view.noBtn.label = noBtnLabel;
				view.noBtn.visible = true;
				btnNum++;
			}else{
				view.noBtn.visible = false;
			}
			var btn:Button;
			if(btnNum == 1){
				view.yesBtn.visible ? btn=view.yesBtn : btn=view.noBtn;
				btn.x = (this._view.width - btn.width)/2;
			}else if(btnNum == 2){
				view.yesBtn.x = _oriYesPos;
				view.noBtn.x = _oriNoPos;
			}
		}
		
		/**覆盖show*/
		override public function show(...args):void{
			this.showAlert.apply(this, args[0]);
			super.show();
			
			AnimationUtil.popIn(this);
		}
		
		/**覆盖关闭*/
		override public function close():void{
			AnimationUtil.popOut(this, onClose, 150,200, this);
		}
		
		private function onClose():void{
			_yesHandler && _yesHandler.recover();
			_noHandler && _noHandler.recover();
			super.close();
		}
		
		private function get view():XAlertUI{
			return this._view as XAlertUI;
		}
		
		/**
		 * 显示警告
		 * @param message 消息
		 * @param title 标题
		 * @param yesHandler yes回调 
		 * @param noHandler 取消按钮回调
		 * @param showYesBtn 是否显示确定按钮
		 * @param showNoBtn 是否显示取消按钮
		 * @param yesBtnLabel “确定”按钮标签
		 * @param noBtnLabel “取消”按钮标签
		 */
		public static function showAlert(message:String,  yesHandler:Handler=null,noHandler:Handler=null,showYesBtn:Boolean = true,showNoBtn:Boolean = true,yesBtnLabel:String = null, noBtnLabel:String = null):void
		{
//			ModuleManager.intance.showModule(XAlert, [message,yesHandler,noHandler,showYesBtn,showNoBtn,yesBtnLabel,noBtnLabel]);
//			var flag = AlertType.YES|AlertType.NO;
			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,message,0,function(v:uint):void{
				if(v == AlertType.RETURN_YES)
				{
					if(yesHandler)
						yesHandler.run();
				}else
				{
					if(noHandler)
						noHandler.run();
				}
			});
		}
	}
}