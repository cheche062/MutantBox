package game.module.military
{
	import MornUI.military.MilitaryItemUI;
	
	import game.global.GameLanguage;
	import game.global.data.DBMilitary;
	import game.global.vo.User;
	
	import laya.ui.UIUtils;
	
	/**base_military
	 * 
	 * MilitaryItem
	 * author:huhaiming
	 * MilitaryItem.as 2017-4-28 上午11:46:27
	 * version 1.0
	 *
	 */
	public class MilitaryItem extends MilitaryItemUI
	{
		private static const TITLE_DIC:Array = [
			"L_A_49600",
			"L_A_49601",
			"L_A_49602",
			"L_A_49603",
			"L_A_49604",
			"L_A_49605",
			"L_A_49606",
			"L_A_49607",
			"L_A_49608"]
		

		public function MilitaryItem()
		{
			super();
		}
		
		override public function set dataSource(value:*):void{
			UIUtils.gray(this, false);
			var curVo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 1);
			if(value){
				this.titleTF.text = GameLanguage.getLangByKey(TITLE_DIC[parseInt(value) -1]);
				var list:Array = DBMilitary.getInfoByLv(value);
				var vo:MilitaryVo = list[0];
				if(vo){
					this.nameTF_0.text = GameLanguage.getLangByKey(vo.name);
					this.priceTF_0.text = vo.down+"";
					this.icon_0.skin = "appRes\\icon\\military\\"+vo.icon+".png"
				}
				vo = list[1];
				if(vo){
					this.nameTF_1.text = GameLanguage.getLangByKey(vo.name);
					this.priceTF_1.text = vo.down+"";
					this.icon_1.skin = "appRes\\icon\\military\\"+vo.icon+".png"
				}else{
					this.nameTF_1.text = ""
					this.priceTF_1.text = "";
					this.icon_1.skin = ""
				}
				vo = list[2];
				if(vo){
					this.nameTF_2.text = GameLanguage.getLangByKey(vo.name);
					this.priceTF_2.text = vo.down+"";
					this.icon_2.skin = "appRes\\icon\\military\\"+vo.icon+".png"
				}else{
					this.nameTF_2.text = "";
					this.priceTF_2.text = "";
					this.icon_2.skin = ""
				}
				if(curVo.level < value){
					UIUtils.gray(this);
				}
			}
		}
	}
}