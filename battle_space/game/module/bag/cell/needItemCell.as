package game.module.bag.cell
{
	import game.common.UIHelp;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.display.Sprite;
	import laya.events.Event;

	public class needItemCell extends BaseItemCell
	{
		protected var m_colors:Array;
		protected var m_font:String;
		protected var m_numChange:Boolean;
		public function needItemCell(colors:Array = ["#ffffff","#ff9f9f"],font:String = "Futura",numChange:Boolean = true)
		{
			super();
			m_colors = colors;
			m_font = font;
			m_numChange = numChange;
			this.showTip = true;
		}
		
		protected override function init():void
		{
			super.init();
			_itemNumLal.fontSize = 18;
			_itemNumLal.font = m_font;
			_itemNumLal.pos(38,9);
			Signal.intance.on(User.PRO_CHANGED, this,userChange);
		}
		
		public override function bindIcon():void{
			_itemIcon.skin = "common/icons/jczy"+_data.iid+".png";
		}
		
		protected function userChange(e:Event = null):void
		{
			if(_data)
			{
				var itemNum:Number = User.getInstance().getResNumByItem(_data.iid);
				_itemNumLal.color = itemNum < _data.inum ? m_colors[1] :  m_colors[0];
//				trace("needCell itemColor",_itemNumLal.color);
			}
		}
		
		public override function bindNum():void{
			super.bindNum();
			UIHelp.crossLayout(this);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			m_colors = null;
			
			Signal.intance.off(User.PRO_CHANGED, this,userChange);
			super.destroy(destroyChild);
		}
		
		/**
		 * 在父元素中居中
		 * 
		 */
		public function displayCenterInParent():void{
			var w:Number = itemNumLal.x + itemNumLal.width;
			var parent:Sprite = this.parent;
			if(parent){
				this.x = (parent.width - w) / 2;
			}
		}
		
		override public function bindData():void{
			super.bindData();
			userChange();		
		}
		
	}
}