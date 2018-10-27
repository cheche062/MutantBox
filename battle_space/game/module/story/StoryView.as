package game.module.story
{
	import MornUI.Story.StoryViewUI;
	import MornUI.bingBook.BingBookShowInfoUI;
	import MornUI.newerGuide.GuiderViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Browser;
	import laya.utils.Tween;
	
	public class StoryView extends BaseView
	{
		private var _guideBg:Sprite;
		private var guildAlpha = 1;

		private var curstoryId:String;
		private var STORY_TALK:String = "config/story_talk.json";//重置条件

		private var isFinish:int;
		public var holdTime:int = 800;//剧情在800秒内不能切换,需要大于渐变动画和声音的时间

		private var ifClick:Boolean;
		//蒙板
		private var _bg:Box;
		//蒙板颜色
		private var _bgColor:String = "#000000";
		public function StoryView()
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
//			this.m_iPositionType = LayerManager.LEFTUP;
		}
		public  var DesignWidth:int = 1024;
		public  var DesignHeight:int = 768;

		private var model:int;

		private var dec:int;
		public  function get fixScale():Number{
			var scaleX:int = Laya.stage.width/DesignWidth;
			var scaleY:int = Laya.stage.height/DesignHeight;
			return Math.max(scaleX, scaleY);
		}
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			super.show(args);
			curstoryId = args[0];
			
			setStory(curstoryId);
		
			trace("当前剧情id:"+curstoryId);
			ani(); 
			Laya.timer.once(holdTime,this,canClick);
			if(!this.bg.displayedInStage){
				this.parent.addChildAt(this.bg, this.parent.getChildIndex(this));
				this.bg.size(Laya.stage.width, Laya.stage.height);
				this.bg.graphics.clear();
				this.bg.graphics.drawRect(0,0,Laya.stage.width, Laya.stage.height, _bgColor);
			}
			reset();
		}
		
		private function phraseConf():void
		{
			
		}
		
		private function canClick():void
		{
			ifClick = true;
		}
		private function ani():void
		{
			Tween.clearTween(view);
			view.alpha = 0;
			Tween.to(view, {alpha:1}, 500);
		}
		private function setStory(curstoryId:String):void
		{
			AndroidPlatform.instance.FGM_CustumEvent("story_"+curstoryId);
			var storyObj:Object = ResourceManager.instance.getResByURL(STORY_TALK);
//			trace("剧情表:"+JSON.stringify(storyObj));  
			for each(var con:Object in storyObj)
			{
				if(con["story_id"] == curstoryId)
				{
					if(con["isFinish"]==1)//当前剧情已完成
					{
						isFinish = 1;
						//弹出剧情任务面板
						
					}else
					{
						isFinish = 0;
					}
					var icon:String = con["icon"];
					var la:String = con["LA"];
					var direction:String = con["direction"];
					var background:String = con["background"];
					if(icon)
					{
						model=0;
					}
					if(background)
					{
						model = 1;
					}
					setStoryPannel(icon,la,direction,background);
				}
			}
		}
		
		private function setStoryPannel(icon:String, la:String, direction:String,background:String):void
		{
//			var delScale:Number = fixScale;
//			trace("delScale"+ delScale);
//			if(delScale > 1){
//				trace("delScale"+ delScale);
//				view.bg.scale(delScale,delScale);
//				_guideBg.scale(delScale,delScale);
//			}
			if(icon)
			{
				var head:String = "appRes/icon/story/storyNpc/"+icon+".png";
				view.guideNpc.skin = head;
				_guideBg.alpha = 0;//设置alpha,如果设置visible会被穿透
				view.introWithMan.visible = true;
				view.txt.visible = false;
				bg.alpha =0;
			}else
			{
				_guideBg.alpha = 1;//设置alpha,如果设置visible会被穿透
				view.introWithMan.visible = false;
				view.txtBox.visible = true;
				bg.alpha =1;
			}
//			trace("background"+background);
			if(background) 
			{
				view.txtBox.visible = true;
				_guideBg.alpha = 1;
				view.bg.visible = true;
				view.bg.skin = "appRes/icon/story/storyBg/"+background+".jpg";
				view.txt.text = GameLanguage.getLangByKey(la);
				bg.alpha =1;
			}else 
			{
				view.txt.visible = false;
				_guideBg.alpha = 0;
				view.bg.visible = false; 
				bg.alpha = 0;
			}
//			view.des1Container.x=290;
			view.des1Container.anchorX = 0.5;
			if(direction==1)//坐     
			{ 
				dec=1;
				view.introWithMan.scaleX=1;
				view.des1Container.scaleX=1;
				LayerManager.instence.setPosition(view.introWithMan,LayerManager.LEFTDOWN);
			}else if(direction==2)
			{
				dec=2;
				view.introWithMan.scaleX=-1;
				LayerManager.instence.setPosition(view.introWithMan,LayerManager.RIGHTDOWN,view.introWithMan.width);
				view.des1Container.scaleX=-1;
//				trace(view.introWithMan.x);
//				trace("界面宽度"+view.introWithMan.width);
//				trace("浏览器宽度"+Browser.clientWidth);
//				view.des1.scaleX=1;
			}
			view.des1.text	= GameLanguage.getLangByKey(la);
			trace("bg.alpha:"+bg.alpha);
		}
		public function get view():StoryViewUI{
			if(!_view)
			{
				_view ||= new StoryViewUI;
			}
			return _view;
		}
		
		override public function createUI():void
		{
			// TODO Auto Generated method stub
			super.createUI();
			this._guideBg  = new Sprite();
			/*trace("bg:", this._bg);
			trace("bg:", this._bg.graphics);*/
			//this._bg.graphics.alpha(0.5);
			this._guideBg.graphics.drawRect(0, 0, LayerManager.instence.stageWidth, LayerManager.instence.stageHeight,"#000000");
			this._guideBg.alpha = guildAlpha;
//			this._guideBg.mouseEnabled = true;
			this.addChild(_guideBg);
			
			this.addChild(view);
			view.guideNpc.skin = "";
			view.bg.skin = "";
			this.mouseThrough = view.mouseThrough = false;
		}
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
		}
		private function onClose():void{
			super.close();
		}
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
		private function onClick():void
		{
			if(!ifClick)
			{
				return;
			}
			ifClick = false;
			Laya.timer.once(holdTime,this,canClick);
//			trace("背景点击");
			if(isFinish==1)
			{
				trace("剧情任务已经完成");
				onClose();
				trace("剧情结束时的剧情id"+curstoryId);
				this.bg.removeSelf();
				StoryManager.intance.showStoryModule(StoryManager.TASK_PANNEL);
				return;
			}
//			view.introWithMan.scaleX *= -1;
//			view.introWithMan.x
			var tmp:Number = Number(curstoryId);
			tmp++;
			curstoryId = String(tmp);
			trace(curstoryId);
			setStory(curstoryId);
			ani();
		}
		
		override public function onStageResize():void
		{
			// TODO Auto Generated method stub
			super.onStageResize();
			reset();
		}
		
		private function reset():void
		{
			if(model==1)
			{
				this.view.size(Laya.stage.width , Laya.stage.height);
				var scaleNum:Number =  Laya.stage.width / 1024; 
				
				if(GameSetting.IsRelease){
					var sy:Number = Laya.stage.height / 768;
					scaleNum = Math.max(scaleNum, sy);
				}
				
				this.view.scaleX = this.view.scaleY = scaleNum;
				this.y = ( Laya.stage.height - 768*scaleNum ) / 2;
				
				//针对页游处理
				if(GameSetting.IsRelease){
					this.x = ( Laya.stage.width - 1024*scaleNum) / 2;
				}
			}else if(model==0)
			{
				this.view.size(Laya.stage.width , Laya.stage.height);
				var delScale:Number =  Laya.stage.width / 1136;
					this.scale(delScale,delScale);
					if(dec==1)
					{
							LayerManager.instence.setPosition(view.introWithMan,LayerManager.LEFTDOWN);
					}else if(dec==2)
					{
						LayerManager.instence.setPosition(view.introWithMan,LayerManager.RIGHTDOWN,view.introWithMan.width);
					}

			}
		}
		public function get bg():Box{
			if(!this._bg){
				this._bg  = new Box();
				this._bg.mouseEnabled = true;
			}
			return this._bg;
		}
	}
}