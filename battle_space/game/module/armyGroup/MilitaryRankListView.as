package game.module.armyGroup
{
	import MornUI.armyGroup.MilitaryRankListViewUI;

	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;

	/**
	 * 军团军衔每日奖励
	 * @author douchaoyang
	 *
	 */
	public class MilitaryRankListView extends BaseDialog
	{
		// 数据缓存
		private var _Array:Array=[];

		private var goodArr:Vector.<Image>=new Vector.<Image>(3);
		private var textArr:Vector.<TextArea>=new Vector.<TextArea>(3);


		public function MilitaryRankListView()
		{
			super();
		}

		/**
		 * 由于数据表下标是从1开始，把第一项删除后，塞给列表
		 *
		 */
		private function initDataHandler():void
		{
			_Array=GameConfigManager.ArmyGroupJuntuanMilitary.slice(1);
		}

		override public function createUI():void
		{
			_view=new MilitaryRankListViewUI();
			this.addChild(_view);
			this._closeOnBlank=true;
			// 设置列表渲染项
			view.rankList.itemRender=MilitaryRankListItem;
			view.rankList.vScrollBarSkin="";
		}

		override public function show(... args):void
		{
			super.show();
			AnimationUtil.popIn(this);
			initDataHandler();
			// 打开view时初始化列表
			view.rankList.array=_Array;
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO);
		}

		override public function close():void
		{
			AnimationUtil.popOut(this, onCloseHandler);
			// 置空数据源
			_Array=[];
		}

		private function onCloseHandler():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}

		override public function addEvent():void
		{
			super.addEvent();
			view.on(Event.CLICK, this, onClickHandler);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO), this, this.onResultHandler, [ServiceConst.ARMY_GROUP_GET_MILITARY_INFO]);
		}

		private function onResultHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_MILITARY_INFO:
					var rankId=parseInt(args[1].military_id);
					setNowRank(rankId);
					break;
				default:
					break;
			}
		}

		/**
		 * 设置当前的军衔
		 * @param id 军衔id
		 *
		 */
		private function setNowRank(id:int):void
		{
			var data:Object=GameConfigManager.ArmyGroupJuntuanMilitary[id];
			view.name.text=data.mc;
			setNowReward(data.reward);
		}

		/**
		 * 设置当前军衔的每日奖励
		 * @param str 奖励数据
		 *
		 */
		private function setNowReward(str:String):void
		{
			var data:Array=str.split(";");
			var len:int=data.length;
			for (var i=0; i < len; i++)
			{
				var info:Array=String(data[i]).split("=");
				if (!goodArr[i])
				{
					goodArr[i]=new Image();
					goodArr[i].name=i;
					goodArr[i].scaleX=goodArr[i].scaleY=0.5;
					goodArr[i].y=448;
					goodArr[i].on(Event.CLICK, this, function():void
					{
						ItemTips.showTip(info[0]);
					});
					this.addChild(goodArr[i]);
				}

				if (!textArr[i])
				{
					textArr[i]=new TextArea();
					textArr[i].font="Futura";
					textArr[i].fontSize=24;
					textArr[i].color="#9bff39";
					textArr[i].mouseEnabled=false;
					textArr[i].y=462;
					this.addChild(textArr[i]);
				}

				goodArr[i].skin=(GameConfigManager.getItemImgPath(info[0]));
				textArr[i].text=info[1];
				// 居中
				switch (len)
				{
					case 1:
						goodArr[i].x=410;
						textArr[i].x=444;
						break;
					case 2:
						goodArr[i].x=300 + 115 * i;
						textArr[i].x=350 + 115 * i;
						break;
					case 3:
						goodArr[i].x=260 + 115 * i;
						textArr[i].x=310 + 115 * i;
						break;
					default:
						break;
				}
			}
		}

		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO), this, this.onResultHandler);
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					this.close();
					break;
				default:
					break;
			}
		}

		private function get view():MilitaryRankListViewUI
		{
			return _view as MilitaryRankListViewUI;
		}
	}
}
