package game.module.invasion
{
	import mx.events.ModuleEvent;
	
	import MornUI.invasion.InvasionMenuUI;
	
	import game.common.DataLoading;
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBInvasion;
	import game.global.data.DBItem;
	import game.global.data.DBMilitary;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.mainui.BtnDecorate;
	import game.module.military.MilitaryVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * InvasionMenuView 基地互动操作界面
	 * author:huhaiming
	 * InvasionMenuView.as 2017-4-24 上午11:49:32
	 * version 1.0
	 *
	 */
	public class InvasionMenuView extends BaseView
	{
		private var _curTime:int = 0;
		private var _priceStr:String = '';
		/**事件-开始战斗*/
		public static const FIGHT:String = "fight";
		//总时间
		public static const TOTAL_TIME:int = 180;
		public function InvasionMenuView()
		{
			super();
		}
		
		public function showSubstitue(resObj:Object):void{
			view.mNumTF_1.text = (resObj[DBItem.DB] || 0) +"";
			view.goldTF.text = (resObj[DBItem.GOLD] || 0) +"";
			view.foodTF.text = (resObj[DBItem.FOOD] || 0) +"";
			view.steelTF.text = (resObj[DBItem.STEEL] || 0) +"";
			view.stoneTF.text = (resObj[DBItem.STONE] || 0) +"";
			view.breadTF.text = (resObj[DBItem.BREAD] || 0) +"";
		}
		
		private function format(data:Object):void{
			var priceRate:Number = DBInvasion.getChangePriceRate(User.getInstance().sceneInfo.base_rob_info.change_number);
			var priceStr:String = DBInvasion.getBuyPrice(User.getInstance().sceneInfo.base_rob_info.search_number);
			_priceStr = priceStr;
			//刷新价格
			var arr:Array = priceStr.split("=");
			ItemUtil.formatIcon(this.view.changeIcon, priceStr);
			if(parseInt(arr[1]) == 0){
				this.view.changeIcon.visible = false;
				
				var str:String = GameLanguage.getLangByKey("L_A_49009");
				str = str.replace(/{(\d+)}/,DBInvasion.getFreeChangeTime()-(User.getInstance().sceneInfo.base_rob_info.change_number || 0));
				this.view.priceTF.text = str;
			}else{
				this.view.changeIcon.visible = true;
				this.view.priceTF.text = Math.ceil(arr[1]*priceRate)+"";
				_priceStr = arr[0]+"="+Math.ceil(arr[1]*priceRate)
			}
			
			//奖牌数
			var cup:Number = (data.role_info.cup || 0);
			view.mNumTF_0.text = data.attacker_win_cup+"";
			view.nameTF.text = data.role_info.base.name+"";
			view.lvTF.text = GameLanguage.getLangByKey("L_A_73")+data.role_info.level;
			view.powerTF.text = data.power_all+"";
			view.cupTF.text = cup+"";
			
			var vo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 1);
			this.view.rankIcon.skin = "appRes\\icon\\military\\"+vo.icon+".png"
		}
		
		//
		private function onClick(e:Event):void{
			switch(e.target){
				case view.quitBtn:
					quit();
					Signal.intance.event(Event.CLOSE, this);
					break;
				case view.attackBtn:
					Signal.intance.event(FIGHT);
					Laya.timer.clear(this,caculateTime);
					break;
				case view.changeBtn:
					var arr:Array = _priceStr.split("=");
					var data:ItemData = new ItemData;
					data.iid = arr[0];
					data.inum = arr[1];
					ConsumeHelp.Consume([data], Handler.create(this, this.onCon))
					break;
				default:
					if(e.target.name == "cupIcon"){
						ItemTips.showTip(DBItem.MEDAL);
					}else if(e.target.name == "dbIcon"){
						ItemTips.showTip(DBItem.DB);
					}
					break;
			}
		}
		
		private function onCon():void{
			Laya.timer.clear(this,caculateTime);
			XFacade.instance.showModule(InvasionView, ["loading"]);
			WebSocketNetService.instance.sendData(ServiceConst.IN_C_TARGET, null);
			view.changeBtn.disabled = true;
			Laya.timer.once(2000, this, updateBtn);
		}
		
		private function updateBtn():void{
			view.changeBtn.disabled = false;
		}
				
		private function quit():void{
			WebSocketNetService.instance.sendData(ServiceConst.IN_QUIT, null);
		}
		
		/**处理网络请求i结果*/
		private function onResult(cmdStr:Number,... args):void{
			trace("onResult>>>>>>>>>>>>>",args);
			DataLoading.instance.close();
			switch(cmdStr){
				case ServiceConst.IN_C_TARGET:
					User.getInstance().sceneInfo.base_rob_info.change_number = parseInt(User.getInstance().sceneInfo.base_rob_info.change_number)+1
					XFacade.instance.closeModule(InvasionView);
					XFacade.instance.getView(InvasionScene).show(args[1]);
					break;
			}
		}
		
		//错误处理
		private function onErr(...args):void{
			DataLoading.instance.close();
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XFacade.instance.closeModule(InvasionView);
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		private function showTime(time:Number):void{
			this.view.timeTF.text = TimeUtil.getShortTimeStr(time*1000)
		}
		
		private function caculateTime():void{
			_curTime --;
			if(_curTime <=0){
				Signal.intance.event(Event.CLOSE, this);
				Laya.timer.clear(this,caculateTime);
				quit();
			}
			showTime(_curTime);
		}
		
		override public function show(...args):void{
			this.onStageResize()
			super.show();
			this.format(args[0]);
			_curTime = TOTAL_TIME;
			Laya.timer.loop(1000, this, caculateTime);
			showTime(_curTime);
		}
		
		override public function close():void{
			super.close();
			Laya.timer.clear(this,caculateTime);
		}
		
		override public function dispose():void{
			//Laya.loader.clearRes("invasion/bg5.png");
			//super.dispose();
		}
		
		override public function onStageResize():void{
			this.view.rightBox.x = LayerManager.instence.stageWidth - this.view.rightBox.width;
			this.view.upCenterBox.x = (LayerManager.instence.stageWidth - this.view.upCenterBox.width)/2;
			this.view.midDownBox.x = (LayerManager.instence.stageWidth - this.view.midDownBox.width)/2;
			this.view.midDownBox.y = LayerManager.instence.stageHeight - this.view.midDownBox.height;
			
			this.view.leftDownBox.y = LayerManager.instence.stageHeight - this.view.leftDownBox.height;
			
			this.view.rightDownBox.x = LayerManager.instence.stageWidth - this.view.rightDownBox.width;
			this.view.rightDownBox.y = LayerManager.instence.stageHeight - this.view.rightDownBox.height;
		}
		
		override public function createUI():void{
			this._view = new InvasionMenuUI();
			this.addChild(_view);
			this.mouseThrough = this._view.mouseThrough = true;
			
			BtnDecorate.decorate(view.attackBtn,"buildingMenu/icon_attack.png");
			this.cacheAsBitmap = true;
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_C_TARGET), this, this.onResult, [ServiceConst.IN_C_TARGET]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onErr);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.IN_C_TARGET), this, this.onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onErr);
		}
		
		private function get view():InvasionMenuUI{
			return this._view as InvasionMenuUI;
		}
	}
}