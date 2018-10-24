package game.module.armyGroup
{
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	import laya.ui.TextArea;
	import MornUI.armyGroup.GroupTotalItemUI;

	import game.common.base.BaseView;

	/**
	 * 军团公会击杀排行列表渲染项
	 * @author douchaoyang
	 *
	 */
	public class GroupTotalItem extends BaseView
	{
		
		private var goodArr:Vector.<ItemContainer>=new Vector.<ItemContainer>(3);
		private var textArr:Vector.<TextArea>=new Vector.<TextArea>(3);
		
		public function GroupTotalItem()
		{
			super();
		}

		/**
		 * 设置数据项中的数据
		 * @param value 数据源
		 *
		 */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return
			}
			var data:Object=Object(value);
			// 排名
			view.rank.text = data.rank;
			
			view.icon.visible = false;
			
			// 公会名称
			if (data.team_id.split("_")[0] == "budui")
			{
				view.icon.skin = "appRes/icon/plantIcon/flag_3.png";
				view.name.text = GameLanguage.getLangByKey(GameConfigManager.ArmyGroupNpcList[parseInt(data.team_id.split("_")[1])].npc_name);
				view.icon.visible = true;
			}
			else
			{
				view.name.text = data.guildName;
				// 会标
				if (parseInt(data.guildIcon) >= 0)
				{
					GameConfigManager.setGuildLogoSkin(view.icon, data.guildIcon, 0.5);

					view.icon.visible = true;
				}
			}
			
			// 积分
			view.scoreTxt.text=data.guildPoint;
			
			view.dom_level.text = (typeof (data.level) == "undefined") ? "" : data.level;
		}

		override public function createUI():void
		{
			_view=new GroupTotalItemUI();
			this.addChild(_view);
		}

		private function get view():GroupTotalItemUI
		{
			return _view as GroupTotalItemUI;
		}
	}
}
