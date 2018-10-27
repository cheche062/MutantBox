/***
 *作者：罗维
 */
package game.module.fighting.panel
{
	import MornUI.fightingChapter.ChapterLevelInfoViewUI;
	import MornUI.fightingChapter.GeneFightingViewUI;
	
	import game.common.RewardList;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.starBar;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.data.bag.ItemCell;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class GeneFightingPanel extends BaseDialog
	{
		private var _rList:RewardList;
		private var thisData:Object;
		private var pNum:Number;
		
		public function GeneFightingPanel()
		{
			super();
		}
		
		public function get view():GeneFightingViewUI{
			if(!_view)
				_view = new GeneFightingViewUI();
			return _view as GeneFightingViewUI;
		}
		
		
		override public function show(...args):void{
			super.show();
			thisData = args[0][0];
			pNum = args[0][1];
//			bindData();
			
//			view.fName.text = thisData.name;
			var showReward:Array =  ItemManager.StringToReward(thisData.zxjl);
			
			_rList.repeatX = showReward.length;
			_rList.array = showReward;
			_rList.x = view.panelBox.width - _rList.width >> 1;
			_rList.y = 145;
			
			if(pNum)
			{
//				view.ackBtn.label = "";
				view.bbox.visible = true;
				view.wNumLbl.text = String(pNum);
			}else
			{
//				view.ackBtn.label = "L_A_1038";
				view.bbox.visible = false;
			}
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			view.closeBtn.on(Event.CLICK,this,closeFun);
			
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			
			view.panelBox.addChild(_rList);
			view.ackBtn.on(Event.CLICK,this,ackClick);
			
		}
		
		
		private  function ackClick(e:Event):void
		{
			FightingManager.intance.getSquad(2,thisData.type,Handler.create(this,fBackFunction));
		}
		
		private function fBackFunction():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP);
		}
		
		private function closeFun(e:Event = null):void{
			super.close();
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy GeneFightingPanel");
			_rList = null;
			thisData = null;
			super.destroy(destroyChild);
		}
		
	}
}