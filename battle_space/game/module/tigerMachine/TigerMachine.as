package game.module.tigerMachine
{
	import MornUI.tigerMachine.TigerMachineUI;
	import MornUI.turnCards.TurnCardsViewUI;
	
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.util.TimeUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.LangCigVo;
	import game.module.activity.ActivityMainView;
	import game.module.bag.cell.ItemCell4;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class TigerMachine extends BaseView
		
	{	private var actLeftTime:Number; 
		private var getRewardLeftTime:Number; 
		private var dataTime:Number;

		private var rewardArr:Array;

		private var arr1:Array;

		private var arr2:Array;

		private var arr3:Array;

		private var arr4:Array;

		private var arr5:Array;

		private var totalArr:Array;

		private var moveArr:Array;

		private var moveY:Number;

		private var rstObj:Object;

		private var num:int;

		private var reward:Object;

		private var selectArr:Array;

		private var showItem:ItemCell;

		private var rewdStr:String;

		private var costArr:Array;

		private var points:int;

		public var rewardGeted:int;

		private var rankConf:Object;

		private var scoreInRank:int;

		private var playerPool:Array;

		private var forcastFinish:Boolean = true;

		private var masks:Sprite;

		private var msg:String;
		public function TigerMachine(dataTime:Number,getLeftTime:Number)
		{
			this.dataTime = dataTime; 
			actLeftTime = dataTime*1000-TimeUtil.now; 
			getRewardLeftTime = getLeftTime*1000-TimeUtil.now; 
//			trace("当前时间:"+TimeUtil.now);
//			trace("到期时间:"+dataTime);
//			trace("剩余时间："+leftTime);
			trace("活动结束时间:"+TimeUtil.getShortTimeStr(actLeftTime," "));
			trace("领奖结束时间:"+TimeUtil.getShortTimeStr(getRewardLeftTime," "));
			super();
			ResourceManager.instance.load(ModuleName.TigerMachine,Handler.create(this, resLoader));
			playerPool = [];
			this.width = 704;
			this.height = 511;
		}
		private function addTimer():void
		{
			Laya.timer.loop(1000, this, timeCountHandler);
		}
		
		private function timeCountHandler():void
		{
			actLeftTime-=1000; 
			//trace("leftTime:"+leftTime);
			view.leftTime.text = GameLanguage.getLangByKey("L_A_53010")+TimeUtil.getShortTimeStr(actLeftTime," ");
			if(actLeftTime<=0)
			{
				view.btn_start.disabled = true;
				Laya.timer.clear(this, timeCountHandler);
				addTimer1();
			}
		}
		
		private function addTimer1():void
		{
			Laya.timer.loop(1000, this, timeCountHandler1);
		}
		
		private function timeCountHandler1():void
		{
			getRewardLeftTime-=1000; 
			//trace("leftTime:"+leftTime);
			view.leftTime.text = GameLanguage.getLangByKey("L_A_86161")+TimeUtil.getShortTimeStr(getRewardLeftTime," ");
			if(getRewardLeftTime<=0)
			{
				Laya.timer.clear(this, timeCountHandler1);
				close();
			}
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
			forcastFinish = true;
			masks=new Sprite(); 
			masks.width = 407;
			masks.height = 50;
			masks.graphics.drawRect(0,0,407,50,'#FF0000');
			//							mask.pos(0,0);
			//							view.addChild(mask); 
			view.forcast.mask=masks; 
		}
		public function setSelect():void
		{
			for(var i:int=1;i<=5;i++)
			{
				var name:String = "i"+i;
				view[name].visible = selectArr[i-1];
			}
		}
		private function setView():void
		{
//			view.itemBox.disabled = true;
//			forcast();
			view.itemBox.gray = false;
			moveY = ItemCell.itemHeight; 
			moveArr = [];
			for(var i:int=0;i<5;i++)
			{ 
				var c1:Box = view.itemBox.getChildByName("outBox"+i)
				if(!c1)
				{
					c1 = new Box();
					view.itemBox.addChild(c1);
					c1.x = 28+ItemCell.itemWidth*i;
					c1.name = "outBox"+i;
				}
				c1.y = 0;
//				trace("c1.x:"+c1.x);
				moveArr.push(c1);
				var rewdArr:Array = totalArr[i];
				trace("rewdArr:"+rewdArr);
				for(var j:int=0;j<4;j++)
				{
					var rewdStr:String = rewdArr[j];
					var rArr:Array = rewdStr.split("=");
					var item:ItemCell =  c1.getChildByName("inBox"+j)
					if(!item)
					{
						item = new ItemCell();
						item.name = "inBox"+j;
						item.y = -item.height+item.height*j;
						c1.addChild(item);
						if(j==0)
						{
							item.disabled = true;
						}else
						{
							item.disabled = false;
						}
//						trace("inBox创建");
					}
					
					var idata:ItemData = new ItemData();
					idata.iid = rArr[0];
					idata.inum = rArr[1];
					item.data = idata;
				}
			}
		
			
			var mask:Sprite=new Sprite();
			mask.width = 450;
			mask.height = 239;
			mask.graphics.drawRect(0,0,450,239,'#FF0000');
//			mask.pos(0,0);
//			view.addChild(mask);
			view.itemBox.mask=mask;
//			moveAll();
			showItem = view.getChildByName("showItem") as ItemCell;
			
			if(!showItem)
			{
				showItem = new ItemCell(); 
				showItem.name = "showItem";
				view.addChild(showItem);
				showItem.x = 322;
				showItem.y = 350;
			}
			showItem.visible = false;
		}
		
		private function moveAll():void
		{
			view.btn_start.disabled = true;
			view.btn_r.disabled = true;
			showItem.visible = false;
			num=0; 
			for(var z:int=0;z<moveArr.length;z++)
			{
				move(moveArr[z],z); 
			}
			
			function move(tar:Box,index:int):void
			{
				Tween.to(tar,{y:moveY},150,null,new Handler(this,moveComplete,[tar,index]));
			}
			function moveComplete(tar:Box,index:int):void
			{
				if(num==30)//
				{
					setView();	
				}
				if(num>50&&tar.name=="outBox0")
				{
					tar.y = 0;
					view["i1"].visible = selectArr[0];
					return;
				}
				if(num>60&&tar.name=="outBox1")
				{
					tar.y = 0;
					view["i2"].visible = selectArr[1];
					return;
				}
				if(num>65&&tar.name=="outBox2")
				{
					tar.y = 0;
					view["i3"].visible = selectArr[2];
					return;
				}
				if(num>70&&tar.name=="outBox3")
				{
					tar.y = 0;
					view["i4"].visible = selectArr[3];
					return;
				}
				if(num>75&&tar.name=="outBox4")
				{
					tar.y = 0;
					view.btn_start.disabled = false;
					view.btn_r.disabled = false;
					view["i5"].visible = selectArr[4];
					if(rewdStr)
					{
						var rewdArr:Array = rewdStr.split("=");
						var idata:ItemData = new ItemData();
						idata.iid = rewdArr[0];
						idata.inum = rewdArr[1]*rstObj["rate"];
						showItem.data = idata;
						showItem.visible = true;
						if(view.displayedInStage)
						{
							var propArr:Array = [];
							propArr.push(idata);		
							//trace("显示的奖励数组:"+JSON.stringify(propArr));
							XFacade.instance.openModule(ModuleName.ShowRewardPanel, [propArr]);
						}
					}else
					{
						showItem.visible = false;
					}
					return;
				}
				
				num++;
				tar.y = 0;
				move(tar);
			}
		}		
		private function stopAll():void
		{
			for(var z:int=0;z<moveArr.length;z++)
			{
				Tween.clearAll(moveArr[z]);
			}
		}
		override public function dispose():void
		{
			super.dispose();
			Signal.intance.off(ActivityMainView.ACTIVITY_MAIN_CLOSE,onCloseMainView);
		}
		public function get view():TigerMachineUI{
			_view = _view || new TigerMachineUI();
			return _view;
		}
		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			super.addEvent();
		}
		override public function removeEvent():void{
			//			view.off(Event.CLICK, this, this.onClick);
			
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			super.removeEvent();
			
		}
		public function forcast():void
		{
			
			if(!playerPool||playerPool.length==0)
			{
				return;
			}
			if(!forcastFinish)
			{
				return;
			}
			forcastFinish = false;
			var index:int=0;
			var re:RegExp =/{(\d)}/g;
//			playerPool = [["p1",1,50],["p2",1,150]];
			msg=""; 
			trace("playerPool.length:"+playerPool.length); 
			while(index<=0&&index<=playerPool.length)
			{
				var tArr:Array =playerPool.shift(); 
				var num:int;
				var iname:String;
				for(var key:String in reward)
				{
					if(key==tArr[1])
					{
						var reds:String = reward[key];
						var rid:int = reds.split("=")[0];
						var iData:ItemVo = DBItem.getItemData(rid);
						iname =  GameLanguage.getLangByKey(iData.name);
						num = reds.split("=")[1]*tArr[2];
						break;
					}
				}
				tArr[1] = num;
				tArr[2] = iname;
				
				msg +="                                         "+GameLanguage.getLangByKey("L_A_86160").replace(re,function($0,$1){
					
					//replace()中如果有子项，
					//第一个参数：$0（匹配成功后的整体结果  2013-  6-）,
					// 第二个参数 : $1(匹配成功的第一个分组，这里指的是\d   2013, 6)
					//第三个参数 : $1(匹配成功的第二个分组，这里指的是-    - - )   
//					trace("$1:"+$1);
					trace("tArr[$1]:"+ tArr[$1]);
					return tArr[$1];  
				})+"    ";
				index++;
			}
//			trace("playerPool.length:"+playerPool.length); 
//			trace("index:"+index);
			trace("msg:"+msg);
			view.forcast.text = msg; 
			var pos:int = 159; 
			
			Tween.to(masks,{x:view.forcast.width},5000);
			Tween.to(view.forcast,{x:pos - view.forcast.width},5000,null,new Handler(this,tFinish));
			function tFinish():void 
			{
				view.forcast.text=Trim(msg);
				view.forcast.x = 159;
				Tween.clearAll(mask);
				masks.x = 0;
				forcastFinish = true;
				forcast();
			}
		}
		private function Trim(ostr:String):String {  
			var r1:RegExp =/^\W+/;  
			var r2:RegExp =/\W+$/;  
			return ostr.replace(r1,"").replace(r2,"");  
		}
		private function addToStageEvent():void 
		{
			playerPool = [];
			if(actLeftTime<=0)
			{
				view.btn_start.disabled = true;
			}
			else
			{
				view.btn_start.disabled = false;
			}
			view.btn_r.disabled = false;
			//ActivityMainView.CURRENT_ACT_ID
			WebSocketNetService.instance.sendData(ServiceConst.TIGER_MACHINE_VIEW,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
			view.btn_start.on(Event.CLICK,this,onStart);
			view.btn_i.on(Event.CLICK,this,onIntroduce);
			view.btn_r.on(Event.CLICK,this,onRank);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIGER_FORCAST), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIGER_MACHINE_VIEW), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TIGER_MACHINE_START), this, onResult);
			Signal.intance.on(ActivityMainView.ACTIVITY_MAIN_CLOSE,this,onCloseMainView);
			if(actLeftTime>0)
			{
				addTimer();
			}
			else if(getRewardLeftTime>0)
			{
				addTimer1();
			}
		}
		private function onCloseMainView():void
		{
			Laya.timer.clear(this, timeCountHandler);
			Laya.timer.clear(this, timeCountHandler1);
		}
		private function onRank():void
		{
			XFacade.instance.openModule(ModuleName.TigerRankView,[points,rewardGeted,rankConf,scoreInRank,this]);
		}
		
		private function onIntroduce():void
		{
			XFacade.instance.openModule(ModuleName.TigerIntroduce);
		}
		
		private function onStart():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.TIGER_MACHINE_START,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
