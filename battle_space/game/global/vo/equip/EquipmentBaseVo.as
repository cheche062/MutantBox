package game.global.vo.equip
{
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;

	public class EquipmentBaseVo
	{
		public var heroList:Array;
		public function EquipmentBaseVo()
		{
		}
		/**
		 * 英雄装备初始化
		 */
		public function setheroList(p_obj:Object,p_heroData:Array):void
		{
			heroList=new Array();
			var srcList:Array=new Array();//静态数据源
			srcList = GameConfigManager.getUnitList(FightUnitVo.HERO);
			for(var i:int=0;i<p_heroData.length;i++)
			{
				var l_vo:Object=p_heroData[i];
				var l_heroVo:HeroEquipVo=new HeroEquipVo();
				l_heroVo.unitId=l_vo.unitId;
				l_heroVo.data=l_vo;
				l_heroVo.level=l_vo.level;
				if(p_obj[l_vo.unitId+""]){
					l_heroVo.setEquipList(p_obj[l_vo.unitId+""]);
				}
				heroList.push(l_heroVo);
			}
		}
		/**
		 * 英雄装备刷新
		 */
		public function updateHeroList(p_obj:Object,p_heroData:Array):void
		{
			var srcList:Array=new Array();//静态数据源
			srcList = GameConfigManager.getUnitList(FightUnitVo.HERO);
			for(var i:int=0;i<srcList.length;i++)
			{
				var l_vo:Object=srcList[i];
				if(p_obj[l_vo.unit_id+""]){
					var l_heroVo:HeroEquipVo=new HeroEquipVo();
					l_heroVo.unitId=l_vo.unit_id;
					l_heroVo.setEquipList(p_obj[l_vo.unit_id+""]);
					var ishas:Boolean=false;
					
					for (var j:int = 0; j < p_heroData.length; j++) 
					{
						if(p_heroData[j].unitId==l_heroVo.unitId)
						{
							l_heroVo.data=p_heroData[j];
						}
					}
					for (var j:int = 0; j < heroList.length; j++) 
					{
						if(heroList[j].unitId==l_heroVo.unitId)
						{
							ishas=true;
							heroList[j]=l_heroVo;
						}
					}
					if(ishas==false)
					{
						heroList.push(l_heroVo);
					}
				}
			}
		}
		
		/**
		 * 获取强化的消耗
		 */
		public function getStrengthArr(p_id:int,p_level:int):Array
		{
			var l_arr:Array=new Array();
			var l_equipvo:EquipmentIntensifyVo=getEquipStringInfo(p_id,p_level);
			var itemData:ItemData=new ItemData();
			itemData.iid=l_equipvo.cost.split("=")[0];
			itemData.inum=l_equipvo.cost.split("=")[1];
			l_arr.push(itemData);
			var l_maxlevel:int=getEquipMaxLevel(p_id);
			var l_level5:int=p_level+5;
			//			if(l_level5>l_maxlevel)
			//			{
			//				l_level5=l_maxlevel;
			//			}
			var l_itemData5:ItemData=new ItemData();
			for(var i:int=p_level;i<l_level5;i++)
			{
				var l_vo:EquipmentIntensifyVo=getEquipStringInfo(p_id,i);
				if(l_vo!=null)
				{
					l_itemData5.iid=l_vo.cost.split("=")[0];
					l_itemData5.inum+=parseInt(l_vo.cost.split("=")[1]);
				}
			}
			l_arr.push(l_itemData5);
			return l_arr;
		}
		
		/**
		 * 
		 * @param p_id
		 * @param p_level
		 * @return 
		 * 
		 */
		private function getEquipStringInfo(p_id:int,p_level:int):EquipmentIntensifyVo
		{
			var l_vo:EquipmentIntensifyVo;		
			var l_equipvo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentIntensifyList.length; i++) 
			{
				var l_vo:EquipmentIntensifyVo= GameConfigManager.EquipmentIntensifyList[i];
				if(l_vo.node_id==l_equipvo.streng_id && l_vo.level==p_level)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		
		/**
		 * 装备最大等级
		 */
		private function getEquipMaxLevel(p_id:int):int
		{
			var l_maxLevel:int=0;		
			var l_equipvo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentIntensifyList.length; i++) 
			{
				var l_vo:EquipmentIntensifyVo= GameConfigManager.EquipmentIntensifyList[i];
				if(l_vo.node_id==l_equipvo.streng_id)
				{
					l_maxLevel++;
				}
			}
			l_maxLevel=l_maxLevel-1;
			var user:User = User.getInstance();
			if(user.level<l_maxLevel)
			{
				l_maxLevel=user.level;
			}
			return l_maxLevel;
		}
		/**
		 * 装备洗练
		 */
		public function getEquipWash(p_id:int):EquipmentBaptizeVo
		{
			
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentBaptizeList.length; i++) 
			{
				var l_vo:EquipmentBaptizeVo=GameConfigManager.EquipmentBaptizeList[i];
				if(l_equipVo.level==l_vo.level && l_equipVo.quality==l_vo.quality)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		/**
		 * 选择英雄
		 */
		public function getSelectHero(p_id:int):HeroEquipVo
		{
			for (var i:int = 0; i < heroList.length; i++) 
			{
				var l_vo:HeroEquipVo=heroList[i];
				if(p_id==l_vo.unitId)
				{
					return l_vo;
				}
			}
			return null;
		}
		
	}
}