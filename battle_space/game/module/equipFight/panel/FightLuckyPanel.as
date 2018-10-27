package game.module.equipFight.panel
{
	import MornUI.equipFight.EquipFightLuckyViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.UIHelp;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.module.bag.cell.needItemCell;
	import game.module.bag.mgr.ItemManager;
	import game.module.equipFight.cell.EquipHeroArmyCell;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class FightLuckyPanel extends BaseDialog
	{
		private var _timerVelue:Number;
		private var _left:Number = 50;
		private var _top:Number = 147;
		private var _jg:Number = 16;
		private var infoData:Object;
		private var cellList:Array = [];
		private var isStart:Boolean ;
		private var _callBackFun:Handler;
		private var getType:Number;  // 0~5 手动   998 自动 999全翻
		private var endTimer:Number;
		private var needCell:needItemCell;
		
		public function FightLuckyPanel()
		{
			super();
		}
	
		public function get timerVelue():Number
		{
			return _timerVelue;
		}

		public function set timerVelue(value:Number):void
		{
			if(value < 0)
				value = 0;
			view.timerBar.value = value / infoData.timeout / 1000;
			view.timerLbl.text = Math.ceil(value / 1000) + "s";
			_timerVelue = value;
		}

		public function get view():EquipFightLuckyViewUI{
			if(!_view){
				_view = new EquipFightLuckyViewUI();
			}
			return _view as EquipFightLuckyViewUI;
		}
		 
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			this.mouseEnabled = this.mouseThrough = view.mouseEnabled = view.mouseThrough = true;
			
			view.box2.visible = false;
			view.box3.visible = false;
			
			for (var i:int = 0; i < 5; i++) 
			{
				var cell:EquipFightLuckyCell = new EquipFightLuckyCell();
				cell.mouseEnabled = cell.mouseThrough = true;
//				cell.on(Event.CLICK,this,cellClick,[i]);
				cellList.push(cell);
				cell.x = _left + (cell.width + _jg)* i;
				cell.y = _top;
				view.addChild(cell);
			}
			needCell = new needItemCell();
		
			var json:Object = ResourceManager.instance.getResByURL("config/galaxy_param.json");
			if(json)
			{
				needCell.data = ItemManager.StringToReward(json["5"].value)[0];
				view.RallNeedBox.addChild(needCell);
				UIHelp.crossLayout(view.RallNeedBox);
				view.RallNeedBox.x = view.allNeedBox.width - view.RallNeedBox.width >> 1;
			}
		}
		
		private function cellClick(idx:Number,e:Event):void
		{
			var cell:EquipFightLuckyCell = e.currentTarget as EquipFightLuckyCell;
			if(!cell || cell.open)
				return ;
			getType = idx;
			getItemFun(1);
		}
		
		
		
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.flowIn(this);
			infoData = args[0][0];
			_callBackFun = args[0][1];
			endTimer = TimeUtil.now + infoData.timeout * 1000;
			this.timerVelue = infoData.timeout * 1000;
			timer.frameLoop(1,this,timerFun,null,false);
			isStart = false;
			
			WebSocketNetService.instance.sendData(ServiceConst.LUCKY_START_C,[infoData.id]);
			
			
			view.box1.visible = true;
			view.box2.visible = view.box3.visible = false;
			
			for (var i:int = 0; i < infoData.items.length; i++) 
			{
				var s:String = infoData.items[i];
				var sar:Array = s.split("=");
				var idata:ItemData = new ItemData();
				idata.iid = Number(sar[0]);
				idata.inum = Number(sar[1]);
				
				var cell:EquipFightLuckyCell = cellList[i];
				cell.bindData(idata);
			}
			
		}
		
		
		
		
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			removeCellEvent();
			timer.clear(this,timerFun);
			super.close();
			
			if(_callBackFun != null)
			{
				_callBackFun.runWith(0);
				_callBackFun = null;
			}
		}
		
		
		
		public override function addEvent():void{
			super.addEvent();
			view.startBtn.on(Event.CLICK,this,startFun);
			view.getAllBtn.on(Event.CLICK,this,getAllFun);
			view.endBtn.on(Event.CLICK,this,close);
		}
		public override function removeEvent():void{
			super.removeEvent();
			view.startBtn.off(Event.CLICK,this,startFun);
			view.getAllBtn.off(Event.CLICK,this,getAllFun);
			view.endBtn.off(Event.CLICK,this,close);
		}
		
		
		private function getAllFun(e:Event):void{
			
			getAllFunBack();
//			var json:Object = ResourceManager.instance.getResByURL("config/galaxy_param.json");
//			if(json)
//			{
//				var itemAr:Array = ItemManager.StringToReward(json["5"].value);
//				ConsumeHelp.Consume(itemAr,Handler.create(this,getAllFunBack),"{0}");
//			}
			
		}
		
		private function getAllFunBack():void{
			getType = 999;
			getItemFun(3);
		}
		
		
		private function getItemFun(type:Number):void{
			
			WebSocketNetService.instance.sendData(ServiceConst.LUCKY_GET_C,[infoData.id,type]);
			
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.LUCKY_GET_C),
				this,getItemFunBack);
			
		}
		
		private function getCloseCell():EquipFightLuckyCell{
			for (var k:int = 0; k < cellList.length; k++) 
			{
				var cell:EquipFightLuckyCell = cellList[k];
				if(!cell.open)
					return cell;
			}
			return null;
		}
		
		private function getItemFunBack(... args):void
		{
			
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,getItemFunBack);
			var items:Array = args[1];
			
