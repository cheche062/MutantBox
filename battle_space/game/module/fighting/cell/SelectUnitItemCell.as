package game.module.fighting.cell
{
	import MornUI.fightingView.SelectUnitItemCellUI;
	
	import game.common.ItemTips;
	import game.global.util.UnitPicUtil;
	import game.module.fighting.adata.ArmyData;
	
	import laya.events.Event;
	
	public class SelectUnitItemCell extends SelectUnitItemCellUI implements ISelectUnitCell
	{
		private var _data:ArmyData;
		
		public function SelectUnitItemCell()
		{
			super();
		}
		
		
		public function get data():ArmyData
		{
			return _data;
		}
		
		public function set data(value:ArmyData):void
		{
			
			_data = value;
			
			if(data)
			{
				faceImg.graphics.clear();
				faceImg.loadImage(UnitPicUtil.getUintPic(data.unitVo.model,UnitPicUtil.PIC_SEL));
				numLbl.text= data.num;
				xLbl.x = numLbl.x  - numLbl.textField.textWidth - xLbl.width + numLbl.width + 5;
				heroName.text = data.unitVo.name;
				flag.skin = "common/l"+(data.unitVo.rarity - 1)+"_1.png"
			}
			
		}
		
		public function getEnabled(showError:Boolean = false):Boolean{
			return true;
		}
	
		public override function set dataSource(value:*):void{
			super.dataSource = data = value;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			infoBtn.on(Event.CLICK,this,infoBtnClick);
		}
		
		private function infoBtnClick(e:Event):void
		{
			if(data.unitVo.itemVo)
			{
				ItemTips.showTip(data.unitVo.itemVo.id);
			}
			e.stopPropagation();
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			infoBtn.off(Event.CLICK,this,infoBtnClick);
			_data = null;
			
			super.destroy(destroyChild);
			trace("SelectUnitItemCell ~~~~  destroy");
			
		}
		
		
	}
}