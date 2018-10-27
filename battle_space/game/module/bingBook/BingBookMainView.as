package game.module.bingBook 
{
	import MornUI.bingBook.BingBookMainViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.vo.VIPVo;
	import game.global.vo.VoHasTool;
	import game.global.vo.guild.GuildItemVo;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.mgr.FightingManager;
	import game.module.mainui.BtnDecorate;
	import game.module.relic.LevelUpView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.ui.UIUtils;
	import laya.utils.Handler;
	import laya.utils.HitArea;
	import laya.utils.Tween;
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class BingBookMainView extends BaseDialog 
	{
		private var dianDic:Object = {};
		private var xianDic:Object = {};
		private var pints:Array = [];
		private var effList:Array = [];
		private var radiuMax:Number = 240;
		private var radiuList:Array = [94,73,68];
		private var zxList:Array = ["zx01","zx01","zx01"];
		private var hxList:Array = ["x01","x02","x03"];
		private var ringN:Number = 8;
		private var finished:Array;
		private var needWater:Array = [0,0];
		private var _started:Number = 0;
		private var freeTimerAr:Array = [0,0];
		private var levels:Array ;
		private var seleList:Array = [];

		private var idArr:Array;

		private var ifSweep:Boolean;

		private var sweepQuanTimes:int;

		private var sweepWaterTimes:*;
		
		
		public function BingBookMainView() 
		{
			super();
			closeOnBlank = true;
		}

		

		public function get view():BingBookMainViewUI{
			if(!_view)
			{
				_view ||= new BingBookMainViewUI;
			}
			return _view;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
		
			var radiu:Number = 0;
			var du:Number = 360 / ringN;
			var img:Image;
			var p:Point;
			var key:String = "";
			var bK:String = "";
			var eK:String = "";
			
			img = new Image("bingBook/ydd2.png");
			img.pivot(img.width >> 1 , img.height >> 1);
			img.name = "d0";
			img.pos(radiuMax,radiuMax);
			dianDic["d0_0"] = img;
			
			for (var i:int = 0; i < radiuList.length; i++) 
			{
				radiu += radiuList[i];
				for (var j:int = 0; j < ringN; j++) 
				{
//					if(!j)
//					{
						
						p = getPoint(radiu - (radiuList[i] / 2),j * du);
						//底
						img = new Image("bingBook/"+zxList[i]+"_1.png");  
						img.sizeGrid = "1,4,1,4";
						img.size(radiuList[i],3);
						view.lBox.addChild(img);
						img.pivot(img.width >> 1 , img.height >> 1);
						img.pos(p.x,p.y);
						img.rotation = j * du;
						
						
						img = new Image("bingBook/"+zxList[i]+".png");
//						view.lBox.addChild(img);
						img.sizeGrid = "1,4,1,4";
						img.size(radiuList[i],3);
						img.pivot(img.width >> 1 , img.height >> 1);
						img.pos(p.x,p.y);
						img.rotation = j * du;
						bK = i == 0 ? "0_0" : i+"_"+(j+1);
						eK = (i+1)+"_"+(j+1);
						key = "l"+bK+"_"+eK;
						xianDic[key] = img;
						
						
						p = getPoint(radiu + 2,j * du + du / 2);
						
						//底
						if(i < 2)
						{
							img = new Image("bingBook/"+hxList[i]+"_1.png");
							view.lBox2.addChild(img);
							img.pivotX =  img.width >> 1 ;
							img.pos(p.x,p.y);
							img.rotation = j * du + du / 2 + 90;
						}
						
						img = new Image("bingBook/"+hxList[i]+".png");
//						view.lBox.addChild(img);
						img.pivotX =  img.width >> 1 ;
						img.pos(p.x,p.y);
						img.rotation = j * du + du / 2 + 90;
						bK = (i + 1)+"_"+(j + 1);
						eK = j == (ringN - 1) ? (i + 1)+"_1" : (i + 1)+"_"+(j + 2);
						key = "l"+bK+"_"+eK;
						xianDic[key] = img;
						
						
						p = getPoint(radiu,j * du);
//						img = new Image("bingBook/ydd.png");
						img = new Image();
						img.size(50,50);
//						view.lBox2.addChild(img);
						var xxx:Number = i * ringN + j + 1;
						img.name = "d"+xxx;
//						trace(img.name);
						img.pivot(img.width >> 1 , img.height >> 1);
						img.pos(p.x,p.y);
						key = "d"+(i + 1)+"_"+(j + 1);
						dianDic[key] = img;
//						var aaaa:Sprite = new Sprite();
//						aaaa.cacheAsBitmap = true;
//						aaaa.graphics.drawCircle(img.width >> 1 , img.height >> 1,30,"#f8ffff");
//						img.addChild(aaaa);
						
						var imgHitArea:HitArea = new HitArea();
						imgHitArea.hit.drawCircle(img.width >> 1 , img.height >> 1,30,"#f8ffff");
						img.hitArea = imgHitArea;
						img.on(Event.CLICK,this,thisDianClick,[xxx - 1]);
						
						
						var quan:Image = new Image("bingBook/dqq.png");
						img.addChild(quan);
						quan.name = "quan";
						quan.pos(-3,-3);
						
						var p:Point = new Point(i+1,j+1);
						pints.push(p);
//					}
				}
			}
			
			for each (img in xianDic) 
			{
				view.lBox.addChild(img);
			}
			for each (img in dianDic) 
			{
				view.lBox.addChild(img);
			}
			view.lBox.addChild(view.feiji);
			
			view.lBox2.size(view.lBox.width,view.lBox.height);
			view.lBox2.pos(view.lBox.x,view.lBox.y);
			view.lBox.mouseThrough = view.lBox2.mouseThrough = true;
			
			UIRegisteredMgr.AddUI(view.fBtn, "BingBookFightBtn");
			
			trace("BingBookMainView createUI");		
		}
	
		private function createReward():void
		{
			for each(var img:Image in dianDic)
			{
//				trace("img:"+img);
				var na:String = img.name;
//				trace("na:"+na);
				var idx:Number = Number(na.substr(1))-1;
				if(idx>=0)
				{
//					trace("idx:"+idx);
					if(levels && levels.length > idx )
					{
						
						var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_level.json");
						if (!jsonObj)
						{
							jsonObj = {};
						}
						
						var gid:Number = levels[idx];
						var obj:Object = jsonObj[gid];
						var rwd:Array =obj.reward.split("=");
						var rwid:String = rwd[0];
//						trace("rwid:"+rwid);
						var url:String = GameConfigManager.getItemImgPath(rwid);
						img.skin = url;
					}
				}
			}
			
		}
		private function getPoint(r:Number,ao:Number):Point{
			var rp:Point = new Point();
			rp.x = radiuMax + r * Math.cos(ao * Math.PI /180);
			rp.y = radiuMax + r * Math.sin(ao * Math.PI /180);
			return rp;
		}
		
	
		public override function show(...args):void{
			super.show(args);
			
			needWater = [0,0];
			freeTimerAr = [0,0];
			
			AnimationUtil.flowIn(this);
			getData();
			
			startEff();
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			stopEff();
			super.close();
		}
		
		
		
		public override function dispose():void{
			dianDic = xianDic = pints = null;
			UIRegisteredMgr.DelUi("BingBookFightBtn");
			super.dispose();
		}
		
		public function startEff():void{
			view.rdBox.rotation = 0;
			Tween.to(view.rdBox,{rotation:360},6000,null,Handler.create(this,startEff));
		}
		
		public function stopEff():void{
			Tween.clearTween(view.rdBox);
		}
		
		public function getData():void{
			WebSocketNetService.instance.sendData(ServiceConst.BINGBOOK_MAIN,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BINGBOOK_MAIN),
				this,getDataBack);
		}
		
		private function getDataBack(... args):void{
//			Signal.intance.off(
//				ServiceConst.getServerEventKey(args[0]),
//				this,getDataBack);
//			return ;
			trace("兵书副本返回:"+JSON.stringify(args));
			var img:Image;
			var ect:Animation;
			sweepQuanTimes = args[1]["sweepTimes"];  
			trace("用券扫荡次数:"+sweepQuanTimes);
			sweepWaterTimes = args[1]["buyTimes"];  
			trace("用水扫荡次数:"+sweepWaterTimes);
			view.btn_openSweep.on(Event.CLICK,this,openSweepView);
			var isRefresh = args[0] == ServiceConst.BINGBOOK_REFRESH;  
			for each(img in xianDic)
			{
				img.visible = false;
			}
			
			for (var i:int = 0; i < effList.length; i++) 
			{
				ect = effList[i];
				ect.stop();
				ect.removeSelf();
			}
			
			for each(img in dianDic)
			{
//				GameUIUtils.intance.delGlitter(img);
				var quan:Image = img.getChildByName("quan");
				if(dianDic["d0_0"] != img)quan.visible = false;
			}
			
			var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_level.json");
			if (!jsonObj)
			{
				jsonObj = {};
			}
			var dataObj:Object = args[1];
			levels = dataObj.levels;
			started = Number(dataObj.started);
			createReward();
			finished = dataObj.finished ? dataObj.finished : [];
			for (var j:int = 0; j < finished.length; j++) 
			{
				finished[j] = Number(finished[j]);
			}
			ifSweep = false; //是否可以扫荡，取决于是否有一关已经打了
//			亮灯 状态
			for (var i:int = 0; i < levels.length; i++) 
			{
				var gid:Number = Number(levels[i]);
				var ooo:Object = jsonObj[gid];
				img = view.lBox.getChildByName("d"+(i+1));
				img.visible = true;
				if(finished.indexOf(gid) == -1)
				{
					
//					img.skin = Number(ooo.type) == 1 ? "bingBook/ydd3.png" : "bingBook/ydd.png";
					var guiImg:Image = img.getChildByName("guiImg");
					if(Number(ooo.type) != 1)
					{
						
						if(!guiImg)
						{
							guiImg = new Image("bingBook/xx.png");
							guiImg.size(24,24);
							guiImg.name = "guiImg";
							img.addChild(guiImg);
						}
					}else
					{
						if(guiImg)
						{
							img.removeChild(guiImg);
						}
					}
				
				}else
				{
					img.visible = false;
					ifSweep = true;
//					trace("img:"+img.name);
//					img.removeSelf();
//					var quan:Image = img.getChildByName("quan");
//					quan.visible = true;
				}
			
			}
			trace("ifSweep:"+ifSweep);
			var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_sweep.json");
			trace("参数:"+JSON.stringify(jsonObj));
			var maxTimes:Number=0;
			for each(var obj:Object in jsonObj)
			{
				if(Number(obj["up"])>maxTimes)
				{
					maxTimes = Number(obj["up"]);
				}
			}
//			var remainTimes:int = maxTimes-sweepQuanTimes;
//			view.btn_openSweep.label =GameLanguage.getLangByKey("L_A_33035")+ "("+remainTimes+")";
			if(ifSweep)
			{
				
					view.btn_openSweep.disabled = false;
				
			}else
			{
				view.btn_openSweep.disabled = true;
			}
			if(isRefresh)
			{
				for (var i:int = 0; i < radiuList.length * ringN; i++) 
				{
					img = view.lBox.getChildByName("d"+(i + 1));
					img.visible = false;
				}
				timer.once(50,this,showDian,[0]);
			}
			
			//连线
//			var leftKey:String = "0_0";
			var leftP:Point = new Point();
			for (var i:int = 0; i < finished.length; i++) 
			{
				var gid:Number = finished[i];
				var idx:Number = levels.indexOf(gid);
				var p:Point = pints[idx];
				var key:String;
				var key2:String;
				key = "l"+p.x + "_"+p.y+"_"+leftP.x + "_"+leftP.y;
				key2 = "l"+leftP.x + "_"+leftP.y+"_"+p.x + "_"+p.y;
				
				var xian:Image = xianDic[key];
				if(xian)
					xian.visible = true;
				else
				{
					xian = xianDic[key2];
					if(xian)
						xian.visible = true;
				}
				leftP = p;
			}
			freeTimerAr[0] = Number(dataObj.totalRefTimes);
			freeTimerAr[1] = Number(dataObj.totalStartTimes) ;
			
			//可选位置
			changEct();
			changeNeed();
			
			
		}
		
		private function changeNeed():void
		{
			var freeAr:Array = [];
			var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_canshu.json");
			if (jsonObj)
			{
				//vip加成
				var vo:VIPVo = VIPVo.getVipInfo();
				
				freeAr.push(Number(jsonObj[2].value));
				//freeAr.push(Number(jsonObj[3].value));
				freeAr.push(vo.radar_fight);
			}
			
			for (var i:int = 0; i < freeAr.length; i++) 
			{
				var rTime:Number = freeTimerAr[i] - freeAr[i] + 1;
				var freeLbl:Label = view["freeLbl"+(i+1)];
				var wNumLbl:Label = view["wNumLbl"+(i+1)];
				var wNeedBox:Box =  view["wNeedBox"+(i+1)];
				freeLbl.visible = wNeedBox.visible = false;
				
				if(rTime > 0)
				{
					wNeedBox.visible = true;
					needWater[i] = getBuyNum(rTime,i).inum;
					wNumLbl.text = needWater[i];
				}else
				{
					freeLbl.visible = true;
					freeLbl.text = StringUtil.substitute(GameLanguage.getLangByKey("L_A_33031"), 0 - rTime + 1 , freeAr[i]);
				}
				if(i && started)wNeedBox.visible =freeLbl.visible = false;
			}
			
		}
		
		
		private function changEct():void
		{
			var img:Image;
			var ect:Animation;
			seleList.splice(0,seleList.length);
			if(started)
			{
				if(finished.length)
				{
					var gid:Number = finished[finished.length - 1];
					var idx:Number = levels.indexOf(gid);
					var p:Point = pints[idx];
					seleList = seleList.concat(getPPP(p,finished));
					
					img = view.lBox.getChildByName("d"+(idx + 1));
					view.feiji.pos(img.x, img.y);
					
				}else
				{
					seleList = seleList.concat([0,1,2,3,4,5,6,7]);
					img = view.lBox.getChildByName("d0");
					view.feiji.pos(img.x, img.y);
				}
			}else
			{
				img = view.lBox.getChildByName("d0");
				view.feiji.pos(img.x, img.y);
			}
			
			//设置可选位置状态
			for (var k:int = 0; k < seleList.length; k++) 
			{
				img = view.lBox.getChildByName("d"+(seleList[k]+1));
				//				GameUIUtils.intance.addGlitter(img);
				
				if(k >= effList.length)
				{
					ect = new Animation();
					ect.interval = BaseUnit.animationInterval;
					var jsonStr:String = "appRes/effects/bingbox_eff.json";
					ect.loadAtlas(jsonStr);
					effList.push(ect);
				}else
				{
					ect = effList[k];
				}
				ect.play();
				img.parent.addChildAt( ect , img.parent.getChildIndex(img));
				ect.pos(img.x - 40 , img.y - 40);
			}
		}
		
		
		public function get started():Number
		{
			return _started;
		}
		
		public function set started(value:Number):void
		{
			_started = value;
			view.fBtn.label = _started ? "L_A_33028":"L_A_2602"; 
			
			view.rBtn.disabled = _started;
			if(_started)
			{
				view.btn_openSweep.disabled = false;
			}else
			{
				view.btn_openSweep.disabled = true;
			}
		}
		
		private function showDian(idx:Number):void{
			idx ++ ;
			if(idx > radiuList.length * ringN) return ;
			
			var img:Image = view.lBox.getChildByName("d"+idx);
			img.visible = true;
			
			timer.once(50,this,showDian,[idx]);
		}
		
		
		public function getBuyNum(n:Number , type:Number = 0):ItemData{
			
			var jsonName:String = !type? "config/book_refresh.json" : "config/book_att.json";
			var buy_json:Object=ResourceManager.instance.getResByURL(jsonName);
			var leftStr:String;
			if(buy_json)
			{
				for each (var c:Object in buy_json)
				{
					leftStr = c.item_num;
					if(n <= Number(c.up) && n >=  Number(c.down))
					{
						return ItemManager.StringToReward(c.price)[0];
					}
				}
			}
			
			return ItemManager.StringToReward(leftStr)[0];
			
		}
		
		private function getPPP(p:Point , finished:Array):Array{
			var idxs:Array = [];
			var n1:Number = p.x ;
			var n2:Number = p.y - 1;
			if(n2 < 1)
				n2 = ringN;
			idxs.push( (n1 - 1) * ringN + n2 - 1 );
			n2 = p.y + 1;
			if(n2 > ringN)
				n2 = 1;
			idxs.push( (n1 - 1) * ringN + n2 - 1 );
			n1 = p.x + 1;
			n2 = p.y;
			idxs.push( (n1 - 1) * ringN + n2 - 1 );
			
			var rIdxs:Array = [];
			for (var i:int = 0; i < idxs.length; i++) 
			{
				var idx:Number = idxs[i];
				if(idx < levels.length)
				{
					var gid:Number = levels[idx];
					if(finished.indexOf(gid) == -1)
					{
						rIdxs.push(idx);
					}
				}
			}
			return rIdxs;
		}
		
		
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.backBtn.on(Event.CLICK,this,backFun);
			view.rBtn.on(Event.CLICK,this,refreshFun);
			view.fBtn.on(Event.CLICK,this,fightFun);
			trace("BingBookMainView addEvent");
			for (var i:int = 1; i <= radiuList.length * ringN; i++) 
			{
				var img:Image = view.lBox.getChildByName("d"+i);
				img.on(Event.CLICK,this,thisDianClick,[i - 1]);
			}
		
		}
		
		private function openSweepView():void
		{
			var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_sweep.json");
			trace("参数:"+JSON.stringify(jsonObj));
			var maxTimes:Number=0;
			for each(var obj:Object in jsonObj)
			{
				if(Number(obj["up"])>maxTimes)
				{
					maxTimes = Number(obj["up"]);
				}
			}
		
			XFacade.instance.openModule(ModuleName.SweepView,[sweepQuanTimes+1,sweepWaterTimes+1]);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.backBtn.off(Event.CLICK,this,backFun);
			view.rBtn.off(Event.CLICK,this,refreshFun);
			view.fBtn.off(Event.CLICK,this,fightFun);
			trace("BingBookMainView removeEvent");
			for (var i:int = 1; i <= radiuList.length * ringN; i++) 
			{
				var img:Image = view.lBox.getChildByName("d"+i);
				img.off(Event.CLICK,this,thisDianClick);
			}
		}
		
		private function backFun(e:Event):void
		{
			XFacade.instance.openModule("LevelUpView");
			this.close();
			
		}
		
		private function refreshFun(e:Event):void
		{
			if(needWater[0])
			{
				var item:ItemData = new ItemData();
				item.iid = DBItem.WATER;
				item.inum = needWater[0];
				ConsumeHelp.Consume([item],Handler.create(this,refreshSend),GameLanguage.getLangByKey("L_A_33025"));
			}else
			{
				AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"L_A_33026",0,function(v:uint):void{
					if(v == AlertType.RETURN_YES)
					{
						refreshSend();
					}
				});
			}
		}
		
		private function startBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,startBack);
			started = 1;
			freeTimerAr[1] = freeTimerAr[1] + 1;
			changeNeed();
			changEct();
			if(ifSweep)
			{
				view.btn_openSweep.disabled = false;
			}
			else
			{
				view.btn_openSweep.disabled = true;
			}
		}
		
		private function fightFun(e:Event):void
		{
			if(!started)  //挑战
			{
				if(needWater[1])
				{
					var item:ItemData = new ItemData();
					item.iid = DBItem.WATER;
					item.inum = needWater[1];
					ConsumeHelp.Consume([item],Handler.create(this,fightSend),GameLanguage.getLangByKey("L_A_33029"));
				}else
				{
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"L_A_33030",0,function(v:uint):void{
						if(v == AlertType.RETURN_YES)
						{
							fightSend();
						}
					});
				}
				return ;
			}
			
			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,"L_A_33034",0,function(v:uint):void{
				if(v == AlertType.RETURN_YES)
				{
					resetSend();
				}
			});
			
		}
		
		
		private function resetSend():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BINGBOOK_RESET,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BINGBOOK_RESET),
				this,getDataBack);
		}
		
		private function fightSend():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BINGBOOK_START,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BINGBOOK_START),
				this,startBack);
			return ;
		}
		
		private function refreshSend():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.BINGBOOK_REFRESH,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.BINGBOOK_REFRESH),
				this,getDataBack);
		}
		
		private function thisDianClick(idx:Number):void{
			if(levels && levels.length > idx )
			{
				
				var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_level.json");
				if (!jsonObj)
				{
					jsonObj = {};
				}
				
				var gid:Number = levels[idx];
				
				XFacade.instance.openModule(ModuleName.BingBookShowInfoView,[jsonObj[gid] , seleList && seleList.indexOf(idx) != -1]);
			}
			else
			{
//				XTip.showTip("这里点不了");
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BingBookMainView");
			Signal.intance.off(
								ServiceConst.getServerEventKey(ServiceConst.BINGBOOK_MAIN),
								this,getDataBack);
			dianDic = null;
			xianDic = null;
			pints = null;
			effList = null;
			radiuList = null;
			zxList = null;
			finished = null;
			needWater = null;
			freeTimerAr = null;
			levels = null;
			seleList = null;
			super.destroy(destroyChild);
		} 
		
	}

}