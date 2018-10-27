/***
 *作者：罗维
 */
package game.module.fighting.cell
{
	import MornUI.fightingView.FightingFaceCellUIUI;
	
	import game.global.util.UnitPicUtil;
	import game.module.fighting.scene.FightingScene;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.resource.Texture;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class FightingFaceCell extends Sprite
	{
		public var facetype:Number = 0;
		protected var _bgImg:Image;
		protected var _faceImg:Image;
		public var scene:FightingScene;
		private var _data:Object
		
		private static var _selectEf:Animation;
		
		public function FightingFaceCell()
		{
			super();
			
			width = 77;
			height = 88;
			initFaceBg();
			this._bgImg.mouseEnabled = this._bgImg.mouseThrough = true;
			this.mouseEnabled = this.mouseThrough = true;
			_faceImg.mouseEnabled = _faceImg.mouseThrough = true;
			this.on(Event.CLICK,this,thisClick);
		}
		
	
		
		public static function get selectEf():Animation
		{
			if(!_selectEf)
			{
				_selectEf = new Animation();
				_selectEf.pos(-10,-10);
				_selectEf.loadAtlas("appRes/atlas/effects/trainSelect.json");
			}
			return _selectEf;
		}

		private function thisClick():void{
			if(scene)
			{
//				alert("点击"+data.pos);
				
				scene.selectUnit(data.pos);
				scene.fightingView.selectPos = data.pos;
				this.addChild(selectEf);
			}
		}
		
		protected function initFaceBg():void
		{
			var ui:FightingFaceCellUIUI = new FightingFaceCellUIUI();
			ui.mouseEnabled = ui.mouseThrough = true;
			addChild(ui);
			_bgImg = ui.bgImg;
			_faceImg = ui.faceImg;
		}
		
		
		public function get data():Object{
			return _data;
		}
		
		public function set data(v:Object):void{
			if(_data != v)
			{
				_data = v;
				_bgImg.skin = ( _data["pos"] as String).indexOf("point_1") == -1 ?
					          "fightingUI/bg3_1.png":
							  "fightingUI/bg3_2.png";
//				_faceImg.loadImage();
				_faceImg.graphics.clear();
				var url:String = UnitPicUtil.getUintPic(data.unitId,UnitPicUtil.ICON_SKEW);
				_faceImg.loadImage(url);
//				Laya.loader.load(url, Handler.create(this, loadeOver), null, Loader.IMAGE);
				if(!scene.fightingView.selectPos && facetype)
				{
					this.addChild(selectEf);
				}
				else if(scene.fightingView.selectPos && scene.fightingView.selectPos == data.pos)
				{
					this.addChild(selectEf);
				}
			}
		}
		
		
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy FightingFaceCell");
			this.off(Event.CLICK,this,thisClick);
			this.scene = null;
			if(_selectEf)
			{
				_selectEf.removeSelf();
				_selectEf = null;
			}
			_bgImg = null;
			_faceImg = null;
			_data = null;
			super.destroy( destroyChild);
			
			
		}
		
	}
}