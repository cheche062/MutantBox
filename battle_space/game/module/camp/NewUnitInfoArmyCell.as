package game.module.camp
{
	import MornUI.camp.NewUnitInfoArmyCellUI;
	
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.module.fighting.adata.ArmyData;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.UIGroup;
	import laya.ui.UIUtils;
	
	public class NewUnitInfoArmyCell extends Box
	{
		public static const itemWidth:Number = 79;
		public static const itemHeight:Number = 79;
		private var _cellUi:NewUnitInfoArmyCellUI;
		private var _data:ArmyData;
		protected var _selectEff:Animation;
		private var _dom_redDot: Sprite;
		public function NewUnitInfoArmyCell()
		{
			super();
			
			size(itemWidth,itemHeight);
			addChild(cellUi);
			
			this.cellUi.mouseEnabled = true;
//			this.cellUi.on(Event.CLICK,this,thisClick);
		}
		
		public function get selectEff():Animation
		{
			if(!_selectEff)
			{
				_selectEff = new Animation();
				_selectEff.autoPlay = true;
				_selectEff.mouseEnabled = _selectEff.mouseThrough = false;
				var jsonStr:String = "appRes/effects/bag_select.json";
				_selectEff.loadAtlas(jsonStr);
//								_selectEff.name = "selectBox";
				_selectEff.interval = 100;
				addChild(_selectEff);
				_selectEff.x = itemWidth - 100 >> 1;
				_selectEff.y = itemHeight - 100 >> 1;
			}
			return _selectEff;
		}
		
		
		
		protected function get cellUi():NewUnitInfoArmyCellUI{
			if(!_cellUi) _cellUi = new NewUnitInfoArmyCellUI();
			return _cellUi;
		}
		
		
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			if(_data){
				cellUi.faceImg.visible = true;
				cellUi.faceImg.skin = UnitPicUtil.getUintPic(_data.unitVo.model,UnitPicUtil.ICON);
				var level:* = 1;
				if(_data.serverData)
					level = _data.serverData.level;
				cellUi.levelLbl.text = "Lv"+ level;
				cellUi.gray = (_data.serverData == null)
				//cellUi.filters = _data.serverData ? null : [UIUtils.grayFilter];
				cellUi.bgImg.skin = "newUnitInfo/f"+_data.unitVo.rarity + ".png";
				
//				判断是否需要显示小红点
				cellUi.dom_red.visible = !!value.showRedPoint;
				
//				trace("【NewUnitInfoArmyCell】", value);
					
			}else{
//				cellUi.faceImg.graphics.clear();
				cellUi.faceImg.visible = false;
				cellUi.levelLbl.text = "";
			}
		}
		
		
		public override function set selected(value:Boolean):void{
			super.selected = value;
			if(value)
			{
				selectEff.visible = value;
			}
			else
			{
				if(_selectEff)
					selectEff.visible = value;
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy NewUnitInfoArmyCell");
			
			_data = null;
			_cellUi =null;
			_selectEff = null;
//			this.cellUi.off(Event.CLICK,this,thisClick);
			super.destroy(destroyChild);
		}
		
		
	}
}