package game.module.equipFight.cell
{
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.util.UnitPicUtil;
	import game.module.equipFight.data.equipFightInfoData;
	import game.module.fighting.adata.ArmyData;
	
	import laya.display.Stage;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.UIUtils;

	public class equipFightHeroCell extends Box
	{
//		public static var itemWidth:Number = 102;
//		public static var itemHeight:Number = 110;
		
		private var _quan1:Image = new Image(); // 常规圈
		private var _quan2:Image = new Image(); //选中圈
		private var _heroFace:Image = new Image();
		private var _nameLbl:Label = new Label();//
		public var data:equipFightInfoData;
		private var _tSelected:Boolean;
		
		
		public function equipFightHeroCell()
		{
			super();
			init();
		}
		
		
		private function init():void{
			size(102,120);
			
			addChild(_quan1);
			addChild(_quan2);
			_quan2.visible = false;
			
			_quan1.skin = "equipFighting/iconbg_2.png";
			_quan2.skin = "equipFighting/iconbg_1.png";
			_quan1.mouseEnabled = _quan2.mouseEnabled = true;
			_quan1.mouseThrough = _quan2.mouseThrough = true;
			addChild(_heroFace);
			
			addChild(_nameLbl);
			_nameLbl.size(width,30);
			_nameLbl.align = Stage.ALIGN_CENTER;
			_nameLbl.font = XFacade.FT_BigNoodleToo;
			_nameLbl.fontSize = 24;
			_nameLbl.color = "#b2b2b2";
			_nameLbl.y = 90;
			_nameLbl.stroke = 1;
			_nameLbl.strokeColor = "#000000";
		}
		
		
		public override function set dataSource(value:*):void{
			super.dataSource = data = value;
			if(data)
			{
				if(!data.vo)
				{
					trace(data.heroId +"~~~~");
					return ;
				}
				this.mouseEnabled = this.mouseThrough = true;
				_nameLbl.text = data.vo.name;
				_heroFace.skin = UnitPicUtil.getUintPic(data.heroId,UnitPicUtil.PIC_EF);
				
				this.filters = data.state ? null : [UIUtils.grayFilter];
			}else
			{
				trace("~~~~~~");
			}
		} 
		
		
		public override function set selected(value:Boolean):void
		{	
			if(_tSelected != value)
			{
				_tSelected = value;
				_quan1.visible = !_tSelected;
				_quan2.visible = _tSelected;
				_nameLbl.color = _tSelected ? "#ffffff" : "#b2b2b2";
			}
			
			super.selected = value;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy equipFightHeroCell");
			_quan1 = null;
			_quan2 = null;
			_heroFace = null;
			_nameLbl = null;
			data = null;
			super.destroy(destroyChild);
		}
		
	}
}