package game.module.guild
{
	import MornUI.guild.AwakeningUI;
	import MornUI.guild.TechnologyUI;
	
	import game.common.ResourceManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class DonateView extends BaseDialog
	{

		private var curData:Array;
		public function DonateView()
		{
			super();
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btnClose.on(Event.CLICK,this,onClose);
			view.btn1.on(Event.CLICK,this,onDonate);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_DONATEVIEW), this, this.serviceResultHandler,[ServiceConst.TECHNOLOGY_DONATEVIEW]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_DONATE), this, this.serviceResultHandler,[ServiceConst.TECHNOLOGY_DONATE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_DONATERESET), this, this.serviceResultHandler,[ServiceConst.TECHNOLOGY_DONATERESET]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_DONATERESET), this, this.serviceResultHandler,[ServiceConst.TECHNOLOGY_DONATERESET]);
			view.btn2.on(Event.CLICK,this,onAdvDonate);
			this.on(Event.ADDED, this, this.addToStageHandler);
		}
		
		private function addToStageHandler():void
		{
			firstTime = true;
		}
		
		private function onAdvDonate():void
		{
		
			var refreshPrice:Object = ResourceManager.instance.getResByURL(JSON_RANDOM_REFRESH_PRICE);
			//			trace("重置价格"+JSON.stringify(refreshPrice));
			var times:int = advDonateTimes+1;
			//			trace("第"+times+"次重置条件:");
			for each(var pri:Object in refreshPrice)
			{
				//				trace(JSON.stringify(pri));
				if(times>=pri["down"]&&times<=pri["up"])
				{
					var priS:String =  pri["price"];
					var priArr:Array = priS.split("=");
					var item:ItemData = new ItemData();
					item.iid = priArr[0];
					item.inum = Number(priArr[1]);
					if(firstTime)
					{
						firstTime = false;
						ConsumeHelp.Consume([item],Handler.create(this,advDonate),GameLanguage.getLangByKey("L_A_80238"));
					}else
					{
						advDonate();
					}
				}	
			}
		}
		
		private function advDonate():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_DONATE,[bclass,lclass,"adv"]);
		}
		private var JSON_RANDOM_RESET_PRICE:String = "config/guild_tec_reset.json";//重置条件 
		private var JSON_RANDOM_REFRESH_PRICE:String = "config/guild_tec_high.json";//重置条件 
		private var GUILD_TEC:String = "config/guild_tec.json";
		private function onDonate():void
		{
			if(donateTimesleft==0)
			{
				var refreshPrice:Object = ResourceManager.instance.getResByURL(JSON_RANDOM_RESET_PRICE);
				//			trace("重置价格"+JSON.stringify(refreshPrice));
				var times:int = donateTimes+1;
				//			trace("第"+times+"次重置条件:");
				for each(var pri:Object in refreshPrice)
				{
					//				trace(JSON.stringify(pri));
					if(times>=pri["down"]&&times<=pri["up"])
					{
						var priS:String =  pri["price"];
						var priArr:Array = priS.split("=");
						var item:ItemData = new ItemData();
						item.iid = priArr[0];
						item.inum = Number(priArr[1]);
						ConsumeHelp.Consume([item],Handler.create(this,resetSend),GameLanguage.getLangByKey("L_A_80238"));
					}	
				}
			}else if(donateTimesleft>0)
			{
				WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_DONATE,[bclass,lclass,"free"]);
			}
		
		}
		
		private function resetSend():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_DONATERESET,[]);
		}
		private var GUILD_PARAM:String = "config/guild_tec_param.json";//参数
		private function serviceResultHandler(cmd:int, ...args):void
		{
			switch(cmd)
			{
				case ServiceConst.TECHNOLOGY_DONATEVIEW:
//					trace("捐献面板:"+JSON.stringify(args[4]));
					refreshView(args);
					break;
				case ServiceConst.TECHNOLOGY_DONATE:
					refreshView(args);
//					Signal.intance.event("refreshDonate",parseInt(args[4]["donateTimesleft"]));
					WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_PANNEL,[]);		
					break;
				case ServiceConst.TECHNOLOGY_DONATERESET:
//					trace("捐献重置返回");
					refreshView(args);
//					Signal.intance.event("refreshDonate",parseInt(args[1]["donateTimesleft"]));
					WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_PANNEL,[]);		
					break;
			}
		}
		public function refreshView(args:Object)
		{
			var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_TEC);
			bclass = args[1];
			lclass = args[2];
			var lv:String = args[3][0];
			var pro:String = args[3][1];
			var id:String = bclass+"-"+lclass+"-"+lv;
			view.curLv.text = GameLanguage.getLangByKey("L_A_34071").replace("{0}",lv);
			for each(var obj:Object in storyObj)
			{
				//					trace("obj:"+JSON.stringify(obj));
				//					trace("obj[id]:"+obj["id"]);
				//					trace("commandArr[i][0]"+commandArr[i][0]);
				if(obj["id"]==id)
				{
					//						trace("参数2"+obj["param2"]);
					view.context.text = GameLanguage.getLangByKey(obj["des"]).replace("{0}", obj["param2"]);
					view.icon.skin = "appRes/icon/guildIcon/tec/"+GameLanguage.getLangByKey(obj["icon"])+".png";
					view.pro.value = pro/obj["need_exp"];
					view.title.text =  GameLanguage.getLangByKey(obj["tpye2lan"]);
					if(obj["need_exp"] == "MAX")
					{
						view.exp.text =  "MAX";
					}else
					{
						view.exp.text =  pro+"/"+obj["need_exp"];
					}
					if(lclass==1&&bclass==1)
					{
						view.lv.text = obj["param2"];
					}else
					{
						view.lv.text = Number(obj["param2"]).toFixed(1)+"%";
					}
					
					var nextLv:int = parseInt(lv)+1;
					var nextId:String = bclass+"-"+lclass+"-"+nextLv;
					var gainStr:String =  obj["gain"];
					var gainArr:Array = gainStr.split("=");
					var propId:String = gainArr[0];
					var propNum:String = gainArr[1];
					
					var gainStr2:String =  obj["gain2"];
					var gainArr2:Array = gainStr2.split("=");
					var propId2:String = gainArr2[0];
					var propNum2:String = gainArr2[1]; 
					view.num2.text = "+"+propNum;
					view.num1.text = "+"+ obj["exp"];
					view.num3.text =  "+"+obj["exp2"];
					view.num4.text =  "+"+propNum2;
					for each(var obj1:Object in storyObj)
					{
						if(obj1["id"]==nextId)
						{
							if(lclass==1&&bclass==1)
							{
								view.nextLv.text = obj1["param2"];
							}
							else
							{
								view.nextLv.text = Number(obj1["param2"]).toFixed(1)+"%";
							}
						}
					}
				}
			}
			donateTimes = args[4]["donateTimes"];
			donateTimesleft = args[4]["donateTimesleft"];
			donateRecoverTime =  args[4]["donateRecoverTime"];
			nowTime =  parseInt(args[4]["nowTime"]);
			nowTime *= 1000;
			donateRecoverTime*=1000;
			donateTimes = parseInt(args[4]["donateTimes"]);
			advDonateTimes = parseInt(args[4]["advDonateTimes"]); 
			rewardRate	= parseInt(args[4]["rewardRate"]);  
			
			if(rewardRate>1)
			{
				view.tipBox.visible = true;
				if(rewardRate==2)
				{
					view.tip.text = GameLanguage.getLangByKey("L_A_76105");
					//							view.num1.text = 
					
				}
				else if(rewardRate==3)
				{
					
					view.tip.text = GameLanguage.getLangByKey("L_A_76106");;
				}
				var propNumRate:int =parseInt(propNum) *rewardRate;
				var expRate:int = parseInt(obj["exp"])*rewardRate;
				var exp2Rate:int = parseInt(obj["exp2"])*rewardRate;
				var propNum2Rate = parseInt(propNum2) *rewardRate;
				view.num2.text = "+"+propNumRate;
				view.num1.text = "+"+ expRate;
				view.num3.text =  "+"+exp2Rate;
				view.num4.text =  "+"+propNum2Rate;
			}else
			{
				view.tipBox.visible = false;
				
			}
			var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_PARAM);
			for each(var obj:Object in storyObj)
			{
				if(obj["id"]==1)
				{
					totalTimes = parseInt(obj["value"]); 
				}
				if(obj["id"]==2)
				{
										recoverTimes = parseInt(obj["value"]);
//					recoverTimes=10;
					recoverTimes*=1000;
				}		
			}
			setRemainTimes();
			setLeftTime();
			setCost(id);
		}
		private function setCost(id:String):void
		{
			var refreshPrice:Object = ResourceManager.instance.getResByURL(GUILD_TEC);
			//			trace("重置价格"+JSON.stringify(refreshPrice));
			var times:int = advDonateTimes+1;
			//			trace("第"+times+"次重置条件:");
			for each(var pri:Object in refreshPrice)
			{
				//				trace(JSON.stringify(pri));
				if(pri["id"]==id)
				{
					var costStr:String = pri["cost"];
					var costArr:Array = costStr.split("=");
					view.itemIcon1.skin = GameConfigManager.getItemImgPath(costArr[0]);
					view.numTF1.text = "x"+costArr[1];
				}	
			}
			var refreshPrice:Object = ResourceManager.instance.getResByURL(JSON_RANDOM_REFRESH_PRICE);
			//			trace("重置价格"+JSON.stringify(refreshPrice));
			var times:int = advDonateTimes+1;
			//			trace("第"+times+"次重置条件:");
			for each(var pri:Object in refreshPrice)
			{
				//				trace(JSON.stringify(pri));
				if(times>=pri["down"]&&times<=pri["up"])
				{
					var priS:String =  pri["price"];
					var priArr:Array = priS.split("=");
					view.itemIcon2.skin = GameConfigManager.getItemImgPath(priArr[0]);
					view.numTF2.text = "x"+priArr[1];
				}	
			}
		}
		private var _timeCount:int = 0;
		private function timeCountHandler():void
		{
			_timeCount--;
			nowTime++;
			if (_timeCount <= 0)
			{
				donateTimesleft++;
				setRemainTimes();
				donateRecoverTime = nowTime;
				setLeftTime();
			}	
			trace("_timeCount:"+_timeCount);
			var leftStr:String = TimeUtil.getTimeCountDownStr(_timeCount,false);
			view.leftTime.text =  GameLanguage.getLangByKey("L_A_2644").replace("{0}",leftStr);
			centerBom();
		}
		private function setRemainTimes():void
		{
			view.remain.text = donateTimesleft + "/" +totalTimes;
		}
		private function setLeftTime():void
		{
//			trace("totalTimes:"+totalTimes);
//			trace("donateTimesleft:"+donateTimesleft);
			view.bomBox.visible = true;
			//				var nowTime:Number = TimeUtil.now;
			
			var times:int = Math.floor((nowTime-donateRecoverTime)/recoverTimes);
							trace("now"+nowTime);
							trace("donateRecoverTime"+donateRecoverTime);
							trace("recoverTimes"+recoverTimes);
							trace("times"+times);
			donateTimesleft+=times;
			
			trace("donateTimesleft:"+donateTimesleft);		
			if(parseInt(donateTimesleft)>=parseInt(totalTimes))
			{
				donateTimesleft = totalTimes;
				view.bomBox.visible = false;	
				Laya.timer.clear(this, timeCountHandler);		
				return;
			}else
			{
				var leftTime:int = (nowTime-donateRecoverTime)%recoverTimes;
				_timeCount = (recoverTimes-leftTime)/1000;
				var leftStr:String = TimeUtil.getTimeCountDownStr(_timeCount,false);
				view.leftTime.text = GameLanguage.getLangByKey("L_A_2644").replace("{0}",leftStr);
				Laya.timer.loop(1000, this, timeCountHandler);
			}
			setRemainTimes();
			centerBom();
			
		}
		
		private function centerBom():void
		{
			view.bomBox.x = view.width/2-view.bomBox.width/2;
		}
		private function onClose():void
		{
			close();
		}
		
		override public function close():void
		{
			// TODO Auto Generated method stub
			super.close();
		}
		
		override public function removeEvent():void
		{
			// TODO Auto Generated method stub
			super.removeEvent();
			view.btnClose.off(Event.CLICK,this,onClose);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_DONATEVIEW), this, this.serviceResultHandler);
			Laya.timer.clear(this, timeCountHandler);
		}
		private var GUILD_TEC:String = "config/guild_tec.json";

		/**
		 *捐献了总次数 
		 */
		private var donateTimes:int;

		/**
		 *当前剩余次数 
		 */
		private var donateTimesleft:int;

		/**
		 *上一次捐献恢复时间 
		 */
		private var donateRecoverTime:Number;

		/**
		 *回复一次需要的时间 
		 */
		private var recoverTimes:int;

		/**
		 *表里配置捐献存储次数 
		 */
		private var totalTimes:int;

		/**
		 *大类科技 
		 */
		private var bclass:String;

		/**
		 *小类科技 
		 */
		private var lclass:String;

		private var nowTime:int;

		private var advDonateTimes:int;

		private var rewardRate:int;

		private var firstTime:Boolean = true;
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			super.show(args);
			closeOnBlank = true;
