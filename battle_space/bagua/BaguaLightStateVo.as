package game.module.bagua
{
	public class BaguaLightStateVo
	{
		/**关卡索引*/
		public var index:int = 0;
		
		/**是否被选中*/
		public var isSelected:Boolean = false;
		
		/**是否已经完成攻打*/
		public var isComplete:Boolean = false;
		
		/**逃出人数*/
		public var peopleNum:int = 0;
		
		
		public function BaguaLightStateVo()
		{
		}
		
		/**
		 * 初始化处理数据（由后台数据处理成本地需要的格式）
		 * 
		 */
		public function init(i:int, obj:Object, arr:Array):void{
			index = i;
			isSelected = false;
			isComplete = (obj["pass"] == 1);
			peopleNum = 0;
			arr.forEach(function(item:Array, index:int):void{
				if (i == item[0] - 1) {
					peopleNum = item[1];
				}
			})
		}
		
		
		
		
		
		
		
		
		
		
		
		
	}
}