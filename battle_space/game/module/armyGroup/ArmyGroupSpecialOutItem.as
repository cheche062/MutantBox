package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.armyGroup.ArmyGroupCityVo;
	import game.global.vo.User;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.armyGroup.ArmyGroupSpecialOutItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupSpecialOutItem extends BaseView 
	{
		private var _planteData:ArmyGroupCityVo;
		private var _itemImg:Image;
		private var _numText:Text;
		private var _iiid:int;
		
		public function ArmyGroupSpecialOutItem() 
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
			
			var gInfo:Object = value.reward
			
			_planteData = GameConfigManager.ArmyGroupCityList[parseInt(value.id) - 1];
			
			view.cNameTxt.text = GameLanguage.getLangByKey(_planteData.name);
			
			view.gray = true;
			if (gInfo.guild_id != "" && gInfo.guild_id == User.getInstance().guildID)
			{
				view.gray = false;
			}
			
			view.gNameTxt.visible = false;
			if (gInfo.guild_info.name && gInfo.guild_info.name != "")
			{
				view.gNameTxt.text = gInfo.guild_info.name;
				view.gNameTxt.visible = true;
			}
			
			_iiid = gInfo.reward_item.split("=")[0];
			
			_itemImg.skin = GameConfigManager.getItemImgPath(_iiid);
			_numText.text = "x" + gInfo.reward_item.split("=")[1];
		}
		
		override public function createUI():void
		{
			this._view = new ArmyGroupSpecialOutItemUI
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			_itemImg = new Image();
			_itemImg.scaleX = _itemImg.scaleY = 0.5;
			_itemImg.y = 3;
			_itemImg.x = 640;
			_itemImg.mouseEnabled = true;
			_itemImg.on(Event.CLICK, this, showTips);
			view.addChild(_itemImg);
			
			_numText = new Text();
			_numText.font = "Futura";
			_numText.fontSize = 18;
			_numText.color = "#ffffff";
			_numText.mouseEnabled = false;
			_numText.y = 13;
			_numText.x = 690;
			
			view.addChild(_numText);
			
		}
		
		private function showTips():void 
		{
			ItemTips.showTip(_iiid);
		}
		
		override public function addEvent():void{
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			
			super.removeEvent();
		}
		
		private function get view():ArmyGroupSpecialOutItemUI{
			return _view;
		}
		
	}

}