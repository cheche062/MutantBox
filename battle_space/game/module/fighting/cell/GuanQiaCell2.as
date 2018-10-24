package game.module.fighting.cell
{
	import MornUI.fightingChapter.GuanQiaCellUIUI;
	
	import game.global.vo.GeneLevelVo;
	import game.global.vo.StageLevelVo;
	
	import laya.net.Loader;
	import laya.utils.Handler;
	
	public class GuanQiaCell2 extends GuanQiaCellUIUI
	{
		public function GuanQiaCell2()
		{
			super();
		}
		
		private var _data:StageLevelVo;
		
		
		
		
		public function get data():GeneLevelVo
		{
			return _data;
		}
		
		public function set data(value:GeneLevelVo):void
		{
			_data = value;
			if(_data)
			{
				var url:String = "appRes/icon/stageIcon/"+this._data.icon+".png";
				//				btn2.loadImage(url, 0,0,0,0);
				Laya.loader.load([{url:url,type:Loader.IMAGE}],Handler.create(this,buttonSkillLoaderOver,[url]))
				btn1.label = this._data.name;
			}
		}
		
		private function buttonSkillLoaderOver(url:String):void
		{
			btn2.skin = url;
		}
		
		public override function set x(value:Number):void{
			super.x = value - btn2.x;
		}
		
		public override function set y(value:Number):void{
			super.y = value - btn2.y;
		}
		
		private var _showstate:Number;
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
			btn1.skin = _showstate == 1 ? "common/buttons/stage_btn_2.png" : "common/buttons/stage_btn_4.png";
			btn1.labelColors = _showstate == 1 ? "#f3d57b,#f3d57b,#f3d57b":"#9bfd96,#9bfd96,#9bfd96";
		}

	}
}