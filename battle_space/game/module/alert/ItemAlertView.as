package game.module.alert 
{
	import MornUI.baseAlert.ItemAlertViewUI;
	
	import game.common.AnimationUtil;
	import game.common.UIHelp;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ItemAlertView extends BaseDialog 
	{
		
		private var _callback:Function;
		private var _callbackParam:Array = [];
		
//		private var itemIcon:Image;
		
		
		
		public function ItemAlertView() 
		{
			super();
			_closeOnBlank = true;
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.confirmBtn:
					if(_callback!=null)
					{
						_callback.apply(this, _callbackParam);
						//_callback.call(_callbackParam);
					}
					this.close()
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
			
		}
		
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			var l_arr:Array=args[0];
			view.itemIcon.removeSelf();
			var str:String = args[0][0];
			
			if(l_arr.length==1)
			{
				
				view.titleTF.text = str.replace(/##/g, "\n");
				
//				itemIcon.skin="";
				view.numTF.text="confirm";
//				view.numTF.x=190;
//				view.numTF.align="center";
				_callback=null;
			}
			else
			{
				view.titleTF.text = str.replace(/##/g, "\n");
				
				if(parseInt(args[0][1])==0)
				{
//					itemIcon.skin = "";
				}
				else
				{
					view.numTF.parent.addChildAt(view.itemIcon,0);
					view.itemIcon.skin = GameConfigManager.getItemImgPath(args[0][1]);
				}
				if(parseInt(args[0][1])==0)
				{
					view.numTF.text = "Free";
//					view.numTF.align="center";
//					view.numTF.x=190;
				}
				else
				{
					view.numTF.text= args[0][2];
//					view.numTF.align="left";
//					view.numTF.x=220;
				}
				
				_callback = args[0][3];
				
				_callbackParam = [];
				if (args[0][4])
				{
					_callbackParam = args[0][4];
					//trace("_callbackParam:", _callbackParam);
				}
			}
			if(view.itemIcon.parent)
				UIHelp.crossLayout(view.numTF.parent , true,-18,-10);
			else
				UIHelp.crossLayout(view.numTF.parent);
			var box:Box = view.numTF.parent;
			box.x = view.confirmBtn.width - box.width >> 1;
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function createUI():void
		{
			this._view = new ItemAlertViewUI();
			this.addChild(_view);
			
//			itemIcon = new Image();
//			itemIcon.width = itemIcon.height = 80;
//			itemIcon.x = 150;
//			itemIcon.y = 175;
//			view.addChild(itemIcon);
//			itemIcon = view.itemIcon;
			//_callback = new Function();
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		
		
		private function get view():ItemAlertViewUI{
			return _view;
		}
		
	}

}