package game.module.mainui
{
	import MornUI.mainView.UserTipUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.data.DBRoleLevel;
	import game.global.vo.User;
	
	/**
	 * UserTip
	 * author:huhaiming
	 * UserTip.as 2017-6-7 下午6:49:56
	 * version 1.0
	 *
	 */
	public class UserTip extends BaseDialog
	{
		public function UserTip()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
			this.bg.alpha = 0.01;
		}
		
		override public function show(...args):void{
			super.show();
			var user:User = User.getInstance();
			
			view.nameTF.text = user.name+"";
			view.uidTF.text = user.uid+"";
			view.lvTF.text = user.level+"";
			view.lvTF.x = view.lvLb.measureWidth+view.lvLb.x;
			view.expTF.text = user.exp+"/"+DBRoleLevel.getLvExp(user.level);
			this.x = this.y = 10;
		}
		
		override public function createUI():void{
			this._view = new UserTipUI();
			this.addChild(this._view);
			this.closeOnBlank = true;
		}
		
		private function get view():UserTipUI{
			return this._view as UserTipUI;
		}
	}
}