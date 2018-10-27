package game.module.armyGroup
{
	import MornUI.armyGroup.MilitaryListItemUI;

	/**
	 * 军团军衔任务列表渲染项
	 * @author douchaoyang
	 *
	 */
	public class MilitaryListItem extends MilitaryListItemUI
	{
		public function MilitaryListItem()
		{
			super();
		}


		override public function set dataSource(value:*):void
		{
			var data:Object=value;
			if (data)
			{
				this.title.text=data.text;
				this.score.text="+" + data.point;
				this.img.skin="appRes/icon/guildIcon/" + data.icon + ".png";
			}
		}

	}
}