//			createInitData();
//			moveAll();
		}
		private function removeFromStageEvent():void
		{
			stopAll();
			view.btn_start.off(Event.CLICK,this,onStart);
			view.btn_i.off(Event.CLICK,this,onIntroduce);
			view.btn_r.off(Event.CLICK,this,onRank);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIGER_MACHINE_VIEW), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIGER_MACHINE_START), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TIGER_FORCAST), this, onResult);
			WebSocketNetService.instance.sendData(ServiceConst.TIGER_MACHINE_LEAVE,[ActivityMainView.CURRENT_ACT_ID]);//活动id 
			forcastFinish = true;
			Tween.clearAll(masks);
			masks.x = 0;
			Tween.clearAll(view.forcast);
			view.forcast.x = 159;
			if(msg&&msg!="")
			{
				view.forcast.text=Trim(msg);
			}else
			{
				view.forcast.text="";
			}
			
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				//打开周卡 
				case ServiceConst.TIGER_MACHINE_VIEW:
				{
					trace("老虎机界面:"+JSON.stringify(args[1]));
					reward =  args[2]; 
					rewardArr = []; 
					costArr = args[3].split("=");
					points = args[5]["rankScore"]; 
					rewardGeted =  args[5]["rewardGeted"];  
					scoreInRank = args[6]; 
					rankConf = args[4]; 
					trace("排行榜配置:"+rankConf);
					for each(var rewd:String in reward)
					{
						rewardArr.push(rewd);
					}
					createInitData();
					setView();
					setSelect();
					setCost();
					setPoints();
					break; 
				}
				case ServiceConst.TIGER_MACHINE_START:
				{
					trace("老虎机启动:"+JSON.stringify(args[2]));
					points = args[3]; 
					setPoints();
					if(args[2].length==0)
					{
						trace("没有抽中");
						rstObj = null;
						rewdStr = null;
						createInitData();
						setSelect();
					}else
					{
						trace("抽中了");
						rstObj = args[2][0]; 
						selectArr = [false,false,false,false,false];
						setSelect();
						createRstData();
					}
					moveAll();
					break;
				}	
				case ServiceConst.TIGER_FORCAST:
				{
					trace("老虎机广播:"+JSON.stringify(args[1]));
					var pool:Array = args[1];
					for(var i:int=0;i<pool.length;i++)
					{
						playerPool.push(pool[i]);
					}
					forcast();
				}
			}
		}
		
		private function setPoints():void
		{
			view.points.text = GameLanguage.getLangByKey("L_A_86151")+points;
		}
		
		private function setCost():void
		{
			view.itemIcon.skin = GameConfigManager.getItemImgPath(costArr[0]);
			view.numTf.text = costArr[1];
		}
		
		private function createRstData():void
		{
			var rstNum:int = rstObj["num"];
			var id:String = rstObj["id"];
			rewdStr = reward[id]; 
			var rewardCopyArr:Array = rewardArr.slice();
			deleteEle(rewdStr);//删除中奖字符串
			var rst:Array = [];
			var leftNum:int = 5-rstNum;
			selectArr = []; 
			for(var i:int=0;i<leftNum;i++)//创建非重复的非奖励数据
			{
				var random:int = parseInt(Math.random() * rewardCopyArr.length);
				var ran:String = rewardCopyArr[random];
				deleteEle(ran);
				rst.push(ran);
			}
			var insetPos:int = parseInt((5-rstNum)*Math.random());
			for(var z:int=0;z<rstNum;z++)
			{
				rst.splice(insetPos,0,rewdStr);//插入n个相邻的奖励
			}
			var tmpPos:int = insetPos;
			var tmpNum:int=0;
			for(var m:int=0;m<5;m++)
			{
				if(m==tmpPos&&tmpNum<rstNum)
				{
					selectArr.push(true);
					tmpNum++;
					tmpPos++;
				}else
				{
					selectArr.push(false);
				}
			}
			trace("selectArr:"+selectArr);
			arr1[2] = rst[0];
			arr2[2] = rst[1];
			arr3[2] = rst[2];
			arr4[2] = rst[3];
			arr5[2] = rst[4];
			totalArr.push(arr1);
			totalArr.push(arr2);
			totalArr.push(arr3);
			totalArr.push(arr4);
			totalArr.push(arr5);
			function deleteEle(ele:String):void
			{
				for(var j:int=rewardCopyArr.length-1;j>=0;j--)
				{
					if(ele==rewardCopyArr[j])
					{
						rewardCopyArr.splice(j,1);
					}
				}
			}
		}
		private function randomArr(arr:Array):Array
		{
			var outputArr:Array = arr.slice();
			var i:int = outputArr.length;
			
			while (i)
			{
				outputArr.push(outputArr.splice(parseInt(Math.random() * i--), 1)[0]);
			}
			
			return outputArr;
		}
		/**
		 *至少配8个以上 奖励
		 * 
		 */
		private function createInitData():void
		{
			selectArr = [false,false,false,false,false];
			var rst:Array = rewardArr.slice(0,5);
			rst = randomArr(rst);
			trace("rst:"+rst);
			totalArr = []; 
			arr1 = [];
			arr2 = []; 
			arr3 = [];
			arr4 = [];
			arr5 = []; 
			for(var i:int=0;i<=3;i++)
			{
				arr1.push(rewardArr[i]);
				
			}
			arr1[2] = rst[0];
			totalArr.push(arr1);
			for(var i:int=1;i<=4;i++)
			{
				arr2.push(rewardArr[i]);
				
			}
			arr2[2] = rst[1];
			totalArr.push(arr2);
			for(var i:int=2;i<=5;i++)
			{
				arr3.push(rewardArr[i]);
				
			}
			arr3[2] = rst[2];
			totalArr.push(arr3);
			for(var i:int=3;i<=6;i++)
			{
				arr4.push(rewardArr[i]);
				
			}
			arr4[2] = rst[3];
			totalArr.push(arr4);
			for(var i:int=4;i<=7;i++)//
			{
				arr5.push(rewardArr[i]);
				
			}
			arr5[2] = rst[4];
			totalArr.push(arr5);
		}
	}
}