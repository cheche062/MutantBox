/***
 *作者：罗维
 */
package game.global.vo
{
	public class HomeScenceConfigVo
	{
		public var block:String;
		
		private var _blockList:Object;
		
		public function HomeScenceConfigVo()
		{
		}
		
		
		
		public function get blockList():Object
		{
			if(!_blockList)
			{
				_blockList = {};
				
				if(block)
				{
					var ar:Array = block.split(",");
					while(ar.length > 1){
						var X:String = ar.shift();
						var Y:String = ar.shift();
						_blockList[X+"_"+Y] = true;
					}
				}
				
			}
			return _blockList;
		}

	}
}