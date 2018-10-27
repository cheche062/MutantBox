package game.module.bingBook
{
	import MornUI.bingBook.BingBookShowInfoUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.data.bag.ItemCell;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class BingBookShowInfoView extends BaseDialog
	{
		
		private var _rList:RewardList;
		private var infoData:Object ;
		private var isf:Boolean;
		
		public function BingBookShowInfoView()
		{
			super();
			closeOnBlank = true;
		}
		
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			infoData = ar[0];
			trace(JSON.stringify(infoData));
			view.fBtn.disabled = !ar[1];
			var ar:Array = ItemManager.StringToReward(infoData.reward);
			_rList.array = ar;
			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
			
			view.tile1.visible = Number(infoData.type) == 1;
			view.tile2.visible = Number(infoData.type) == 2;
//			trace("名字是:"+this["constructor"]);
		}
		
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			view.rBox.addChild(_rList);
		}
		
		public function get view():BingBookShowInfoUI{
			if(!_view)
			{
				_view ||= new BingBookShowInfoUI;
			}
			return _view;
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.fBtn.on(Event.CLICK,this,fightFun);
//			view.fBtn.mouseThrough = true; 
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.fBtn.off(Event.CLICK,this,fightFun);
		}
		
		private function fightFun(e:Event):void
		{
			if(!infoData)return ;
			FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_BINGBOOK,infoData.id,Handler.create(this,fightOver));
			XFacade.instance.closeModule(BingBookMainView);
			this.close();
//			StoryManager.intance.showStoryModule(StoryManager.STORY_PANNEL);
		}
		
		
		private function fightOver():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			XFacade.instance.openModule(ModuleName.BingBookMainView);
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BingBookShowInfoView");
			_rList = null;
			infoData = null;
			super.destroy(destroyChild);
		}
	}
}