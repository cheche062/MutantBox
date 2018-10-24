package game.module.commonGuide 
{
	import game.common.base.BaseDialog;
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.funGuide;
	import game.global.vo.User;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import MornUI.commonGuide.CommonGuideViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CommonGuideView extends BaseDialog 
	{
		
		private var _guideID:int = 0;
		
		private var _funOpenVo:funGuide;
		
		private var _funImg:Image;
		
		public function CommonGuideView() 
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
			this.name = "CommonGuideView";
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				case this.view.confirmBtn:
					
					User.getInstance().isInGuilding = false;
					
					if (_funOpenVo.lx == 3)
					{
						User.getInstance().isInGuilding = true;
						XFacade.instance.openModule(ModuleName.FunctionGuideView,_funOpenVo.g_id);
					}
					else
					{
						User.getInstance().curGuideArr.shift();
						User.getInstance().checkHasNextGuide();
						/*if (User.getInstance().curGuideArr.length > 0)
						{
							_guideID = User.getInstance().curGuideArr[0];
							Tween.to(view, { scaleX:0, scaleY:0,x:LayerManager.instence.stageWidth/2,y:LayerManager.instence.stageHeight/2 }, 300,Ease.linearNone,new Handler(this,showView));
							return;
						}*/
					}
					
					close();
					
					/*if (_guideArr.length > 0)
					{
						Tween.to(view, { scaleX:0, scaleY:0,x:LayerManager.instence.stageWidth/2,y:LayerManager.instence.stageHeight/2 }, 300,Ease.linearNone,new Handler(this,showView));
						return;
					}
					close();*/
					//XFacade.instance.openModule(ModuleName.GuildBossView);
					break;
				default:
					break;
				
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			_guideID = args[0];
			showView();
			User.getInstance().isInGuilding = true;
			
		}
		
		private function showView():void
		{
			_funOpenVo = GameConfigManager.fun_open_vec[_guideID];
			
			view.funDesTxt.height = view.funDesTxt.textHeight = 120
			
			view.funNameTxt.text = GameLanguage.getLangByKey(_funOpenVo.title);
			view.funDesTxt.text = GameLanguage.getLangByKey(_funOpenVo.dec).replace(/##/g, "\n");
			
			view.funDesTxt.y = 80 + (184 - view.funDesTxt.textHeight) / 2;
			
			_funImg.skin = _funOpenVo.icon;
			view.scaleX = 1;
			view.scaleY = 1;
			view.x = 0;
			view.y = 0;
			
			Tween.from(view, { scaleX:0, scaleY:0,x:LayerManager.instence.stageWidth/2,y:LayerManager.instence.stageHeight/2 }, 300);
		}
		
		override public function close():void{
			super.close();
			
			//AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new CommonGuideViewUI();
			this.addChild(_view);
			
			_funImg = new Image();
			view.imgContainer.addChild(_funImg);
			view.funDesTxt.fontSize = 18;
			view.funDesTxt.wordWrap = true;
			
		}
		
		private function get view():CommonGuideViewUI{
			return _view;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
	}

}