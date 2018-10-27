package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyItemTipUI;
	
	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.event.Signal;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Handler;
	
	/**
	 * ArmyEditCom
	 * author:huhaiming
	 * ArmyEditCom.as 2017-11-30 下午3:12:23
	 * version 1.0
	 *
	 */
	public class ArmyEditCom extends ArmyItemTipUI
	{
		//容器
		private var _container:Sprite;
		//对坐标用
		private var _target:Sprite;
		//
		private var _data:Object;
		private static const WIDTH:Number = 87;
		/**事件-编辑*/
		public static const EDIT:String = "edit";
		/**事件-下阵*/
		public static const DOWN:String = "down";
		public function ArmyEditCom(sp:Sprite, target:Sprite)
		{
			super();
			_container = sp;
			_target = target;
			list.itemRender = ArmyDeployItem;
		}
		
		public function show(data:Object, index:int):void{
			_data = data;
			_container.addChild(this);
			var p:Point = new Point(_target.x,_target.y);
			this.pos(p.x+index*WIDTH - (this.width-WIDTH)/2,p.y-200);
			this.on(Event.CLICK, this, this.onClick);
			Laya.stage.on(Event.CLICK, this, this.onStageClick);
			list.array = [data];
			list.refresh();
		}
		
		public function close():void{
			this.off(Event.CLICK, this, this.onClick);
			this.removeSelf();
			Laya.stage.off(Event.CLICK, this, this.onStageClick);
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case editBtn:
					Signal.intance.event(EDIT,[_data]);
					this.close();
					break;
				case downBtn:
					Signal.intance.event(DOWN,[_data]);
					this.close();
					break;
			}
		}
		
		private function onStageClick(e:Event):void{
			if(!XUtils.checkHit(this)){
				this.close();
			}
		}
	}
}