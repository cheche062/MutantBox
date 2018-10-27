package game.module.armyGroup 
{
	import MornUI.armyGroup.ArmyGroupPlantCtrlViewUI;
	
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupPlantCtrlView extends BaseView 
	{
		
		private var _btnArr:Array = [];
		
		public function ArmyGroupPlantCtrlView() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				
				default:
					break;
				
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("guildboss: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				
				default:
					break;
			}
		}
		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function show(isMyCity:Boolean,isMyGuild:Boolean,isMoving:Boolean, scaleNum:int):void{
			super.show();
			visible = true;
			
			scale(1 / scaleNum, 1 / scaleNum);
			
			view.fightBtn.visible = false;
			view.moveBtn.visible = false;
			view.justLookBtn.visible = false;
			
			if (User.getInstance().guildID == "")
			{
				isMyGuild = false;
			}
			
			if (isMyGuild)
			{
				view.defBtn.visible = true;
				
			}
			else
			{
				view.defBtn.visible = false;
			}
			
			if (isMyCity && !isMoving)
			{
				view.fightBtn.visible = true;
				view.moveBtn.visible = false;
			}
			else
			{
				view.justLookBtn.visible = true;
				view.moveBtn.visible = true;
				view.fightBtn.visible = false;
			}
			adjustBtnPos();
		}
		
		private function adjustBtnPos():void
		{
			var len:int = _btnArr.length;
			var i:int = 0;
			var sn:int = 0;
			for (i = 0; i < len; i++)
			{
				if (_btnArr[i].visible)
				{
					sn++;
				}
			}
			
			var sIndex:int = 0;
			for (i = 0; i < len; i++)
			{
				if (_btnArr[i].visible)
				{
					_btnArr[i].x = 55 - (sn - 1) * 38 + sIndex * 75;
					sIndex++;
				}
				
			}
		}
		
		override public function close():void{
			visible = false;
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ArmyGroupPlantCtrlViewUI();
			this.addChild(_view);
			
			this.size(view.width, view.height);
			this.anchorX = this.anchorY = 0.5;
			
			_btnArr.push(view.fightBtn, view.moveBtn,view.justLookBtn,view.defBtn);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		public function get view():ArmyGroupPlantCtrlViewUI{
			return _view;
		}
		
	}

}