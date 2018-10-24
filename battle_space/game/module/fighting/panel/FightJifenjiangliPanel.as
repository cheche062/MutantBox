package game.module.fighting.panel
{
	import MornUI.fightingChapter.FightJifenjiangliViewUI;
	import MornUI.fightingChapter.SaoDangRewardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.StageChapterVo;
	import game.module.fighting.cell.FightJifenjiangliCell;
	import game.module.fighting.mgr.FightingStageManger;
	import game.module.fighting.sData.stageChapetrData;
	
	import laya.events.Event;
	
	public class FightJifenjiangliPanel extends BaseDialog
	{
		private var _rList:RewardList;
		public function FightJifenjiangliPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			var ar:Array = args[0];
			var isJy:Boolean = ar[0];
			var cid:Number = ar[1];
			dataChange(isJy,cid);
		} 
		
		
		public function get view():FightJifenjiangliViewUI{
			if(!_view){
				_view = new FightJifenjiangliViewUI();
			}
			return _view as FightJifenjiangliViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			
			_rList = new RewardList();
			_rList.itemRender = FightJifenjiangliCell;
			_rList.itemWidth = FightJifenjiangliCell.itemWidth;
			_rList.itemHeight = FightJifenjiangliCell.itemHeight;
			view.rBox.addChild(_rList);
			_rList['clickSound'] = "";
			UIRegisteredMgr.AddUI(view.closeBtn,"FightReward_closeBtn");
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			Signal.intance.on(FightingStageManger.FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE,this,rewardChange);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE,this,rewardChange);
		}
		
		private function rewardChange(_isJy:Boolean , _cid:Number):void
		{
			_rList.refresh();
		}
		
		
		private function dataChange(isJy:Boolean,cid:Number):void
		{
//			var listData:Array = [];
			var scData:stageChapetrData = FightingStageManger.intance.getChapetrData(cid,isJy);
			var dic:Object = isJy ? GameConfigManager.stage_chapter_jy_dic : GameConfigManager.stage_chapter_dic;
			
			var scVo:StageChapterVo = dic[cid];
			
			view.starNum.text = "X "+scData.integral;
			view.tileLbl.text = scVo.chapter_name;
			_rList.array = scVo.chapterRewardList;
			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
		}	
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_rList.destroy(true);
			_rList = null;
			UIRegisteredMgr.DelUi("FightReward_closeBtn");
			super.destroy(destroyChild);
			
		}
		
	}
}