package game.module.relic
{
	import MornUI.equip.EquipCellUI;
	import MornUI.relic.LevelUpCellUI;
	import MornUI.relic.TrainLogCellUI;
	
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.event.EquipEvent;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.ItemVo;
	import game.module.fighting.adata.frSoldierData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.panel.BaseFightResultsView;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class TrainLogCell extends Box
	{
		private var m_ui:TrainLogCellUI;
		private var m_data:Object;
		private var m_type:int;
		public var isClick:Boolean;
		public function TrainLogCell()
		{
			super();
			init();
		}
		
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			setData(value);
			initUI();
		}
		
		
		private function setData(value:*):void
		{
			if(value){
				if(value is String){
					this.m_data = JSON.parse(value);
				}else{
					this.m_data = value;
				}
			}
		}
		
		
		private function initUI():void
		{
			isClick=true;
			initUIData();
			this.m_ui.LogBtn.on(Event.CLICK,this,setSelectBgHandler);
			this.m_ui.ReplayBtn.on(Event.CLICK,this,onReplayHandler);
		}
		
		private function onReplayHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			Signal.intance.event(TrainBattleLogEvent.TRAIN_REPLAY_EVENT_CLICK,m_data);
		}
		
		private function setSelectBgHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			setSelectType();
			Signal.intance.event(TrainBattleLogEvent.TRAIN_LOG_EVENT_CLICK,m_data);
		}
		
		private function initUIData():void
		{
			if(m_data.isWin==1)
			{
				m_ui.LogBuchImage.skin="relic/icon_win.png";
			}
			else
			{
				m_ui.LogBuchImage.skin="relic/icon_lose.png";
			}
			
			m_ui.PlayerNameText.text=m_data.name+"";
			m_ui.LevelText.text=m_data.level+"";
			this.m_ui.LogBtn.selected=isClick;
			var arr:Array = [];
			m_ui.AttackLostList.itemRender = FightResultsSoldierCell;
			for (var i:int = 0; i < m_data.army.length; i++) 
			{
				var sdata:Object = m_data.army[i];
				var sod:frSoldierData = new frSoldierData();
				sod.addExp = Number(sdata.addExp);
				sod.uid = Number(sdata.id);
				sod.uExp = Number(sdata.exp);
				sod.uLev = Number(sdata.level);
				sod.uNum = Number(sdata.surplus);
				sod.uMaxNum = Number(sdata.total);	
				arr.push(sod);
			}
			
			this.m_ui.BattleInfoBox.visible=!isClick;
			m_ui.AttackLostList.array = BaseFightResultsView.filterSoldierData(arr);
			m_ui.AttackLostList.refresh();
			
		}
		
		public function setType(p_type:int):void
		{
			if(p_type==1)
			{
				m_ui.LogBuchText.text="Reward:";
				if(m_data.itemsGet!=null&&m_data.itemsGet!=undefined&&m_data.itemsGet.length>0)
				{
					m_ui.ItemList.visible=true;
					m_ui.NullText.visible=false;
					m_ui.ItemList.itemRender=PlanRewardCell;
					m_ui.ItemList.selectEnable = true;
					m_ui.ItemList.selectHandler=new Handler(this, onHeroSelect);
					m_ui.ItemList.array=getList(m_data.itemsGet);
//					for (var i:int = 0; i < m_data.itemsGet.length; i++) 
//					{
//						var l_data:Object=m_data.itemsGet[i];
//						var itemvo:ItemVo=GameConfigManager.items_dic[l_data.id];
//						m_ui.ItemImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
//						m_ui.ItemNumText.text=l_data.num;
//						m_ui.ItemImage.visible=true;
//						m_ui.NullText.visible=false;
//					}
				}
				else
				{
					m_ui.ItemList.visible=false;
					m_ui.NullText.visible=true;
				}
			}
			else
			{
				m_ui.LogBuchText.text="Lost:";
				if(m_data.itemsLost!=null&&m_data.itemsLost!=undefined&&m_data.itemsLost.length>0)
				{
					m_ui.ItemList.visible=true;
					m_ui.NullText.visible=false;
					m_ui.ItemList.itemRender=PlanRewardCell;
					m_ui.ItemList.selectEnable = true;
					m_ui.ItemList.selectHandler=new Handler(this, onHeroSelect);
					m_ui.ItemList.array=getList(m_data.itemsLost);
					
//					for (var i:int = 0; i < m_data.itemsLost.length; i++) 
//					{
//						var l_data:Object=m_data.itemsLost[i];
//						var itemvo:ItemVo=GameConfigManager.items_dic[l_data.id];
//						m_ui.ItemImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
//						m_ui.ItemNumText.text=l_data.num;
//						m_ui.ItemImage.visible=true;
//						m_ui.NullText.visible=false;
//					}	
				}
				else
				{
					m_ui.ItemList.visible=false;
					m_ui.NullText.visible=true;
				}
			}
			
		}
		
		private function onHeroSelect():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function getList(p_arr:Array,p_num:int=-1):Array
		{
			var l_arr:Array=new Array();
			for(var i:int=0;i<p_arr.length;i++)
			{
				var l_vo:ItemData=new ItemData();
				l_vo.iid=p_arr[i].id;
				l_vo.inum=p_arr[i].num;
				if(p_num!=-1)
				{
					l_vo.inum=p_num;
				}
				l_arr.push(l_vo);
			}
			return l_arr;
		}
		
		
		public function updateInfo(p_str:*):void
		{
			setData(p_str);
			initUIData();
		}
		
		public function setSelectType():void
		{
			this.m_ui.LogBtn.selected=!this.m_ui.LogBtn.selected;
			isClick=this.m_ui.LogBtn.selected;
			this.m_ui.BattleInfoBox.visible=!this.m_ui.LogBtn.selected;
		}
		
		
		/**
		 * 初始化控件
		 */		
		private function init():void{
			if(!m_ui){
				m_ui = new TrainLogCellUI();
				this.addChild(m_ui);
			}
		}
	}
}