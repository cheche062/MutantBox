package game.module.techTree 
{
	import game.common.UIRegisteredMgr;
	import laya.display.Sprite;
	import laya.ui.Box;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TechBlockContainer extends Box 
	{
		
		private var _blockVec:Vector.<TechBlock> = new Vector.<TechBlock>();
		private var _data:Array;
		
		
		public function TechBlockContainer() 
		{
			super();
			init();
			
			this.width = 460;
			this.height = 335;
		}
		
		private function init():void
		{
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value as Array;
			
			
			if(!data)
			{
				return;
			}
			
			for (var i:int = 0; i < data.length; i++ )
			{
				if (!_blockVec[i])
				{
					_blockVec[i] = new TechBlock();
					_blockVec[i].x = data[i].h * 120;
					_blockVec[i].y = data[i].v * 120;
					this.addChild(_blockVec[i]);
				}
				
				if (i == 0 && !UIRegisteredMgr.getTargetUI("techIcon"))
				{
					UIRegisteredMgr.AddUI(_blockVec[i].bg, "techIcon");
				}
				
				_blockVec[i].setData(data[i].id,data[i].isEnd);
			}
			
		}
		
		public function refreshBlockData():void
		{
			var len:int = _blockVec.length;
			for (var i:int = 0; i < len; i++) 
			{
				_blockVec[i].updateData();
			}
		}
		
		public function hideAllSelectState():void
		{
			for (var i:int = 0; i < data.length; i++ )
			{
				if (!_blockVec[i])
				{
					return;
				}
				
				_blockVec[i].hideSelectState();
			}
		}
		
		public function get data():Array{
			return this._data;
		}
		
	}

}