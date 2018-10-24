package game.module.bag.alert
{
	import MornUI.panels.BagUseViewUI;
	import MornUI.panels.ItemUseSelctViewUI;
	
	import game.common.AnimationUtil;
	import game.common.RewardList;
	import game.common.UIRegisteredMgr;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.vo.StageLevelVo;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class ItemUseSelctView extends BaseDialog
	{
		private var _rList:RewardList;
		private var rAr:Array ;  //可选道具
		private var sNum:Number; //可选数量
		private var ikey:String; //道具唯一ID
		
		
		public function ItemUseSelctView()
		{
			super();
		}
		
	
		public override function show(...args):void{
			super.show(args);
			AnimationUtil.popIn(this);
			var ar:Array = args[0];
			_rList.array = rAr = ar[0];
			_rList.x = view.rBox.width - _rList.width >> 1;
			_rList.y = view.rBox.height - _rList.height >> 1;
			
			sNum = ar[1];
			ikey = ar[2];
			
			selectIdxs = [];
			
			for (var i:int = 0; i < rAr.length; i++) 
			{
				var cell:ItemCell = _rList.getCell(i);
				cell.selected = false;
			}
			
			
			view.getBtn.disabled = true;
		} 
		
		public function get view():ItemUseSelctViewUI{
			if(!_view){
				_view = new ItemUseSelctViewUI();
			}
			return _view as ItemUseSelctViewUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			addChild(view);
			
			_rList = new RewardList;
			_rList.selectEnable = true;
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			view.rBox.addChild(_rList);
			
			
		}
		
		override public function close():void{
			AnimationUtil.popOut(this, this.onClose);
		}
		
		private function onClose():void{
			_rList.array = [];
			super.close();
		}
		
		
		
		private function getBtnFun(e:Event):void{
			var ssssAr:Array = [];
			var dStr:String = "";
			for (var i:int = 0; i < selectIdxs.length; i++) 
			{
				ssssAr.push((rAr[selectIdxs[i]] as ItemData).iid);
			}
			dStr = ssssAr.join("|");
			BagManager.instance.useItem(ikey,1,dStr);
			this.close();
		}
		
		private var selectIdxs:Array = [] ;
		private function selectFun(e:Event,idx:Number):void
		{
			if(e.type != Event.CLICK)return ;
			var cell:ItemCell = _rList.getCell(idx);
			if(cell.selected)
			{
				cell.selected = false;
				var i2:Number = selectIdxs.indexOf(idx);
				if(i2 != -1)
					selectIdxs.splice(i2 , 1);
			}else
			{
				if(sNum == 1 || sNum > selectIdxs.length)
				{
					if(sNum == 1 && selectIdxs.length)
					{
						var cell2:ItemCell =  _rList.getCell(selectIdxs[0]);
						cell2.selected = false;
						selectIdxs.shift();
					}
					cell.selected = true;
					selectIdxs.push(idx);
					
				}else{
					XTip.showTip("选满了");
				}
			}
			
			view.getBtn.disabled = selectIdxs.length != sNum;
		}
		
		public override function addEvent():void{
			super.addEvent();
			view.getBtn.on(Event.CLICK,this,getBtnFun);
			view.closeBtn.on(Event.CLICK,this,close);
			_rList.mouseHandler = Handler.create(this,selectFun,null,false);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			view.getBtn.off(Event.CLICK,this,getBtnFun);
			view.closeBtn.off(Event.CLICK,this,close);
			_rList.mouseHandler = null;
		}
	}
}