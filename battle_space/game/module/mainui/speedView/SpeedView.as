package game.module.mainui.speedView
{
	import MornUI.homeScenceView.SpeedViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingCD;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.module.mainScene.BaseArticle;
	import game.module.mainui.MainMenuView;
	import game.module.mainui.SceneVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * SpeedView
	 * author:huhaiming
	 * SpeedView.as 2018-1-19 上午10:28:53
	 * version 1.0
	 *
	 */
	public class SpeedView extends BaseDialog
	{
		private var _timeItem:SpeendItem;
		private var _items:Array;
		private var _data:*;
		private var _needAni:Boolean = true;
		private var _itemUseCom:SpeedItemUseView;
		private static var PIC_W:int;
		private static const ITEMS:Array = [20202,20203,20204,20205];
		public function SpeedView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			if(_needAni){
				_needAni = false;
				AnimationUtil.flowIn(this);
			}
			var data:Object = args[0];
			this._data = data;
			trace(data);
			
			var db:* = DBBuilding.getBuildingById(data.buildId);
			view.tfName.text = db.name;
			view.tfLv.text = "Lv"+data.level;
			view.tfName.x = (view.width - (view.tfName.textField.textWidth + view.tfLv.textField.textWidth + 10))/2;
			view.tfLv.x = view.tfName.x+view.tfName.textField.textWidth + 10;
			trace(db);
			
			updateTime();
			Laya.timer.loop(1000, this,updateTime);
			onChange();
		}
		
		private function updateTime():void{
			var vo:* = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level);
			var total:Number = vo.CD*1000
			var currentTime:Number;
			for(var i:int=0; i<User.getInstance().sceneInfo.queue.length; i++){
				if(_data.id == User.getInstance().sceneInfo.queue[i][0]){
					currentTime = User.getInstance().sceneInfo.queue[i][1];
					break;
				}
			}
			if(currentTime){
				var leftTime:Number = currentTime * 1000 - TimeUtil.now;
				this.view.bar.width = (1-leftTime/total)*PIC_W
				view.tfTime.text = TimeUtil.getShortTimeStr(leftTime, " ")+"";
				
				vo = User.getInstance().sceneInfo;
				var cost:Number = DBBuildingCD.cost(vo.getQueueTime(_data.id));
				if(cost == 0){
					view.itemTime.btnSpeed.label = "L_A_27";
				}else{
					view.itemTime.btnSpeed.label = cost+"";
				}
			}else{
				this.view.bar.width = 0.1;
				view.tfTime.text = "";
				Laya.timer.clear(this,updateTime);
				this.close();
			}
		}
		
		override public function close():void{
			Laya.timer.clear(this,updateTime);
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			_needAni = true;
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
					break;
				default:
					var pname:String = "";
					if(e.target && e.target.parent){
						pname = e.target.parent.name
					}
					trace(e.target.name);
					if(e.target.name == "btnSpeed"){
						speedUpByWater();
					}else if(e.target.name == "btnContinue"){
						trace("btnContinue",pname)
						itemUseCom.show(_data, ITEMS[pname.split("_")[1]])
					}else if(e.target.name == "btnUse"){
						speedUpByItem(ITEMS[pname.split("_")[1]]);
					}
					break;
			}
		}
		
		private function speedUpByWater(){
			var vo:SceneVo = User.getInstance().sceneInfo;
			var cost:Number = DBBuildingCD.cost(vo.getQueueTime(_data.id));
			if(cost == 0){
				DataLoading.instance.show();
				WebSocketNetService.instance.sendData(ServiceConst.B_ONCE,[vo.getQueueId(_data.id)]);
			}else{
				var str:String = GameLanguage.getLangByKey("L_A_49");
				var handler:Handler = Handler.create(this, sendAction,[ServiceConst.B_ONCE,[vo.getQueueId(_data.id)]])
				
				var item:ItemData = new ItemData;
				item.iid = DBItem.WATER;
				item.inum = cost;
				ConsumeHelp.Consume([item],handler,str)
			}
			this.close();
		}
		
		private function speedUpByItem(itemId:int, num:int=1):void{
			var vo:SceneVo = User.getInstance().sceneInfo;
			DataLoading.instance.show();
			WebSocketNetService.instance.sendData(ServiceConst.Build_Item_CD,[vo.getQueueId(_data.id),itemId, num]);
		}
		
		private function sendAction(action:int, args:Array):void{
			DataLoading.instance.show();
			WebSocketNetService.instance.sendData(action,args)
		}
		
		//错误处理
		private function onErr(...args):void{
			DataLoading.instance.close();
			var cmd:Number = args[1];
			var errStr:String = args[2];
			switch(cmd){
				case ServiceConst.Build_Item_CD:
					XTip.showTip( GameLanguage.getLangByKey(errStr));
					break;
				default:
					break;
			}
		}
		
		private function onChange():void{
			for(var i:int=0; i<_items.length; i++){
				_items[i].update();
			}
		}
		
		private function onUse(data):void{
			speedUpByItem(data.item, data.num);
		}
		
		override public function addEvent():void{
			this.on(Event.CLICK, this, this.onClick);
			super.addEvent();
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, this.onChange);
			Signal.intance.on(SpeedItemUseView.USE, this, this.onUse);
		}
		
		override public function removeEvent():void{
			this.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onErr);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, this.onChange);
			Signal.intance.off(SpeedItemUseView.USE, this, this.onUse);
		}
		
		override public function createUI():void{
			this._view = new SpeedViewUI();
			this.addChild(_view);
			this.closeOnBlank = true;
			
			PIC_W = view.bar.width;
			
			_timeItem = new SpeendItem(view.itemTime, true);
			_timeItem.format(DBItem.WATER);
			_items = new Array();
			for(var i:int=0; i<4; i++){
				_items.push(new SpeendItem(view["item_"+i]));
				_items[i].format(ITEMS[i]);
			}
		}
		
		private function get view():SpeedViewUI{
			return this._view as SpeedViewUI;
		}
		
		private function get itemUseCom():SpeedItemUseView{
			if(!_itemUseCom){
				_itemUseCom = new SpeedItemUseView();
			}
			return _itemUseCom;
		}
	}
}