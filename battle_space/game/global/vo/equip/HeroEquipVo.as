package game.global.vo.equip
{
	import game.global.GameConfigManager;
	import game.global.vo.FightUnitVo;
	
	import laya.debug.data.Base64AtlasManager;
	import laya.debug.tools.Base64Atlas;
	import laya.debug.tools.Base64Tool;
	import laya.utils.Dictionary;
	
	import org.flexunit.runner.notification.Failure;

	public class HeroEquipVo
	{
		public var unitId:int=0;
		public var equipList:Array=[];
		public var data:Object;
		public var level:int;
		public function HeroEquipVo()
		{
		}
		
		public function setEquipList(p_obj:Object):void
		{
			equipList=new Array();
			for (var i:int = 1; i < 7; i++) 
			{
				if(p_obj[i+""])
				{
					var l_equip:EquipInfoVo=new EquipInfoVo();
					l_equip.location=i;
					l_equip.setInfo(p_obj[i+""]);
					equipList.push(l_equip);
				}
			}
		}
		
		public function getEquipProperty():Dictionary
		{
			var dic:Dictionary=new Dictionary();
			var l_dicSuit:Dictionary=new Dictionary();
			if(equipList!=null)
			{
				for(var i:int=0;i<equipList.length;i++)
				{
					var l_equipVo:EquipInfoVo=equipList[i];
					var l_equipBaseInfo:EquipmentListVo=GameConfigManager.EquipmentList[l_equipVo.equip_item_id];
					if(l_equipBaseInfo.suit>0)
					{
						var l_equipSuitNum:int=l_dicSuit.get(l_equipBaseInfo.suit);
						if(l_equipSuitNum==null||l_equipSuitNum==undefined)
						{
							l_equipSuitNum=1;
						}
						else
						{
							l_equipSuitNum+=1;
						}
						l_dicSuit.set(l_equipBaseInfo.suit,l_equipSuitNum);
					}
				}
			}
			
			for(var i:int;i<equipList.length;i++)
			{
				var l_vo:EquipInfoVo=equipList[i];
				var l_equipmentIntensify:EquipmentIntensifyVo=getEquipStringInfo(l_vo.equip_item_id,l_vo.strong_level);
				var l_arr:Array=new Array();
				var l_baseVo:EquipmentListVo=GameConfigManager.EquipmentList[l_vo.equip_item_id];
				var l_baseAttr:Array=l_baseVo.getAttr();
				if(l_equipmentIntensify!=null)
				{
					l_arr=l_baseVo.getStrongAttr();
				}
				
				for(var j:int = 0; j < l_arr.length; j++)
				{
					var l_attVo:AttVo=l_arr[j];
					if(dic[l_attVo.name]==undefined)
					{
						dic[l_attVo.name]=0;
					}
					var num:int=dic[l_attVo.name];
					var maxNum:int=num+parseInt(l_attVo.num)*l_vo.strong_level;
					dic[l_attVo.name]=maxNum;
				}
				
				for(var j:int = 0; j < l_baseAttr.length; j++)
				{
					var l_attVo:AttVo=l_baseAttr[j];
					if(dic[l_attVo.name]==undefined)
					{
						dic[l_attVo.name]=0;
						
					}
					var num:int=dic[l_attVo.name];
					var maxNum:int=num+parseInt(l_attVo.num);
					dic[l_attVo.name]=maxNum;
				}
				
				
				for (var j:int = 0; j < l_vo.wash_effect.length; j++) 
				{
					var l_attVo:AttVo=l_vo.wash_effect[j];
					if(dic[l_attVo.name]==undefined)
					{
						dic[l_attVo.name]=0;
					}
					var num:int=dic[l_attVo.name];
					var maxNum:int=num+parseInt(l_attVo.num);
					dic[l_attVo.name]=maxNum;
				}
			}
			var l_num:int=0;
			for (var i:int = 0; i < l_dicSuit.keys.length; i++) 
			{
				var l_suitVoList:EquipmentSuitVo=getEquipmentSuitVo(l_dicSuit.keys[i]);
				if(l_suitVoList==null)
				{
					break;
				}
				var att2:Array=l_suitVoList.getAttr2();
				var att4:Array=l_suitVoList.getAttr4();
				var att6:Array=l_suitVoList.getAttr6();
				
				
				l_num=l_dicSuit.values[i]
				if(l_num<2)
				{
					break;
				}
				if(l_num>=2)
				{
					for (var j:int = 0; j < att2.length; j++) 
					{
						var l_attVo:AttVo=att2[j];
						if(dic[l_attVo.name]==undefined)
						{
							dic[l_attVo.name]=0;
						}
						var num:int=dic[l_attVo.name];
						var maxNum:int=num+parseInt(l_attVo.num);
						dic[l_attVo.name]=maxNum;
					}
				}
				if(l_num>=4)
				{
					for (var j:int = 0; j < att4.length; j++) 
					{
						if(att4[j].name!="skill2")
						{
							var l_attVo:AttVo=att4[j];
							if(dic[l_attVo.name]==undefined)
							{
								dic[l_attVo.name]=0;
							}
							var num:int=dic[l_attVo.name];
							var maxNum:int=num+parseInt(l_attVo.num);
							dic[l_attVo.name]=maxNum;
						}
						
						
					}
				}
				if(l_num>=6)
				{
					for (var j:int = 0; j < att6.length; j++) 
					{
						if(att6[j].name!="skill2")
						{
							var l_attVo:AttVo=att6[j];
							if(dic[l_attVo.name]==undefined)
							{
								dic[l_attVo.name]=0;
							}
							var num:int=dic[l_attVo.name];
							var maxNum:int=num+parseInt(l_attVo.num);
							dic[l_attVo.name]=maxNum;
						}
					}
				}
			}
			
			
			
			return dic;
		}
		
		private function getEquipmentSuitVo(p_id:int):EquipmentSuitVo
		{
			for (var i:int = 0; i < GameConfigManager.EquipmentSuitList.length; i++) 
			{
				var l_suitVo:EquipmentSuitVo=GameConfigManager.EquipmentSuitList[i]
				if(p_id==l_suitVo.suit)
				{
					return l_suitVo;
				}
			}
			
			return null;
		}
		
		
		
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
		
		
	}
}