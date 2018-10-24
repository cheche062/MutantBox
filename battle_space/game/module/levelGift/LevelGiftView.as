package game.module.levelGift
{
	import game.common.base.BaseView;
	import game.net.socket.WebSocketNetService;
	import MornUI.LevelGift.LevelupViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.LangCigVo;
	import game.global.vo.User;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.utils.Handler;
	
	public class LevelGiftView extends BaseView
	{
		/**数据表*/
		private var JSON_PAY_CARD:String = "config/level_gift.json";

		private var dataList:Array;
		public function LevelGiftView()
		{
			super();
			ResourceManager.instance.load(ModuleName.LevelGiftView,Handler.create(this, resLoader));
		}
		
//		override public function close():void
//		{
//			// TODO Auto Generated method stub
//			super.close();
//		}
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		private function onClose():void{
			super.close();
		}
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			super.show(args);
			AnimationUtil.flowIn(this);
			
		}
		
		public function resLoader():void
		{
			// TODO Auto Generated method stub
			super.createUI();
			this.addChild(view);
			this.closeOnBlank = true;
			view.list.renderHandler = Handler.create(this, onRender, null, false);
			
			addEvent();
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
		public function get view():LevelupViewUI{
			_view = _view || new LevelupViewUI();
			return _view;
		}
		
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.OPEN_LEVEL_GIFT);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_LEVEL_GIFT), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CLAIM_LEVEL_GIFT), this, onResult);
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_LEVEL_GIFT), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CLAIM_LEVEL_GIFT), this, onResult);
			
		}
		
		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
		}
	
		private function onRender(cell:Box,index:int):void
		{
			var data:Object = view.list.array[index];
			var lv:Text = cell.getChildByName("lvTxt") as Text;
			lv.text =GameLanguage.getLangByKey("L_A_56094")+ data["level"];
			lv.wordWrap = true;
			var btn:Button = cell.getChildByName("btn_pick") as Button;
//			trace("单项数据"+index + ":"+data);
			cell.disabled = false; 
			btn.visible = true;
			if(data["status"]==0) 
			{ 
				btn.disabled = true; 
				btn.visible = true;
			}else if(data["status"]==1) 
			{ 
				btn.disabled = false;
				btn.visible = true;
			}else if(data["status"]==2)
			{
				btn.disabled = false;
				btn.visible = false;
			}
			btn.dataSource = data;
			btn.on(Event.CLICK, this, this.pickup);
			
			var rewardS:String = data["reward"];
			var reward:Array = rewardS.split(";");
			var box:Box = cell.getChildByName("ItemBox");
		
			
			if(box)
			{
				box.removeChildren();
			}else
			{
				box = new Box();
				cell.addChild(box);
				box.name = "ItemBox";
			}
			for(var i:int=0;i<reward.length;i++)
			{
				var rewardStr:String = reward[i];
				var rewardArr:Array = rewardStr.split("=");
				var itemData:ItemData = new ItemData();
				itemData.iid = rewardArr[0];
				itemData.inum = rewardArr[1];
				var item:ItemCell = new ItemCell3();
				item.data = itemData;
//				item.height = 40;
//				item.itemNumLal.visible = false;
				box.addChild(item);
				item.x =(item.width+10)*i;
				item.itemIcon.width = 10;
//				item.y = -8;
//				trace("道具名字:"+itemData.vo.name); 
//				trace("道具名字:"+itemData.vo.des); 
			}
			box.x = (cell.width/2-box.width/2);
//			box.y = cell.height/2-box.height/2;
			trace("box.y"+box.y);
		}
		
		private function pickup(e:Event):void
		{
			var lv:int = (e.target as Button).dataSource["level"];
			sendData(ServiceConst.CLAIM_LEVEL_GIFT,[lv]);
			//trace("领取的道具："+(e.target as Button).dataSource["reward"]);
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.OPEN_LEVEL_GIFT:
				{
					var pay_card_data:Object = ResourceManager.instance.getResByURL(JSON_PAY_CARD);
					var severData:Object = args[1];//后端只发已经领取的奖励   
					trace(pay_card_data);
					//trace(pay_card_data["3"]);
					//对解析的配置数据增加状态字段，凑成实际需要的数据,status 0:不能领,1:可以领，2:已经领
					dataList = [];
					for each(var value:Object in pay_card_data)
					{
						value["status"] = 0;
						var lv:int = value["level"];
						if(User.getInstance().level>=lv)
						{
							value["status"] = 1;
							for (var key:* in severData)
							{
								if(key==lv)
								{
									value["status"] = 2;
								}
							}
						}
						dataList.push(value);
					}
//					trace("数据列表:"+JSON.stringify(dataList));
					view.list.array = dataList; 
					break;
				} 
					
				case ServiceConst.CLAIM_LEVEL_GIFT:
				{
//					trace("领取道具返回1111111111111");
					var dataArr:Object = [];
					var propArr:Array = [];
//					trace(JSON.stringify(args[1]));
					dataArr = args[1]["add_item"];
//					trace("道具数组"+dataArr);
					for each(var value1:Object in dataArr)
					{
						trace("id"+value1[0]+"数量"+value1[1]);
						var itemData:ItemData = new ItemData();
						itemData.iid = value1[0];
						itemData.inum = value1[1];
						propArr.push(itemData);
					}					
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [propArr]);
					sendData(ServiceConst.OPEN_LEVEL_GIFT);	
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
	}
}