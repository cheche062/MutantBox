package game.module.mainui 
{
	import MornUI.mainView.BoardCasterViewUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	
	import laya.display.Sprite;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import laya.webgl.shapes.LoopLine;
	
	/**
	 * ...
	 * @author ...
	 */
	public class BoardCasterView extends BaseView 
	{
		
		private var _boardMask:Sprite;
		/**文案长度*/
		private var _textWidth:int;
		
		public function BoardCasterView() 
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
			this.m_iPositionType = LayerManager.CENTER;
			this.name = "BoardCasterView";
		}
		
		override public function show(...args):void
		{
			super.show();
			
			showBoardMsg();
		}
		
		private function showBoardMsg():void
		{
			var str:String;
			switch(parseInt(GlobalRoleDataManger.instance.boardcastVec[0].type))
			{
				case 1:
					str = GameLanguage.getLangByKey(GameConfigManager.boardcastVec[1].text)
					.replace("{0}", GlobalRoleDataManger.instance.boardcastVec[0].username);
					
					break;
				
				// 国战BOSS开启通知
				case 3:
					str = GameConfigManager.boardcastVec[3].text;
					break;
				
				case 2:
				case 4:
				case 5:
				case 6:
				case 7:
					str = GlobalRoleDataManger.instance.boardcastVec[0].sysMsg;
					break;
			}
			view.infoTxt.text = str;
			view.infoTxt.x = view.width;
			_textWidth = view.infoTxt.width; 
			
			frameLoop(1, this, stepMove);
			
//			Tween.to(view.infoTxt, { x: -view.infoTxt.width }, 8000, Ease.linearNone, new Handler(this, moveOverHandler));
		}
		
		private function stepMove():void {
			view.infoTxt.x -= 2;
			
			if (view.infoTxt.x < _textWidth * -1) {
				clearTimer(this, stepMove);
				moveOverHandler();
			}
		}
		
		private function moveOverHandler():void
		{
			GlobalRoleDataManger.instance.boardcastVec.shift();
			if (GlobalRoleDataManger.instance.boardcastVec.length > 0)
			{
				showBoardMsg();
			}
			else
			{
				close();
				GlobalRoleDataManger.instance.isBoarding = false;
			}
		}
		
		override public function createUI():void {
			
			this._view = new BoardCasterViewUI();
			this.addChild(_view);
			
			view.y = LayerManager.instence.stageHeight * -0.3;
			
			_boardMask = new Sprite();
			_boardMask.graphics.drawRect(0, 0, view.width, view.height, "0xff0f0f");
			_boardMask.y = LayerManager.instence.stageHeight * -0.3;
			//this.addChild(_boardMask);
			view.parent.mask = _boardMask;
			
		}
		
		private function get view():BoardCasterViewUI{
			return _view;
		}
		
		override public function addEvent():void{
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			
			super.removeEvent();
		}
	}

}