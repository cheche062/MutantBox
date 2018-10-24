package game.module.military
{
	import MornUI.military.MilitaryBuffViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.DBMilitary;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * MilitaryBuffView
	 * author:huhaiming
	 * MilitaryBuffView.as 2017-6-21 下午2:20:43
	 * version 1.0
	 *
	 */
	public class MilitaryBuffView extends BaseDialog
	{
		public function MilitaryBuffView()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case this.view.closeBtn:
					this.close();
					break;
				case this.view.prevBtn:
					view.buffList.page --;
					break;
				case this.view.nextBtn:
					view.buffList.page ++;
					break;
				case this.view.infoBtn:
					var tipStr:String = GameLanguage.getLangByKey("L_A_49610")
					tipStr = tipStr.replace(/##/g,"\n");
					XTipManager.showTip(tipStr);
					break;
			}
		}
		
		private var _curX:Number = -1;
		private function onMD():void{
			_curX = Laya.stage.mouseX;
		}
		
		private function onMU():void{
			var delX:Number = _curX - Laya.stage.mouseX;
			if(delX < -100){
				view.buffList.page --;
			}else if(delX > 100){
				view.buffList.page ++;
			}
			_curX = Laya.stage.mouseX
		}
		
		private function onBuy(data:MilitaryVo):void{
			WebSocketNetService.instance.sendData(ServiceConst.IN_BUY_BUFF, [data.ID]);
		}
		
		private function onResult(...args):void{
			MilitaryView.data.base_rob_info.buy_buff = args[1].buy_buff
			MilitaryView.buy_buff_time = args[1].buy_buff_time;
			view.buffList.refresh();
		}
		
		private function onError(...args):void{
			if(args[1] == ServiceConst.IN_BUY_BUFF){
				XTip.showTip(GameLanguage.getLangByKey(args[2]));
			}
		}
		
		override public function show(...args):void{
			super.show();
			view.buffList.array = DBMilitary.getAll();
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			view.on(Event.MOUSE_DOWN, this, this.onMD);
			view.on(Event.MOUSE_UP, this, this.onMU);
			Signal.intance.on(MilitaryBuffItem.BUY, this, this.onBuy);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_BUY_BUFF), this, this.onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			view.off(Event.MOUSE_DOWN, this, this.onMD);
			view.off(Event.MOUSE_UP, this, this.onMU);
			Signal.intance.off(MilitaryBuffItem.BUY, this, this.onBuy);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_BUY_BUFF), this, this.onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		override public function createUI():void{
			this._view = new MilitaryBuffViewUI();
			this.addChild(this._view);
			
			view.buffList.itemRender = MilitaryBuffItem;
			//view.buffList.hScrollBarSkin="";
		}
		
		private function get view():MilitaryBuffViewUI{
			return this._view as MilitaryBuffViewUI;
		}
	}
}