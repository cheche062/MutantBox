package game.common
{
	import laya.display.Node;
	import laya.ui.Box;
	import laya.ui.List;
	
	public class ListPanel extends Box
	{
		protected var m_renderClass:Array = [];
		protected var m_panelList:Array;
		protected var m_index:Number = -1;
		
		public function ListPanel(renderClass:Array)
		{
			super();
			m_renderClass = renderClass;
			m_panelList = [];
			for (var i:int = 0; i < m_renderClass.length; i++) 
			{
				m_panelList.push(null);
			}
			
		}
		
		

		public function get selIndex():Number
		{
			return m_index;
		}

		public function set selIndex(value:Number):void
		{
			if(m_index != value)
			{
				m_index = value;
				
				for (var i:int = 0; i < m_panelList.length; i++) 
				{
					if(i != m_index && m_panelList[i])
					{
						(m_panelList[i] as ITabPanel).removeEvent();
						(m_panelList[i] as Node).removeSelf();
					}
				}
				
				if(m_index != -1)
				{
					var tabP:ITabPanel = getPanel(m_index);
					if(tabP)
					{
						addChild(tabP as Node);
						tabP.addEvent();
					}
				}
			}
		}
		
		public function getPanel(idx:Number):ITabPanel{
			if(idx < 0)return null;
			if(m_panelList[idx]) return m_panelList[idx];
			if(m_renderClass.length > idx)
			{
				var cls:Class = m_renderClass[idx];
				m_panelList[idx] = new cls();
				return m_panelList[idx];
			}
			return null;
		}
		
		public function get panelList():Array{
			return m_panelList;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy ListPanel");
			m_renderClass = null;
			m_panelList = null;
			super.destroy(destroyChild);
		} 

	}
}