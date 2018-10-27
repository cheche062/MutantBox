package game.module.fighting.cell
{
	import MornUI.fightingChapter.chapterStarCellUI;
	
	import game.common.RewardList;
	import game.common.starBar;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.bag.ItemCell;
	import game.global.vo.requirementVo;
	
	import laya.ui.UIUtils;
	
	public class chapterStarCell extends chapterStarCellUI
	{
		private var _starb:starBar;
		private var dataVo:requirementVo;
		private var state:Number;
		private var star:Number;
		
		public function chapterStarCell()
		{
			super();
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_starb = new starBar("common/star_1.png","common/star_2.png",26,27,-5);
			starImg.addChild(_starb);

		}
		
		
		private function bindData():void
		{
			if(dataVo)
			{
				_starb.maxStar = 3;
				_starb.barValue = star;
				_starb.pos(starImg.width - _starb.width >> 1 , -5);
				decLbl.filters = state ? null : [UIUtils.grayFilter];
				
				var t:String = GameLanguage.getLangByKey(dataVo.rq_text);
				t = StringUtil.substitute(t,dataVo.canshu);
				decLbl.text = t;
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
			trace(1,"destroy chapterStarCell");
			_starb = null;
			dataVo = null;
			super.destroy(destroyChild);
		}
		
	}
}