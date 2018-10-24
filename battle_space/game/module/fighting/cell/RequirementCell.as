/***
 *作者：罗维
 */
package game.module.fighting.cell
{
	import MornUI.fightResults.RequirementCellUI;
	
	import game.common.starBar;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.vo.StageLevelVo;
	import game.global.vo.requirementVo;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.UIUtils;
	
	public class RequirementCell extends RequirementCellUI
	{
		private var _starb:starBar;
		private var dataVo:requirementVo;
		private var state:Number;
		private var star:Number;
		
		public function RequirementCell()
		{
			super();
			
		}
	
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			_starb = new starBar("common/star_1.png","common/star_2.png",26,27,-5);
			_starb.scaleX = _starb.scaleY = .7;
			addChild(_starb);
			this.rStar.removeSelf();
		}
		
		
		private function bindData():void
		{
			if(dataVo)
			{
				_starb.maxStar = 3;
				_starb.barValue = star;
				decLbl.color = state ? "#b7ffc1" : "#b2b2b2";
				
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
			trace(1,"destroy RequirementCell");
			_starb = null;
			dataVo = null;
			super.destroy(destroyChild);
		}
	}
}