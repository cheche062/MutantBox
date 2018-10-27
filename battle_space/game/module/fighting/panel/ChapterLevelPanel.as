/***
 *作者：罗维
 */
package game.module.fighting.panel
{
	import MornUI.fightingChapter.ChapterLevelInfoViewUI;
	import MornUI.panels.BagViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.GameLanguageMgr;
	import game.common.ResourceManager;
	import game.common.RewardList;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.starBar;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.StageLevelVo;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.global.vo.requirementVo;
	import game.module.bag.cell.needItemCell;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.cell.chapterListCell;
	import game.module.fighting.cell.chapterStarCell;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.mgr.FightingStageManger;
	import game.module.fighting.sData.stageChapetrData;
	import game.module.fighting.sData.stageLevelData;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class ChapterLevelPanel extends BaseDialog
	{
		private var _starb:starBar;
		protected var _sType:Number = 0;
		private var _cellList:Array = [];
		protected var _overTongguan:Boolean;
		protected var _maxfNum:Number = 0;
		protected var buyUrl:String = "config/stage_buy.json";
		protected var param:String = "config/stage_param.json";
		protected var toF:Boolean;
		protected var thisData:stageLevelData;
		protected var scData:stageChapetrData;
		protected var dataList:Array;
		protected var _dataIdx:Number = 0;
		protected var needCell1:needItemCell;
		protected var needCell2:needItemCell;
		
		public function ChapterLevelPanel()
		{
			super();
			closeOnBlank = true;
		}
		
		
		public function get buyTimer():Number
		{
			if (!scData) return 0;
			
			return thisData.buyTimes;
			//return scData.type == 1 ? FightingStageManger.intance.buyNum1 : FightingStageManger.intance.buyNum2 ;
		}

		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
			toF = false;
			UIRegisteredMgr.DelUi("SweepFiveBtn");
			//XFacade.instance.disposeView(this);
		}
		
		
		public function get view():ChapterLevelInfoViewUI{
			if(!_view)
				_view = new ChapterLevelInfoViewUI();
			return _view as ChapterLevelInfoViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			var mbox:Sprite = new Sprite();
			mbox.graphics.drawPoly(0,0,[0,0,108,0,108,37,29,37],"#ffffff");
			view.closeBtn.mask = mbox;
//			view.closeBtn.addChild(mbox);
			
			_starb = new starBar("common/star_1.png","common/star_2.png",26,27,-5);
			view.starBg.addChild(_starb);
			
			view.rItem1.removeSelf();
			view.list1.pos(view.rItem1.x , view.rItem1.y);
			view.list1.itemRender = chapterListCell;
			
			needCell1 = new needItemCell();
			needCell2 = new needItemCell();
			view.needBox1.addChild(needCell1);
			view.needBox2.addChild(needCell2);
			Signal.intance.on(FightingStageManger.FIGHTINGMAP_LEVEL_FNUM_CHANGE,this,fNumChangeFun);
		}
		
		protected  function addClick(e:Event = null):void
		{
			if(Number(view.numLbl.text) >= _maxfNum)
			{
				XTip.showTip("L_A_1198");
				return ;
			}
			var showError = getBuyNum(buyTimer + 1);
			ConsumeHelp.Consume([showError],Handler.create(this,buyTimerFun),GameLanguage.getLangByKey("L_A_1195"));
		}
		
		public function getBuyNum(n:Number):ItemData{
			var stage_buy_json:Object=ResourceManager.instance.getResByURL(buyUrl);
			var leftStr:String;
			
			if(stage_buy_json)
			{
				for each (var c:Object in stage_buy_json)
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
		
		protected function get stageLevelDic():Object{
			return GameConfigManager.stage_level_dic;
		}
		
		protected  function ackClick(e:Event):void
		{
	
			var vo:StageLevelVo = stageLevelDic[thisData.id];
			
			if(!thisData.fightNum)
			{
				var f:Function = function():void{
					toF = true;
					buyTimerFun();
				}
				var showError = getBuyNum(buyTimer + 1);
				ConsumeHelp.Consume([showError],Handler.create(this,f),GameLanguage.getLangByKey("L_A_1195"));
				return ;
			}
			fightingFun();
		}
		
		protected function buyTimerFun():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_MAP_BUY_TIMER,[thisData.id]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_MAP_BUY_TIMER),
				this,buyTimerBack);
		}
		
		protected function buyTimerBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,buyTimerBack);
