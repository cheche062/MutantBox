package game.module.camp.avatar
{
	import game.common.ResourceManager;
	import game.module.camp.CampData;

	/**
	 * DBSkin
	 * author:huhaiming
	 * DBSkin.as 2018-3-30 下午4:17:36
	 * version 1.0
	 *
	 */
	public class DBSkin
	{
		private static var _skinInfo:Object;
		private static var _skinPro:Object;
		//材料数据
		private static var _mInfo:Object;
		/***/
		public static const MAX_LV:int = 50;
		public function DBSkin()
		{
		}
		
		/**获取皮肤列表*/
		public static function getSkinData(unitId:*):Array{
			var arr:Array = [];
			for(var i:String in skinInfo){
				if(skinInfo[i].unit == unitId){
					arr.push(skinInfo[i]);
				}
			}
			return arr;
		}
		
		/**获取皮肤信息*/
		public static function getSkin(skinId:*):SkinVo{
			for(var i:String in skinInfo){
				if(skinInfo[i].ID == skinId){
					return skinInfo[i];
				}
			}
			return new SkinVo();
		}
		
		/**获取材料描述*/
		public static function getMInfo(id:*):Object{
			for(var i:String in mInfo){
				if(mInfo[i].id == id){
					return mInfo[i];
				}
			}
			return {};
		}
		
		/**获取皮肤属性*/
		public static function getSkinPro(skinLv:int, skinNode:int):SkinProVo{
			for(var i:String in skinPro){
				if(skinPro[i].node == skinNode && skinPro[i].level == skinLv){
					return skinPro[i];
				}
			}
			return null;
		}
		
		/**获取连续升级所需的资源*/
		public static function getResToNine(skinId:int):int{
			var num:int = 0;
			var vo:SkinVo = getSkin(skinId)
			var hero:Object = CampData.getUintById(vo.unit);
			if(hero && hero.skins){
				var info:Object = hero.skins[skinId];
				var proInfo:SkinProVo;
				var tmp:Array;
				if(info){
					var lv:int = info[0];
					if(lv >= MAX_LV){
						return 0; 
					}
					var end:int = Math.floor(lv/10)*10+10;
					for(var i:int=lv; i<end; i++){
						proInfo = getSkinPro(i,vo.node);
						tmp = proInfo.cost.split("=");
						num += parseInt(tmp[1]);
					}
				}
			}
			return num;
		}
		
		private static function get skinPro():Object{
			if(!_skinPro){
				_skinPro = ResourceManager.instance.getResByURL("config/skin_qianghua.json");
			}
			return _skinPro;
		}
		
		private static function get skinInfo():Object{
			if(!_skinInfo){
				_skinInfo = ResourceManager.instance.getResByURL("config/skin_shuxing.json");
			}
			return _skinInfo;
		}
		
		private static function get mInfo():Object{
			if(!_mInfo){
				_mInfo = ResourceManager.instance.getResByURL("config/skin_source.json");
			}
			return _mInfo;
		}
	}
}