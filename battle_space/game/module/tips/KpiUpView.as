package game.module.tips
{
	import MornUI.componets.KpiUpUI;
	
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	
	import laya.display.Animation;
	
	/**
	 * KpiUpView 战力上升界面
	 * author:huhaiming
	 * KpiUpView.as 2017-12-11 下午6:11:53
	 * version 1.0
	 *
	 */
	public class KpiUpView extends BaseView
	{
		private var _deltaNum:Number= 0;
		private var _ani:Animation;
		/**等待时间*/
		private static const WAIT_TIME:int = 800;
		private static const CLOSE_TIME:int = 1600;
		public function KpiUpView()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
			this._m_iPositionType = LayerManager.CENTER;
		}
		
		override public function show(...args):void{
			var delNum = parseInt(args[0]);
			if(_deltaNum > 0){
				_deltaNum = _deltaNum+delNum;
			}else{
				_deltaNum = delNum;
			}
			if(this.visible){
				onShow();
			}else{
				Laya.timer.clear(this, onShow);
				Laya.timer.once(WAIT_TIME, this, onShow);
			}
		}
		
		private function onShow():void{
			super.show();
			this.visible = true;
			var str:String = GameLanguage.getLangByKey("L_A_116");//BATTLE RATING +{0}
			
			var str1 = str.replace(/{(\d+)}/, _deltaNum+"");
			if(_deltaNum<0){
				str1 = str1.replace("+","");
			}
			view.kpiTF.text = str1;
			_deltaNum = 0;
			_ani.play(0, false);
			//自动关闭；
			Laya.timer.clear(this, close);
			Laya.timer.once(CLOSE_TIME, this, close);
			SoundMgr.instance.playSound(ResourceManager.getSoundUrl("br_upgrade_v2",'uiSound'));
			trace("xxxxxxxxxxxxxxx")
		}
		
		override public function close():void{
			_deltaNum = 0;
			super.close();
			this.visible = false;
		}
		
		override public function createUI():void{
			_view = new KpiUpUI();
			this.addChild(_view);
			this.mouseEnabled = this.mouseThrough = true;
			_view.mouseEnabled = false;
			
			_ani = new Animation();
			_ani.loadAtlas("appRes/atlas/effects/kpi.json");
			_ani.stop();
			_view.addChildAt(_ani, 0);
		}
		
		private function get view():KpiUpUI{
			return _view;
		}
	}
}