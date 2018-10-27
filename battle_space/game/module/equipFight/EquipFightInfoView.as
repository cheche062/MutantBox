package game.module.equipFight
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.LayerManager;
	import game.common.ListPanel;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	
	public class EquipFightInfoView extends BaseView
	{
		public static var returnType:Number = 0;
		
		private var tabPanelList:ListPanel;
		
		public function EquipFightInfoView()
		{
			super();
			m_iLayerType	= LayerManager.M_FIX;
			m_iPositionType = LayerManager.LEFTUP;
			
			this.mouseEnabled  = true;
			
		}
		
	
		
		override public function createUI():void
		{
			super.createUI();
			
			size(Laya.stage.width ,Laya.stage.height);
			tabPanelList = new ListPanel([EquipFightSelectView,EquipFightHangXingView]);
			addChild(tabPanelList); 
		}
		
		
		
		
		public override function show(...args):void{
			super.show();
			var n:Number = args[0];
			
			if(returnType)
			{
				if(returnType == 1)
				{
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,
						GameLanguage.getLangByKey("L_A_44020")
						,AlertType.YES);
				}else
				{
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,
						GameLanguage.getLangByKey("L_A_44018")
						,AlertType.YES);
				}
				n = returnType = 0;
			}
			bindZhangJie(n);
		}
		
		public override function close():void{
			super.close();
			tabPanelList.selIndex = -1;
		}
		
		public function bindZhangJie(n:Number):void{
			
			if(n)
			{
				tabPanelList.selIndex = 1;
				showHangXing(n);
			}else
			{
				tabPanelList.selIndex = 0;
			}
		}
		
		private function showHangXing(cId:Number):void
		{
			var _equipHangxing:EquipFightHangXingView = tabPanelList.getPanel(1);
			
			_equipHangxing.sendInfo(cId);
		}
		
		
		override public function addEvent():void{
			super.addEvent();
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIP_FIGHT_FIGHT),
				this,sendFightBack);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			Signal.intance.off(
				ServiceConst.getServerEventKey(ServiceConst.EQUIP_FIGHT_FIGHT),
				this,sendFightBack);
		}
		
		private function sendFightBack(... args):void{
			
			var backObj:Object = args[1];
			
			showHangXing(Number(backObj.chapter));
		}
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy EquipFightInfoView");
			tabPanelList = null;
			
			super.destroy(destroyChild);
		}
	}
}