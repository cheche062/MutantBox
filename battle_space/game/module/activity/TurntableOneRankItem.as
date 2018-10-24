package game.module.activity 
{
	import game.common.base.BaseView;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import MornUI.TurntableLottleOne.TurnTableOneRankItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TurntableOneRankItem extends BaseView 
	{
		
		private var rewardArr:Array = [];
		
		private var rewardContainer:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		public function TurntableOneRankItem() 
		{
			super();
			
		}
		
		public function setData(value:*,reArr:String,rIndex:int):void
		{
			var i:int = 0;
			var len:int = 0;
			rewardArr = reArr.split(";");
			len = rewardContainer.length;
			for (i = 0; i < len; i++ )
			{
				rewardContainer[i].visible = false;
			}
			
			len = Math.max(rewardArr.length, rewardContainer.length);
			for (i = 0; i < len; i++) 
			{
				if (!rewardContainer[i])
				{
					rewardContainer[i] = new ItemContainer();
					rewardContainer[i].scaleX = rewardContainer[i].scaleY = 0.7;
					rewardContainer[i].y = 10;
					view.addChild(rewardContainer[i]);
				}
				rewardContainer[i].x = 700 - rewardArr.length * 50+i*100;
				rewardContainer[i].visible = true;
				
				if (!rewardArr[i])
				{
					rewardContainer[i].visible = false;
				}
				else
				{
					rewardContainer[i].setData(rewardArr[i].split("=")[0], rewardArr[i].split("=")[1]);
				}
			}
			
			if (!value)
			{
				view.nameTxt.text = "";
				view.scoreTxt.text = "";
				view.rankTxt.text = rIndex;
				view.gbg.visible = false;
				return;
			}
			
			view.nameTxt.text = value.user;
			view.scoreTxt.text = value.score;
			view.rankTxt.text = value.rank;
			
			view.gbg.visible = (value.uid == User.getInstance().uid);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			
		}
		
		override public function createUI(vv:TurnTableOneRankItemUI):void
		{
			if (!vv)
			{
				return;
			}
			this._view = vv;
			view.nameTxt.text = "";
			view.scoreTxt.text = "";
			view.rankTxt.text = "";
		}
		
		override public function addEvent():void{
			super.addEvent();
		}
		
		override public function removeEvent():void{
			
			super.removeEvent();
		}
		
		private function get view():TurnTableOneRankItemUI{
			return _view;
		}
	}

}