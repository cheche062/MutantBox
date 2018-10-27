package game.module.fighting.cell
{
	import MornUI.fightingChapter.SaoDangRewardCellUI;
	
	import game.common.RewardList;
	import game.global.StringUtil;
	import game.global.data.bag.ItemCell;
	
	import laya.ui.List;
	
	public class SaoDangRewardCell extends SaoDangRewardCellUI
	{
		private var _rList:List;
		private var thisData:Array;
		private var showAr:Array  = [];
		
		public function SaoDangRewardCell()
		{
			super();
		}
		
		override public function createChildren():void
		{
			super.createChildren();
			_rList = new List();
			_rList.width = ItemCell.itemWidth * 5;
			_rList.height = ItemCell.itemHeight;
			_rList.itemRender = ItemCell;
			rBox.addChild(_rList);
			this._rList.y = this.rBox.height - ItemCell.itemHeight >> 1;
		}
		
		
	
		public override function set dataSource(value:*):void{
			super.dataSource =  value;
			if(thisData == value)
			{
				trace("thisData,",thisData);
				return ;
			}
			thisData = value;
			if(thisData)
			{
				this.tileLbl.text = StringUtil.substitute("{0}nd",thisData[0]);
//				this._rList.array = thisData[1];
				_rList.array = [];
				timer.clear(this,additem);
				showAr = thisData[1];
				showAr = showAr.concat();
				if(thisData[2])
				{
					additem();
					thisData[2] = false;
				}else
				{
					_rList.array = showAr;
				}
			}
		}
		
		public function additem():void
		{
			var d:* = showAr.shift();
			_rList.addItem(d);
			
			
			
			if(showAr.length)
				timer.once(200,this,additem,null,false);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy SaoDangRewardCell");
			_rList = null;
			thisData = null;
			showAr = null;
			super.destroy(destroyChild);
		}
		
	}
}