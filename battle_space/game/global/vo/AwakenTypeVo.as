package game.global.vo
{
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.module.bag.mgr.ItemManager;

	public class AwakenTypeVo
	{
		public var id:Number = 0;
		public var name:String;
		public var des:String;
		public var type:Number = 0;
		public var att1:Number = 0;
		public var att2:Number = 0;
		public var icon:Number = 100;
		
		public function AwakenTypeVo()
		{
		}
		
		
		public function getDes(lv:Number):String
		{
			var s:String = GameLanguage.getLangByKey(des);
			var bei:Number = 10000;
			var attM1:Number = att1 * bei;
			var attM2:Number = att2 * bei;
			var v:Number = attM1 + (lv - 1) * attM2;
			return StringUtil.substitute(s,v / bei);
		}
		
		private function getSpecialityVo(lv:Number):AwakenSpecialityVo{
			var ar:Array = GameConfigManager.awakenSpecialityVoArr;
			for (var i:int = 0; i < ar.length; i++) 
			{
				var vo:AwakenSpecialityVo = ar[i];
				// 目前取消单位等级的限制（仅特性等级与花费金额一一对应）
//				if(vo.s_level <= lv && vo.u_level >= lv && vo.costAr)
				if(vo.s_level == lv && vo.costAr)
					return vo;
			}
			return null;
		}
		
		//仍然可升级次数
		public function upCount(lv:Number):Number   
		{
			var i:Number = 0;
			while(getSpecialityVo(lv)){
				lv ++ ;
				i ++;
			}
			return i;
		}
		
		//升级N次需要物资
		public function upCountCost(lv:Number,count:Number):Array
		{
			var ar:Array = [];
			for (var i:int = 0; i < count; i++) 
			{
				var vo:AwakenSpecialityVo = getSpecialityVo(lv);
				ItemManager.merge(ar,vo.costAr);
				lv ++;
			}
			return ar;
		}
		
		public function get iconPath():String{
			return "appRes/icon/texingIcon/"+icon+".png";
		}
	}
}