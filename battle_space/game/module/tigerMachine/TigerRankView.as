package game.module.tigerMachine
{
	import MornUI.tigerMachine.IntroduceViewUI;
	import MornUI.tigerMachine.TigerRankViewUI;
	
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.activity.ActivityMainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class TigerRankView extends BaseDialog
	{

		/**
		 *points,rewardGeted,rankConf,scoreInRank
		 */
		private var dataFormTigerView:Array;

		private var curPage:int;

		private var itemNum:int;

		private var totalPage:int;
		public function TigerRankView()
		{
			super();
		}
		override public function createUI():void
		{
			super.createUI();
			this.closeOnBlank = true;
			isModel = true;
			addChild(view); 
			view.list.renderHandler = Handler.create(this, onRender, null, false);
//			view.list.array = [1,2,3,4,5];
		}
		private function onRender(cell:Box,index:int):void
		{
			
			
			if(index>view.list.array.length-1)
			{
				return;
			}
			var data:Object = view.list.array[index];
			if(!data)
			{
				return;
			}
		
			
//			var reward:Array = rewardStr.split(";");
//			var reward:Array = ["1=200","1=300"];
			
			var rankTxt:Text = cell.getChildByName("rankTxt") as Text;
			var rank:int = (curPage-1)*5+index+1;
			rankTxt.text = rank;
			var nameTxt:Text = cell.getChildByName("nameTxt") as Text;
			nameTxt.text = data["name"];
			var pointTxt:Text = cell.getChildByName("pointTxt") as Text;
			pointTxt.text = data["score"];
			if(User.getInstance().uid == data["uid"])
			{
				rankTxt.color = "#afffa7";
				nameTxt.color = "#afffa7";
				pointTxt.color = "#afffa7";
			}else
			{
				rankTxt.color = "#aadbeb";
				nameTxt.color = "#aadbeb";
				pointTxt.color = "#aadbeb";
			}
			var rankConf:Object = dataFormTigerView[2];
			var rewardStr:String;
			trace("rankConf:"+JSON.stringify(rankConf));
			for each(var confItem:Object in rankConf)
			{
//				trace("score:"+data["score"]);
//				trace("down:"+confItem["down"]);
//				trace("up"+confItem["up"]);
				if(rank>=parseInt(confItem["down"])&&rank<=parseInt(confItem["up"]))
				{
					rewardStr = confItem["reward"];
				}
			}
			if(!rewardStr)
			{
				trace("名次超出100，奖励不在配置里");
				return;
			}
			trace("rewardStr:"+rewardStr);
			var reward:Array = rewardStr.split(";");
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
				item.scaleX=0.8;
				item.scaleY=0.8;
				item.x =(item.width-16)*i;
				item.y = 3.5;
//				item.itemIcon.width = 10;
				
				//				item.y = -8;
				//				trace("道具名字:"+itemData.vo.name); 
				//				trace("道具名字:"+itemData.vo.des); 
			}
			box.x = (view.creward.x-view.list.x)-(box.width/2-view.creward.width/2)-1;
		}
		public function get view():TigerRankViewUI{
			if(!_view)
			{
				_view ||= new TigerRankViewUI;
			}
			return _view;
		}
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btn_close.on(Event.CLICK,this,this.close);
			view.btn_left.on(Event.CLICK,this,this.onFpage);
			view.btn_right.on(Event.CLICK,this,this.onLpage);
			view.btn_get.on(Event.CLICK,this,this.onGetReward);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIGER_RANK_PAGE), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIGER_RANK_GET_REWARD), this, onResult);
		}	
		
		private function onGetReward():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.TIGER_RANK_GET_REWARD,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
		}
		
		/**
		 *后一页 
		 * 
		 */
		private function onLpage():void
		{
		   curPage++
		   if(curPage>=20)
		   {
			   curPage=20;
		   }
		   trace("curPage:"+curPage);
		   view.pageTxt.text = curPage + "/" + totalPage;
		   WebSocketNetService.instance.sendData(ServiceConst.TIGER_RANK_PAGE,[ActivityMainView.CURRENT_ACT_ID,curPage,5]);//活动id 
		   setTurnPageBtn();
		}
		
		/**
		 *前一页 
		 * 
		 */
		private function onFpage():void
		{
			curPage--;
			if(curPage<=1)
			{
				curPage=1;
			}
			trace("curPage:"+curPage);
			view.pageTxt.text = curPage + "/" + totalPage;
			WebSocketNetService.instance.sendData(ServiceConst.TIGER_RANK_PAGE,[ActivityMainView.CURRENT_ACT_ID,curPage,5]);//活动id 
			setTurnPageBtn();
		}
		override public function removeEvent():void
		{
			super.removeEvent();
			view.btn_close.off(Event.CLICK,this,this.close);
			view.btn_left.off(Event.CLICK,this,this.onFpage);
			view.btn_right.off(Event.CLICK,this,this.onLpage);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIGER_RANK_GET_REWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIGER_RANK_PAGE), this, onResult);
		}
		
		override public function show(...args):void
		{
			super.show(args);
			trace("打开排行榜数据:"+args[0]);
			dataFormTigerView = args[0];
			curPage = 1; 
			WebSocketNetService.instance.sendData(ServiceConst.TIGER_RANK_PAGE,[ActivityMainView.CURRENT_ACT_ID,curPage,5]);//活动id 
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.TIGER_RANK_PAGE:
				{
					trace("单页排行数据:"+JSON.stringify(args));
					var dataList:Array = [];
					for each(var itemData:Object in args[2])//{"746":{"uid":746,"times":200,"name":"Player746"}}
					{
						dataList.push(itemData);
					}
					view.list.array = dataList;//[{"uid":746,"times":200,"name":"Player746"}];
					totalPage = args[4]; 
//					totalPage = 3;
					view.pageTxt.text = curPage + "/" + totalPage;
					setTurnPageBtn();
					view.yourRankTxt.text = GameLanguage.getLangByKey("L_A_79016")+args[3]["rank"];
					view.yourPointTxt.text = GameLanguage.getLangByKey("L_A_86151")+args[3]["score"];
					
						if(args[3]["rank"]=="")
						{
							view.btn_get.disabled = true;
						}
						else if(dataFormTigerView[1]==0)//没领
						{
							view.btn_get.label = GameLanguage.getLangByKey("L_A_20844");
							view.btn_get.disabled = false;
						}else
						{
							view.btn_get.label = GameLanguage.getLangByKey("L_A_20845");
							view.btn_get.disabled = true;
						}
					
					view.txt1.text =  GameLanguage.getLangByKey("L_A_86157").replace("{0}",dataFormTigerView[3]);;
					break;
				}
				case ServiceConst.TIGER_RANK_GET_REWARD:
				{
					trace("排行榜领奖数据:"+JSON.stringify(args));
					view.btn_get.disabled = true;
//					dataFormTigerView[1] = 1;
					var mainview:* = dataFormTigerView[4];
					if(mainview)
					{
						mainview.rewardGeted = 1;
					}
					
					view.btn_get.label = GameLanguage.getLangByKey("L_A_20845");
					var getReward:String = args[2];
					var reardArr:Array = getReward.split(";"); 
					var propArr:Array = [];
					for(var i:int=0;i<reardArr.length;i++)
					{
						var rStr:String = reardArr[i];
						var rArr:Array = rStr.split("=");
						var idata:ItemData = new ItemData();
						idata.iid = rArr[0];
						idata.inum = rArr[1];
						propArr.push(idata);	
					}
					trace("显示的奖励数组:"+JSON.stringify(propArr));
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [propArr]);
					break;
				}
			}
		}
		
		private function setTurnPageBtn():void
		{
			if(totalPage==1)
			{
				view.btn_left.disabled = true;
				view.btn_right.disabled = true;
			}else
			{
				if(curPage<totalPage)
				{
					if(curPage==1)
					{
						view.btn_left.disabled = true;
						view.btn_right.disabled = false;
					}else
					{
						view.btn_left.disabled = false;
						view.btn_right.disabled = false;
					}
				}else if(curPage==totalPage)
				{
					view.btn_left.disabled = false;
					view.btn_right.disabled = true;
				}
			}
		}
	}
}