package game.module.pvp.cell
{
	import MornUI.pvpFight.PvpMathHeroUI;
	
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.UIUtils;
	
	public class MathHeroCell extends Box
	{
		public static const itemWidth:Number = 79;
		public static const itemHeight:Number = 79;
		private var _cellUi:PvpMathHeroUI;
		private var _data:Array;
		public function MathHeroCell()
		{
			super();
			
			size(itemWidth,itemHeight);
			addChild(cellUi);
			
			this.cellUi.mouseEnabled = true;
			this.cellUi.on(Event.CLICK,this,thisClick);
			
		}
		
		private function thisClick(e:Event):void
		{
			if(!_data)return;
			var item:Object = {
				unitId:_data[0]
			};
			XFacade.instance.openModule("UnitInfoView", [item]);
		}
		
		
		
		protected function get cellUi():PvpMathHeroUI{
			if(!_cellUi) _cellUi = new PvpMathHeroUI();
			return _cellUi;
		}
		
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			cellUi.icon.graphics.clear();
			if(_data && _data.length > 1)
			{
				cellUi.lockIcon.visible = false;
				var vo:FightUnitVo = GameConfigManager.unit_dic[_data[0]];
				cellUi.icon.loadImage(UnitPicUtil.getUintPic(vo.model,UnitPicUtil.ICON));
				this.filters = _data[1] ? null:[UIUtils.grayFilter];
			}else
			{
				this.filters = [UIUtils.grayFilter];
				cellUi.lockIcon.visible = true;
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy MathHeroCell");
			
			_data = null;
			_cellUi =null;
			this.cellUi.off(Event.CLICK,this,thisClick);
			super.destroy(destroyChild);
		}
		
		
	}
}