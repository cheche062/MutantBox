package game.module.guild 
{
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.vo.User;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import MornUI.guild.BossRewardItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class BossRewardItem extends Box 
	{
		private var itemMC:BossRewardItemUI;
		private var _data:Object;
		
		private var _goodArr:Vector.<Image> = new Vector.<Image>(3);
		private var _textArr:Vector.<TextArea> = new Vector.<TextArea>(3);
		private var rewardArr:Array;
		
		public function BossRewardItem() 
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new BossRewardItemUI();
			this.addChild(itemMC);
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			if(!data)
			{
				return;
			}
			
			this.itemMC.rFirst.visible = false;
			this.itemMC.rSecond.visible = false;
			this.itemMC.rThird.visible = false;
			this.itemMC.rankTF.visible = false;
			
			var rank:String = data.rewards[0];
			this.itemMC.bgg.visible = false;
			
			switch(rank)
			{
				case "1|1":
					this.itemMC.bgg.visible = Boolean(User.getInstance().guildBossRank == 1);
					this.itemMC.rFirst.visible = true;
					break;
				case "2|2":
					this.itemMC.bgg.visible = Boolean(User.getInstance().guildBossRank == 2);
					this.itemMC.rSecond.visible = true;
					break;
				case "3|3":
					this.itemMC.bgg.visible = Boolean(User.getInstance().guildBossRank == 3);
					this.itemMC.rThird.visible = true;
					break;
				default:
					if (parseInt(rank.split("|")[0]) <= User.getInstance().guildBossRank && 
						User.getInstance().guildBossRank <= parseInt(rank.split("|")[1]))
					{
						this.itemMC.bgg.visible = true;
					}
					this.itemMC.rankTF.text = rank.split("|")[0] + " - " + rank.split("|")[1];
					this.itemMC.rankTF.visible = true;
					break;
			}
			
			rewardArr = data.rewards.slice(1);// .split(":");
			var len:int = rewardArr.length;
			
			for (var i:int = 0; i < len; i++) 
			{
				if (!_goodArr[i])
				{
					_goodArr[i] = new Image();
					_goodArr[i].name = i;
					_goodArr[i].scaleX = _goodArr[i].scaleY = 0.5;
					_goodArr[i].y = 5;
					_goodArr[i].on(Event.CLICK, this, showItemTips);
					itemMC.addChild(_goodArr[i]);
				}
				
				if (!_textArr[i])
				{
					_textArr[i] = new TextArea();
					_textArr[i].font = "BigNoodleToo";
					_textArr[i].fontSize = 18;
					_textArr[i].color = "#ffffff";					
					_textArr[i].mouseEnabled = false;
					_textArr[i].y = 16;
					itemMC.addChild(_textArr[i]);
				}
				
				_goodArr[i].skin = (GameConfigManager.getItemImgPath(rewardArr[i].split("=")[0]));
				_textArr[i].text = rewardArr[i].split("=")[1];
				
				switch(len)
				{
					case 1:
						_goodArr[i].x = 300;
						_textArr[i].x = 340;
						break;
					case 2:
						_goodArr[i].x = 250 + 75 * i;
						_textArr[i].x = 290 + 75 * i;
						break;
					case 3:
						_goodArr[i].x = 200 + 75 * i;
						_textArr[i].x = 240 + 75 * i;
						break;
				}
			}
			
		}
		
		private function showItemTips(e:Event):void 
		{
			
			if (rewardArr[e.currentTarget.name]);
			{
				ItemTips.showTip(rewardArr[e.currentTarget.name].split("=")[0]);
			}
			
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():BossRewardItemUI{
			return itemMC;
		}
		
	}

}