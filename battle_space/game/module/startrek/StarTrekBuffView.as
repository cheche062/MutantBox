package game.module.startrek
{
	import laya.display.Animation;
	import MornUI.startrek.StarTrekBuffViewUI;

	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBFightEffect;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.ui.Image;

	/**
	 * ...
	 * @author ...
	 */
	public class StarTrekBuffView extends BaseDialog
	{

		private var _buffVo0:Object;
		private var _buffVo1:Object;

		private var _i1:Image;
		private var _i2:Image;
		
		private var _buffMotion0:Animation;
		private var _buffMotion1:Animation;

		private var _buffData:Object;

		public function StarTrekBuffView()
		{
			super();

		}

		override public function show(... args):void
		{
			super.show();
			
			_buffData = args[0];
			
			_buffMotion0.visible = true;
			_buffMotion0.play(0, false);
			
			_buffMotion1.visible = true;
			_buffMotion1.play(0, false);
			
			_buffVo0 = DBFightEffect.getEffectInfo(GameConfigManager.StarTrekEvents[_buffData.id].param1.split(";")[0]);
			_buffVo1 = DBFightEffect.getEffectInfo(GameConfigManager.StarTrekEvents[_buffData.id].param1.split(";")[1]);
			
			_i1.skin = "appRes/icon/mazeIcon/" + _buffVo0.icon + ".png";
			_i2.skin = "appRes/icon/mazeIcon/" + _buffVo1.icon + ".png";
			
			view.buffDes0.text = GameLanguage.getLangByKey(_buffVo0.des);
			view.buffDes1.text = GameLanguage.getLangByKey(_buffVo1.des);
			
		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, this.onCloseHandler);
		}

		private function onCloseHandler():void
		{
			super.close();
		}

		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
		}

		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.buff0:
					WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_GET_THINGS, [_buffData.x, _buffData.y, _buffVo0.id]);
					close();
					break;
				case view.buff1:
					WebSocketNetService.instance.sendData(ServiceConst.STAR_TREK_GET_THINGS, [_buffData.x, _buffData.y, _buffVo1.id]);
					close();
					break;
				default:
					break;
			}
		}

		override public function createUI():void
		{
			this._view=new StarTrekBuffViewUI();
			this.addChild(this._view);

			this.closeOnBlank=true;

			view.buffDes0.wordWrap=view.buffDes1.wordWrap=true;

			_i1=new Image();
			view.img0.addChild(_i1);

			_i2=new Image();
			view.img1.addChild(_i2);
			
			_buffMotion0 = new Animation();
			_buffMotion0.interval = 100;
			_buffMotion0.loadAtlas("appRes/atlas/effects/mazebuff.json");
			_buffMotion0.stop();
			_buffMotion0.x = view.buff0.x-15;
			_buffMotion0.y = view.buff0.y-12;
			_buffMotion0.loop = false;
			_buffMotion0.visible = false;
			view.addChild(_buffMotion0);
			
			_buffMotion1 = new Animation();
			_buffMotion1.interval = 100;
			_buffMotion1.loadAtlas("appRes/atlas/effects/mazebuff.json");
			_buffMotion1.stop();
			_buffMotion1.x = view.buff1.x-15;
			_buffMotion1.y = view.buff1.y-12;
			_buffMotion1.loop = false;
			_buffMotion1.visible = false;
			view.addChild(_buffMotion1);
		}

		private function get view():StarTrekBuffViewUI
		{
			return _view as StarTrekBuffViewUI;
		}
	}

}
