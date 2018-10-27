package game.global.util
{
	import game.common.ResourceManager;
	import game.global.GameConfigManager;
	import game.module.camp.CampData;
	import game.module.camp.avatar.DBSkin;
	import game.module.camp.avatar.SkinVo;
	
	import laya.net.URL;

	/**
	 * UnitPicUtil 单位相关图像地址管理
	 * author:huhaiming
	 * UnitPicUtil.as 2017-4-21 上午11:25:44
	 * version 1.0
	 *
	 */
	public class UnitPicUtil
	{
		/**类型-全身像-值与资源中的定义需要定义*/
		public static const PIC_FULL:String = "";
		/**类型-半身像*/
		public static const PIC_HALF:String = "_c";
		/**类型-布阵界面头像---改版，由原来的_g -> _c*/
		public static const PIC_SEL:String = "_c";
		/**类型-Boss -> _i*/
		public static const PIC_BOSS:String = "_i";
		/**类型-武器副本头像*/
		public static const PIC_EF:String = "_f";
		
		/**类型-icon正方形*/
		public static const ICON:String = "_b";
		/**类型-icon斜角*/
		public static const ICON_SKEW:String = "_a";
		/**类型-技能图标*/
		public static const SKILL_0:String = "_d";
		/**类型*/
		public static const SKILL_1:String = "_e";
		
		
			
	
		public function UnitPicUtil()
		{
		}
		
		/**
		 * 获取一个unit的图像地址
		 * @param unitId 单位的id
		 * @param type 头像类型,取值范围：UnitPicUtil.PIC_FULL,UnitPicUtil.PIC_HALF,UnitPicUtil.ICON,UnitPicUtil.ICON_SKEW
		 * @param skinID 皮肤 默认获取当前英雄皮肤
		 * */
		public static  function getUintPic(unitId:*, type:String, skinID:int = 0):String{
			var vo:Object = GameConfigManager.unit_json[unitId];
			var picId:String = unitId;
			if(vo){
				picId = vo.model;
			}
			vo = CampData.getUintById(unitId);
			
			var skinVo:SkinVo
			if(skinID){
				skinVo = DBSkin.getSkin(skinID);
			}else{
				if(vo && vo.skin){
					skinVo = DBSkin.getSkin(vo.skin);
				}
			}
			
			// 有皮肤
			if(skinVo && skinVo.garde != 0){
				var skin_shuxing = ResourceManager.instance.getResByURL("config/skin_shuxing.json");
				var targetData = skin_shuxing[skinVo.ID];
				switch (type) {
					case ICON_SKEW:
						picId = targetData["head_a"]
						break;
					case ICON:
						picId = targetData["head_b"]
						break;
					case PIC_HALF:
						picId = targetData["portrait_c"]
						break;
					case PIC_FULL:
						picId = targetData["portrait"]
						break;
				}
			} else {
				picId += type;
			}
			
			return URL.formatURL("appRes/icon/unitPic/"+picId+".png")
		}
	}
}