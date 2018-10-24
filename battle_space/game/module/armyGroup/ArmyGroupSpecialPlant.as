package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.armyGroup.ArmyGroupCityVo;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.armyGroup.ArmyGroupSpecialItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupSpecialPlant extends BaseView 
	{
		
		private var _plantImg:Image;
		private var _planteData:ArmyGroupCityVo;
		private var _specialItem:ItemContainer;
		private var _guildIcon:Image;
		
		public function ArmyGroupSpecialPlant() 
		{
			super();
			
		}
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				
				default:
					break;
			}
		}
		
		public function setData(pid:int, info:Object):void
		{
			_planteData = GameConfigManager.ArmyGroupCityList[pid - 1];
			
			_plantImg.skin = "appRes/icon/plantIcon/" + _planteData.plant_Icon + ".png";
			
			_specialItem.setData(info.reward_item.split("=")[0], info.reward_item.split("=")[1]);
			
			view.cNameTxt.text = GameLanguage.getLangByKey(_planteData.name);
			
			view.greenBg.visible = false;
			if (info.guild_id != "" && info.guild_id == User.getInstance().guildID)
			{
				view.greenBg.visible = true;
			}
			
			view.gNameTxt.visible = false;
			_guildIcon.visible = false;
			if (info.guild_info.name && info.guild_info.name != "")
			{
				view.gNameTxt.text = info.guild_info.name;
				view.gNameTxt.visible = true;
				
				GameConfigManager.setGuildLogoSkin(_guildIcon, info.guild_info.icon, 0.5);
					
				_guildIcon.x = view.gNameTxt.x + (view.gNameTxt.width - view.gNameTxt.textWidth) / 2 - _guildIcon.width;
				_guildIcon.visible = true;
			}
		}
		
		override public function createUI():void
		{
			this._view = new ArmyGroupSpecialItemUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			_plantImg = new Image;
			_plantImg.width = _plantImg.height = 175;
			view.plantContainer.addChild(_plantImg);
			
			_specialItem = new ItemContainer();
			view.addChild(_specialItem);
			
			_guildIcon = new Image();
			_guildIcon.width = _guildIcon.height = 30;
			GameConfigManager.setGuildLogoSkin(_guildIcon, "0", 0.5);
			_guildIcon.y = view.gNameTxt.y-5;
			view.addChild(_guildIcon);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():ArmyGroupSpecialItemUI{
			return _view;
		}
	}

}