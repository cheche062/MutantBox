package game.module.activity 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameLanguage;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import MornUI.TurntableLottleOne.TurnTableOneRankItemUI;
	import MornUI.TurntableLottleOne.TurntableOneRankViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TurntableOneRankView extends BaseDialog 
	{
		
		private var rewardArr:Vector.<RewardVo> = new Vector.<RewardVo>();
		private var rankArr:Array = [];
		
		private var rankItemVec:Vector.<TurntableOneRankItem> = new Vector.<TurntableOneRankItem>(5);
		
		private var nowIndex:int = 0;
		
		public function TurntableOneRankView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.prevBtn:
					nowIndex--;
					if (nowIndex < 0)
					{
						nowIndex = 0;
					}
					refreshData();
					break;
				case view.nextBtn:
					nowIndex++;
					if (nowIndex > 19)
					{
						nowIndex = 19;
					}
					refreshData();
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		private function refreshData():void
		{
			view.pageTxt.text = (nowIndex + 1) + "/20";
			for (var i:int = 0; i < 5; i++) 
			{
				if (rankArr[nowIndex * 5 + i])
				{
					rankItemVec[i].setData(rankArr[nowIndex * 5 + i],findReward(nowIndex * 5 + i+1),nowIndex * 5 + i+1);
				}
				else
				{
					rankItemVec[i].setData(null,findReward(nowIndex * 5 + i+1),nowIndex * 5 + i+1);
				}
			}
		}
		
		private function findReward(index:int):String
		{
			var len:int = rewardArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (index <= rewardArr[i].down)
				{
					return rewardArr[i].reArr;
				}
			}
			return "";
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.TURNTABLE_ONE_RANK:
					trace("rank:", args);
					view.pRank.text = args[0].myrank;
					rankArr = args[0].list;
					refreshData();
					break;
				default:
					break;
			}
		}
		
		override public function dispose():void		
		{
			
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			view.pScore.text = args[0][0];
			
			rewardArr = [];
			
			
			
			var ar:Array = args[0][1];
			trace("ar:", ar);
			var len:int = ar.length;
			for (var i:int = 0; i < len; i++) 
			{
				var rVo:RewardVo = new RewardVo();
				rVo.up = ar[i].up;
				rVo.down = ar[i].down;
				rVo.reArr = ar[i].reward;
				rewardArr.push(rVo);
			}
			
			nowIndex = 0;
			view.pageTxt.text = (nowIndex + 1) + "/20";
			refreshData();
			
			WebSocketNetService.instance.sendData(ServiceConst.TURNTABLE_ONE_RANK, [ActivityMainView.CURRENT_ACT_ID]);
			
		}
		
		override public function close():void
		{
			
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new TurntableOneRankViewUI();
			this.addChild(_view);
			
			for (var i:int = 0; i < 5; i++) 
			{
				rankItemVec[i] =  new TurntableOneRankItem();
				rankItemVec[i].createUI(view["rItem_" + i] as TurnTableOneRankItemUI);
			}
			
		}
		
		/**保留*/
		override public function dispose():void{
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_RANK), this, this.serviceResultHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TURNTABLE_ONE_RANK), this, this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.removeEvent();
		}
		
		
		
		private function get view():TurntableOneRankViewUI{
			return _view;
		}
		
	}
	
	private class RewardVo
	{
		public var up:int;
		public var down:int;
		public var reArr:String;
	}

}