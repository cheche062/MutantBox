package game.global.vo.Card
{
	import game.global.GameConfigManager;

	public class CardPvwVo
	{
		public var level:int;
		public var free:String;
		public var pay:String;
		public var high:String;
		public function CardPvwVo()
		{
		}
		
		public function getFree():Array
		{
			var l_arr:Array=new Array();
			var l_idArr:Array=free.split("|");
			for (var i:int = 0; i < l_idArr.length; i++) 
			{
				l_arr.push(GameConfigManager.unit_json[l_idArr[i]]);
			}
			
			return l_arr;
			
		}
		
		public function getPay():Array
		{
			var l_arr:Array=new Array();
			var l_idArr:Array=pay.split("|");
			for (var i:int = 0; i < l_idArr.length; i++) 
			{
				l_arr.push(GameConfigManager.unit_json[l_idArr[i]]);
			}
			return l_arr;
		}
		
		public function getHigh():Array
		{
			var l_arr:Array=new Array();
			var l_idArr:Array=high.split("|");
			for (var i:int = 0; i < l_idArr.length; i++) 
			{
				l_arr.push(GameConfigManager.unit_json[l_idArr[i]]);
			}
			return l_arr;
		}
	}
}