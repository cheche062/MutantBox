package game.module.armyGroup 
{
	import MornUI.armyGroup.ArmyGroupNPCItemUI;
	
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.module.armyGroup.newArmyGroup.StarVo;
	import game.net.socket.WebSocketNetService;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupNPCItem extends BaseView 
	{
		
		private var npcData:Object = { };
		private var _npcCount:int = 999999;
		
		public function ArmyGroupNPCItem() 
		{
			super();
			
		}
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			npcData= value
			
			view.npcNTxt.text = GameLanguage.getLangByKey(GameConfigManager.ArmyGroupNpcList[value.budui_id].npc_name);
			
			if(npcData.guild_id == User.getInstance().guildID){
				view.imgBg.skin = 'armyGroup/bg14_green.png';
			}
			else{
				view.imgBg.skin = 'armyGroup/bg14.png';
			}
			
			var starData:StarVo = ArmyGroupMapView.open_planet_data[parseInt(npcData.city_id)];
			view.planeNTxt.text = starData ? GameLanguage.getLangByKey(starData.name) : "";
			if (npcData.status == 1|| npcData.status == 3)
			{
				view.goBtn.visible = true;
				
				
				if (npcData.status == 3)
				{
					view.warTTxt.text = GameLanguage.getLangByKey("L_A_23015");
				}
				else
				{
					view.warTTxt.text = GameLanguage.getLangByKey("L_A_21008");
				}
			}
			else
			{
				_npcCount = npcData.war_time - parseInt(TimeUtil.now / 1000);
//				view.planeNTxt.text = "-"
				view.goBtn.visible = false;
			}
			
			view.goBtn.visible = !!ArmyGroupMapView.open_planet_data[npcData.city_id];
		}
		
		private function onClickHandler(e:Event):void 
		{
			switch(e.target)
			{
				case view.goBtn:
					Signal.intance.event(ArmyGroupEvent.GO_NPC_PLANT, [npcData.city_id]);
					
					break;
			}
		}
		
		private function timeCountHandler():void
		{
			if (npcData.status == 1 || npcData.status == 3)
			{
				
				if (npcData.status == 3)
				{
					view.warTTxt.text = GameLanguage.getLangByKey("L_A_23015");
				}
				else
				{
					view.warTTxt.text = GameLanguage.getLangByKey("L_A_21008");
				}
				return;
			}
			_npcCount--;
			if (_npcCount <= 0)
			{
				_npcCount = 0;
				npcData.status = 1;
				//				WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_NPC_INFO);
			}
			view.warTTxt.text = TimeUtil.getTimeCountDownStr(_npcCount, false);
		}
		
		
		override public function createUI():void
		{
			this._view = new ArmyGroupNPCItemUI
			view.cacheAsBitmap = true;
			this.addChild(_view);
			addEvent();
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
			timeCountHandler();
			Laya.timer.loop(1000, this, timeCountHandler);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
			Laya.timer.clear(this, timeCountHandler);
		}
		
		private function get view():ArmyGroupNPCItemUI{
			return _view;
		}
		
	}
	
}