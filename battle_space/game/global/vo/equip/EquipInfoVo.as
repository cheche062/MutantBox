package game.global.vo.equip
{
	import game.global.GameConfigManager;

	public class EquipInfoVo
	{
		public var equip_item_id:int;
		public var strong_level:int;
		public var wash_effect:Array;
		public var location:int;
		public function EquipInfoVo()
		{
		}
		
		public function setInfo(p_obj:Object):void
		{
			this.equip_item_id=p_obj.equip_item_id;
			this.strong_level=p_obj.strong_level;
			setWashEffect(p_obj.wash_effect);
		}
		
		public function setWashEffect(p_obj:Object):void
		{
			wash_effect = new Array();
			var l_vo:EquipmentMaxVo=getWashInfo(equip_item_id);
			if(l_vo!=null)
			{
				var l_attArr:Array=l_vo.getAttr();
				for(var i:int=0;i<l_attArr.length;i++)
				{
					var l_attVo:AttVo=l_attArr[i];
					
					if(p_obj!=null)
					{
						var l_change:int= p_obj[l_attVo.name];
						if(l_change!=null && l_change!=undefined)
						{
							l_attVo.num=l_change;
							l_attArr[i]=l_attVo;
							wash_effect.push(l_attVo);
						}
					}
				}
			}
		}
		
		private function getWashInfo(p_id:int):EquipmentMaxVo
		{
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentMaxList.length; i++) 
			{
				var l_vo:EquipmentMaxVo=GameConfigManager.EquipmentMaxList[i];
				if(l_equipVo.level==l_vo.level && l_equipVo.quality==l_vo.quality)
				{
					return l_vo;
				}
			}
			return null;
		}
	}
}