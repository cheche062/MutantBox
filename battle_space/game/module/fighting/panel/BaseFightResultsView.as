/***
 *作者：罗维
 */
package game.module.fighting.panel
{
	import game.common.UnpackMgr;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.adata.frSoldierData;
	
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	
	public class BaseFightResultsView extends Box
	{
		/**
		 * 结算面板基类
		 */
		public var closeBtn:Button;
		public var tileImg:Image;
		public var bgImg:Image;
		private var _data:FightingResultsData;
		public function BaseFightResultsView()
		{
			super();
//			bgImg = new Image();
//			tileImg = new Image();
//			closeBtn = new Button();
		}
		
		

		public function init():void
		{
//			addChild(bgImg);
//			addChild(tileImg);
//			addChild(closeBtn);
//			closeBtn.skin = "common/buttons/btn_2.png";
//			closeBtn.labelColors = "#ffffff,#ffffff,#ffffff";
//			closeBtn.labelFont = "BigNoodleToo";
//			closeBtn.labelSize = 36;
//			closeBtn.label = "BACK";
		}
		
		public function bindData():void
		{
			
		}
		
		public function get data():FightingResultsData
		{
			return _data;
		}
		
		public function set data(value:FightingResultsData):void
		{
			if(_data != value)
			{
				_data = value;
//				bindData();
			}
		}
		
		protected function tileLoadeBack():void{
			tileImg.x = width - tileImg.width >> 1;
		}
		
		
		public static function filterSoldierData(arr:Array):Array{
			var copyAr:Array = [];
			if(!arr || !arr.length) return copyAr;
			for (var i:int = 0; i < arr.length; i++) 
			{
				var frData:frSoldierData = arr[i];
				if(frData.death)
				{
					copyAr.push(frData);
				}
			}
			return copyAr;
			
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			if(bgImg){
				if(UnpackMgr.instance.check(bgImg.skin))
				{	
					trace(1,"清除未压缩背景图",bgImg.skin);
					Loader.clearRes(bgImg.skin);
				}
			}
			bgImg = null;
			closeBtn = null;
			tileImg = null;
			_data = null;
			trace(1,"destroy BaseFightResultsView");
			super.destroy(destroyChild);
		}
		
	}
}