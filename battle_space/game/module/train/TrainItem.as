package game.module.train
{
	import game.global.GameConfigManager;
	import game.global.util.UnitPicUtil;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.ui.Box;
	import laya.ui.Component;
	import laya.ui.Image;
	
	/**
	 * TrainItem 训练单元
	 * author:huhaiming
	 * TrainItem.as 2017-3-16 下午3:23:23
	 * version 1.0
	 *
	 */
	public class TrainItem extends Box
	{
		private var _bg:Sprite;
		//
		private var _icon:Sprite;
		private var _quality:Image;
		private var _data:Object;
		private var _eff:Animation;
		
		public function TrainItem()
		{
			init();
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			if(this.selected){
				if(!_eff){
					_eff = TrainItem.eff;
				}
				this.addChild(_eff);
				_eff.play();
				this.cacheAsBitmap  = false;
			}else{
				if(_eff){
					if(this.contains(_eff)){
						this.removeChild(_eff);
					}
					this._eff = null;
				}
				this.cacheAsBitmap  = true;
			}
		}
		
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			this._data = value;
			if(this._data){
				this._icon.graphics.clear();
				this._icon.loadImage(UnitPicUtil.getUintPic(_data.unitId || _data.unit_id,UnitPicUtil.ICON_SKEW));
				
				var vo:Object = GameConfigManager.unit_dic[_data.unitId || _data.unit_id];
//				this._quality.skin = "common\/item_bar"+(vo.rarity-1)+".png";
			}
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function init():void{
			this._bg = new Sprite();
			this.addChild(this._bg);
			_bg.pos(0,4);
			this._icon = new Sprite();
			this.addChild(this._icon);
			this._icon.pos(4,4);
			this.mouseEnabled = true;
			this._bg.loadImage("common/bg_c.png");
			
//			this._quality = new Image();
//			this.addChild(_quality);
//			_quality.pos(22,6);
			this.cacheAsBitmap  = true;
		}
		
		override public function get width():Number{
			return 75;
		}
		
		override public function get height():Number{
			return 90;
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			if(_eff)
			{
				_eff.removeSelf();
				_eff = null;
			}
			super.destroy(destroyChild);
		}
		
		
		private static var _ani:Animation;
		/**静态-获取特效*/
		public static function get eff():Animation{
			if(!_ani){
				_ani = new Animation();
				_ani.loadAtlas("appRes/atlas/effects/trainSelect.json");
				_ani.pos(-10,-6);
			}
			return _ani;
		}
	}
}