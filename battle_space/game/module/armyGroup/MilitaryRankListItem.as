package game.module.armyGroup
{
	import game.module.bingBook.ItemContainer;
	import MornUI.armyGroup.MilitaryRankListItemUI;

	import game.common.ItemTips;
	import game.global.GameConfigManager;

	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;

	/**
	 * 军团军衔每日奖励列表渲染项
	 * @author douchaoyang
	 *
	 */
	public class MilitaryRankListItem extends MilitaryRankListItemUI
	{
		private var goodArr:Vector.<ItemContainer>=new Vector.<ItemContainer>;
		private var textArr:Vector.<TextArea> = new Vector.<TextArea>;
		
		public function MilitaryRankListItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void
		{
			var data:Object=value;
			if (data)
			{
				this.rankName.text=String(data.mc);
				setRewardHandler(String(data.reward));
			}
		}
		
		/**
		 * 设置奖励
		 * @param str 奖励数据
		 *
		 */
		private function setRewardHandler(str:String):void
		{
			var data:Array=str.split(";");
			var len:int = data.length;
			var i:int = 0;
			
			len = goodArr.length;
			
			for (i = 0; i < len; i++) 
			{
				goodArr[i].visible = false;
				textArr[i].visible = false;
			}
			
			
			len = data.length;
			
			for (var i=0; i < len; i++)
			{
				var info:Array=String(data[i]).split("=");
				if (!goodArr[i])
				{
					goodArr[i]=new ItemContainer();
					goodArr[i].name=i;
					goodArr[i].scaleX=goodArr[i].scaleY=0.5;
					goodArr[i].y=5;
					goodArr[i].needBg = false;
					goodArr[i].numTF.visible = false;
					this.addChild(goodArr[i]);
				}
				
				if (!textArr[i])
				{
					textArr[i]=new TextArea();
					textArr[i].font="Futura";
					textArr[i].fontSize=24;
					textArr[i].color="#fff9a1";
					textArr[i].mouseEnabled=false;
					textArr[i].y=13;
					this.addChild(textArr[i]);
				}
				
				goodArr[i].visible = true;
				textArr[i].visible = true;
				
				goodArr[i].setData(info[0]);
				textArr[i].text = info[1];
				
				// 居中
				switch (len)
				{
					case 1:
						goodArr[i].x=380;
						textArr[i].x=414;
						break;
					case 2:
						goodArr[i].x=270 + 115 * i;
						textArr[i].x=320 + 115 * i;
						break;
					case 3:
						goodArr[i].x=230 + 115 * i;
						textArr[i].x=280 + 115 * i;
						break;
					default:
						break;
				}
			}
		}
	}
}
