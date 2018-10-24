package game.module.armyGroup 
{
	import game.common.base.BaseDialog;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.armyGroup.ArmyGroupCityVo;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.armyGroup.ArmyGroupDefinderListUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupDefinderList extends BaseDialog 
	{
		
		public function ArmyGroupDefinderList() 
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
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("guildboss: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				/*
				 *    $tidyList[] = [
				$teamInfo['power'], //战力
				$teamInfo['name'], //姓名
				$teamInfo['level'], //等级
				]; 
				*/
				case ServiceConst.ARMY_GROUP_CHECK_DEF_LIST:
					view.RankList.array = args[1];
					break;
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
		
		override public function show(...args):void{
			super.show();
			this.view.visible = true;
			
			view.bossBR.text = GameConfigManager.ArmyGroupBossBRInfo[(args[0][0] as ArmyGroupCityVo).level];
			view.bossname.text = "(" + args[0][1] + ")" + GameLanguage.getLangByKey("L_A_20978");
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_CHECK_DEF_LIST,(args[0][0] as ArmyGroupCityVo).id);
		}
		
		override public function close():void{
			onClose();
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			view.RankList.itemRender = ArmyGroupDefItem;
			view.RankList.vScrollBarSkin = "";
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_CHECK_DEF_LIST), this, this.serviceResultHandler,[ServiceConst.ARMY_GROUP_CHECK_DEF_LIST]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_CHECK_DEF_LIST), this, this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		public function get view():ArmyGroupDefinderListUI{
			return _view = _view || new ArmyGroupDefinderListUI();
		}
		
	}

}