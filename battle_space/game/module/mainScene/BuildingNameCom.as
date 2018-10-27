package game.module.mainScene
{
	import MornUI.mainView.BuildNameComUI;
	
	/**
	 * BuildingNameCom
	 * author:huhaiming
	 * BuildingNameCom.as 2017-5-11 下午3:04:23
	 * version 1.0
	 *
	 */
	public class BuildingNameCom extends BuildNameComUI
	{
		public function BuildingNameCom()
		{
			super();
		}
		
		public function setInfo(name:String, lvStr:String):void{
			name && (nameTF.text = name);
			lvTF.text = lvStr+"";
		}
	}
}