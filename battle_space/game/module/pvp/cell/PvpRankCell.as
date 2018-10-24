package game.module.pvp.cell
{
	import MornUI.pvpFight.pvpRankCellUI;
	
	import game.global.GlobalRoleDataManger;
	import game.global.StringUtil;
	import game.global.vo.PvpLevelVo;
	import game.global.vo.pvpShopItemVo;
	import game.module.pvp.PvpManager;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	
	public class PvpRankCell extends pvpRankCellUI
	{
		
		protected var _data:Object;
		
		public function PvpRankCell()
		{
			super();
		}
		
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			var ct:Number = cellType;
			this.rankLbl.color = this.scoreLbl.color = this.nameLbl.color = this.currentLbl.color = ct == 1 ? "#add3ff":"#adffad";
			this.bgImg.skin = ct == 1?"pvpRank/bg16.png":"pvpRank/bg16_1.png";
			
			if(_data)
			{
				this.rankLbl.text = StringUtil.substitute("{0}",_data.rank);
				this.nameLbl.text = _data.name;
				this.levelLbl.text = _data.level;
				var vo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(
					Number(_data.integral)
				);
				this.scoreLbl.text = vo ? vo.name : "--";
				this.currentLbl.text = _data.integral;
				
				var jg:Number = 5;
				var pBox:Box = this.levelBg.parent as Box;
				this.levelBg.visible = true;
				this.nameLbl.x = this.levelBg.x  + this.levelBg.width + jg;
				
				
			}else
			{
				this.rankLbl.text = "--";
				this.nameLbl.text = "--";
				this.scoreLbl.text = "--";
				this.currentLbl.text = "--";
				this.levelBg.visible = false;
				var jg:Number = 5;
				var pBox:Box = this.levelBg.parent as Box;
				this.nameLbl.x = (pBox.width -  this.nameLbl.textField.textWidth) / 2;
			}
			
			pBox = this.currentLbl.parent as Box;
			this.currentLbl.x = (pBox.width -  this.currentLbl.textField.textWidth) / 2;
		}
		
		protected function get cellType():Number{
			if(!_data)return 1;
			return String(_data.uid) == String(GlobalRoleDataManger.instance.userid) ? 2:1;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy PvpRankCell");
			
			_data = null;
			super.destroy(destroyChild);
		}
		
	}
}