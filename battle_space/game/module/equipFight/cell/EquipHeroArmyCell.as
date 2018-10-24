package game.module.equipFight.cell
{
	import MornUI.equipFight.heroArmyCellBoxUI;
	
	import game.common.ResourceManager;
	import game.global.util.UnitPicUtil;
	import game.module.fighting.adata.ArmyData;
	
	public class EquipHeroArmyCell extends heroArmyCellBoxUI
	{
		public var data:ArmyData;
		
		public function EquipHeroArmyCell()
		{
			super();
			this.size(79,120);
			this.mouseEnabled = true;
		}
		
	
		public override function set dataSource(value:*):void{
			super.dataSource = data = value;
			if(data)
			{
				this.heroFace.visible = this.numLbl.visible = true;
				this.heroFace.graphics.clear();
				this.heroFace.loadImage(UnitPicUtil.getUintPic(data.unitId,UnitPicUtil.ICON_SKEW));
				this.numLbl.text= String(data.num);
				this.rkLbl.text = String(data.unitVo.population);
				this.maxLb.text = data.unitVo.num_limit+"";
//				this.numLbl.visible = data.num > 1;  //
//				this.bgImg.mouseEnabled = this.bgImg.mouseThrough = true;
				this.numLbl.visible = !data.unitVo.isHero;
				this.rkBox.visible = !data.unitVo.isHero;
				
				this.disabled = !data.num || data.disabled;
			}else
			{
				this.heroFace.visible = this.numLbl.visible = false;
				this.numLbl.visible = false;
				this.rkBox.visible = false;
			}
		} 
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy EquipHeroArmyCell");
			data = null;
			super.destroy(destroyChild);
		}
	}
}