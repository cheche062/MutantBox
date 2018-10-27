package game.module.techTree 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.ItemTips;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.tech.TechPointVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.tech.TechBuyPointViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TechBuyPointView extends BaseDialog 
	{
		
		private var _itemImg1:Image;
		private var _itemImg2:Image;
		private var c1:int = 0;
		private var c2:int = 0;
		private var i1:int = 20000;
		private var i2:int = 20001;
		private var n1:int;
		private var n2:int;
		
		private var needItem:int = 0;
		
		private var buyNum:int = 1;
		private var maxNum:int = 1;
		
		private var addNum:int = 0;
		
		public function TechBuyPointView() 
		{
			super();
			
		}
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case this.view.maxBtn:
					buyNum = maxNum;
					view.buyNumTF.text = buyNum;
					checkCost();
					break;
				case this.view.minBtn:
					buyNum--
					if (buyNum < 1)
					{
						buyNum = 1;
					}
					view.buyNumTF.text = buyNum;
					checkCost();
					break;
				case this.view.plusBtn:
					buyNum++
					if (buyNum >= maxNum)
					{
						buyNum = maxNum;
					}
					view.buyNumTF.text = buyNum;
					checkCost();
					break;
				case this.view.closeBtn:
					close();
					break;
				case this.view.confirmBtn:
					if (needItem > 0)
					{
						var wrongStr:String = GameLanguage.getLangByKey("L_A_42023");
						wrongStr = wrongStr.replace("{0}", GameLanguage.getLangByKey(GameConfigManager.items_dic[needItem].name));
						XTip.showTip(wrongStr);
						return;
					}
					if (buyNum < 1)
					{
						return;
					}
					addNum = buyNum;
					WebSocketNetService.instance.sendData(ServiceConst.TECH_BUY_POINT, [buyNum]);
					break;
				default:
					break;
				
			}
		}
		
		private function clickImg(...args):void 
		{
			switch(args[0])
			{
				case 1:
					ItemTips.showTip(i1);
					break;
				case 2:
					ItemTips.showTip(i2)
				default:
					break;
			}
		}
		
		private function checkCost():void
		{
			var allPoint:int = User.getInstance().getUserAllTechPoint() + User.getInstance().currentTechPoint;
			/*trace("allPoint1111:", allPoint);
			trace("buyNum:", buyNum);*/
			allPoint += buyNum;
			//trace("allPoint2222:", allPoint);
			var vo:TechPointVo = GameConfigManager.intance.getTechPointCost(allPoint);
			
			if(vo)
			{
				i1 = vo.sum.split(";")[0].split("=")[0];
				i2 = vo.sum.split(";")[1].split("=")[0];
				
				n1 = vo.sum.split(";")[0].split("=")[1] - c1;
				n2 = vo.sum.split(";")[1].split("=")[1] - c2;
				
				/*trace("allPoint:", allPoint);
				trace("buyNum:", buyNum);
				trace("vo:", vo);
				trace("c1:", c1);
				trace("c2:", c2);
				trace("n1:", n1);
				trace("n2:", n2);*/
				
				_itemImg1.skin = GameConfigManager.getItemImgPath(i1);
				_itemImg1.width = _itemImg1.height = 64;
				
				_itemImg2.skin = GameConfigManager.getItemImgPath(i2);
				_itemImg2.width = _itemImg2.height = 64;
				
				checkNum();
			}
		}
		
		private function checkMaxNum():void
		{
			var allPoint:int = User.getInstance().getUserAllTechPoint() + User.getInstance().currentTechPoint;
			
			if (allPoint > 0)
			{
				i1 = GameConfigManager.intance.getTechPointCost(allPoint).sum.split(";")[0].split("=")[0];
				i2 = GameConfigManager.intance.getTechPointCost(allPoint).sum.split(";")[1].split("=")[0];
				
				c1 = GameConfigManager.intance.getTechPointCost(allPoint).sum.split(";")[0].split("=")[1];
				c2 = GameConfigManager.intance.getTechPointCost(allPoint).sum.split(";")[1].split("=")[1];
			}
			
			
			/*trace("tech_point_vec:", GameConfigManager.tech_point_vec);
			trace("allPoint:", allPoint);
			trace("i1:", i1);
			trace("i2:", i2);
			trace("c1:", c1);
			trace("c2:", c2);*/
			
			maxNum = 0;
			
			var bgNum2:int = BagManager.instance.getItemNumByID(i2);
			var bgNum:int = BagManager.instance.getItemNumByID(i1);
			
			var need1:int = 0;
			var need2:int = 0;
			
			var vo:TechPointVo
			while (true)
			{
				allPoint++;
				vo = GameConfigManager.intance.getTechPointCost(allPoint);
				if (vo)
				{
					need1 = vo.sum.split(";")[0].split("=")[1] - c1;
					need2 = vo.sum.split(";")[1].split("=")[1] - c2;
					
					if (bgNum < need1 || bgNum2 < need2)
					{
						break;
					}
					
					maxNum++;
				}
				else
				{
					break;
				}
			}
			
			if (maxNum == 0)
			{
				maxNum = 1;
				buyNum = 1;
				view.buyNumTF.text = buyNum;
			}
			checkCost();
			//trace("当前最大可买数量为;", maxNum);
		}
		
		private function checkNum():void
		{
			needItem = 0;
			
			var bgNum2:int = 0;
			view.num2TF.color = "#ff0000";
			if (BagManager.instance.getItemListByIid(i2) && BagManager.instance.getItemListByIid(i2)[0])
			{
				bgNum2 = BagManager.instance.getItemNumByID(i2);
				
				if ( bgNum2 < n2)
				{
					needItem = i2;
					view.num2TF.color = "#ff0000";
				}
				else
				{
					view.num2TF.color = "#ffffff";
				}
			}
			else
			{
				needItem = i2;
			}
			view.num2TF.text = bgNum2 + "/" + n2;
			
			var bgNum:int = 0;
			view.num1TF.color = "#ff0000";
			if (BagManager.instance.getItemListByIid(i1) && BagManager.instance.getItemListByIid(i1)[0])
			{
				bgNum = BagManager.instance.getItemNumByID(i1);
				
				if ( bgNum < n1)
				{
					needItem = i1;
					view.num1TF.color = "#ff0000";
				}
				else
				{
					view.num1TF.color = "#ffffff";
				}
			}
			else
			{
				needItem = i1;
			}
			view.num1TF.text = bgNum + "/" + n1;
			
			//trace("bb:", BagManager.instance.getItemListByIid(i1));
		}
		
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			buyNum = 1;
			checkMaxNum();
			//checkCost();
			updateData();
			view.buyNumTF.text = buyNum;
			
			
			view.buyNumTF.text = buyNum;
			
			if (BagManager.instance.getItemNumByID(20000) == 0)
			{
				BagManager.instance.initBagData();
			}
			
			//WebSocketNetService.instance.sendData(ServiceConst.ADD_ITEM,["20000=2000"]);
			//WebSocketNetService.instance.sendData(ServiceConst.ADD_ITEM,["20001=2000"]);
		}
		
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new TechBuyPointViewUI();
			this.addChild(_view);
			
			_itemImg1 = new Image();
			_itemImg1.on(Event.CLICK, this, this.clickImg, [1]);
			_itemImg1.skin = "appRes/icon/itemIcon/20000.png";
			_itemImg1.x = 210;
			_itemImg1.y = 160;
			this.view.addChild(_itemImg1);
			
			_itemImg2 = new Image();
			_itemImg2.on(Event.CLICK, this, this.clickImg, [2]);
			_itemImg2.skin = "appRes/icon/itemIcon/20001.png";
			_itemImg2.x = 342;
			_itemImg2.y = 160;
			this.view.addChild(_itemImg2);
			updateData();
			
			view.buyNumTF.text = buyNum;
			
			/*view.tpTF.text = GameLanguage.getLangByKey("L_A_42004").replace("|param1|", "");
			view.ppTF.text = GameLanguage.getLangByKey("L_A_42005").replace("|param1|", "");*/
			//view.btnNameTF.text = GameLanguage.getLangByKey("42005").replace("|param1|", "");
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECH_BUY_POINT), this, serviceResultHandler, [ServiceConst.TECH_BUY_POINT]);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT, this, checkMaxNum, [BagEvent.BAG_EVENT_INIT]);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, checkMaxNum, [BagEvent.BAG_EVENT_CHANGE]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(User.TECH_UPDATE, this, this.updateData);
			super.addEvent();
		}
		
		private function serviceResultHandler():void 
		{
			trace("addNum:", addNum);
			/*trace("pppp2:", User.getInstance().currentTechPoint);*/
			XTip.showTip(GameLanguage.getLangByKey("L_A_42018").replace("{0}", addNum));
			User.getInstance().currentTechPoint+=addNum;
			User.getInstance().updateTechEvent();
			checkMaxNum();
			
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(User.TECH_UPDATE, this, this.updateData);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TECH_BUY_POINT), this, serviceResultHandler);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, checkMaxNum);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, checkMaxNum);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			
			super.removeEvent();
		}
		
		private function updateData():void 
		{
			/*view.presentPointsTF.text = User.getInstance().currentTechPoint;
			view.totalPointsTF.text = User.getInstance().getUserAllTechPoint();*/
		}
		
		private function get view():TechBuyPointViewUI{
			return _view;
		}
	}

}