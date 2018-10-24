package game.module.guild
{
	import MornUI.guild.GuildKejiViewUI;
	import MornUI.guild.GuildStoreViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.VoHasTool;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * 公会科技
	 * @author hejianbo
	 * 
	 */
	public class GuildKejiView extends BaseView
	{
		public function GuildKejiView()
		{
			super();
		}
		
		private function addToStageHandler():void 
		{
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_OPEN_STORE), this, this.serviceEventHandler);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_BUY_GOODS), this, this.serviceEventHandler);
			
//			WebSocketNetService.instance.sendData(ServiceConst.GUILD_OPEN_STORE, []);
			addToStageRender();
		}
		
		private function removeFromStageHandler():void 
		{
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_OPEN_STORE), this, this.serviceEventHandler);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_BUY_GOODS), this, this.serviceEventHandler);
		}
		
		
		override public function createUI():void{
			this.addChild(view);
			
			//init scrollbar
			
			view.dom_list.hScrollBarSkin = "common/hscrollBarr.png";
			view.dom_list.array = null;
			
			addEvent();
		}
		
		public function addToStageRender():void {
			var data_level = ResourceManager.instance.getResByURL("config/guild_level.json");
			var data_skill = ResourceManager.instance.getResByURL("config/guild_skill.json");
			var data_skill_obj = {};
			ToolFunc.objectValues(data_skill).forEach(function(item) {
				data_skill_obj[item.id] = item; 
			});
			var target_data = ToolFunc.getTargetItemData(data_level, "level", GuildMainView.state.level); 
			var skills_List:Array = target_data["guild_skill"].split(";");
			
			var array:Array = skills_List.map(function(item:String, index:int) {
				var currentData = data_skill_obj[item];
				var nextData = data_skill_obj[Number(item) + 1];
				return {
					"dom_bg": "guild/guildMainView/kj" + (index + 1) + ".png",
					"dom_name": currentData.name,
					"dom_level": "LEVEL " + currentData.skill_level,
					"dom_current": formateText(GameLanguage.getLangByKey(currentData.explain), currentData.skill_effect),
					"dom_next": nextData ? formateText(GameLanguage.getLangByKey(nextData.explain), nextData.skill_effect): "L_A_73125"
				}
			});
			
			view.dom_list.array = array;
		}
		
		private function formateText(text:String, effect:String):String {
			effect.split(";").forEach(function(item) {
				text = text.replace(/\{\d\}/, item);
			});
			return text;
		}
		
		override public function addEvent():void{
//			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
//			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageHandler);
			this.off(Event.REMOVED, this, removeFromStageHandler);
			
			super.removeEvent();
		}
		
		private function get view():GuildKejiViewUI{
			_view = _view || new GuildKejiViewUI();
			return _view;
		}
		
		
	}
}