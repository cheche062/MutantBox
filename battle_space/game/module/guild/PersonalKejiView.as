package game.module.guild
{
	import MornUI.guild.PersonalKejiViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * 个人科技
	 * @author hejianbo
	 * 
	 */
	public class PersonalKejiView extends BaseView
	{
		/**状态数据*/
		public var state:GuildMainStateVo;
		/**当前技能提升的消耗*/
		public var consume_value:int;
		public function PersonalKejiView()
		{
			super();
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			view.dom_list.itemRender = PersonalKejiItem;
			view.dom_list.hScrollBarSkin = "common/hscrollBarr.png";
			view.dom_list.array = null;
			
			addEvent();
		}
		
		public function addToStageRender():void {
			state = GuildMainView.state;
			
			view.dom_icon.skin = GameConfigManager.getItemImgPath(6);
			view.dom_fund.text = state.personal_fund;
		}
		
		/**技能升级效果公式  id 公式id*/
		private function effectFormula(num:int, level:int):int{
			return formula(33, num, level);
		}
		
		/**技能升级消耗公式 */
		private function consumeFormula(num:int, level:int):int{
			return formula(34, num, level);
		}
		
		private function formula(id, num, level):int {
			var guild_canshu = ResourceManager.instance.getResByURL("config/guild_canshu.json");
			var scoreFormula = guild_canshu[id].value;
			scoreFormula = scoreFormula.replace(/\\\$param1/g, num).replace(/\\\$param2/g, level);
			
			return __JS__("eval(scoreFormula)");
		}
		
		/**获取服务器消息*/
		private function serviceEventHandler(...args):void {
			trace("【个人科技】", args);
			switch(args[0])
			{
				case ServiceConst.GUILD_PERSONAL_SKILL:
					state.personal_keji = args[1];
					var array:Array = createListData(state.personal_keji);
					view.dom_list.array = array;
					
					break;
				
				case ServiceConst.GUILD_PERSONAL_SKILL_UP:
					state.personal_fund = state.personal_fund - consume_value;
					ToolFunc.copyDataSource(state.personal_keji, args[1]);
					var array:Array = createListData(state.personal_keji);
					view.dom_list.array = array;
					addToStageRender();
					
					break;
				
				default:
					break;
			}
		}
		
		private function createListData(arr:Array):Array {
			var data = arr || [];
			var guild_attribute = ResourceManager.instance.getResByURL("config/guild_attribute.json");
			var callBack:Function = sendSkillUpHandler.bind(this);
			var guildLevel = GuildMainView.state.level;
			var result:Array = ToolFunc.objectValues(guild_attribute).map(function(item) {
				var _skill_level = data[item.id] ? data[item.id] : 0;
				var consumeValue:int = consumeFormula(item.expend.split("=")[1], Number(_skill_level) + 1);
				var effectValue:int = effectFormula(item.skill_value.split("=")[1], _skill_level);
				
				var next_effectValue = (_skill_level == item.max_level) ? 
				GameLanguage.getLangByKey("L_A_3037") : effectFormula(item.skill_value.split("=")[1], Number(_skill_level) + 1);
				var skill_des = GameLanguage.getLangByKey(item.skill_des)
				.replace("{0}", effectValue).replace("{1}", next_effectValue).replace('##', "\n");
				
				return {
					"id": item.id,
					"icon": "appRes/icon/buff_big/"+ item.icon + ".png",
					"skill_name": item.skill_name,
					"level": "LV. " + _skill_level,
					"skill_des": skill_des,
					"skill_consume": consumeValue,
					"isGray": item.open_limit > guildLevel,
					"isMaxLevel": data[item.id] == item.max_level,
					"isEnoughToUpgrade": consumeValue <= GuildMainView.state.personal_fund,
					"open_limit": "Require Guild Lv." + item.open_limit,
					"callBack": callBack
				}
			});
			
			return result;
		}
		
		/**发送技能提升*/
		private function sendSkillUpHandler(id, num):void {
			consume_value = num;
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_PERSONAL_SKILL_UP, [id]);
		}
		
		private function addToStageHandler():void {
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_PERSONAL_SKILL), this, serviceEventHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_PERSONAL_SKILL_UP), this, serviceEventHandler);
			addToStageRender();
			
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_PERSONAL_SKILL);
		}
		
		private function removeFromStageHandler():void {
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_PERSONAL_SKILL), this, serviceEventHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_PERSONAL_SKILL_UP), this, serviceEventHandler);
		}
		
		override public function addEvent():void{
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.off(Event.ADDED, this, addToStageHandler);
			this.off(Event.REMOVED, this, removeFromStageHandler);
			
			super.removeEvent();
		}
		
		private function get view():PersonalKejiViewUI{
			_view = _view || new PersonalKejiViewUI();
			return _view;
		}
	}
}