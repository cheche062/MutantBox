package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightReportItemUI;
	
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.data.DBItem;
	import game.global.vo.ItemVo;
	
	/**
	 * ArmyFightReportItem
	 * author:huhaiming
	 * ArmyFightReportItem.as 2017-11-27 下午7:09:49
	 * version 1.0
	 *
	 */
	public class ArmyFightReportItem extends ArmyFightReportItemUI
	{
		public function ArmyFightReportItem()
		{
			super();
		}
		
		/**
		 * L_A_20871 你击败了防守方{0}，获得了击杀奖励：
			L_A_20872 防守方{0}击败了你，请再派驻部队。
			L_A_20901 你击败了进攻方{0}，获得了击杀奖励：
			L_A_20902 进攻方{0}击败了你，请再派驻部队。
			[0,1,1,"L_A_xxxxxx","1=1;2=1;3=1;10004=1"]]
		 * 
		 * */
		override public function set dataSource(value:*):void{
			if(value){
				if(value is String){
					value = JSON.parse(value);
				}
				var lan:String;
				if(value[2] > 0){//胜利
					if(value[1] == 1){//进攻方
						lan = "L_A_20871"
					}else{
						lan = "L_A_20901"
					}
				}else{//失败
					if(value[1] == 1){//进攻方
						lan = "L_A_20872"
					}else{
						lan = "L_A_20902"
					}
				}
				//道具
				var itemList:Array;
				itemList = (value[4]+"").split(";");
				trace("value[4]:",itemList)
				var tmp:Array;
				var db:ItemVo;
				var itemStr:String = "";
				for(var i:int=0; i<itemList.length; i++){
					tmp = (itemList[i]+"").split("=");
					db = DBItem.getItemData(tmp[0]);
					if(db){
						itemStr+= GameLanguage.getLangByKey(db.name) + "x"+tmp[1]+";"
					}
				}
				trace("itemStr::",itemStr)
				var str:String = GameLanguage.getLangByKey(lan)+itemStr;
				
				str = str.replace(/{(\d+)}/, GameLanguage.getLangByKey(value[3]));
				
				infoTF.text = str;
				
			}
		}
	}
}