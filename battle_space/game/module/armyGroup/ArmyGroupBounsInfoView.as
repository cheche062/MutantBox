package game.module.armyGroup 
{
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import MornUI.armyGroup.ArmyGroupBounsInfoViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupBounsInfoView extends BaseDialog 
	{
		
		public function ArmyGroupBounsInfoView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case view.closeBtn:
					close();
					break;
				default:
					break;
				
			}
		}
		
		override public function show(...args):void{
			super.show();
			this.view.visible = true;
		}
		
		override public function close():void{
			onClose();
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ArmyGroupBounsInfoViewUI();
			this.addChild(_view);
			
			this._closeOnBlank = true;
			
			
			view.infoTxt.text = GameLanguage.getLangByKey("L_A_20942").replace(/##/g, "\n");
			
			
			var i:int = 0;
			var len:int = 0;
			
			len = GameConfigManager.ArmyGroupBaseParam.normalBox.length
			for (i = 0; i < len; i++ )
			{
				var ic:ItemContainer = new ItemContainer();
				ic.numTF.visible = false;
				ic.width = ic.height = 70;
				ic.y = 190;
				ic.x = 150 + 41 * (6 - len) + i * 82;
				ic.setData(GameConfigManager.ArmyGroupBaseParam.normalBox[i]);
				view.addChild(ic);				
			}
			
			len = GameConfigManager.ArmyGroupBaseParam.greenBox.length
			for (i = 0; i < len; i++ )
			{
				var ic:ItemContainer = new ItemContainer();
				ic.numTF.visible = false;
				ic.width = ic.height = 70;
				ic.y = 275;
				ic.x = 150 + 41 * (6 - len) + i * 82;
				ic.setData(GameConfigManager.ArmyGroupBaseParam.greenBox[i]);
				view.addChild(ic);				
			}
			
			len = GameConfigManager.ArmyGroupBaseParam.blueBox.length
			for (i = 0; i < len; i++ )
			{
				var ic:ItemContainer = new ItemContainer();
				ic.numTF.visible = false;
				ic.width = ic.height = 70;
				ic.y = 360;
				ic.x = 150 + 41 * (6 - len) + i * 82;
				ic.setData(GameConfigManager.ArmyGroupBaseParam.blueBox[i]);
				view.addChild(ic);				
			}
			
			len = GameConfigManager.ArmyGroupBaseParam.goldenBox.length
			for (i = 0; i < len; i++ )
			{
				var ic:ItemContainer = new ItemContainer();
				ic.numTF.visible = false;
				ic.width = ic.height = 70;
				ic.y = 445;
				ic.x = 150 + 41 * (6 - len) + i * 82;
				ic.setData(GameConfigManager.ArmyGroupBaseParam.goldenBox[i]);
				view.addChild(ic);				
			}
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);			
			super.removeEvent();
		}
		
		public function get view():ArmyGroupBounsInfoViewUI{
			return _view;
		}
		
	}

}