//			thisData.fightTimes = Number(thisData.fightTimes) + 1;
			
//			var sdv:SaoDangView = XFacade.instance.getView(SaoDangView);
//			if(sdv) sdv.bindNum(thisData.fightTimes);
			
//			buyTimer ++;
//			view.numLbl.text = thisData.fightNum;
			thisData.buyTimes++;
			if(toF)
			{
				fightingFun();
				toF;
			}
		}
		
		
		protected function fightingFun():void
		{
			
			if (!User.getInstance().hasFinishGuide)
			{
				trace("id=============="+thisData.id);
				switch(parseInt(thisData.id))
				{
					case 1: 
						Laya.timer.once(750, null, function() { 
							trace("FIGHT_CHAPTER_ONE==============");
							Signal.intance.event(NewerGuildeEvent.FIGHT_CHAPTER_ONE);
							} );
						break;
					case 2:
						Laya.timer.once(750, null, function() { 
							Signal.intance.event(NewerGuildeEvent.FIGHT_CHAPTER_TWO);
							} );
						break;
					case 3:
						Laya.timer.once(750, null, function() { 
							Signal.intance.event(NewerGuildeEvent.FIGHT_CHAPTER_THREE);
							} );
						break;
					default:
						break;
				}
			}
			
			var vo:StageLevelVo = stageLevelDic[thisData.id];
			var cId:Number = vo.chapter_id;
			if(!thisData.star)
				cId = 0;
			trace("关卡id:"+vo.id);
			FightingManager.intance.getSquad(1,vo.id,new Handler(this,fBackFunction,[cId,vo.id]));
			
			this.close();
		}
		
		
		/**
		 * 
		 * @param cid 章节id
		 * @param id  关卡id
		 * 
		 */
		protected function fBackFunction(cid:Number,id:Number):void{
			trace("执行一次推图回调");
			var ar:Array = [0];
			if(cid)
				ar.push(cid - 1);
			trace("推图回调的数据:"+ar);
			trace("第"+id+"关打完");
			if(id==20)//暂时在4-1提示首冲
			{
				trace("FightingStageManger.intance.ifFirstCharge："+FightingStageManger.intance.ifFirstCharge);
				if(FightingStageManger.intance.ifFirstCharge)
				{
					XFacade.instance.openModule(ModuleName.FirstChargeView,0);
					
				}
			}
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,ar);
			
		}
		
		
		
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			trace("开面不开：", args);
			scData =  args[0][0];
			dataList = args[0][1];
			dataIdx = args[0][2];
