package game.module.military
{
	import MornUI.military.ShieldViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBShield;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.invasion.shield.ShieldItem;
	import game.module.invasion.shield.ShieldVo;
	import game.module.mainui.MainMenuView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * ShieldView
	 * author:huhaiming
	 * ShieldView.as 2017-7-5 下午2:12:38
	 * version 1.0
	 *
	 */
	public class ShieldView extends BaseDialog
	{
		/**事件-更新护盾*/
		public static const UPDATE:String = "sv_update";
		public function ShieldView()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				default:
					if(e.target.name == "infoBtn"){
						var tipStr:String = GameLanguage.getLangByKey("L_A_49020");
						tipStr = tipStr.replace(/##/g,"\n");
						XTipManager.showTip(tipStr);
					}
					break;
			}
		}
		
		private function onSelectItem(e:Event, index:int):void{
			if(e.type == Event.CLICK){
				var item:ShieldItem = view.list.getCell(index) as ShieldItem;;
				if(item.buyBtn.hitTestPoint(e.stageX,e.stageY) && !item.buyBtn.disabled){
					DataLoading.instance.show();
					WebSocketNetService.instance.sendData(ServiceConst.IN_BUY_SHIELD, [item.data.id]);
				}
			}
		}
		
		private function onResult(cmdStr:Number,... args):void{
			DataLoading.instance.close();
			switch(cmdStr){
				case ServiceConst.IN_BUY_SHIELD:
					format(args[1].shield_list)
					if(!User.getInstance().sceneInfo.base_rob_info){
						User.getInstance().sceneInfo.base_rob_info = {};
					}
					MilitaryView.data.base_rob_info.shield_last_time = args[1].shield_last_time
					User.getInstance().sceneInfo.base_rob_info.shield_last_time = args[1].shield_last_time;
					Signal.intance.event(UPDATE);
					break;
			}
		}
		
		private function onError(...args):void{
			DataLoading.instance.close();
			var cmd:Number = args[1];
			var errStr:String = args[2]
			switch(cmd){
				case ServiceConst.IN_BUY_SHIELD:
					XTip.showTip(GameLanguage.getLangByKey(errStr));
					break;
			}
		}
		
		private function format(info:Object):void{
			var item:ShieldItem;
			var vo:ShieldVo;
			for(var i:String in info){
				vo = getData(i);
				vo && (vo.cdEndTime = info[i]);
			}
			view.list.refresh();
		}
		
		private function getData(id:*):ShieldVo{
			var list:Array = DBShield.getShieldList();
			for(var i:String in list){
				if(list[i].id == id){
					return list[i]
				}
			}
			return null;
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			format(MilitaryView.data.base_rob_info.shield_list);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function addEvent():void{
			super.addEvent();
			this.on(Event.CLICK, this, this.onClick);
			view.list.mouseHandler = Handler.create(this, this.onSelectItem,null, false);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_BUY_SHIELD),this,onResult,[ServiceConst.IN_BUY_SHIELD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		override public function removeEvent():void{
			this.off(Event.CLICK, this, this.onClick);
			view.list.mouseHandler = null
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_BUY_SHIELD),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		override public function createUI():void{
			this._view = new ShieldViewUI();
			this.addChild(_view);
			this.closeOnBlank = true;
			
			view.list.itemRender = ShieldItem;
			view.list.hScrollBarSkin="";
			view.list.array = DBShield.getShieldList();
		}
		
		private function get view():ShieldViewUI{
			return this._view as ShieldViewUI;
		}
	}
}