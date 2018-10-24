package game.module.camp
{
	import MornUI.camp.NewJuXingXQViewUI;
	import MornUI.panels.ShowRewardViewUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.UIHelp;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.vo.AwakenEqVo;
	import game.global.vo.itemSourceVo;
	import game.module.bag.cell.BaseItemSourceCell;
	import game.module.bag.cell.ItemCell4;
	import game.module.camp.data.JueXingData;
	import game.module.camp.data.JueXingMange;
	import game.module.fighting.mgr.FightingStageManger;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class NewJuXingXQView extends BaseDialog
	{
		private var itemCell:ItemCell;
		private var unitId:Number;
		/**
		 * 觉醒装备数据
		 */
		private var vo:AwakenEqVo;
		
		public function NewJuXingXQView()
		{
			super();
			closeOnBlank = true;
		}
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			unitId = ar[0];
			vo = ar[1];
			var states:Array = vo.getStates(unitId);
			view.equipBtn.disabled = states.length;
			view.shuxingLbl.text = vo.attStr;
			if(states.indexOf(1) != -1)  //级别不满足
			{
				var ss:String = GameLanguage.getLangByKey("L_A_73115");
				view.levelErrorLbl.text = StringUtil.substitute(ss,vo.site);
			}else
			{
				view.levelErrorLbl.text = "";
			}
			var iData:ItemData = vo.cost[0];
			var num:Number = BagManager.instance.getItemNumByID(iData.iid);
			view.numLbl.text = num.toString();
			view.numLbl2.text = iData.inum;
			view.numLbl.color = num < iData.inum ? "#ffa0a0":"#a0daff";
			var iData2:ItemData = new ItemData();
			iData2.iid = iData.iid;
			iData2.inum = 0;
			itemCell.data = iData2;
			view.nameLbl.text = iData.vo.name;
			
			UIHelp.crossLayout(view.numBox,true,0,10);
			UIHelp.crossLayout(view.numBox2,true,0,10);
			view.numBox.x = view.rigthBox.width - view.numBox.width >> 1;
			view.numBox2.x = view.rigthBox.width - view.numBox2.width >> 1;
			
			trace("道具来源数据;", iData.vo.sourceAr);
			view.laiyuanList.array = iData.vo.sourceAr;
			
			if(!FightingStageManger.intance.isInit)
			{
				FightingStageManger.intance.initData();
				Signal.intance.on(FightingStageManger.FIGHTINGMAP_INIT,this,initMapDataBack);
			}else
			{
				initMapDataBack();
			}
			
			
		} 
		
		
		protected function initMapDataBack():void{
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_INIT,this,initMapDataBack);
			var ar:Array = view.laiyuanList.array;
			if(ar && ar.length)
			{
				for (var i:int = 0; i < ar.length; i++) 
				{
					var vo:itemSourceVo = ar[i];
					if(vo) vo.changeState();
				}
				
				ar.sort(sortfun);
				view.laiyuanList.refresh();
			}
		}
		
		private function sortfun(a:itemSourceVo, b:itemSourceVo):Number {
			if(a.state > b.state)
				return 1;
			else if(a.state < b.state)
				return -1;
			
			if(a.id < b.id)
				return -1;
			else if(a.id > b.id)
				return 1;
			return 0;
		}
		
		
		public function get view():NewJuXingXQViewUI{
			if(!_view){
				_view = new NewJuXingXQViewUI();
			}
			return _view as NewJuXingXQViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			itemCell = new ItemCell();
			view.itemBox.addChild(itemCell);
			itemCell.showTip = true;
//			view.rList.itemRender = ItemCell;
			
			view.laiyuanList.mouseEnabled = true;
			view.laiyuanList.repeatX = 1;
			view.laiyuanList.repeatY = 5;
			view.laiyuanList.itemRender = NewItemSourceCell;
			view.laiyuanList.spaceX = 3;
			view.laiyuanList.spaceY = 8;
			view.laiyuanList.array = [];
			view.laiyuanList.scrollBar.visible = false;
			view.laiyuanList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			view.laiyuanList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			itemCell = null;
			vo = null;
			super.destroy(destroyChild);
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			Signal.intance.event(TrainBattleLogEvent.TRAIN_SHOWREWARD);
			super.close();
		}
		
		
		public override function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,close);
			view.equipBtn.on(Event.CLICK,this,equipBtnClik);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.JUEXING_OPEN_LOCK), this, openLockBack);
			view.laiyuanList.mouseHandler = Handler.create(this,listMouseHandler,null,false);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,close);
			view.equipBtn.off(Event.CLICK,this,equipBtnClik);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.JUEXING_OPEN_LOCK), this, openLockBack);
			view.laiyuanList.mouseHandler = null;
		}
		
		private function listMouseHandler(e:Event,index:int):void
		{
			if(e.type != Event.CLICK)return ;
			var cell:BaseItemSourceCell = view.laiyuanList.getCell(index);
			if(!cell || !cell.dataSource) return ;
			
			var vo:itemSourceVo = cell.dataSource;
			if(!vo.state) return;
			
			BaseItemSourceCell.sourceClick(cell.dataSource, Handler.create(this, function() {
				XFacade.instance.closeModule(NewUnitInfoView);
				XFacade.instance.closeModule(CampView);
				close();
			}));
		}
		
		private function openLockBack(... args):void{
			this.close();
		}
		
		private function equipBtnClik(e:Event):void
		{
			JueXingMange.intance.openLockFun(unitId,vo.idx);
		}
		
		
	}
}