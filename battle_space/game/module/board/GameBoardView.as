package game.module.board
{
	import MornUI.board.GameBoardViewUI;
	
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Graphics;
	import laya.display.Text;
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.HitArea;
	import laya.utils.Tween;

	public class GameBoardView extends BaseDialog
	{

		private var boradList:Array = [];
		private var idList:Array;
		
		private var prevX:Number = 0;
		private var prevY:Number = 0;
		/*
		 * 
		[
		{id: "15", UI_type: "1", order: "1", select: "", url: "15"},
		{id: "19", UI_type: "1", order: "5", select: "", url: "19"},
		{id: "15", UI_type: "1", order: "1", select: "", url: "15"}
		]
		
		*/
		

		public function GameBoardView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view=new GameBoardViewUI();
			this.addChild(this._view);
			onStageResize();
			
			view.contentTxt.wordWrap = true;
			view.contentTxt.overflow = Text.SCROLL;
			
			closeOnBlank = true;
			
			// 设置可点区域（进入对应活动）
			var g:Graphics = new Graphics();
			g.drawRect(40, 40, 750, 400, "#ffff00");
			var hitArea:HitArea = new HitArea();
			hitArea.hit = g;
			view.boardBorder.hitArea = hitArea;
			
		}

		override public function show(... args):void
		{
			super.show();
			trace("args:", args);
			WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST);
			if (args[0])
			{
				boradList=args[0];
				idList = boradList.map(function(item) {
					return item["id"];
				});
			}
			
			view.titleTxt.visible = false;
			view.titleTxt.wordWrap = true;
			
			view.contentTxt.visible = false;
			view.contentTxt.wordWrap = true;
			switch(parseInt(boradList[0].UI_type))
			{
				case 1:
					view.type1Bg.skin = "appRes/board/images/" + boradList[0].url + ".jpg";
					view.boardBorder.skin = "appRes/board/images/bg14.png";
					break;
				case 2:
					view.titleTxt.text = GameLanguage.getLangByKey(boradList[0].title);
					view.titleTxt.visible = true;
					
					view.contentTxt.text = GameLanguage.getLangByKey(boradList[0].des).replace(/##/g,"\n");
					view.contentTxt.visible = true;
					view.type1Bg.skin = "appRes/board/images/" + boradList[0].url + ".jpg";
					view.boardBorder.skin = "appRes/board/images/bg1.png";
					break;
				default:
					break;
			}
			
			Tween.from(this, {y: -10, alpha: 0}, 200, Ease.linearNone);

		}
		
		override protected function _onClick():void {
			nextHandler();
		}

		/**直接进入对应活动*/
		private function enterActivity():void {
			trace(boradList[0].id);
			var id = Number(boradList[0].id); 
			var type:String = boradList[0].param1;//1,运营活动，2，福利活动,3首冲
			trace("activityData111"+JSON.stringify(activityData));
			if(type=="1")
			{
				if (activityData.activity1)
				{
					for each(var obj:Object in activityData.activity1)
					{
						if(obj["tid"]==boradList[0].param2)
						{
							XFacade.instance.openModule(ModuleName.ActivityMainView, obj["id"]);
							break;
						}
					}
				}
				else if(activityData.activity2)
				{
					for each(var obj:Object in activityData.activity2)
					{
						if(obj["tid"]==boradList[0].param2)
						{
							if(boradList[0].param3==1)//在外面
							{
//								ThreeGiftView
								if(obj["tid"]==13)
								{
									trace("活动id:"+obj["id"]);
									XFacade.instance.openModule(ModuleName.ThreeGiftView, obj["id"]);
								}
								
							}else if(boradList[0].param3==2)//在里面
							{
								XFacade.instance.openModule(ModuleName.ActivityMainView, obj["id"]);
							}
						
							break;
						}
					}	
				}
			}else if(type=="2")
			{
				XFacade.instance.openModule(ModuleName.WelfareMainView, [boradList[0].param2]);
			}else if(type=="3")
			{
				XFacade.instance.openModule(ModuleName.FirstChargeView,0);
			}
			
			boradList.length = 0;
			close();
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.jumpBtn:
					enterActivity();
					
					boradList.length = 0;
					close();
					
					break;
				
				case view.btn_close:
					nextHandler();
					
					break;
				default:
					break;
			}
		}
		
		/**下一步函数*/
		private function nextHandler():void {
			boradList.shift();
			if (boradList.length)
			{
				show();
			}
			else
			{
				if (view.dom_checkbox.selected) {
					idList.forEach(function(item) {
						sendData(ServiceConst.TOTAY_FORBID, [item, 1]);
					});
				}
				
				close();
			}
		}
		
		/* 开始滚动文本 */
		private function startScrollText(e:Event):void
		{
			prevX = view.contentTxt.mouseX;
			prevY = view.contentTxt.mouseY;
			Laya.stage.on(Event.MOUSE_MOVE, this, scrollText);
			Laya.stage.on(Event.MOUSE_UP, this, finishScrollText);
		}

		/* 停止滚动文本 */
		private function finishScrollText(e:Event):void
		{
			Laya.stage.off(Event.MOUSE_MOVE, this, scrollText);
			Laya.stage.off(Event.MOUSE_UP, this, finishScrollText);
		}

		/* 鼠标滚动文本 */
		private function scrollText(e:Event):void
		{
			var nowX:Number = view.contentTxt.mouseX;
			var nowY:Number = view.contentTxt.mouseY;

			view.contentTxt.scrollX += prevX - nowX;
			view.contentTxt.scrollY += prevY - nowY;

			prevX = nowX;
			prevY = nowY;
		}

		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClickHandler);
			
			view.boardBorder.on(Event.CLICK, this, enterActivity);
			
			view.contentTxt.on(Event.MOUSE_DOWN, this, startScrollText);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_ACT_LIST), this, this.serviceResultHandler, [ServiceConst.GET_ACT_LIST]);
		}
		
		/**所有活动的详细数据*/
		private var activityData:Object;
		private function serviceResultHandler(cmd:int, ...args):void
		{
			switch(cmd)
			{
				// 获取当前活动列表
				case ServiceConst.GET_ACT_LIST:
//					trace("afljaf");
					activityData = args[1];
					break;
				
			}
		}
		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClickHandler);
			view.boardBorder.off(Event.CLICK, this, enterActivity);
			
			view.contentTxt.on(Event.MOUSE_DOWN, this, startScrollText);
		}
		
		override public function close():void
		{
			super.close();
			
		}

		private function get view():GameBoardViewUI
		{
			return _view as GameBoardViewUI;
		}
	}
}
