package game.module.guild
{
	import MornUI.guild.PersonalKejiItemUI;
	
	import game.global.GameConfigManager;
	
	import laya.events.Event;
	
	/**
	 * 个人科技子项
	 * @author hejianbo
	 * 
	 */
	public class PersonalKejiItem extends PersonalKejiItemUI
	{
		public function PersonalKejiItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			dom_icon.skin = value.icon;		
			dom_name.text = value.skill_name;
			dom_level.text = value.level;
			dom_current.text = value.skill_des;
			
			dom_viewstack.selectedIndex = value.isGray ? 1 : 0;
			this.gray = value.isGray;
			
			dom_daoju.skin = GameConfigManager.getItemImgPath(6);
			dom_num.text = "x" + value.skill_consume;
			dom_limit.text = value.open_limit;
			
			btn_up.offAll();
			btn_up.on(Event.CLICK, this, value.callBack, [value.id, value.skill_consume]);
			btn_up.disabled = value.isMaxLevel || !value.isEnoughToUpgrade;
			
			btn_up.label = value.isMaxLevel ? "L_A_73125" : "L_A_3038";
			dom_daoju.visible = dom_num.visible = !value.isMaxLevel;
			
			super.dataSource = value;
		}
	}
}