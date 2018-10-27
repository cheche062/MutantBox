package game.module.guild
{
	import MornUI.guild.StoreListAllUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Label;
	
	/**
	 * 商店所有商品展示
	 * @author hejianbo
	 * 
	 */
	public class StoreListAllView extends BaseDialog
	{
		public function StoreListAllView()
		{
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void
		{
			this.addChild(view);
			
			var data = ResourceManager.instance.getResByURL("config/guild_shop.json");
			var result:Object = {};
			
			ToolFunc.objectValues(data).forEach(function(item) {
				result[item["unlock_level"]] = result[item["unlock_level"]] || [];
				result[item["unlock_level"]].push(item["item"]);
			});
			
			view.dom_content.destroyChildren();
			for (var key in result) {
				var box:Box = createItemBox(key, result[key]);
				if (view.dom_content.numChildren) {
					var last_child:Box = view.dom_content.getChildAt(view.dom_content.numChildren - 1);
					box.y = last_child.y + last_child.height + 20;
				}
				view.dom_content.addChild(box);
			}
			
			trace(result);
		}
		
		private function createItemBox(key:String, data:Array):Box {
			var wrap_box:Box = new Box();
			var content_box:Box = new Box();
			var label:Label = new Label();
			label.font = "Futura";
			label.fontSize = 22;
			label.color = "#a6dbff";
			label.text = GameLanguage.getLangByKey("L_A_2703").replace("{0}", key);
			wrap_box.addChild(label);
			
			content_box.y = label.height + 10;
			wrap_box.addChild(content_box);
			
			data.forEach(function(item:String, index:int) {
				var child:ItemContainer = new ItemContainer();
				var arr = item.split("=");
				child.setData(arr[0], arr[1]);
				child.x = (index % 6) * (child.width + 20);
				child.y = Math.floor(index / 6) * (child.height + 10);
				content_box.addChild(child);
			});
			
			return wrap_box;
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.btn_close:
					close();
					break;
			}
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, onClick);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, onClick);
			
			super.removeEvent();
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		private function get view():StoreListAllUI
		{
			_view = _view || new StoreListAllUI();
			return _view;
		}
	}
}