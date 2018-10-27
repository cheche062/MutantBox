package game.module.mainui.speedView
{
	import MornUI.homeScenceView.SpeedItemUserViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.bag.BagManager;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.module.invasion.ItemIcon;
	
	import laya.events.Event;
	
	/**
	 * SpeedItemUseView
	 * author:huhaiming
	 * SpeedItemUseView.as 2018-1-19 下午6:11:17
	 * version 1.0
	 *
	 */
	public class SpeedItemUseView extends BaseDialog
	{
		private var _item:ItemIcon;
		private var _data:Object;
		private var _leftTime:Number;
		private var _itemId:*;
		private var _itemNum:int;
		private var _curNum:int;
		private var _maxNum:int;
		private static var PIC_W:int;
		/**免费时间*/
		private static const FREE_TIME:int = 10;
		/***/
		public static const USE:String = "USE";
		private static var itemInfo:Object={
			20202:1,
			20203:10,
			20204:30,
			20205:60
		}
		public function SpeedItemUseView()
		{
			super();
		}
		
		override public function show(...args):void{
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			AnimationUtil.popIn(this);
			
			var data:Object = args[0];
			_itemId = args[1]
			_data = data;
			var db:* = DBBuilding.getBuildingById(data.buildId);
			view.tfName.text = db.name;
			view.tfLv.text = "Lv"+data.level;
			view.tfName.x = (view.width - (view.tfName.textField.textWidth + view.tfLv.textField.textWidth + 10))/2;
			view.tfLv.x = view.tfName.x+view.tfName.textField.textWidth + 10;
			
			_itemNum = BagManager.instance.getItemNumByID(args[1])
			_item.dataSource = {id:args[1],num:_itemNum}
				
			updateTime();
			Laya.timer.loop(1000, this,updateTime);
			
			//计算不能时间
			var m:int = Math.ceil(_leftTime/(60*1000));
			var per:int = itemInfo[_itemId]
			_maxNum = Math.ceil(m/per);
			_maxNum = Math.min(_maxNum, _itemNum);
			
			var vipInfo:VIPVo = VIPVo.getVipInfo();
			var freeTime:Number = FREE_TIME+parseInt(vipInfo.build_speed_up+"")
			
			curNum = Math.ceil((m-freeTime)/per);
			view.tfItemNum.text = curNum+""
			view.tfTotal.text = GameLanguage.getLangByKey("L_A_17007")+TimeUtil.getShortTimeStr(curNum*per*60*1000);
		}
		
		private function updateTime():void{
			var vo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level);
			var total:Number = vo.CD*1000
			var currentTime:Number;
			for(var i:int=0; i<User.getInstance().sceneInfo.queue.length; i++){
				if(_data.id == User.getInstance().sceneInfo.queue[i][0]){
					currentTime = User.getInstance().sceneInfo.queue[i][1];
					break;
				}
			}
			var leftTime:Number = currentTime * 1000 - TimeUtil.now;
			_leftTime = leftTime;
			this.view.bar.width = (1-leftTime/total)*PIC_W
			view.tfTime.text = TimeUtil.getShortTimeStr(leftTime, " ")+"";
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
					break;
				case view.btnAdd:
					curNum ++;
					view.tfItemNum.text = curNum+""
					break;
				case view.btnMinus:
					curNum --;
					view.tfItemNum.text = curNum+""
					view.tfTotal.text = GameLanguage.getLangByKey("L_A_17007")+TimeUtil.getShortTimeStr(curNum*itemTime*60*1000);
					break;
				case view.btnUse:
					Signal.intance.event(USE,{item:_itemId, num:curNum});
					this.close();
					view.tfTotal.text = GameLanguage.getLangByKey("L_A_17007")+TimeUtil.getShortTimeStr(curNum*itemTime*60*1000);
					break;
			}
		}
		
		private function get itemTime():int{
			return itemInfo[_itemId];
		}
		
		private function set curNum(v:int):void{
			if(v >= _maxNum){
				v= _maxNum;
			}else if(v<1){
				v = 1;
			}
			this._curNum = v;
		}
		
		private function get curNum():int{
			return this._curNum;
		}
		
		override public function addEvent():void{
			super.addEvent();
			this.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			this.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			this._view = new SpeedItemUserViewUI();
			this.addChild(this._view);
			PIC_W = view.bar.width;
			
			this.closeOnBlank = true;
			
			_item = new ItemIcon();
			view.itemContainer.addChild(_item);
		}
		
		private function get view():SpeedItemUserViewUI{
			return this._view as SpeedItemUserViewUI;
		}
	}
}