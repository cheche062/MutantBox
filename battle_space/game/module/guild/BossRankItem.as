package game.module.guild
{
	import game.common.ItemTips;
	import game.global.GameConfigManager;
	import game.global.vo.User;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import MornUI.guild.BossRankItemUI;
	import MornUI.guild.GuildBossItemUI;
	
	import game.common.XFacade;
	import game.global.ModuleName;
	
	import laya.events.Event;
	import laya.ui.Box;
	
	public class BossRankItem extends Box
	{
		
		private var itemMC:BossRankItemUI;
		private var _data:Object;
		
		private var _goodArr:Vector.<Image> = new Vector.<Image>(3);
		private var _textArr:Vector.<TextArea> = new Vector.<TextArea>(3);
		
		private var rewardArr:Array = [];
		
		public function BossRankItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new BossRankItemUI();
			this.addChild(itemMC);
			
			itemMC.nameTF.text = "";
			itemMC.rankTF.text = "";
			itemMC.hurtTF.text = "";
			this.itemMC.bg_green.visible = false;
			
			itemMC.rFirst.visible = false;
			itemMC.rSecond.visible = false;
			itemMC.rThird.visible = false;
			itemMC.rankTF.visible = false;
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			if(!data)
			{
				return;
			}
			
			for (var j:int = 0; j < 3; j++)
			{
				if (_goodArr[j])
				{
					_goodArr[j].visible = false;
				}
				
				if(_textArr[j])
				{
					_textArr[j].visible = false;
				}
			}
			
			this.itemMC.bg_green.visible = Boolean(User.getInstance().guildBossRank == parseInt(data.rank));
			
			itemMC.nameTF.text = data.name;
			itemMC.rankTF.text = data.rank;
			itemMC.hurtTF.text = data.hurt;
			
			itemMC.rFirst.visible = false;
			itemMC.rSecond.visible = false;
			itemMC.rThird.visible = false;
			itemMC.rankTF.visible = false;
			
			switch(data.rank)
			{
				case "1":
					itemMC.rFirst.visible = true;
					break;
				case "2":
					itemMC.rSecond.visible = true;
					break;
				case "3":
					itemMC.rThird.visible = true;
					break;
				default:
					itemMC.rankTF.visible = true;
					break;
			}
			
			rewardArr = data.reward
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
					_textArr[i].font = "Futura";
					_textArr[i].fontSize = 18;
					_textArr[i].color = "#ffffff";					
					_textArr[i].mouseEnabled = false;
					_textArr[i].y = 20;
					itemMC.addChild(_textArr[i]);
				}
				
				_goodArr[i].skin = (GameConfigManager.getItemImgPath(rewardArr[i].split("=")[0]));
				_goodArr[i].visible = true;
				
				_textArr[i].text = "x"+rewardArr[i].split("=")[1];
				_textArr[i].visible = true;
				
				switch(len)
				{
					case 1:
						_goodArr[i].x = 430;
						_textArr[i].x = 470;
						break;
					case 2:
						_goodArr[i].x = 380 + 75 * i;
						_textArr[i].x = 420 + 75 * i;
						break;
					case 3:
						_goodArr[i].x = 330 + 75 * i;
						_textArr[i].x = 370 + 75 * i;
						break;
				}
			}
		}
		
		private function showItemTips(e:Event):void 
		{
			
			trace("  asdfas:" + e.currentTarget.name);
			if (rewardArr[e.currentTarget.name]);
			{
				ItemTips.showTip(rewardArr[e.currentTarget.name].split("=")[0]);
			}
			
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():BossRankItemUI{
			return itemMC;
		}
	}
}