//			var items = ["1=100","2=20","1=30","2=30"];
			var itemDts:Array = [];
			for (var i:int = 0; i < items.length; i++) 
			{
				var s:String = items[i];
				var sar:Array = s.split("=");
				var idata:ItemData = new ItemData();
				idata.iid = Number(sar[0]);
				idata.inum = Number(sar[1]);
				itemDts.push(idata);
			}
			
			
			if(getType == 999 || getType == 998)
			{
				view.box1.visible = view.box2.visible = false;
				view.box3.visible = true;
				view.needWBox.visible = false;
				
				if(getType == 998)
				{
					for (var j:int = 0; j < itemDts.length; j++) 
					{
						var cell:EquipFightLuckyCell = getCloseCell();	
						if(cell)
							cell.bindDataAndFey(itemDts[j])
					}
					if(!timerVelue)
					{
						timer.once(500,this,close);
					}
				}else{
					for (var k:int = 0; k < cellList.length; k++) 
					{
						var cell:EquipFightLuckyCell = cellList[k];
						cell.feyItem();
					}
					timer.once(500,this,close);
				}
			}else
			{
				cellList[getType].bindDataAndFey(itemDts[0]);
				infoData.freeTimes -- ;
				changeFerrTimer();
				if(infoData.freeTimes <= 0)
				{
					view.box2.visible = false;
					view.box3.visible = true;
					var xxxx:Number = 0 - infoData.freeTimes;
					var price:Array = infoData.price.split("|");
					if(xxxx >= 0 && xxxx < price.length){
						view.needWBox.visible = true;
						var ss:String = GameLanguage.getLangByKey("L_A_44027");
						view.numLbl.text = StringUtil.substitute(ss,price[xxxx].split("=")[1]);
						UIHelp.crossLayout(view.needWBox);
						view.needWBox.x = view.box3.width - view.needWBox.width >> 1;
					}
					else
					{
						timer.clear(this,timerFun);
						view.needWBox.visible = false;
					}
				}
				var b:Boolean = false;
				for (var i2:int = 0; i2 < cellList.length; i2++) 
				{
					var cell:EquipFightLuckyCell = cellList[i2];
					if(!cell.open)
					{
						b = true;
					}
				}
				
				if(!b)
				{
					timer.once(500,this,close);
				}
				
					
			}
			
		}
		
		private function startFun(e:Event):void{
			timer.clear(this,timerFun);
			startFunBack();
			isStart = true;
		}
		
		private function startFunBack():void
		{
			view.box1.visible = view.box3.visible = false;
			view.box2.visible = true;
			changeFerrTimer();
			
			for (var i:int = 0; i < cellList.length; i++) 
			{
				var cell:EquipFightLuckyCell = cellList[i];
				if(i == 0)
					cell.bindData(null,true,Handler.create(this,afun1));
				else
					cell.bindData(null,true);
			}
		}
		
		//动作1 合体
		private function afun1():void
		{
			var zCell:EquipFightLuckyCell = cellList[2]; 
			for (var i:int = 0; i < cellList.length; i++) 
			{
				var cell:EquipFightLuckyCell = cellList[i];
				if(i != 2)
				{
					if(i == 0)
						Tween.to(cell,{x:zCell.x},500,null,Handler.create(this,afun2));
					else
						Tween.to(cell,{x:zCell.x},500);
				}
			}
		}
		//动作2 打乱
		private function afun2():void
		{
			timer.once(500,this,afun3);
		}
		
		//动作3 打乱
		private function afun3():void
		{
			for (var i:int = 0; i < cellList.length; i++) 
			{
				var cell:EquipFightLuckyCell = cellList[i];
				if(i != 2)
				{
					var toX:Number = _left + (cell.width + _jg)* i;
					if(i == 0)
						Tween.to(cell,{x:toX},500,null,Handler.create(this,afun4));
					else
						Tween.to(cell,{x:toX},500);
				}
			}
		}
		
		
		//动作4
		private function afun4():void
		{
			endTimer = TimeUtil.now + infoData.timeout * 1000;
			timer.frameLoop(1,this,timerFun,null,false);
			
			view.box1.visible = view.box3.visible = false;
			view.box2.visible = true;
			changeFerrTimer();
			for (var i:int = 0; i < cellList.length; i++) 
			{
				var cell:EquipFightLuckyCell = cellList[i];
				cell.on(Event.CLICK,this,cellClick,[i]);
			}
			
		}
		
		private function removeCellEvent():void
		{
			for (var i:int = 0; i < cellList.length; i++) 
			{
				var cell:EquipFightLuckyCell = cellList[i];
				cell.off(Event.CLICK,this,cellClick);
			}
		}
		
		
		private function timerFun():void{
			timerVelue = endTimer - TimeUtil.now;
			if(!timerVelue)
			{
				timer.clear(this,timerFun);
				
				if(!isStart)
				{
					startFun(null);
					return ;
				}
				if(infoData.freeTimes > 0)
				{
					getType = 998;
					getItemFun(2);
					removeCellEvent();
					return ;
				}
				removeCellEvent();
				this.close();
				
			}
		}
		
		private function changeFerrTimer():void{
			var tstr:String = GameLanguage.getLangByKey("L_A_44023");
			tstr = StringUtil.substitute(tstr,infoData.freeTimes);
			view.freeLbl.text = tstr;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy FightLuckyPanel");
			infoData = null;
			cellList = null;
			_callBackFun = null;
			needCell = null;
			super.destroy(destroyChild);
		}
		
	}
}