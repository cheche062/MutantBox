package game.global.vo
{
	import game.module.bag.mgr.ItemManager;

	public class AwakenVo
	{
		public var id:Number = 0;  //ID 
		public var level:Number = 0; 	//等级
		public var cost:String; //突破消耗
		private var _awakenEqList:Array;
		
		private var _nextId:Number = 0;
		
		public var maxEqN:Number = 4;  //最大部位数
		
		private var _costList:Array;
		
		public function AwakenVo()
		{
			
			for (var i:int = 1; i <= maxEqN; i++) 
			{
				this["site"+i] = 0;  
				this["item"+i] = null;  
				this["att"+i] = 0;  
			}
		}
		
		
		public function get costList():Array
		{
			if(!_costList)
			{
				_costList = ItemManager.StringToReward(cost);
			}
			return _costList;
		}

		public function get nextId():Number
		{
			if(!_nextId)
			{
				var idStr:String = id.toString();
				var _lev:Number  = Number( idStr.substring(2,idStr.length - 1));
				_lev++;
				_nextId = idStr.substr(0,2) + _lev;
			}
			
			return _nextId;
		}

		public function get awakenEqList():Array
		{
			if(!_awakenEqList)
			{
				_awakenEqList = [];
				
				for (var i:int = 1; i <= maxEqN; i++) 
				{
					if(this["site"+i])
					{
						var vo:AwakenEqVo = new AwakenEqVo();
						vo.idx = i - 1;
						vo.site = this["site"+i];
						vo.item = this["item"+i];
						vo.att = this["att"+i];
						_awakenEqList.push(vo);
					}
				}
			}
			return _awakenEqList;
		}
		
	}
}