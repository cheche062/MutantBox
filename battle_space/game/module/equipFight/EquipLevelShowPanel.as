package game.module.equipFight
{
	import MornUI.equipFight.EquipLevelShowViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.module.equipFight.vo.equipFightChapterVo;
	import game.module.equipFight.vo.equipFightLevelVo;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class EquipLevelShowPanel extends BaseDialog
	{
		
		private var _rList:RewardList;
		private var _showVo:equipFightLevelVo;
		private var _cid:Number = 0;
		
		public function EquipLevelShowPanel()
		{
			super();
			closeOnBlank = true;
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
		
		
		public function get view():EquipLevelShowViewUI
		{
			if(!_view)
				_view = new EquipLevelShowViewUI();
			return _view;
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			var ar:Array = args[0];
			_showVo = ar[0];
			_cid = ar[1];
			view.fName.text = _showVo.name;
			_rList.array = _showVo.showReward;
			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
		} 
		
		
		public override function addEvent():void{
			super.addEvent();
			view.ackBtn.on(Event.CLICK,this,ackFun);
			view.closeBtn.on(Event.CLICK,this,close);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.ackBtn.off(Event.CLICK,this,ackFun);
			view.closeBtn.off(Event.CLICK,this,close);
		}
		
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		
		private function ackFun():void
		{
			FightingManager.intance.getSquad(5,null,Handler.create(this,fBackFunction));
			XFacade.instance.closeModule(EquipFightInfoView);
			this.close();
		}
		
		
		private function fBackFunction():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,2]);
			XFacade.instance.openModule(ModuleName.EquipFightInfoView,_cid);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy EquipLevelShowPanel");
			_rList = null;
			_showVo = null;
			
			super.destroy(destroyChild);
		}
		
	}
}