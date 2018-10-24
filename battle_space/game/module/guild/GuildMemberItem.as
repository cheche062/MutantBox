package game.module.guild
{
	import MornUI.guild.GuildMemberItemUI;
	
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	
	public class GuildMemberItem extends BaseView
	{
		private var _data:Object;
		private var _user:User = User.getInstance();
		
		public function GuildMemberItem()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new GuildMemberItemUI();
			this.addChild(_view);
			
			view.iconImg.visible = false;
			
			addEvent();
		}
		
		private function clickItem():void
		{
			var parameter:Object;
			switch (String(this._user.guildJob)){
				case "1":
				case "2": 
					parameter = {
						place:data.place,
						uid:_data.uid,
						btnNum:5,
						lableArray:[
							GameLanguage.getLangByKey("L_A_2541"),
							GameLanguage.getLangByKey("L_A_2542"),
							GameLanguage.getLangByKey("L_A_2543"),
							GameLanguage.getLangByKey("L_A_2544"),
							GameLanguage.getLangByKey("L_A_2545")
						],
						service:"adjustMemberJob"
					};
				
					break;
				
				case "3":
					parameter = {
						place:data.place,
						uid:_data.uid,
						btnNum:3,
						lableArray:[
							GameLanguage.getLangByKey("L_A_2543"),
							GameLanguage.getLangByKey("L_A_2544"),
							GameLanguage.getLangByKey("L_A_2545")
						],
						service:"adjustMemberJob"
					}
					break;
				
				default:
					parameter = {
						place:data.place,
						uid:_data.uid,
						btnNum:2,
						lableArray:[
							GameLanguage.getLangByKey("L_A_2544"),
							GameLanguage.getLangByKey("L_A_2545")
						],
						service:"adjustMemberJob"
					}
					
					break;
			}
			
			XFacade.instance.openModule(ModuleName.MutilBtnContainer, parameter);
		}
		
		override public function addEvent():void{
			
			
			view.btn_edit.on(Event.CLICK, this, this.clickItem);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			
			
			view.btn_edit.off(Event.CLICK, this, this.clickItem);
			
			super.removeEvent();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
			this._data = value;
			
			if (!data || !data.name)
			{
				return;
			}
			//trace("memberData:", data);
			
			view.bg_green.visible = (data.uid == User.getInstance().uid);
			view.btn_edit.visible = (data.uid != User.getInstance().uid);
			
			view.memberNameTF.text = data.name;
			view.memberLvTF.text = data.lv;
			view.memberPlaceTF.text = data.place;
			
			view.memberDonateTF.text = data.donate;
			view.memberWarScoreTF.text = data.war_score;
			
			// 单位（s）
			var nowTime = new Date().getTime() / 1000;
			// 单位（h）
			var diffHour = parseInt((nowTime - data.last_login) / 3600);
			
			var _txt = "";
			var _today = GameLanguage.getLangByKey("L_A_2628");
			var _dago= GameLanguage.getLangByKey("L_A_2629");
			
			switch(true){
				case(diffHour <= 24):
					_txt = _today;
					break;
				case(diffHour > 24 && diffHour <= 72):
					_txt = _dago.replace("{0}", "1");
					break;
				case(diffHour > 72 && diffHour <= 168):
					_txt = _dago.replace("{0}", "3");
					break;
				case(diffHour > 168):
					_txt = _dago.replace("{0}", "7");
					break;
			}
			
			view.memberLastLoginTF.text = _txt;
		}
		
		public function get data():Object
		{
			return this._data;
		}
		
		private function get view():GuildMemberItemUI
		{
			return _view;
		}
	}
}