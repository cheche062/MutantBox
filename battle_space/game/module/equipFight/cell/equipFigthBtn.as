package game.module.equipFight.cell
{
	import MornUI.fightingChapter.GuanQiaCellUIUI;
	
	import game.common.FilterTool;
	import game.global.GameConfigManager;
	import game.global.util.UnitPicUtil;
	import game.global.vo.StageLevelVo;
	import game.module.equipFight.vo.equipFightChapterVo;
	import game.module.equipFight.vo.equipFightLevelVo;
	
	import laya.filters.ColorFilter;
	import laya.filters.GlowFilter;
	import laya.net.Loader;
	import laya.ui.Button;
	import laya.ui.UIUtils;
	import laya.utils.Handler;
	
	public class equipFigthBtn extends GuanQiaCellUIUI
	{
		private var _data:equipFightLevelVo;
		
		
		
		
		public function get data():equipFightLevelVo
		{
			return _data;
		}
		
		public function set data(value:equipFightLevelVo):void
		{
			_data = value;
			if(_data)
			{
				var ar:Array = GameConfigManager.equipFightChapters;
				var ecv:equipFightChapterVo;
				for (var j:int = 0; j < ar.length; j++) 
				{
					if( (ar[j] as equipFightChapterVo).id == data.chapter_id)
					{
						ecv = ar[j];
						break
					}
				}
				
				//faceImg.loadImage(UnitPicUtil.getUintPic(ecv.hero,UnitPicUtil.PIC_EF));
				trace("PIC::::::::",UnitPicUtil.getUintPic(ecv.hero,UnitPicUtil.PIC_EF))
				faceImg.skin = UnitPicUtil.getUintPic(ecv.hero,UnitPicUtil.PIC_EF)
				nameLbl.text = this.data.name;
			}
		}
		
		public override function set x(value:Number):void{
			super.x = value - img1.x;
		}
		
		public override function set y(value:Number):void{
			super.y = value - img1.y;
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
//			btn1.skin = _showstate == 1 ? "common/buttons/stage_btn_2.png" : "common/buttons/stage_btn_4.png";
//			btn1.labelColors = _showstate == 1 ? "#f3d57b,#f3d57b,#f3d57b":"#9bfd96,#9bfd96,#9bfd96";
			img3.visible = _showstate != 1;
			this.filters = _showstate == 1 ?  null : [UIUtils.grayFilter];
		}
		
		public override function set selected(value:Boolean):void
		{
			super.selected = value;
			img1.visible = selected;
			img2.visible = !selected;
//			this.filters = selected ? [FilterTool.glowFilter] : null;
			
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy equipFigthBtn");
			_data = null;
			super.destroy(destroyChild);
		}
		
	}
}