package game.module.monterRiot
{
	import MornUI.monsterRush.MonsterRushItemUI;
	
	import game.global.GameLanguage;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingAttribute;
	import game.global.data.DBBuildingUpgrade;
	import game.global.util.ItemUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.BuildingVo;
	import game.global.vo.User;
	import game.module.mainui.SceneVo;
	
	import laya.net.URL;
	
	/**
	 * MonsterRiotItem
	 * author:huhaiming
	 * MonsterRiotItem.as 2017-3-31 下午3:53:16
	 * version 1.0
	 *
	 */
	public class MonsterRiotItem extends MonsterRushItemUI
	{
		private var _data:Object
		public function MonsterRiotItem()
		{
			super();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			this._data = value;
			
			if(_data){
				var buInfo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId,1);
				this.icon.skin = URL.formatURL("appRes/building/"+buInfo.building_id+".png");
				var vo:Object = DBBuilding.getBuildingById(_data.buildId);
				var bid:String = (_data.buildId+"").replace("B", "");
				if(vo){
					this.nameTF.text = GameLanguage.getLangByKey(vo.name) +"";
					
				}
				//todo图标
				//防御塔-----
				var _lvData:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level);
				if(_data.buff && _data.buff.ATK){
					var vo:Object = DBBuildingAttribute.getAttr(_lvData.buldng_stats);
					if(vo){
						this.valueTF_0.text = Math.round(vo.ATK)+"";
						this.valueTF_1.text = Math.round(vo.ATK * (1+parseFloat(_data.buff.ATK[1])) + _data.buff.ATK[0])+"";
						this.icon_0.skin = "common/icons/icon_attack.png";
						this.icon_1.skin = "common/icons/icon_attack.png";
					}
				}else if(_data.buff && _data.buff.PRD){
					const arr:Array = [DBBuilding.B_FOOD_F, DBBuilding.B_GOLD_F, DBBuilding.B_STEEL_F, DBBuilding.B_STONE_F];
					var cap:Number = parseFloat((_lvData.buldng_capacty+"").split("=")[1]);
					if(arr.indexOf(bid) != -1){
						cap = parseFloat((_lvData.buldng_output+"").split("=")[1]);
						this.valueTF_0.text = Math.round(cap*60)+"/H";
					}else{
						this.valueTF_0.text = Math.round(cap)+"";
					}
					ItemUtil.formatIcon(this.icon_0, _lvData.buldng_output || _lvData.buldng_capacty);
					trace("_lvData.buldng_output.............",_lvData.buldng_output);
					
					this.valueTF_1.text = Math.round(cap * (1+parseFloat(_data.buff.PRD[1])) + _data.buff.PRD[0])+"";
					if(arr.indexOf(bid) != -1){
						this.valueTF_1.text = Math.round(cap*60 * (1+parseFloat(_data.buff.PRD[1])) + parseFloat(_data.buff.PRD[0]))+"/H"
					}else{
						this.valueTF_1.text = Math.round(cap * (1+parseFloat(_data.buff.PRD[1])) + _data.buff.PRD[0])+"";
					}
					ItemUtil.formatIcon(this.icon_1, _lvData.buldng_output || _lvData.buldng_capacty);
				}else{
					this.valueTF_0.text = "";
					this.valueTF_1.text = "";
				}
			}
			//
			trace("format data____________________________________",this._data);
		}
	}
}