package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import laya.display.Text;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupTresureLogItem extends BaseView 
	{
		
		private var _logText:Text;
		
		public function ArmyGroupTresureLogItem() 
		{
			super();
			initUI();
		}
		
		private function initUI():void
		{
			_logText = new Text();
			_logText.width = 535;
			_logText.font = "Futura";
			_logText.fontSize = 24;
			_logText.color = "#ffffff";
			
			this.addChild(_logText);
			this.height = 30;
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			var ii:String = value[2].split("=")[0];
			var nn:String = value[2].split("=")[1];
			_logText.text = "Player " + value[0] + " get " + GameLanguage.getLangByKey(GameConfigManager.items_dic[ii].name) + "x" + nn;
			switch(value[1])
			{
				case 1:
					_logText.color = "#abff47";
					break;
				case 2:
					_logText.color = "#47e8ff";
					break;
				case 3:
					_logText.color = "#ffea56";
					break;
				default:
					_logText.color = "#ffffff";
					break;
			}
			
		}
		
	}

}