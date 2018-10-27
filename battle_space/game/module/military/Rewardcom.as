package game.module.military
{
	import MornUI.military.MilitaryViewUI;
	
	import game.common.XGroup;
	import game.global.data.DBMilitary;
	import game.global.vo.User;

	/**
	 * Rewardcom
	 * author:huhaiming
	 * Rewardcom.as 2017-9-13 上午11:36:13
	 * version 1.0
	 *
	 */
	public class Rewardcom implements IMilitaryCom
	{
		private var _ui:*;
		private var _view:MilitaryViewUI;
		public function Rewardcom(ui:*, view:MilitaryViewUI)
		{
			this._ui = ui;
			this._view = view;
			init();
		}
		
		public function show(...args):void
		{
			this._ui.visible = true;
			var arr:Array = DBMilitary.getAll()
			_view.rewardList.array = arr.slice(1, arr.length);
		}
		
		public function check():Boolean{
			var recordArr:Array = MilitaryView.data.base_rob_info.get_mil_log || [];
			var arr:Array = DBMilitary.getAll()
			arr = arr.slice(1, arr.length);
			var data:Object;
			for(var i:int=0; i<arr.length; i++){
				data = arr[i];
				trace("data-------------------------------",data,recordArr);
				if(User.getInstance().cup >= data.down){
					if(recordArr.indexOf(data.ID) != -1){
						continue;
					}else{
						return true;
					}
				}else{
					return false;
				}
			}
			return false;
		}
		
		public function close():void
		{
			this._ui.visible = false;
		}
		
		private function init():void{
			_view.rewardList.itemRender = MilitaryRewardItem;
			_view.rewardList.vScrollBarSkin="";
		}
	}
}