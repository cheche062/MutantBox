package game.module.TeamCopy
{
	import MornUI.teamcopy.TeamCopyCellUI;
	import MornUI.teamcopy.TeamCopyRoomInfoCellUI;
	
	import game.global.GameLanguage;
	import game.global.data.bag.ItemCell;
	import game.global.event.Signal;
	import game.global.event.TeamCopyEvent;
	import game.global.vo.teamCopy.TeamCopyRoomVo;
	import game.global.vo.teamCopy.TeamCopyUnitVo;
	import game.global.vo.teamCopy.TeamFightLevelVo;
	
	import laya.events.Event;
	import laya.ui.Box;
	
	public class TeamCopyRoomInfoCell extends Box
	{
		private var m_ui:TeamCopyRoomInfoCellUI;
		private var m_data:TeamCopyRoomVo;
		public function TeamCopyRoomInfoCell()
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
				initUI();
			}
		}
		
		private function initUI():void
		{
			var l_levelVo:TeamFightLevelVo=m_data.getLevelVo();
			
			m_ui.RestrictionsUseText.text=GameLanguage.getLangByKey("L_A_14016");
			m_ui.RoomLevelText.text=GameLanguage.getLangByKey("L_A_14015");
			m_ui.NameText.text=m_data.user_name;
			m_ui.PlayerLevelText.text=m_data.level;
			m_ui.RoomLevelText.text=GameLanguage.getLangByKey("L_A_73")+l_levelVo.xsdj;
			m_ui.RestrictionsUseText.text=GameLanguage.getLangByKey(l_levelVo.rq_text1);
			m_ui.RewardList.itemRender=ItemCell;
			m_ui.RewardList.array=l_levelVo.getRewardList();
			
			if(l_levelVo.double==1)
			{
				m_ui.DoubleImage.visible=true;
			}
			else
			{
				m_ui.DoubleImage.visible=false;
			}
			this.m_ui.JoinBtn.on(Event.CLICK,this,onJoinHandler);
			
			m_ui.NumText.text=m_data.teamList.length+"/3";
		}
		
		private function onJoinHandler(e:Event):void
		{
			
			// TODO Auto Generated method stub
			Signal.intance.event(TeamCopyEvent.TEAMCOPY_CLICK_JOIN,m_data);
		}		
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new TeamCopyRoomInfoCellUI();
				this.addChild(m_ui);
			}
		}
	}
}