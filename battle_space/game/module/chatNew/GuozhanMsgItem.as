package game.module.chatNew
{
	import MornUI.chatNew.GuozhanMsgItemUI;
	
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	
	import laya.events.Event;
	
	/**
	 * 聊天中国战的战斗信息
	 * @author hejianbo
	 * 
	 */
	public class GuozhanMsgItem extends GuozhanMsgItemUI
	{
		public function GuozhanMsgItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			otBg.skin = value.type == "self" ? "common/alterDialog/bg10_2.png" : "common/alterDialog/bg10_1.png";
			dom_time.color = dom_name.color = dom_msg.color = value.type == "self" ? "#76ff33" : "#ffb933";
			
			dom_time.text = value.time;
			switch (Number(value.msg_type)) {
				//宣战
				case 1:
					dom_name.text = value.att_guild_name;
					dom_msg.text = GameLanguage.getLangByKey("L_A_2748").replace("{0}", value.att_player_name)
					.replace("{1}", value.att_player_position).replace("{2}", value.city_name);
					
					if (value.def_guild_name) {
						dom_msg.text = dom_msg.text.replace("{3}", value.def_guild_name);
					}else {
						dom_msg.text = dom_msg.text.replace("{3}", GameLanguage.getLangByKey("L_A_3040"));
					}
					
					break;
				
				//防守
				case 2:
					dom_name.text = value.def_guild_name;
					dom_msg.text = GameLanguage.getLangByKey("L_A_2749").replace("{0}", value.att_guild_name)
					.replace("{1}", value.city_name)
					
					break;
				
				// 进攻召集
				case 3:
					dom_name.text = value.name;
					dom_msg.text = GameLanguage.getLangByKey("L_A_2750").replace("{0}", value.city_name)
					if (value.def_guild_name) {
						dom_msg.text = dom_msg.text.replace("{1}", value.def_guild_name);
					}else {
						dom_msg.text = dom_msg.text.replace("{1}", GameLanguage.getLangByKey("L_A_3040"));
					}
					
					break;
				
				// 防守召集
				case 4:
					dom_name.text = value.name;
					dom_msg.text = GameLanguage.getLangByKey("L_A_2751").replace("{0}", value.att_guild_name)
					.replace("{1}", value.city_name)
					
					break;
			}
			
			btn_go.offAll();
			btn_go.on(Event.CLICK, this, function(){
				LiaotianView.current_module_view && LiaotianView.current_module_view.close();
				LiaotianView.current_module_view = null;
				XFacade.instance.openModule(ModuleName.ArmyGroupMapView, {cityId: value.city_id});
			})
			
			super.dataSource = value;
		}
	}
}