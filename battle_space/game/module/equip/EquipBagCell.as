package game.module.equip
{
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	
	import laya.display.Text;
	
	public class EquipBagCell extends ItemCell
	{
		private var m_text:Text;
		public function EquipBagCell()
		{
			super();
		}
		
		
		override public function set data(value:ItemData):void{
			super.data = value;
			if(value && value.vo){
				if(m_text==null)
				{
					m_text=new Text();
					addChild(m_text);
				}
				var level:int;
				if(value.exPro.strong_level==undefined)
				{
					level=0;
				}
				else
				{
					level=value.exPro.strong_level;
				}
				m_text.color="#ffffff";
				m_text.font="Futura";
				m_text.fontSize=14;
				m_text.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_44002"),level);
				m_text.x=5;
				m_text.y=5;
				m_text.visible=true;
				showTip=false;
			}
			else
			{
				if(m_text!=null)
				{
					m_text.visible=false;
				}
			}
		}
		
		
		protected override function init():void
		{
			super.init();
		}
	}
}