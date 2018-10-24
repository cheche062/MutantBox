package game.module.fighting.panel
{
	import MornUI.fightResults.PvpResultsShowGradeUI;
	import MornUI.panels.ShowRewardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.bag.ItemCell;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.PvpLevelVo;
	import game.module.pvp.PvpManager;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class showPvpResultsPanel extends BaseDialog
	{
		
		private var _rList:RewardList;
		private var _callBackFun:Handler;
		public function showPvpResultsPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			var items:Array = ar[0];
			var integral:Number = Number(ar[1]);
			
			_callBackFun = ar[2];
			if(!items)
			{
				_rList.array = [];
				return ;
			}
			_rList.array = items;
			
			_rList.pos( view.rBox.width - _rList.width >> 1, view.rBox.height - _rList.height >> 1);
			
			var vo:PvpLevelVo = PvpManager.intance.getPvpLevelByIntegral(integral);
			if(vo)
			{
				var s:String = GameLanguage.getLangByKey("L_A_70094");
				var lName:String = GameLanguage.getLangByKey(vo.name);
				view.textLbl.text = StringUtil.substitute(s,lName);
				view.rankFace.skin = vo.rankIcon;
			}
		} 
		
		public function get view():PvpResultsShowGradeUI{
			if(!_view){
				_view = new PvpResultsShowGradeUI();
			}
			return _view as PvpResultsShowGradeUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			_rList = new RewardList;
			_rList.selectEnable = true;
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			view.rBox.addChild(_rList);
		}
		
		
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			_rList.array = [];
			Signal.intance.event(TrainBattleLogEvent.TRAIN_SHOWREWARD);
			
			if(_callBackFun != null)
			{
				_callBackFun.runWith(0);
				_callBackFun = null;
			}
			
			super.close();
			
			
		}
		
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy showPvpResultsPanel");
			_rList = null;
			_callBackFun = null;
			super.destroy(destroyChild);
		}
	}
}