package game.module.fighting.cell
{
	import MornUI.fightingChapter.GuanQiaCellUIUI;
	import MornUI.fightingChapter.ZXGuanQiaCellUIUI;
	
	import game.common.starBar;
	import game.global.vo.StageLevelVo;
	import game.module.fighting.scene.FightingScene;
	
	import laya.net.Loader;
	import laya.utils.Handler;
	
	public class GuanQiaCell extends ZXGuanQiaCellUIUI
	{
		private var _starb:starBar;
		private var _data:StageLevelVo;
		private var _showstate:Number;
		public static const W:int = 135;
		public static const H:int = 160;
		public function GuanQiaCell()
		{
			super();
			bindState();
			
			this.mouseEnabled = this.mouseThrough = true;
			this.Img1.mouseEnabled = this.Img2.mouseEnabled = this.Img4.mouseEnabled = true;
		}
		
	
		
		

		public function get data():StageLevelVo
		{
			return _data;
		}

		public function set data(value:StageLevelVo):void
		{
			_data = value;
			if(_data)
			{
//				var url:String = "appRes/icon/stageIcon/"+this.data.stage_icon+".png";
////				btn2.loadImage(url, 0,0,0,0);
//				Laya.loader.load([{url:url,type:Loader.IMAGE}],Handler.create(this,buttonSkillLoaderOver,[url]))
				cName.text = this.data.stage_name_a;
				
				if(!_starb)
				{
					_starb = new starBar("common/star_1.png","common/star_2.png",26,27,-5);
					addChild(_starb);
				}
				_starb.maxStar = this.data.maxStar;
//				_starb.barValue = 2;
				
				_starb.y = Img3.y - 5;
				_starb.x = width - _starb.width >> 1;
			}
		}
		
		public function set starValue(value:Number):void
		{
			if(_starb)
				_starb.barValue = value;
		}
		
//		public override function set disabled(value:Boolean):void {
//			super.disabled = value;
//			Img4.visible = disabled;
//			Img3.visible = !disabled;
//			if(_starb)
//			{
//				_starb.visible = !disabled;
//			}
//		}
		
		private function buttonSkillLoaderOver(url:String):void
		{
//			btn2.skin = url;
		}
		
		public override function set x(value:Number):void{
			super.x = value - Img1.x;
		}
		
		public override function set y(value:Number):void{
			super.y = value - Img2.y;
		}
		
		public function get showstate():Number
		{
			return _showstate;
		}
		
		public function set showstate(value:Number):void
		{
			if(_showstate != value)
			{
				_showstate = value;
				bindState();
			}
		}	
		
		private function bindState():void
		{
//			btn1.skin = _showstate == 1 ? "common/buttons/stage_btn_2.png" : "common/buttons/stage_btn_4.png";
//			btn1.labelColors = _showstate == 1 ? "#f3d57b,#f3d57b,#f3d57b":"#9bfd96,#9bfd96,#9bfd96";
			
			Img1.visible = _showstate == 1;
			Img2.visible = _showstate == 0;
			Img4.visible = _showstate == -1;
			Img3.visible = _showstate != -1;
			disabled = _showstate == -1;
			if(_starb)
				_starb.visible = !disabled;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy GuanQiaCell");
			_starb = null;
			_data = null;
			
			super.destroy(destroyChild);
		}
	
	}
}