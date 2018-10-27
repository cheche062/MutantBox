package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	import laya.ui.TextArea;
	import MornUI.armyGroup.SeasonRewardItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class SeasonRewardItem extends BaseView 
	{
		private var goodArr:Vector.<ItemContainer>=new Vector.<ItemContainer>(3);
		private var textArr:Vector.<TextArea>=new Vector.<TextArea>(3);
		public function SeasonRewardItem() 
		{
			super();
			
		}
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return
			}
			var data:Object=Object(value);
			// 排名
			view.rankTxt.text = data.rank;
			
			view.icon.visible = false;
			
			// 公会名称
			if (data.team_id.split("_")[0] == "budui")
			{
				view.icon.skin = "appRes/icon/plantIcon/flag_3.png";
				view.pNameTxt.text = GameLanguage.getLangByKey(GameConfigManager.ArmyGroupNpcList[parseInt(data.team_id.split("_")[1])].npc_name);
				view.icon.visible = true;
			}
			else
			{
				view.pNameTxt.text = data.guildName;
				// 会标
				if (parseInt(data.guildIcon) >= 0)
				{
					GameConfigManager.setGuildLogoSkin(view.icon, data.guildIcon, 0.5);
					view.icon.visible = true;
				}
			}
			
			// 积分
			view.socreTxt.text=data.guildPoint;
			
			var reArr:Array = GameConfigManager.intance.getArmyGroupSeasonReward(ArmyGroupMapView.CURRENT_SEASON, data.rank).split(";");
			var len:int = reArr.length;
			var it:ItemContainer = new ItemContainer();
			//len = parseInt(data.rank) % 3 + 1;
			for (var i=0; i < 3; i++)
			{
				if (!goodArr[i])
				{
					goodArr[i]=new ItemContainer();
					goodArr[i].name=i;
					goodArr[i].scaleX=goodArr[i].scaleY=0.5;
					goodArr[i].y = 0;
					goodArr[i].needBg = false;
					goodArr[i].numTF.visible = false;
					view.addChild(goodArr[i]);
				}
				if (!textArr[i])
				{
					textArr[i]=new TextArea();
					textArr[i].font="Futura";
					textArr[i].fontSize=22;
					textArr[i].color="#ffda80";
					textArr[i].mouseEnabled=false;
					textArr[i].y=13;
					view.addChild(textArr[i]);
				}
				
				goodArr[i].x = 620 - 60 * len + 90 * i;
				textArr[i].x = goodArr[i].x + 35;
				if (reArr[i])
				{
					goodArr[i].visible=true;
					textArr[i].visible=true;
					var info:Array=String(reArr[i]).split("=");
					
					goodArr[i].setData(info[0]);
					textArr[i].text="x" + XUtils.formatResWith(info[1]);
				}
				else
				{
					goodArr[i].visible=false;
					textArr[i].visible=false;
				}
				
			}
		}

		override public function createUI():void
		{
			_view=new SeasonRewardItemUI();
			this.addChild(_view);
			view.cacheAsBitmap=true;
		}

		private function get view():SeasonRewardItemUI
		{
			return _view as SeasonRewardItemUI;
		}
	}

}