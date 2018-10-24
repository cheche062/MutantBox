package game.module.MilitaryHouse 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.ItemTips;
	import game.common.UIRegisteredMgr;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.militaryHouse.MilitaryBlockVo;
	import game.global.vo.militaryHouse.MilitaryScore;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.militaryHouse.MilitaryUpgradeViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MilitaryUpgradeView extends BaseDialog 
	{
		
		private var _typeImg:Image;
		private var _typeData:MilitaryBlockVo;
		private var _upgradeInfo:MilitaryScore;
		
		private var _itemImage:Image;
		
		private var _typeId:int = 0;
		private var _nowLv:int = 0;
		private var _nowScore:int = 0;
		
		private var _cost:String;
		
		public function MilitaryUpgradeView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.upgradeBtn:
					WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_UPGRADE, [_typeData.id]);
					break;
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
			//trace("mUgrade: ", args);
			var len:int = 0;
			var i:int = 0;
			var max:int = 0;
			switch(cmd)
			{
				case ServiceConst.MILITARY_HOUSE_UPGRADE:
					WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_INIT);
					_nowLv++;
					refreshInfo();
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			if (!_typeImg)
			{
				_typeImg = new Image();
				_typeImg.skin = "militaryHouse/icon_1.png";
				_typeImg.x = 135;
				_typeImg.y = 27;
				view.addChild(_typeImg);
				
				_itemImage = new Image();
				
				_itemImage.width = _itemImage.height = 80;
				_itemImage.on(Event.CLICK, this, showTips);
				_itemImage.x = 280;
				_itemImage.y = 280;
				view.addChild(_itemImage);
			}
			
			_nowLv = args[0][1];
			_typeId = args[0][0];
			_nowScore = args[0][2];
			
			_typeData = GameConfigManager.military_block_info[args[0][0]];
			
			view.titleTF.text = GameLanguage.getLangByKey(_typeData.name);
			
			var ta:Array = _typeData.req.split("|");
			
			if (ta[0] == 256)
			{
				_typeImg.skin = "militaryHouse/icon_256.png";
			}
			else if (parseInt(ta[1])!=0)
			{
				_typeImg.skin = "militaryHouse/icon_"+ ta[1] +".png";
			}
			else
			{
				_typeImg.skin = "militaryHouse/icon_"+ ta[2] +".png";
			}
			
			refreshInfo();
		}
		
		public function showTips():void
		{
			ItemTips.showTip(_cost.split("=")[0]);
		}
		
		private function refreshInfo():void
		{
			_upgradeInfo = GameConfigManager.military_score[_nowLv+1];
			
			//trace("upgradeInfo:", _upgradeInfo);
			
			if (!_upgradeInfo)
			{
				close();
				return;
			}
			
			switch(_typeId)
			{
				case 0:
					_cost = _upgradeInfo.cost_1;
					break;
				case 1:
					_cost = _upgradeInfo.cost_2;
					break;
				case 2:
					_cost = _upgradeInfo.cost_3;
					break;
				case 3:
					_cost = _upgradeInfo.cost_4;
					break;
				case 4:
					_cost = _upgradeInfo.cost_5;
					break;
				case 5:
					_cost = _upgradeInfo.cost_6;
					break;
				case 6:
					_cost = _upgradeInfo.cost_7;
					break;
				case 7:
					_cost = _upgradeInfo.cost_8;
					break;
				case 8:
					_cost = _upgradeInfo.cost_9;
					break;
				default:
					break;
			}
			
			_itemImage.skin = GameConfigManager.getItemImgPath(_cost.split("=")[0]);
			
			view.nowLvTF.text = "LVL." + _nowLv;
			view.nextLvTF.text = "LVL." + (_nowLv + 1);
			
			/*view.nowEffTF.text = _upgradeInfo.inc * (_nowLv ) + "%";
			view.nextEffTF.text = _upgradeInfo.inc * (_nowLv + 1) + "%";*/
			
			var add:int=Math.ceil(_nowScore*(_nowLv * _upgradeInfo.inc / 100));
			view.nowEffTF.text = parseInt(_nowScore+add) + "(+" + add + ")";
			
			add = Math.ceil(_nowScore*((_nowLv+1) * _upgradeInfo.inc / 100));
			view.nextEffTF.text = parseInt(_nowScore+add) + "(+" + add + ")";
			
			if (BagManager.instance.getItemNumByID(_cost.split("=")[0]) == 0)
			{
				BagManager.instance.initBagData();
			}			
			view.numTF.text = BagManager.instance.getItemNumByID(_cost.split("=")[0]) + "/" + _cost.split("=")[1];
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function createUI():void
		{
			this._view = new MilitaryUpgradeViewUI();
			this.addChild(_view);
			
			UIRegisteredMgr.AddUI(view.upgradeBtn, "MilitaryUpgradeBtn");
			UIRegisteredMgr.AddUI(view.closeBtn, "MilitaryCloseUpgradeBtn");
		}
		
		public override function destroy(destroyChild:Boolean = true):void {
			
			UIRegisteredMgr.DelUi("MilitaryUpgradeBtn");
			UIRegisteredMgr.DelUi("MilitaryCloseUpgradeBtn");
			
			super.destroy(destroyChild);
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_UPGRADE),this,serviceResultHandler,[ServiceConst.MILITARY_HOUSE_UPGRADE]);
			/*Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_GET_INFO),this,serviceResultHandler,[ServiceConst.ASCENDING_GET_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_AUTO_UPGRADE),this,serviceResultHandler,[ServiceConst.ASCENDING_AUTO_UPGRADE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_ONE_UPGRADE), this, serviceResultHandler, [ServiceConst.ASCENDING_ONE_UPGRADE]);*/
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, refreshInfo);
			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_UPGRADE), this, serviceResultHandler);
			/*Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_GET_INFO), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_AUTO_UPGRADE), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_ONE_UPGRADE), this, serviceResultHandler);*/
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, refreshInfo);
			
			super.removeEvent();
		}
		
		
		
		private function get view():MilitaryUpgradeViewUI{
			return _view;
		}
	}

}