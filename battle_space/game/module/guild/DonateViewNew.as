package game.module.guild
{
	import MornUI.guild.DonateViewUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * 公会捐献新的
	 * @author hejianbo
	 * 
	 */
	public class DonateViewNew extends BaseView
	{
		public function DonateViewNew()
		{
			super();
		}
		
		/**添加进舞台渲染*/
		public function addToStageRender():void {
			updateListRender();
			updateGuildInfo();
		}
		
		private function updateGuildInfo():void {
			var data:GuildMainStateVo = GuildMainView.state;
			User.getInstance().guildLv = data.level;
			User.getInstance().guildExp = data.exp - GameConfigManager.guild_info_vec[data.level - 1].requirement;
			GameConfigManager.setGuildLogoSkin(this.view.gIcon, data.icon);
			view.gNameTF.text = data.name;
			view.gLvTF.text = GameLanguage.getLangByKey("L_A_73") + data.level;
			
			view.gExpTF.text = User.getInstance().guildExp + "/" + GameConfigManager.guild_info_vec[data.level].re_qian;
			view.expBar.value = User.getInstance().guildExp/GameConfigManager.guild_info_vec[data.level].re_qian;
			
			view.gMemberTF.text = data.members_count + "/"+GameConfigManager.guild_info_vec[data.level].max_member;
			view.gJoinType.text = GameLanguage.getLangByKey(GuildeInfoView.JOIN_TYPE[data.join_type]);
			view.gClaimLvTF.text = GameLanguage.getLangByKey("L_A_73") + data.join_limit;
			
			view.dom_guild.text = data.guild_cash;
			view.dom_personal.text = data.personal_fund;
			
			view.dom_icon2.skin = GameConfigManager.getItemImgPath(6); 
		}
		
		/**更新列表渲染*/
		private function updateListRender():void {
			var data = ResourceManager.instance.getResByURL("config/guild_contribution.json");
			
			var donate_times = GuildMainView.state.donate_times;
			var result:Array = [];
			// 挑出每种捐献道具的次数所对应表的 具体内容  {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}   1:食物  2:黄金 3:钢材 4:矿石  5:水
			for (var key in donate_times) {
				// 下次的内容
				var times = donate_times[key] + 1;
				var target_data = ToolFunc.getItemDataOfWholeData(times, data, "down", "up");
				result.push({
					type_id: key,
					consumption: target_data["consumption_" + key],
					reward: target_data["reward_" + key],
					guild_exp: target_data["guild_exp_" + key],
					guild_cash: target_data["guild_cash_" + key]
				});
			}
			
			view.dom_list.array = createListData(result);
			
			trace(result);
		}
		
		private function createListData(data:Array):Array {
			return data.map(function(item) {
				var iconArr = item.consumption.split("="); 
				return {
					type_id: item.type_id,
					icon_id: iconArr[0],
					icon_num: iconArr[1],
					my_num: User.getInstance().getResNumByItem(iconArr[0]),
					guild_exp: item.guild_exp,
					guild_fund: item.guild_cash,
					personal_fund: item.reward.split("=")[1]
				}
			});
		}
		
		private function addToStageHandler():void 
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_DONATE), this, this.serviceEventHandler);
			
			addToStageRender();
			
		}
		
		private function removeFromStageHandler():void 
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_DONATE), this, this.serviceEventHandler);
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
//				case view.btn_all:
//					
//					break;
			}
		}
		/**获取服务器消息*/
		private function serviceEventHandler(...args):void
		{
			trace("【公会捐献】", args);
			switch(args[0]) {
				case ServiceConst.GUILD_DONATE:
					
					break;
				
				default:
					break;
			}
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			view.dom_list.itemRender = DonateItem;
			view.dom_list.hScrollBarSkin = "common/hscrollBarr.png";
			
			addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageHandler);
			this.off(Event.REMOVED, this, removeFromStageHandler);
			
			super.removeEvent();
		}
		
		private function get view():DonateViewUI{
			_view = _view || new DonateViewUI();
			return _view;
		}
	}
}