//			m_buyTimer = args[0][2];
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.SHOW_CHAPTER_PANEL);
			}
			
			UIRegisteredMgr.AddUI(view.sweepBtn2, "SweepFiveBtn");
		}
		
		
		public function get dataIdx():Number
		{
			return _dataIdx;
		}
		
		public function set dataIdx(value:Number):void
		{
			_dataIdx = value;
			
			thisData = dataList[_dataIdx];
			bindData();
		}
		
		
		private function bindData():void{
			var vo:StageLevelVo = stageLevelDic[thisData.id];
			view.chapterNameLabel.text = vo.stage_name;
			_starb.maxStar = vo.maxStar;
			
			_starb.barValue = thisData.star;
			_starb.pos( view.starBg.width - _starb.width >> 1 , -5);
			
			var listAr:Array = [];
			_overTongguan = thisData.star;
			for (var j:int = 0; j < vo.requirementList.length; j++) 
			{
				var rvo:requirementVo = vo.requirementList[j];
				listAr.push([rvo,thisData.star > j,j + 1]);
			}
			view.list1.array = listAr;
			trace("thisData::::::::", thisData);
			if(thisData.star == 0){
				var vipVo:VIPVo = VIPVo.getVipInfo();
				//trace("thisData::::::::",thisData)
				if(thisData.type == 1){
					view.numLbl.text = (Math.round(thisData.fightNum)+Math.round(vipVo.stage_wipe))+"";
				}else{
					view.numLbl.text = (Math.round(thisData.fightNum)+Math.round(vipVo.elite_wipe))+"";
				}
			}else{
				view.numLbl.text = thisData.fightNum;
			}
			
			_maxfNum = vo.challenge_times;

			view.sweepBtn.disabled = !_overTongguan || Number(thisData.fightNum) < 1;
			view.sweepBtn2.disabled = !_overTongguan || Number(thisData.fightNum) < _maxfNum;
			
			var s:String = GameLanguage.getLangByKey("L_A_59016")
			view.sweepBtn2.label = StringUtil.substitute(s,_maxfNum);
			
			var itemD1:ItemData = vo.stageCost[0];
			needCell1.data = itemD1;
			var itemD2:ItemData = new ItemData();
			itemD2.iid = itemD1.iid;
			itemD2.inum = itemD1.inum * _maxfNum ;
			needCell2.data = itemD2;
			
			needCell1.x = view.needBox1.width - needCell1.width >> 1;
			needCell2.x = view.needBox2.width - needCell2.width >> 1;
		}
	
		public override function addEvent():void{
			super.addEvent();
			view.ackBtn.on(Event.CLICK,this,ackClick);
			view.addBtn.on(Event.CLICK,this,addClick);
			view.closeBtn.on(Event.CLICK,this,close);
			view.sweepBtn.on(Event.CLICK,this,sweepClick);
			view.sweepBtn2.on(Event.CLICK, this, sweepClick);
			Signal.intance.on(FightingStageManger.FIGHTINGMAP_CHAPETR_INIT,this,bindData);
			Signal.intance.on("SweepFiveBtn",this,sweepGuideClick);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.ackBtn.off(Event.CLICK,this,ackClick);
			view.addBtn.off(Event.CLICK,this,addClick);
			view.closeBtn.off(Event.CLICK,this,close);
			view.sweepBtn.off(Event.CLICK,this,sweepClick);
			view.sweepBtn2.off(Event.CLICK, this, sweepClick);
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_CHAPETR_INIT,this,bindData);
			Signal.intance.off("SweepFiveBtn",this,sweepGuideClick);
		}
		
		override public function dispose():void{
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_LEVEL_FNUM_CHANGE,this,fNumChangeFun);
			super.dispose();
		}
		private function sweepGuideClick(btn:*):void{
			//trace("11111");
			if(btn == view.sweepBtn2)
			{
				//trace("引导扫荡");
				var vo:StageLevelVo = stageLevelDic[thisData.id];
				var nm:Number = _maxfNum;
				var ar:Array = [];
				for (var i:int = 0; i < vo.stageCost.length; i++) 
				{
					var itemD:ItemData = vo.stageCost[i];
					var itemD2:ItemData = new ItemData();
					itemD2.iid = itemD.iid;
					itemD2.inum = itemD.inum * nm;
					ar.push(itemD2);
				}
				FightingManager.intance.saoDangStage(ar,nm,vo.id,_sType);
				this.close();
			}
		} 
		
		private function fNumChangeFun(e:Event):void
		{
			if(thisData) bindData();
		}
		
		private function sweepClick(e:Event):void{
			//trace("扫荡");
			var vo:StageLevelVo = stageLevelDic[thisData.id];
			var nm:Number = 1;
			if(e.target == view.sweepBtn2)
				nm = _maxfNum;
			var ar:Array = [];
			for (var i:int = 0; i < vo.stageCost.length; i++) 
			{
				var itemD:ItemData = vo.stageCost[i];
				var itemD2:ItemData = new ItemData();
				itemD2.iid = itemD.iid;
				itemD2.inum = itemD.inum * nm;
				ar.push(itemD2);
			}
			FightingManager.intance.saoDangStage(ar,nm,vo.id,_sType);
			this.close();
		}

		
		public override function destroy(destroyChild:Boolean=true):void{
			//trace(1,"destroy ChapterLevelPanel");
			_starb = null;
			_cellList = null;
			thisData = null;
			scData = null;
			dataList = null;
			needCell1 = null;
			needCell2 = null;
			super.destroy(destroyChild);
		}
		
		protected override function clearUnpackRes():void{
			
		}
		
	}
}