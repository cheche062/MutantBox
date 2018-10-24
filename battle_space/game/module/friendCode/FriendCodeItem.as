package game.module.friendCode 
{
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import MornUI.friendCode.FriendCodeItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FriendCodeItem extends Box 
	{
		private var rewardData:FriendCodeVo;
		private var itemMC:FriendCodeItemUI;
		
		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		private var _rewardTxt:Vector.<Text> = new Vector.<Text>();
		
		public function FriendCodeItem() 
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new FriendCodeItemUI();
			this.addChild(itemMC);
			
			view.claimBtn.on(Event.CLICK, this, this.btnEventHandle);
			
		}
		
		private function btnEventHandle():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.GET_INVITE_REWARD,[rewardData.id]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if(!value)
			{
				return;
			}
			
			rewardData = value as FriendCodeVo;
			//trace("value:", value);
			
			
			
			var len:int = _rewardVec.length;
			var i:int = 0;
			for (i = 0; i < len; i++) 
			{
				_rewardVec[i].visible = false;
				_rewardTxt[i].text = "";
			}
			
			view.claimBtn.visible = true;
			view.claimBtn.disabled = true;
			view.reStateTxt.visible = false;
			
			
			if (rewardData.mission_type == 1)
			{
				itemMC.infoTxt.text = GameLanguage.getLangByKey(rewardData.invite_lp) + "  (" + FriendCodeView.INVITE_NUM + "/" + rewardData.amount + ")";
				if (FriendCodeView.INVITE_NUM >= rewardData.amount)
				{
					view.claimBtn.disabled = false;
				}
			}
			else
			{
				itemMC.infoTxt.text = GameLanguage.getLangByKey(rewardData.invite_lp) + "  (" + FriendCodeView.FRIEDN_CHARGE + "/" + rewardData.amount + ")";
				if (FriendCodeView.FRIEDN_CHARGE >= rewardData.amount)
				{
					view.claimBtn.disabled = false;
				}
			}
			
			var reArr:Array = rewardData.reward.split(";");
			len = reArr.length;
			
			for (i = 0; i < len; i++ )
			{
				if (!_rewardVec[i])
				{
					_rewardVec[i] = new ItemContainer();
					_rewardVec[i].scaleX = _rewardVec[i].scaleY = 0.6;
					_rewardVec[i].x = 30 + i * 110;
					_rewardVec[i].y = 50;
					itemMC.addChild(_rewardVec[i]);
					
					_rewardTxt[i] = new Text();
					_rewardTxt[i].x = 80 + i * 110;
					_rewardTxt[i].y = 65;
					_rewardTxt[i].font = "Futura";
					_rewardTxt[i].fontSize = 18;
					_rewardTxt[i].color = "#ffffff";
					itemMC.addChild(_rewardTxt[i]);
				}
				_rewardVec[i].visible = true;
				_rewardVec[i].needBg = false;
				_rewardVec[i].numTF.visible = false;
				_rewardVec[i].setData(reArr[i].split("=")[0],0);
				
				_rewardTxt[i].text = "x"+reArr[i].split("=")[1];
			}
			
			if (rewardData.getState == 1)
			{
				view.claimBtn.visible = false;
				view.reStateTxt.visible = true;
			}
			
		}
		
		private function get view():FriendCodeItemUI{
			return itemMC;
		}
		
	}

}