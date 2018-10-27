package game.module.military
{
	import MornUI.military.MilitaryRankItemUI;
	
	import game.global.vo.User;
	
	/**
	 * MilitaryRankItem
	 * author:huhaiming
	 * MilitaryRankItem.as 2017-4-28 上午11:51:41
	 * version 1.0
	 *
	 */
	public class MilitaryRankItem extends MilitaryRankItemUI
	{
		public function MilitaryRankItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			if(value){
				this.nameTF.text = value.base.name+"";
				this.rankTf.text = value.order;
				this.lvTF.text = value.level;
				this.medalTF.text = value.cup+"";
				if(value.base.uid == User.getInstance().uid){
					this.visitBtn.disabled = true;
					bg.skin = "military/bar_2.png"
				}else{
					this.visitBtn.disabled = false;
					bg.skin = "military/bar_1.png"
				}
			}
		}
	}
}