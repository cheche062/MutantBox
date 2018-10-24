/***
 *作者：罗维
 */
package game.global.data.bag
{
	import game.global.GameConfigManager;
	import game.global.vo.ItemVo;

	public class ItemData
	{
		public var key:String;   //唯一ID
		public var iid:uint;    //道具id
		public var inum:uint;   //堆叠数量
		public var exPro:Object = {};//道具附加属性,胡同学加,目前的key——level:基因等级,exp:基因经验
		//tips使用参数
		public var level:int;
		public var playerLevel:int;
		//消耗物品
		public var isShowMax:Boolean=true;
		
		private var _vo:ItemVo;  //vo
		
		public var select:Boolean;
		
		public function ItemData()
		{
			
		}

		public function get vo():ItemVo
		{
			if(!_vo)
				_vo = GameConfigManager.items_dic[iid];
			return _vo;
		}
		
		
		public function toString():String{
			return vo.name + "x" + inum;
		}
		

	}
}