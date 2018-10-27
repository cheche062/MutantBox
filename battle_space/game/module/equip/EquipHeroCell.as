package game.module.equip
{
	import MornUI.equip.EquipCellUI;
	import MornUI.equip.EquipHeroCellUI;
	import MornUI.friend.ChatInfoCellUI;
	
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.bag.ItemCell;
	import game.global.event.BagEvent;
	import game.global.event.EquipEvent;
	import game.global.event.Signal;
	import game.global.vo.FightUnitVo;
	import game.global.vo.equip.EquipInfoVo;
	import game.global.vo.equip.HeroEquipVo;
	import game.module.train.TrainItem;
	
	import laya.events.Event;
	import laya.net.Loader;
	import laya.resource.Texture;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.utils.Handler;
	
	
	public class EquipHeroCell extends Box
	{
		public var m_ui:EquipHeroCellUI;
		public var heroData:HeroEquipVo;
		public var isClick:Boolean;
		private var m_equipCellList:Array;
		private var m_HeroBgBtn:Button;
		public function EquipHeroCell(p_ui:EquipHeroCellUI)
		{
			super();
			m_ui=p_ui;
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			heroData=value;
			if(heroData!=null)
			{
				this.m_HeroBgBtn=new Button();
				initUI();
			}
		}
		
		private function initUI():void
		{
			isClick=true;
			m_equipCellList=new Array();
			var l_trainCell:TrainItem=new TrainItem();
			l_trainCell.dataSource=heroData;
			m_ui.EquipCell0.name="EquipCell_"+heroData.unitId+"_"+0;
			m_ui.EquipCell1.name="EquipCell_"+heroData.unitId+"_"+1;
			m_ui.EquipCell2.name="EquipCell_"+heroData.unitId+"_"+2;
			m_ui.EquipCell3.name="EquipCell_"+heroData.unitId+"_"+3;
			m_ui.EquipCell4.name="EquipCell_"+heroData.unitId+"_"+4;
			m_ui.EquipCell5.name="EquipCell_"+heroData.unitId+"_"+5;
//			m_ui.HeroBgBtn.skin="appRes/unpackUI/equip/btn_bg1.png";
			this.addChild(l_trainCell);
			l_trainCell.mouseEnabled=false;
			updateInfo(heroData);
			
//			this.m_ui.HeroBgBtn.selected=isClick;
//			this.m_ui.HeroBgBtn.on(Event.CLICK,this,setSelectBgHandler);
			
			
			var skllUrl:String = "equip/btn_bg1.png";
			var source:Texture = Loader.getRes(skllUrl);
			if (source) {
				m_HeroBgBtn.skin = "";
				m_HeroBgBtn.skin = skllUrl;
			} else Laya.loader.load(skllUrl, Handler.create(this, 
				function(url:String, img:*=null):void {
					m_HeroBgBtn.skin = "";
					m_HeroBgBtn.skin = skllUrl;
				}
				, [skllUrl]), null, Loader.IMAGE,1,true);
			m_ui.addChildAt(m_HeroBgBtn,0);
			this.m_HeroBgBtn.selected=isClick;
			this.m_HeroBgBtn.on(Event.CLICK,this,setSelectBgHandler);
			
//			var skllUrl:String = m_ui.HeroBgBtn.skin;
//			var source:Texture = Loader.getRes(skllUrl);
//			if (source) {
//				m_ui.HeroBgBtn.skin = "";
//				m_ui.HeroBgBtn.skin = skllUrl;
//			} else Laya.loader.load(skllUrl, Handler.create(this, 
//				function(url:String, img:*=null):void {
//					m_ui.HeroBgBtn.skin = "";
//					m_ui.HeroBgBtn.skin = skllUrl;
//				}
//				, [skllUrl]), null, Loader.IMAGE,1,true);

			
		}
		
		public function updateInfo(p_data:HeroEquipVo):void
		{
			heroData=p_data;
			m_ui.HeroLevelText.text=GameLanguage.getLangByKey("L_A_73")+heroData.data.level;
			m_ui.HeroNameText.text=GameConfigManager.unit_dic[heroData.unitId].name;
			if(heroData.equipList!=null)
			{
				for (var i:int = 0; i < 6; i++) 
				{
					var l_ui:EquipCellUI=m_ui.getChildByName("EquipCell_"+heroData.unitId+"_"+i)as EquipCellUI;
					l_ui.visible=!isClick;
					var l_cell:EquipCell=new EquipCell(l_ui,null);
				}
				for (var i:int = 0; i < heroData.equipList.length; i++) 
				{
					var l_vo:EquipInfoVo=heroData.equipList[i];
					var l_index:int=l_vo.location-1;
					var l_ui:EquipCellUI=m_ui.getChildByName("EquipCell_"+heroData.unitId+"_"+l_index)as EquipCellUI;
					
					l_ui.visible=!isClick;
					l_ui.mouseEnabled=l_ui.mouseThrough=true;
					var l_cell:EquipCell=new EquipCell(l_ui,l_vo);
					l_cell.mouseEnabled=l_cell.mouseThrough=true;
					m_equipCellList[l_index]=l_cell;
				}
				
				
				m_HeroBgBtn.selected=isClick;
//				this.m_ui.HeroBgBtn.selected=isClick;
			}
		}
		
		public function setSelectEquipCell(p_local:int):void
		{
			for (var i:int = 0; i < heroData.equipList.length; i++) 
			{
				var l_vo:EquipInfoVo=heroData.equipList[i];
				var l_index:int=l_vo.location-1;
				var l_cell:EquipCell=m_equipCellList[l_index]
				if(p_local==l_index)
				{
					l_cell.selected=true;
				}
				else
				{
					l_cell.selected=false;
				}
			}
			
		}
		
		private function setSelectBgHandler(e:Event):void
		{
			setSelectType();
			Signal.intance.event(EquipEvent.EQUIP_EVENT_CLICK,heroData);
		}
		
		public function setSelectType():void
		{
			m_HeroBgBtn.selected=!m_HeroBgBtn.selected;
			isClick=this.m_HeroBgBtn.selected;
			for (var i:int = 0; i < 6; i++) 
			{
				var l_ui:EquipCellUI=m_ui.getChildByName("EquipCell_"+heroData.unitId+"_"+i)as EquipCellUI;
				l_ui.visible=!this.m_HeroBgBtn.selected;
			}
		}
		
		public function getHeroBtn():Button
		{
			return m_HeroBgBtn;
		}
		
		public function getEquipCell():EquipCellUI
		{
			var l_ui:EquipCellUI=m_ui.getChildByName("EquipCell_"+heroData.unitId+"_"+0)as EquipCellUI;
			return l_ui;
		}
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new EquipHeroCellUI();
				this.addChild(m_ui);
			}
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			super.destroy(destroyed);
			//Loader.clearRes("equip/btn_bg1.png");
		}
	}
}