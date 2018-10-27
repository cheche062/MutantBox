package game.module.turnCards
{
	import MornUI.turnCards.TurnCardsViewUI;
	
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.util.TimeUtil;
	import game.module.activity.ActivityMainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class TurnCardsView extends BaseView
	{
		private var unSelectedArr:Array;//没有被抽到的奖励位置数组
		private var selectedArr:Array;//已经抽到的奖励数组

		private var newRewardPos:int;

		private var curRewardsArr:Array;

		private var turnNum:int;

		private var configObj:Object;

		private var dataTime:Number;

		private var leftTime:Number;
		public function TurnCardsView(dataTime:Number)
		{
			this.dataTime = dataTime; 
			leftTime = dataTime*1000-TimeUtil.now; 
			/*trace("当前时间:"+TimeUtil.now);
			trace("到期时间:"+dataTime);
			trace("剩余时间："+leftTime);*/
			super();
			this.width = 845;
			this.height = 514;
			ResourceManager.instance.load(ModuleName.TurnCardsView,Handler.create(this, resLoader));
		}
		public function resLoader():void
		{
			// TODO Auto Generated method stub
			super.createUI();
			this.addChild(view);
			addEvent();
			if(view.displayedInStage) 
			{
				addToStageEvent();  
			}
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			Laya.timer.clear(this, timeCountHandler);
			super.dispose();
		}
		public function get view():TurnCardsViewUI{
			_view = _view || new TurnCardsViewUI();
			return _view;
		}
		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		
		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_LEVEL_GIFT), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CLAIM_LEVEL_GIFT), this, onResult);
			Signal.intance.off(TrainBattleLogEvent.TRAIN_SHOWREWARD,this,closeHandler);
			view.btn_start.off(Event.CLICK,onClick);
			Laya.timer.clear(this, showReward);
			for(var pos:int=1;pos<=6;pos++)
			{
				var lname:String = "l"+pos;
				var lImage:Image = view[lname];
				Tween.clearAll(lImage);
			}
		}
		
		
		override public function removeEvent():void{
//			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
		   
			
			super.removeEvent();
		}
		private function addToStageEvent():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.TURN_CARDS_VIEW,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TURN_CARDS_VIEW), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TURN_CARDS), this, onResult);
			view.btn_start.on(Event.CLICK,this,this.onClick);
			Signal.intance.on(TrainBattleLogEvent.TRAIN_SHOWREWARD, this, closeHandler);
			
			addTimer();
		}
		
		private function closeHandler():void
		{
			view.btn_start.disabled = false;
			WebSocketNetService.instance.sendData(ServiceConst.TURN_CARDS_VIEW,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
		}
		public function onClick():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.TURN_CARDS,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
//			newRewardPos = 1;
//			curRewardsArr = [4,"1002"];
//			playAni();
		}
		
		private function playAni():void
		{
			view.btn_start.disabled = true;
			var ifSelected = false;
			var index:int=0;
			var v:int=140;
			loop();
			function loop():void
			{
				if(unSelectedArr.length==0)
				{
					trace("所有奖励都已经选择，不播动画");
					return;	
				}
				if(ifSelected)
				{
					trace("已经选中奖励，停止动画");
					selectedArr.push(newRewardPos);
					for(var i:int=unSelectedArr.length-1;i>=0;i--)
					{
						if(unSelectedArr[i]==newRewardPos)
						{
							unSelectedArr.splice(i,1);
						}
					}
					Laya.timer.once(600,this,showReward);
					return;
				}
				if(index<=unSelectedArr.length-1)
				{
					var pos:int = unSelectedArr[index];
					var lname:String = "l"+pos;
					var curTarght:Image;
					var lImage:Image = view[lname];
					curTarght = lImage;
					light(lImage,pos); 
				}
				else
				{
					index=0;
					loop();
				}
			}
			
			function light(lImage:Image,pos:int):void
			{
				lImage.alpha = 1;
				Tween.to(lImage, {alpha:0.5},v,null,Handler.create(null, lightComplete,[pos,lImage]));
			}
			function lightComplete(pos:int,target:Image):void
			{
				target.alpha = 0;
				trace("pos:"+pos);
				index++;
				if(v<=360)
				{
					v+=20;
				}else
				{
					trace("v=:"+v);
					if(pos == newRewardPos)
					{
						ifSelected = true;
						var lname:String = "l"+pos;
						var lImage:Image = view[lname];
						lImage.visible = true;
						lImage.alpha = 1;
					}
				}
				loop();
			}
		}
		
		private function showReward():void
		{
				if(view.displayedInStage)
				{
					var propArr:Array = [];
					var itemData:ItemData = new ItemData();
					itemData.iid =curRewardsArr[0];
					itemData.inum = curRewardsArr[1];
					propArr.push(itemData);		
					trace("显示的奖励数组:"+JSON.stringify(propArr));
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [propArr]);
				}
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.TURN_CARDS_VIEW:
				{
					view.btn_start.disabled = false;
					trace("翻牌子界面:"+JSON.stringify(args[1]));
					turnNum = args[1]["my_info"]["number"]+1; 
					trace("翻牌子次数:"+turnNum);
					selectedArr = args[1]["my_info"]["draw_log"];
					configObj = args[1]["draw_config"]; 
					trace("配置文档："+JSON.stringify(configObj));
					unSelectedArr = [];
					for(var i:int=1;i<=6;i++)
					{
						if(selectedArr.indexOf(String(i))==-1)
						{
							unSelectedArr.push(i);
						}
					}
					//假数据
					trace("选中奖励的数组:"+selectedArr);
					trace("未选中奖励的数组:"+unSelectedArr);
					setView();
					break; 
				}
				case ServiceConst.TURN_CARDS:
				{
					trace("翻开的牌子数据:"+JSON.stringify(args[2]));
					newRewardPos = args[2]; 
					curRewardsArr = args[1][0]; 
					trace("翻拍后奖励数组："+curRewardsArr);
					trace("翻盘后选中奖励的数组:"+selectedArr);
					trace("翻盘后未选中奖励的数组:"+unSelectedArr);
					playAni();
//					setView
					break;
				}
			}
		}
		
		private function addTimer():void
		{
			Laya.timer.loop(1000, this, timeCountHandler);
		}
		
		private function timeCountHandler():void
		{
			leftTime-=1000; 
			//trace("leftTime:"+leftTime);
			view.leftTime.text = TimeUtil.getShortTimeStr(leftTime," ");
		}
		
		private function setView():void
		{
			for(var i:int=1;i<=6;i++)
			{
				var lname:String = "l"+i;
			    var boxName:String = "box"+i
				var gouName:String = "gou"+i;
				view[lname].alpha = 0;
//				view[boxName].visible = true;
				view[boxName].disabled = false;
				view[gouName].visible = false;
			}
			//设置选中项
			for(var i:int=0;i<selectedArr.length;i++)
			{
				var boxName:String = "box"+selectedArr[i];
//				trace("boxName:"+boxName);
//				view[boxName].visible = false;
				var gouName:String = "gou"+selectedArr[i];
				view[boxName].disabled = true;
				view[gouName].visible = true;
			}
			//设置价格
			var curPrice:String;
			for each(var eve:Object in configObj)
			{
				if(eve["num"]==turnNum)
				{
					curPrice = eve["price"];
					var site:String = eve["site"];
					var rewardStr:String = eve["reward"];
					var rewardArr:Array = rewardStr.split("=");
					var itemData:ItemData = new ItemData();
					itemData.iid = rewardArr[0];
					itemData.inum = rewardArr[1];
					var boxName:String = "box"+site;
					var item:ItemCell3;
					if(!(view[boxName] as Box).getChildByName("item"))
					{
						item = new ItemCell3();
						item.name = "item";
						item.x += 48;
						
					}else
					{
						item =(view[boxName] as Box).getChildByName("item");
					}
					item.data = itemData;
					view[boxName].addChild(item);
				}
			}
			var curPriceArr:Array = curPrice.split("=");
			view.numTf.text = curPriceArr[1];
			view.itemIcon.skin = GameConfigManager.getItemImgPath(curPriceArr[0]);
			//设置奖励
			
		}
	}
}