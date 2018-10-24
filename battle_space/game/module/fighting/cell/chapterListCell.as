package game.module.fighting.cell
{
	import MornUI.fightingChapter.chapterListCellUI;
	
	import game.common.RewardList;
	import game.common.starBar;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.bag.ItemCell;
	import game.global.vo.requirementVo;
	
	import laya.ui.UIUtils;
	
	public class chapterListCell extends chapterListCellUI
	{
		private var _rList:RewardList;
		private var _starb:starBar;
		private var dataVo:requirementVo;
		private var state:Number;
		private var star:Number;
		
		public function chapterListCell()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_starb = new starBar("common/star_1.png","common/star_2.png",26,27,-5);
			starImg.addChild(_starb);
			
			_rList = new RewardList();
			_rList.itemRender = ItemCell;
			_rList.itemWidth = ItemCell.itemWidth;
			_rList.itemHeight = ItemCell.itemHeight;
			this.rBox.addChild(_rList);
			
//			_initV = true;
//			bindData();
		}
		
		
		private function bindData():void
		{
			if(dataVo)
			{
				_starb.maxStar = 3;
				_starb.barValue = star;
				_starb.pos(starImg.width - _starb.width >> 1 , -5);
				_rList.array = dataVo.showReward;
				_rList.filters = state ? null : [UIUtils.grayFilter];
				_rList.pos(this.rBox.width - _rList.width >> 1,this.rBox.height - _rList.height >> 1);
				
				var t:String = GameLanguage.getLangByKey(dataVo.rq_text);
				t = StringUtil.substitute(t,dataVo.canshu);
				lbl.text = t;
				lbl.y = this.height - lbl.textField.textHeight >> 1;
			}
		}
		
	
		override public function set dataSource(value:*):void{
			super.dataSource = value;
			if(value)
			{
				dataVo = value[0];
				state = value[1];
				star = value[2];
			}
			bindData();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy chapterListCell");
			_rList = null;
			_starb = null;
			dataVo = null;
			
			super.destroy(destroyChild);
		}
		
	}
}