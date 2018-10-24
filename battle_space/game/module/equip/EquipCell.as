package game.module.equip
{
	import MornUI.equip.EquipCellUI;
	import MornUI.friend.ChatInfoCellUI;
	
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	import game.global.vo.equip.EquipInfoVo;
	
	import laya.display.Animation;
	import laya.ui.Box;
	
	public class EquipCell extends Box
	{
		private var m_ui:EquipCellUI;
		private var m_equipData:EquipInfoVo;
		public static const itemWidth:Number = 79;
		public static const itemHeight:Number = 79;
		
		protected var _selectEff:Animation;
		public function EquipCell(p_ui:EquipCellUI,p_equipData:EquipInfoVo)
		{
			super();
			m_ui=p_ui;
			m_equipData=p_equipData;
			init();
			if(m_ui!=null&&m_equipData!=null)
			{
				initUI();
			}
			else
			{
				m_ui.EquipImage.graphics.clear();
				m_ui.EquipLevelText.visible=false;
			}
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_equipData=value;
			if(m_equipData!=null)
			{
				initUI();
			}
			else
			{
				m_ui.EquipImage.graphics.clear();
				m_ui.EquipLevelText.visible=false;
			}	
		}
		
		public function get selectEff():Animation
		{
			if(!_selectEff)
			{
				_selectEff = new Animation();
				_selectEff.autoPlay = true;
				_selectEff.mouseEnabled = _selectEff.mouseThrough = false;
				var jsonStr:String = "appRes/atlas/bag/effects/select.json";
				_selectEff.loadAtlas(jsonStr);
				//				_selectEff.name = "selectBox";
				_selectEff.interval = 100;
				m_ui.addChild(_selectEff);
				_selectEff.x = itemWidth - 100 >> 1;
				_selectEff.y = itemHeight - 100 >> 1;
			}
			return _selectEff;
		}
		
		public override function set selected(value:Boolean):void{
			super.selected = value;
			//trace("selected========================================");
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
		
		private function initUI():void
		{
			m_ui.EquipImage.graphics.clear();
			var l_itemVo:ItemVo=GameConfigManager.items_dic[this.m_equipData.equip_item_id];
			
			
			var url:String = GameConfigManager.getItemImgPath(this.m_equipData.equip_item_id);
			
			m_ui.EquipImage.loadImage(url, 0,0,0,0/*,Handler.create(this, this.onLoaded)*/);
//			m_ui.ItemBarImage.skin= "common/item_bar"+(l_itemVo.quality-1)+".png";
			if(m_equipData.strong_level==undefined)
			{
				m_equipData.strong_level=0;
			}
			m_ui.EquipLevelText.visible=true;
			m_ui.EquipImage.visible=true;
			m_ui.EquipLevelText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_44002"),m_equipData.strong_level);
			
		}
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new EquipCellUI();
				this.addChild(m_ui);
			}
		}
	}
}