package game.module.activity 
{
	import game.global.event.ActivityEvent;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import laya.events.Event;
	import laya.net.LocalStorage;
	import laya.ui.Box;
	import MornUI.acitivity.ActivityTypeItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WelfareTypeItem extends Box
	{
		
		private var itemMC:ActivityTypeItemUI;
		
		private var actIndex:int = 0;
		private var actName:String = "";
		
		private var btnName:Object = { 
			checkIn:"L_A_56065", 
			levelGift:"L_A_56087", 
			dayCard:"L_A_56081", 
			"7daysObjective":"L_A_56019", 
			fund:"L_A_80300",
			invite:"L_A_80730",
			"clock": "L_A_56065",
			giftbag4newplayer:"L_A_30529", //限时礼包名字
			timelimitedtask:"L_A_30602" //限时任务
		};
		
		public function WelfareTypeItem() 
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			this.itemMC = new ActivityTypeItemUI();
			this.addChild(itemMC);
			itemMC.tipsImg.visible = false;
			itemMC.actBtn.on(Event.CLICK, this, this.btnEventHandle);
			
		}
		
		private function btnEventHandle():void 
		{
			itemMC.tipsImg.visible = false;
			LocalStorage.setItem(actName, 1);
			Signal.intance.event(ActivityEvent.SELECT_WELFARE, [actName,actIndex]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(!value)
			{
				return;
			}
			selected = false;
			actName = value.name;
			actIndex = value.index;
			//actID = value.id;
			itemMC.actName.text = GameLanguage.getLangByKey(btnName[value.displayName]);
			
			itemMC.tipsImg.visible = false;
			
			if (!LocalStorage.getItem(actName) || parseInt(value.status) == 1)
			{
				itemMC.tipsImg.visible = true;
				
			}
			
			view.actBtn.selected = value.isSelected;
			
		}
		
		private function get view():ActivityTypeItemUI{
			return itemMC;
		}
		
		/**
		 * 设置选中状态
		 */
		override public function set selected(value: Boolean):void{
			if(this.selected !== value){
				super.selected = value;
				itemMC.actBtn.selected = value;
			}
		}
		
		
	}

}