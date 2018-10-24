package game.module.armyGroup
{
	import game.common.UIRegisteredMgr;
	import game.global.GameLanguage;
	import game.global.vo.armyGroup.ArmyGroupJuntuanMilitaryVo;
	import game.module.bingBook.ItemContainer;
	import MornUI.armyGroup.MilitaryRankViewUI;

	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;

	/**
	 * 军团军衔任务
	 * @author douchaoyang
	 *
	 */
	public class MilitaryRankView extends BaseDialog
	{
		// 数据
		private var _Array:Array=[];

		private var _rewardVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var goodArr:Vector.<Image>=new Vector.<Image>(3);
		private var textArr:Vector.<TextArea> = new Vector.<TextArea>(3);
		private var _claimLog:Array = [];
		private var _canGetID:int = 1;
		private var rankId:int;

		public function MilitaryRankView()
		{
			super();
		}

		/**
		 * 由于数据表下标是从1开始，把第一项删除后，塞给列表
		 *
		 */
		private function initDataHandler():void
		{
			_Array=GameConfigManager.ArmyGroupMilitaryPoint.slice(1);
		}

		override public function createUI():void
		{
			_view=new MilitaryRankViewUI();
			this.addChild(_view);
			this._closeOnBlank=true;
			// 设置列表渲染项
			view.missionList.itemRender=MilitaryListItem;
			view.missionList.vScrollBarSkin="";

			UIRegisteredMgr.AddUI(view.closeBtn, "AG_mCloseBtn");
		}

		public override function destroy(destroyChild:Boolean=true):void
		{
			UIRegisteredMgr.DelUi("AG_mCloseBtn");
			super.destroy(destroyChild);
		}

		override public function show(... args):void
		{
			super.show();

			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO);
			initDataHandler();
			view.missionList.array=_Array;
			AnimationUtil.flowIn(this);
		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, onCloseHandler);
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
			// 领取奖励
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILLITARY_REWARD), this, this.onResultHandler, [ServiceConst.ARMY_GROUP_GET_MILLITARY_REWARD]);
		}

		override public function removeEvent():void
		{
			super.removeEvent();
			view.off(Event.CLICK, this, onClickHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO), this, this.onResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_MILLITARY_REWARD), this, this.onResultHandler);
		}

		// 处理数据回调
		private function onResultHandler(cmd:int, ... args):void
		{
			//trace("军衔信息，", args);
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_MILITARY_INFO:
					// trace("军衔信息，", args);
					// 军衔id
					rankId =parseInt(args[1].military_id);
					// 奖励是否可领 ，0不可领取，1可领取，2已领取
					//view.claimBtn.disabled=!(parseInt(args[1].status) == 1);
					_claimLog = args[1].get_log;
					
					_canGetID = _claimLog.length + 1;
					
					view.rewardTitle.text = GameLanguage.getLangByKey("L_A_20785").replace("{0}", _canGetID);

					// 如果不可领取，抛出事件去除小红点
					if (!(parseInt(args[1].status) == 1))
					{
						Signal.intance.event(ArmyGroupEvent.HIDE_RED_DOT, [2]);
					}
					
					view.rankTitle.text=GameConfigManager.ArmyGroupJuntuanMilitary[rankId].mc;
					
					// 设置进度条
					setProgress(rankId, args);
					// 设置当前军衔
					setNowReward(_canGetID);
					
					
					break;
				case ServiceConst.ARMY_GROUP_GET_MILLITARY_REWARD:
					var arr:Array=[];
					var list:Array=args[1];
					for (var i=0; i < list.length; i++)
					{
						var item:ItemData=new ItemData();
						item.iid=list[i].id;
						item.inum=list[i].num;
						arr.push(item);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [arr]);
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_MILITARY_INFO);
					break;
				default:
					break;
			}
		}

		private function setNowReward(id:int):void
		{
			var data:ArmyGroupJuntuanMilitaryVo = GameConfigManager.ArmyGroupJuntuanMilitary[id];
			
			var reArr:Array=data.reward.split(";");
			var len:int = _rewardVec.length;
			var i:int = 0;
			for (i = 0; i < len; i++ )
			{
				_rewardVec[i].visible = false;
			}
			
			len = reArr.length;
			i = 0;
			for (i = 0; i < len; i++ )
			{
				if (!_rewardVec[i])
				{
					_rewardVec[i] = new ItemContainer();
					_rewardVec[i].scaleX = _rewardVec[i].scaleY = 0.8;
					_rewardVec[i].y = 325;
					_rewardVec[i].x = 162 - len * 35 + i * 70;
					this.addChild(_rewardVec[i]);
				}
				_rewardVec[i].setData(reArr[i].split("=")[0], reArr[i].split("=")[1]);
				_rewardVec[i].visible = true;
			}
			
			view.claimBtn.disabled = false;
			if (_canGetID > rankId || _canGetID > GameConfigManager.ArmyGroupJuntuanMilitary.length)
			{
				view.claimBtn.disabled = true;
			}
		}
		
		private function setProgress(id:int, args):void
		{
			var data:Object=GameConfigManager.ArmyGroupJuntuanMilitary[id];
			var prScore:int;
			if (id == 18)
			{
				prScore="-";
				view.rankPr.value=1;
			}
			else
			{
				prScore=parseInt(data.up) - args[1].militaryPoint;
				view.rankPr.value=Number((args[1].militaryPoint - data.down) / (data.up - data.down)).toFixed(2);
			}
			view.rankNum.text = (args[1].militaryPoint - data.down) + "/" + (data.up - data.down);
			view.jxLog.x = view.rankNum.x + (view.rankNum.width - view.rankNum.textWidth) / 2 - 50;
		}

		private function onClickHandler(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					this.close();
					break;
				case view.searchBtn:
					// 打开军衔列表页
					XFacade.instance.openModule(ModuleName.MilitaryRankListView);
					break;
				case view.claimBtn:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_MILLITARY_REWARD,[_canGetID]);
					break;
				default:
					break;
			}
		}

		private function get view():MilitaryRankViewUI
		{
			return _view as MilitaryRankViewUI;
		}
	}
}
