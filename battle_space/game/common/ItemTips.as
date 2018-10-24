package game.common 
{
	import MornUI.tips.ItemTipsUI;
	
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.data.bag.ItemCell;
	import game.global.vo.ItemVo;
	
	import laya.events.Event;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ItemTips extends BaseView 
	{
		private var itemID:String;
		private var itemVo:ItemVo;
		
		public function ItemTips() 
		{
			super();
			this._m_iLayerType = LayerManager.M_POP;
			
		}
		
		override public function show(...args):void{
			super.show();
			//AnimationUtil.flowIn(this);
			this.x = this.view.stage.mouseX+20;
			this.y = this.view.stage.mouseY;
			
			
			this.view.bg.height = 150;
			this.view.bg.width = 270;
			view.desTF.width = view.desTF.textWidth = this.view.bg.width - 46;
			view.desTF.height = view.desTF.textHeight = 50;
			
			itemID = args[0];
			itemVo = GameConfigManager.items_dic[itemID]
			//trace("item: ", itemVo);
			if (itemVo)
			{
				view.nameTF.text = GameLanguage.getLangByKey(itemVo.name);
				view.desTF.text = GameLanguage.getLangByKey(itemVo.des).replace(/##/g, "\n\n");
				view.icon.skin = GameConfigManager.getItemImgPath(this.itemVo.id)
			}
			else
			{
				view.nameTF.text = "";
				view.desTF.text = GameLanguage.getLangByKey("L_A_57019")+itemID;
			}
			
			if (view.nameTF.textWidth > 170)
			{
				
				view.desTF.text = "";
				this.view.bg.width = view.nameTF.x + view.nameTF.textWidth + 50;
				
				view.desTF.width = view.desTF.textWidth = this.view.bg.width-46;
				view.desTF.text = GameLanguage.getLangByKey(itemVo.des).replace(/##/g,"\n\n");
			}
			/*trace("desTF:", view.desTF.text);
			trace("desTF.textHeight:", view.desTF.textHeight);*/
			if (view.desTF.textHeight > 50)
			{
				this.view.bg.height = view.desTF.textHeight + 105;
			}
			
			if ((this.y + this.view.bg.height) > LayerManager.instence.stageHeight)
			{
				this.y = LayerManager.instence.stageHeight - this.view.bg.height;
			}
			
			if ((this.x + this.view.bg.width) > LayerManager.instence.stageWidth)
			{
				this.x = LayerManager.instence.stageWidth - this.view.bg.width;
			}
		}
		
		/**
		 * 显示一个道具Tips
		 * @param	tipStr
		 */
		public static function showTip(id:String):void{
			
			XFacade.instance.openModule(ModuleName.ItemTips, id);
		}
		
		
		private function onClick(e:Event):void
		{
			
			onClose();
			switch(e.target)
			{
				case this.view.closeBtn:
					close();
					break;
				
			}
		}
		
		override public function dispose()
		{
			super.dispose();
		}
		
		override public function close():void{
			//AnimationUtil.flowOut(this, onClose);
			
			
			if (!this.view || !this || !this.view.displayedInStage)
			{
				return;
			}
			super.close();
		}
		
		private function onClose():void {
			
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ItemTipsUI();
			this.addChild(_view);
			
			this.closeOnBlank = true;
			view.desTF.fontSize = 18;
			view.desTF.wordWrap = true;
		}
		
		override public function addEvent():void{
			super.addEvent();
			
			Laya.stage.on(Event.MOUSE_DOWN, this, close);
			Laya.stage.on(Event.MOUSE_WHEEL, this, close);
		}
		
		override public function removeEvent():void {
			
			
			view && view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
			
			Laya.stage.off(Event.MOUSE_DOWN, this);
			Laya.stage.off(Event.MOUSE_WHEEL, this);
		}
		
		private function get view():ItemTipsUI{
			return _view;
		}
	}

}