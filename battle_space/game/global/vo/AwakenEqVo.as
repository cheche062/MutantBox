package game.global.vo
{
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.module.bag.mgr.ItemManager;
	import game.module.camp.CampData;

	public class AwakenEqVo
	{
		public var idx:Number = 0;
		public var site:Number = 0;  //激活等级
		public var item:String ;  //激活材料
		public var att:Number = 0;  //属性
		
		private var _cost:Array;
		
		public function AwakenEqVo()
		{
		}

		public function get cost():Array
		{
			if(!_cost)
			{
				_cost = ItemManager.StringToReward(item);
			}
			return _cost;
		}
		// 0 没有英雄  1 级别不足  2材料不足 
		public function getStates(uid:Number):Array{
			var cdata:Object = CampData.getUintById(uid);
//			trace("adkadjadlj");
//			trace("cdata:"+JSON.stringify(cdata));
			if(!cdata) return [0];
			var ar:Array = [];
			if(Number(cdata.level) < site)
				ar.push(1);
			for (var i:int = 0; i < cost.length; i++) 
			{
				var iData:ItemData = cost[i];
				var num:Number = BagManager.instance.getItemNumByID(iData.iid);
//				trace("uid:"+uid+"num:"+num+"inum"+iData.inum);
				if(num < iData.inum)
				{
					ar.push(2);
					break;
				}
			}
			
			return ar;
		}
		
		public function get attStr():String{
			var atName:Array = ["L_A_73121","L_A_38023","L_A_38024","L_A_38025"];
			var str:String = GameLanguage.getLangByKey(atName[idx]);
			return StringUtil.substitute(str,att);
		}

	}
}