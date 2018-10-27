package game.module.fighting.cell
{
	import MornUI.fightingView.buffCellUIUI;
	
	import game.global.GameConfigManager;
	import game.global.vo.SkillBuffVo;
	
	public class BuffCell extends buffCellUIUI
	{
		public function BuffCell()
		{
			super();
		}
		
		public override function set dataSource(value:*):void{
			super.dataSource = value;
			this.iconImg.visible = this.NumLbl.visible = value;
			if(!value)
			{
				return ;
			}
			var buffVo:SkillBuffVo = GameConfigManager.skill_buff_dic[value.buffId];
			if(buffVo)
			{
				this.iconImg.graphics.clear();
				this.iconImg.loadImage(buffVo.iconUrl);
			}
			
			this.NumLbl.text = value.rounds;
			this.bg1.visible = buffVo.zy;
			this.bg2.visible = !this.bg1.visible;
		}
	}
}