//			trace("args:"+JSON.stringify(args));
//			trace("当前强化的科技:"+);
			curData = args[0]; 
			var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_TEC);
			var id:String = curData[0];
			var idArr:Array = id.split("-");
			bclass = idArr[0];
			lclass = idArr[1];
//			for each(var obj:Object in storyObj)
//			{
//				//					trace("obj:"+JSON.stringify(obj));
//				//					trace("obj[id]:"+obj["id"]);
//				//					trace("commandArr[i][0]"+commandArr[i][0]);
//				if(obj["id"]==curData[0])
//				{
//					//						trace("参数2"+obj["param2"]);
//					view.context.text = GameLanguage.getLangByKey(obj["des"]).replace("{0}", obj["param2"]);
//					view.icon.skin = "appRes/icon/guildIcon/tec/"+GameLanguage.getLangByKey(obj["icon"])+".png";
//					view.pro.value = curData[2]/obj["need_exp"];
//					view.lv.text = obj["param2"];
//					var nextLv:int = parseInt(curData[1])+1;
//					var nextId:String = idArr[0]+"-"+idArr[1]+"-"+nextLv;
//					var gainStr:String =  obj["gain"];
//					var gainArr:Array = gainStr.split("=");
//					var propId:String = gainArr[0];
//					var propNum:String = gainArr[1];
//					view.num2.text = "+"+propNum;
//					view.num1.text = "+"+ obj["exp"];
//					view.num3.text =  "+"+obj["exp2"];
//					var gainStr2:String =  obj["gain2"];
//					var gainArr2:Array = gainStr2.split("=");
//					var propId2:String = gainArr2[0];
//					var propNum2:String = gainArr2[1]; 
//					view.num4.text =  "+"+propNum2;
//					for each(var obj1:Object in storyObj)
//					{
//						if(obj1["id"]==nextId)
//						{
//							view.nextLv.text = obj1["param2"];
//						}
//					}
//				}
//			}
			WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_DONATEVIEW,[idArr[0],idArr[1]]);
		}
		
		override public function createUI():void
		{
			// TODO Auto Generated method stub
			super.createUI();
			addChild(view);
			
		}	
		public function get view():AwakeningUI{
			if(!_view)
			{ 
				_view ||= new AwakeningUI;  
			} 
			return _view;
		}
	}
}