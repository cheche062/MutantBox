package game.module.TeamCopy
{
	import MornUI.relic.CarrierCellUI;
	import MornUI.teamcopy.TeamCopyCellUI;
	
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.event.TeamCopyEvent;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.User;
	import game.global.vo.teamCopy.TeamCopySoldierVo;
	import game.global.vo.teamCopy.TeamCopyUnitVo;
	import game.module.camp.ProTipUtil;
	import game.module.camp.UnitItem;
	import game.module.camp.UnitItemVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class TeamCopyCell extends Box
	{
		private var m_ui:TeamCopyCellUI;
		private var m_data:TeamCopyUnitVo;
		
		public function TeamCopyCell()
		{
			super();
			init();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			m_data=value;
			if(m_data!=null)
			{
				m_ui.visible=true;
				initUI();
			}
			else
			{
				m_ui.visible=false;
			}
		}
		
		
		private function initUI():void
		{
			m_ui.UnReadyBtn.visible=true;
			m_ui.AutoBtn.visible=true;
			m_ui.UnReadyBtn.skin="common/btn_7.png";
			m_ui.AutoBtn.skin="common/btn_7.png";
			m_ui.NameText.text=m_data.user_name;
			m_ui.LevelText.text=m_data.level;
			if(m_data.state==1)
			{
				m_ui.GouImage.visible=true;
				m_ui.UnReadyBtn.text.text=GameLanguage.getLangByKey("L_A_164");
			}
			else
			{
				m_ui.UnReadyBtn.text.text=GameLanguage.getLangByKey("L_A_14031");
				m_ui.GouImage.visible=false;
			}
			
			if(m_data.userIsMaster==true)
			{
//				m_ui.AutoBtn.visible=true;
//				m_ui.AutoBtn.y=35;
//				m_ui.UnReadyBtn.visible=false;
				if(m_data.uid!=User.getInstance().uid)
				{
					m_ui.BootBtn.visible=true;
				}
				else
				{
					m_ui.BootBtn.visible=false;
				}
			}
			else
			{
				m_ui.BootBtn.visible=false;
			}
			if(m_data.uid!=User.getInstance().uid)
			{
				m_ui.UnReadyBtn.visible=false;
				m_ui.AutoBtn.visible=false;
			}
			createList();
			this.m_ui.AutoBtn.on(Event.CLICK,this,onAutoHandler);
			this.m_ui.BootBtn.on(Event.CLICK,this,onBootHandler);
			this.m_ui.UnReadyBtn.on(Event.CLICK,this,onReadyHandler);
		}
		
		private function onReadyHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_READY,m_data);
		}
		
		private function onBootHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_BOOT,m_data);
		}
		
		private function onAutoHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			if(m_data.state==1)
			{
				Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_READY,m_data);
			}
			Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_AUTO,m_data);
		}
		
		private function createList():void
		{
			polishingList();
			m_ui.SoldierList.itemRender=TeamCopyUnitCell;
			if(m_data.uid==User.getInstance().uid)
			{
				m_ui.SoldierList.selectEnable=true;
			}
			m_ui.SoldierList.selectedIndex=-1;
			m_ui.SoldierList.array=m_data.unit_list;
			
			m_ui.SoldierList.selectHandler=new Handler(this, onHeroSelect);
			
			if(m_data.uid!=User.getInstance().uid)
			{
				for (var i:int = 0; i < m_ui.SoldierList.array.length; i++) 
				{
					var l_cell:TeamCopyUnitCell=m_ui.SoldierList.getCell(i) as TeamCopyUnitCell;
					l_cell.AddBtn.visible=false;
				}
			}
		}
		
		private function onHeroSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			if(p_index<0)
			{
				return;
			}
			var _selectedItem:TeamCopyUnitCell = m_ui.SoldierList.getCell(p_index) as TeamCopyUnitCell;
			var data:TeamCopySoldierVo = _selectedItem.teamCopyData;
			if(data){
				if(XUtils.checkHit(_selectedItem.attackIcon)){
					ProTipUtil.showAttTip(_selectedItem.data.id);
				}else if(XUtils.checkHit(_selectedItem.defendIcon)){
					ProTipUtil.showDenTip(_selectedItem.data.id);
				}else{
					/**如果是解散*/
					if(!_selectedItem.minusBtn.disabled && _selectedItem.minusBtn.visible && _selectedItem.minusBtn.mouseX > 0 && _selectedItem.minusBtn.mouseY > 0){
						
							
						Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_UN_UNITCELL,p_index);
						
					}
					else
					{
						Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_UNITCELL,p_index);
					}
				}		
			}
			else
			{
				Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_UNITCELL,p_index);
			}
			
			if(m_data.state==1)
			{
				Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_READY,m_data);
			}
			m_ui.SoldierList.selectedIndex=-1;
		}
		
		private function polishingList():void
		{
			for (var i:int = 0; i < 3; i++) 
			{
				if(m_data.unit_list.length<(i+1))
				{
					m_data.unit_list[i]=null;
				}
			}
			
			m_ui.UnReadyBtn.gray=true;
			for (var i:int = 0; i< m_data.unit_list.length; i++) 
			{ 
				if(m_data.unit_list[i]!=null)
				{
					m_ui.UnReadyBtn.gray=false;
				}	
			}
		}
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new TeamCopyCellUI();
				this.addChild(m_ui);
			}
		}
	}
}