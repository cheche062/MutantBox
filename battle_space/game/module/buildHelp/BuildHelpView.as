package game.module.buildHelp 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Tween;
	import MornUI.buildHelp.BuildHelpViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class BuildHelpView extends BaseDialog 
	{
		public static const HELP_BUILD:String = "HELP_BUILD";
		public static const NO_HELP:String = "NO_HELP";
		
		private var _buildImg:Image;
		
		private var _helpArr:Array = [];
		
		private var _dayContribute:int = 0;
		
		private var allTime:int = 0;
		private var leftTime:int = 0;
		private var maxHelp:int = 0;
		
		public function BuildHelpView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				case this.view.closeBtn:				
					close();
					break;
				case this.view.infoBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_84207"));
					break;
				default:
					break;
				
			}
		}
		
		private function helpBuild(...args):void
		{
			
			WebSocketNetService.instance.sendData(ServiceConst.BUILDING_HELP_DO_HELP, [args[0]]);
			
			var len:int = _helpArr.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (_helpArr[i].bid == args[0])
				{
					_helpArr.splice(i, 1);
					i--;
					len--;
				}
			}
			
			view.helpList.array = _helpArr;
			view.helpList.refresh();
			
			if (_helpArr.length == 0)
			{
				Signal.intance.event(NO_HELP);
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.BUILDING_HELP_INIT:
					
					_dayContribute = args[1].day_contribution;
					view.todayTxt.text = _dayContribute+"/"+maxHelp;
					view.todayProg.value = _dayContribute / maxHelp;
					
					var myBuildInfo:Object = args[1].my_build;
					if (myBuildInfo.build_base_id)
					{
						view.noBuild.visible = false;
						
						var buInfo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(myBuildInfo.build_base_id.split("_")[0],myBuildInfo.build_level);
						_buildImg.skin = "appRes/building/" + buInfo.building_id + ".png";
						view.buildName.text = DBBuilding.getBuildingById(buInfo.building_id).name;
						
						allTime = buInfo.CD * 1000;
						leftTime = myBuildInfo.last_time-parseInt(TimeUtil.now / 1000);
						
						_buildImg.visible = true;
						view.buildName.visible = true;
						
						view.helpTimeTxt.text = myBuildInfo.number + "/" + myBuildInfo.max_number;
						view.helpTimeProg.value = parseInt(myBuildInfo.number) / parseInt(myBuildInfo.max_number);
						
						countTime();
					}
					
					_helpArr = [];
					for (var id in args[1].help_build_list)
					{
						var hd:Object = args[1].help_build_list[id];
						hd.bid = id;
						_helpArr.push(hd);
					}
					
					view.helpList.array = _helpArr;
					view.helpList.refresh();
					
					break;
				case ServiceConst.BUILDING_HELP_DO_HELP:
					if (args[1].reward.length > 0)
					{
						var ar:Array = [];
						len = args[1].reward.length;
						ar = [];
						for (i = 0; i < len; i++) 
						{
							//User.getInstance().contribution += parseInt(args[1].reward[i][1]);
							
							if (_dayContribute < maxHelp)
							{
								view.addNum.text = parseInt(args[1].reward[i][1]);
								view.addMotion.alpha = 1;
								view.addMotion.y = 135;
								Tween.to(view.addMotion, { y:120, alpha:0 }, 500);
							}
							
							_dayContribute += parseInt(args[1].reward[i][1]);
							view.todayTxt.text = _dayContribute+"/"+maxHelp;
							view.todayProg.value = _dayContribute / maxHelp;
							
							
						}
					}
					break;
				default:
					break;
			}
		}
		
		private function countTime():void
		{
			leftTime--;
			if (leftTime < 0)
			{
				leftTime = 0;
				view.restTimeTxt.text = "";
				view.restTimeProg.value = 0;
			}
			else
			{
				view.restTimeTxt.text = TimeUtil.getTimeCountDownStr(leftTime, false);
				view.restTimeProg.value = leftTime / allTime;
			}
			
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			_buildImg.visible = false;
			view.buildName.visible = false;
			view.noBuild.visible = true;
			view.restTimeTxt.text = "";
			view.restTimeProg.value = 0;
			
			view.helpTimeTxt.text = "";
			view.helpTimeProg.value = 0;
			
			view.addMotion.y = 135;
			view.addMotion.alpha = 0;
			
			WebSocketNetService.instance.sendData(ServiceConst.BUILDING_HELP_INIT);
		}	
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void{
			
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new BuildHelpViewUI();
			this.addChild(_view);
			
			this.closeOnBlank = true;
			
			_buildImg = new Image();
			_buildImg.x = 70;
			_buildImg.y = 70;
			view.addChild(_buildImg);
			
			view.helpList.itemRender = BuildHelpItem;
			
			maxHelp = GameConfigManager.guild_params[25].value;
		}
		
		private function get view():BuildHelpViewUI{
			return _view;
		}
		
		override public function addEvent():void {
			
			
			this.view.on(Event.CLICK, this, this.onClick);
			
			Laya.timer.loop(1000, this, countTime);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_INIT), this, serviceResultHandler, [ServiceConst.BUILDING_HELP_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_DO_HELP), this, serviceResultHandler, [ServiceConst.BUILDING_HELP_DO_HELP]);
			Signal.intance.on(HELP_BUILD, this, helpBuild);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void {
			
			
			this.view.off(Event.CLICK, this, this.onClick);
			
			Laya.timer.clear(this, countTime);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUILDING_HELP_DO_HELP),this,serviceResultHandler);
			Signal.intance.off(HELP_BUILD, this, helpBuild);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);			
			super.removeEvent();
		}
		
	}

}