package game.module.bag.cell
{
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;

	public class showMoneyCell extends BaseItemCell
	{
		
		
		private var m_color:String;
		private var m_font:String;
		private var m_fontSize:Number;
		private var m_textLeft:Number;
		private var m_textTop:Number;
		private var m_textAuto:Boolean;
		private var m_textWidth:Number;
		private var m_textAlign:String;
		
		/**
		 *文本颜色
		 *文本字体
		 *字体大小
		 *文字距图片距离
		 *自动高宽
		 *文本宽度
		 *文本水平对齐方式 可选值："left"，"center"，"right"。 
		 */
		public function showMoneyCell(moneyType:Number,
									  color:String = "#ffffff" , 
									  font:String = "Futura" , 
									  fontSize:Number = 18 ,
									  textLeft:Number = 0 ,
									  textTop:Number = 9 ,
									  textAuto:Boolean = false,
									  textWidth:Number = 60 ,
									  textAlign:String = "left"
		)
		{
			m_color = color;
			m_font = font;
			m_fontSize = fontSize;
			m_textLeft = textLeft;
			m_textTop = textTop;
			m_textAuto = textAuto;
			m_textWidth = textWidth;
			m_textAlign = textAlign;
			var itd:ItemData = new ItemData();
			itd.iid = moneyType;
			
			super();
			this.showTip = true;
			this.data = itd;
			
		}
		
		protected override function init():void
		{
			super.init();
			_itemNumLal.color = m_color;
			_itemNumLal.font = m_font;
			_itemNumLal.fontSize = m_fontSize;
			_itemNumLal.pos(38 + m_textLeft , m_textTop);
			_itemNumLal.autoSize = m_textAuto;
			if(!_itemNumLal.autoSize)
			{
				_itemNumLal.size(m_textWidth , m_fontSize + 2);
				_itemNumLal.align = m_textAlign;
			}
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
				_data.inum = itemNum;
				bindNum();
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			Signal.intance.off(User.PRO_CHANGED, this,userChange);
			super.destroy(destroyChild);
		} 
		
		public function bindData():void{
			super.bindData();
			userChange();		
		}
		
	}
}