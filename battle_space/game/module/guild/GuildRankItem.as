package game.module.guild
{
	import MornUI.guild.GuildRankItemUI;
	import MornUI.guild.WelfareItemUI;
	
	import game.global.GameLanguage;
	import game.global.vo.User;
	
	import laya.ui.Box;
	
	public class GuildRankItem extends Box
	{
		
		private var itemMC:GuildRankItemUI;
		private var _data:Object;
		
		public function GuildRankItem()
		{
			super();
			init();
		}
		private function init():void
		{
			this.itemMC = new GuildRankItemUI();
			this.addChild(itemMC);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			
			if(!data)
			{
				return;
			}
			
			//trace("gv:", value);
			itemMC.rFirst.visible = false;
			itemMC.rSecond.visible = false;
			itemMC.rThird.visible = false;
			itemMC.rankTF.visible = false;
			itemMC.bg_green.visible = false;
			switch(data.rank)
			{
				case 1:
					itemMC.rFirst.visible = true;
					break;
				case 2:
					itemMC.rSecond.visible = true;
					break;
				case 3:
					itemMC.rThird.visible = true;
					break;
				default:
					itemMC.rankTF.visible = true;
					break;
			}
			
			if (data.id == User.getInstance().guildID)
			{
				itemMC.bg_green.visible = true;
			}
			
			itemMC.rankTF.text = data.rank;
			itemMC.gNameTF.text = data.rName;
			itemMC.aLvTF.text = GameLanguage.getLangByKey("L_A_73")+data.aLv;
			itemMC.honorTF.text = data.exp;
			itemMC.memberTF.text = data.memberNum+"/"+data.maxNum;
			
			
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():GuildRankItemUI{
			return itemMC;
		}
	}
}