package game.module.invasion
{
	import MornUI.invasion.InvasionResultUI;
	
	import game.common.ItemTips;
	import game.common.RewardList;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemCell;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * InvasionResultView
	 * author:huhaiming
	 * InvasionResultView.as 2017-5-5 下午12:26:53
	 * version 1.0
	 *
	 */
	public class InvasionResultView extends BaseDialog
	{
		public function InvasionResultView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			var arr:Array = [];
			var list:Array = args[0].fight_result;
			for(var i:int=0; i<list.length; i++){
				if(list[i].id != DBItem.MEDAL){
					arr.push(list[i]);
				}
			}
			//view.rewardLable.visible = (arr.length > 0)
			var delCup:Number = User.getInstance().cup - args[0].old_cup;
			if(delCup > 0){
				view.cupTF_0.text = User.getInstance().cup+"(";
				view.arrowUp.visible = true;
				view.arrowUp.x = view.cupTF_0.x+view.cupTF_0.textWidth;
				view.cupTF_1.text = delCup+")";
				view.cupTF_1.x = view.arrowUp.x + view.arrowUp.width; 
			}else{
				view.cupTF_0.text = User.getInstance().cup+"";
				view.arrowUp.visible = false;
				view.cupTF_1.text = "";
			}
			view.itemList.array = arr;
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
				case view.confirmBtn:
					this.close();
					Signal.intance.event(Event.CLOSE, this);
					break;
			}
		}
		
		private function onSelect(e:Event,index:int):void{
			if(e.type == Event.CLICK){
				var item:ItemIcon = view.itemList.getCell(index) as ItemIcon;
				if(item.data){
					ItemTips.showTip(item.data.id);
				}
			}
		}
		
		override public function createUI():void{
			this._view = new InvasionResultUI();
			this.addChild(_view);
			
			this.view.tipTF.text = "L_A_49037";
			
			view.itemList.itemRender = ItemIcon;
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.itemList.mouseHandler = Handler.create(this, this.onSelect, null, false);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.itemList.mouseHandler = null
		}
		
		private function get view():InvasionResultUI{
			return this._view as InvasionResultUI;
		}
	}
}