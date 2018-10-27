package game.module.gameRankView 
{
	import MornUI.gameRank.GameRankViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GameRankView extends BaseDialog 
	{
		
		private var _nowIndex:int = 0;
		private var _sendType:Array = ["level", "power", "hero", "soldier", "stage_level"];
		
		public function GameRankView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case this.view.closeBtn:
					close();
					break;
				
				case this.view.btn_help:
					var msg:String = GameLanguage.getLangByKey("L_A_78008");
					XTipManager.showTip(msg);
					break;
				
				default:
					
					break;
				
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("游戏排行榜数据:", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GAME_RANK:
					var td:Array = args[1].data;
					len = td.length;
					var myRank:int = -1;
					for (i = 0; i < len; i++ )
					{
						td[i].rank = (i + 1);
						td[i].rType = _sendType[_nowIndex];
						if (td[i].uid == User.getInstance().uid)
						{
							myRank = td[i].rank
						}
					}
					view.pList.array = td;
					
					var od:Array = args[1].oldData;
					len = od.length;
					var myOldRank:int = -1;
					for (i = 0; i < len; i++ )
					{
						od[i].rank = (i + 1);
						if (od[i].uid == User.getInstance().uid)
						{
							myOldRank = od[i].rank
						}
					}
					
					if (myRank > 0)
					{
						view.rankChangeIcon.visible = true;
						view.myRankTxt.text = myRank;
					}
					else
					{
						view.rankChangeIcon.visible = false;
						view.myRankTxt.text = "50+";
					}
					
					if (myRank > myOldRank)
					{
						view.rankChangeIcon.skin = "gameRank/arrow_up.png";
					}
					else if(myRank < myOldRank)
					{
						view.rankChangeIcon.skin = "gameRank/arrow_down.png";
					}
					else
					{
						view.rankChangeIcon.skin = "gameRank/arrow_nochange.png";
					}  
					
					break;
				default:
					break;
			}
		}
		
		private function onChangeType():void
		{
			_nowIndex = view.rankTypeTab.selectedIndex;
			WebSocketNetService.instance.sendData(ServiceConst.GAME_RANK, [_sendType[_nowIndex]]);
			
			switch(_sendType[_nowIndex])
			{
				case "level":
					view.t2Txt.text = GameLanguage.getLangByKey("L_A_53065");// "等级";
					view.t3Txt.text = GameLanguage.getLangByKey("L_A_87059");// "用户昵称";
					break;
				case "stage_level":
					view.t2Txt.text = GameLanguage.getLangByKey("L_A_87059");// "用户昵称";
					view.t3Txt.text =  GameLanguage.getLangByKey("L_A_130");
					break;
				case "power":
					view.t2Txt.text = GameLanguage.getLangByKey("L_A_87059");// "用户昵称";
					view.t3Txt.text = GameLanguage.getLangByKey("L_A_49046");// "战斗力";
					break;
				case "soldier":
					view.t2Txt.text = GameLanguage.getLangByKey("L_A_87059");// "用户昵称";
					view.t3Txt.text = GameLanguage.getLangByKey("L_A_125");
					break;
				case "hero":
					view.t2Txt.text = GameLanguage.getLangByKey("L_A_87059");// "用户昵称";
					view.t3Txt.text = GameLanguage.getLangByKey("L_A_44007");// "英雄";
					break;
				default:
					break;
			}
			/*var type:int;
			if(id == 0){
				type = 2
			}else{
				type = 1;
			}*/
			
			//selectedItem = null;
		}
		
		override public function show(...args):void
		{
			
			super.show();
			
			AnimationUtil.flowIn(this);
			
			view.rankTypeTab.selectedIndex = 0;
			view.t2Txt.text = GameLanguage.getLangByKey("L_A_53065");// "等级";
			view.t3Txt.text = GameLanguage.getLangByKey("L_A_87059");// "用户昵称";
			WebSocketNetService.instance.sendData(ServiceConst.GAME_RANK, [_sendType[0]]);
		}
		
		override public function close():void {
			
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			view.rankTypeTab.on(Event.CHANGE, this, this.onChangeType);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GAME_RANK),this,serviceResultHandler,[ServiceConst.GAME_RANK]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			view.rankTypeTab.off(Event.CHANGE, this, this.onChangeType);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GAME_RANK),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		override public function createUI():void {
			this.closeOnBlank = true;
			this._view = new GameRankViewUI();
			this.addChild(_view);
			
			
			
			
			view.pList.itemRender = GameRankItem;
			view.pList.scrollBar.sizeGrid = "0,6,0,6";
		}
		
		private function get view():GameRankViewUI{
			return _view;
		}
		
		
		
	}

}