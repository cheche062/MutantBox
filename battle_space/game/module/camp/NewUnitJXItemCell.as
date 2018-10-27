package game.module.camp
{
	import MornUI.camp.NewUnitJXItemCellUI;
	
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.AwakenEqVo;
	import game.global.vo.AwakenVo;
	
	public class NewUnitJXItemCell extends NewUnitJXItemCellUI
	{
		public static const itemWidth:Number = 79;
		public static const itemHeight:Number = 79;
		
		public function NewUnitJXItemCell()
		{
			super();
		}
		
		
		private var _data:Array ;
		/**
		 *	[id, AwakenEqVo,（是否打开）1：打开 2：不打开] 
		 * @param value
		 * 
		 */
		public override function set dataSource(value:*):void{
			_data = value;
			if(_data)
			{
				var unitId:Number = _data[0];
				var vo:AwakenEqVo = _data[1];
				var isOpen:Number = Number(_data[2]);
				
				this.itemFace.skin = GameConfigManager.getItemImgPath((vo.cost[0] as ItemData).iid);
				
				
				if(isOpen)
				{
					this.upBtn.visible = false;
					this.itemFace.alpha = 1;
//					trace("【NewUnitJXItemCell】isOpen", isOpen);
					return ;
				}

//				this.itemFace.alpha = 1;
				this.upBtn.visible = true;
				this.itemFace.alpha = .3;
				
				var states:Array  = vo.getStates(unitId);
				this.upBtn.disabled  = states.length > 0;
				
//				trace("【NewUnitJXItemCell】item ", this.upBtn.disabled);
			}else
			{
//				trace("NewUnitJXItemCell bind null");
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_data = null;
			super.destroy(destroyChild);
		}
	}
}