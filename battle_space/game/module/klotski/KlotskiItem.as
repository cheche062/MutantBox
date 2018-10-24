package game.module.klotski
{
	import MornUI.klotski.KlotskiItemUI;
	
	import game.global.event.Signal;
	
	import laya.events.Event;
	import laya.net.Loader;
	import laya.resource.Texture;

	/**
	 * KlotskiItem
	 * author:huhaiming
	 * KlotskiItem.as 2018-2-6 上午10:52:39
	 * version 1.0
	 *
	 */
	public class KlotskiItem
	{
		private var _ui:KlotskiItemUI
		private var _selected:Boolean = false;
		private static const W:int = 118;
		private static const H:int = 81;
		/**事件-选中*/
		public static const SELECTED:String = "K_selected";
		public static const NORMAL:int = 0;
		public static const DONE:int = 1;
		private static const SIZE_DIC:Object =
		{
			2:{w:140, h:95},
			3:{w:170, h:105},
			6:{w:160, h:106}
		}
		public function KlotskiItem(ui:KlotskiItemUI, index:int)
		{
			this._ui  = ui;
			this._ui.bmSelected.visible = false;
			var tx:Texture = Loader.getRes("klotski/g"+(index+1)+".png");
			this._ui.bm.skin = "klotski/g"+(index+1)+".png";
			this._ui.bmSelected.skin = "klotski/bg_select.png";
			if(SIZE_DIC[index]){
				this._ui.bmSelected.width = SIZE_DIC[index].w;
				this._ui.bmSelected.height = SIZE_DIC[index].h;
			}
		}
		
		private function onClick(e:Event):void{
			Signal.intance.event(SELECTED);
		}
		
		public function set selected(b:Boolean):void{
			this._selected = b;
			if(_selected){
				_ui.on(Event.CLICK, this, this.onClick);
			}else{
				_ui.off(Event.CLICK, this, this.onClick);
			}
		}
		
		public function set state(v:int):void{
			if(v == NORMAL){
				this._ui.bmSelected.visible = false;
			}else{
				this._ui.bmSelected.visible = true;
			}
		}
		
		public function get selected():Boolean{
			return this._selected;
		}
	}
}