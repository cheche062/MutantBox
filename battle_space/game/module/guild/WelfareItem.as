package game.module.guild
{
	import MornUI.guild.BossRankItemUI;
	import MornUI.guild.WelfareItemUI;
	
	import game.global.GameLanguage;
	import game.global.vo.guild.GuildWelfareVo;
	
	import laya.ui.Box;
	
	public class WelfareItem extends Box
	{
		private var itemMC:WelfareItemUI;
		private var _data:GuildWelfareVo;
		
		public function WelfareItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new WelfareItemUI();
			this.addChild(itemMC);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value as GuildWelfareVo;
			
			
			if(!data)
			{
				return;
			}
			
			
			itemMC.welfareNameTF.text = data.effect.split("=")[0];
			itemMC.welfareLvTF.text = GameLanguage.getLangByKey("L_A_73") + data.level;
			itemMC.enhancedTF.text = data.effect.split("=")[1];
			itemMC.timeTF.text = parseFloat(data.last/3600)+"h";
			itemMC.priceTF.text = data.upgrade_cost.split("=")[1];
			
			
		}
		
		public function get data():GuildWelfareVo{
			return this._data;
		}
		
		private function get view():WelfareItemUI{
			return itemMC;
		}
	}
}