package game.module.armyGroup 
{
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XUtils;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.TextArea;
	import MornUI.armyGroup.ArmyGroupSeasonRewardUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupSeasonRewardView extends BaseDialog 
	{
		// 存放列表数据
		private var gRankArr:Array=[];
		
		// 自己公会信息
		private var ownInfo:Object;
		
		private var myGoodArr:Vector.<ItemContainer>=new Vector.<ItemContainer>(3);
		private var myTextArr:Vector.<TextArea>=new Vector.<TextArea>(3);

		
		public function ArmyGroupSeasonRewardView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			switch (e.target)
			{
				case view.closeBtn:
					close();
					break;
				case view.claimReward:
					WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_SEASON_REWARD);
					break;
				default:
					break;
			}
		}

		private function serviceResultHandler(cmd:int, ... args):void
		{
			var len:int = 0;
			var i:int = 0;
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_GUILD_RANK:
					formatList(args[1][1]);
					ownInfo=Object(args[2]);
					// 设置自己公会的信息
					view.myRankTxt.text=GameLanguage.getLangByKey(ownInfo.rank);
					GameConfigManager.setGuildLogoSkin(view.myIcon, ownInfo.guildIcon);
					view.myNameTxt.text=ownInfo.guildName;
					view.myScoreTxt.text = ownInfo.guildPoint;
					
					
					var reArr:Array = [];
					
					if (parseInt(ownInfo.rank))
					{
						reArr = GameConfigManager.intance.getArmyGroupSeasonReward(ArmyGroupMapView.CURRENT_SEASON, ownInfo.rank).split(";");
					}
					
					len = reArr.length;
					var it:ItemContainer = new ItemContainer();
					
					for (i=0; i < 3; i++)
					{
						if (!myGoodArr[i])
						{
							myGoodArr[i]=new ItemContainer();
							myGoodArr[i].name=i;
							myGoodArr[i].scaleX=myGoodArr[i].scaleY=0.5;
							myGoodArr[i].y = 333;
							myGoodArr[i].needBg = false;
							myGoodArr[i].numTF.visible = false;
							view.addChild(myGoodArr[i]);
						}
						if (!myTextArr[i])
						{
							myTextArr[i]=new TextArea();
							myTextArr[i].font="Futura";
							myTextArr[i].fontSize=22;
							myTextArr[i].color="#a7ffad";
							myTextArr[i].mouseEnabled=false;
							myTextArr[i].y=346;
							view.addChild(myTextArr[i]);
						}
						
						myGoodArr[i].x = 730 - 84 * len + 90 * i;
						myTextArr[i].x = myGoodArr[i].x + 35;
						if (reArr[i])
						{
							myGoodArr[i].visible=true;
							myTextArr[i].visible=true;
							var info:Array=String(reArr[i]).split("=");
							
							myGoodArr[i].setData(info[0]);
							myTextArr[i].text="x" + XUtils.formatResWith(info[1]);
						}
						else
						{
							myGoodArr[i].visible=false;
							myTextArr[i].visible=false;
						}
					}
					
					view.claimReward.label = GameLanguage.getLangByKey("L_A_32004");
					view.claimReward.disabled = false;
					if (parseInt(args[3]) != 0)
					{
						view.claimReward.disabled = true;
						view.claimReward.label = GameLanguage.getLangByKey("L_A_32005");
					}
					
					break;
				case ServiceConst.ARMY_GROUP_GET_SEASON_REWARD:
					//trace("成功领取奖励;", args[1]);
					var rw:Array = args[1];
					var ar:Array = [];
					len = rw.length;
					for (i = 0; i < len; i++)
					{
						var i4:ItemData = new ItemData();
						i4.iid = rw[i][0];
						i4.inum = rw[i][1];
						ar.push(i4);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [ar]);
					view.claimReward.disabled = true;
					break;
				default:
					break;
			}

		}
		
		private function formatList(args:Object):void
		{
			gRankArr=[];
			for (var tid in args)
			{
				args[tid]["team_id"] = tid;
				gRankArr.push(args[tid]);
			}
			/*gRankArr = [ { "rank":"1", "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":99,"uid":3,"nickname":"Player3","guildname":"F.F.F.","killnum":0}];*/
			view.rankInfoList.array = gRankArr;
		}
		
		override public function show(... args):void
		{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_GUILD_RANK);

		}

		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}

		private function onClose():void
		{
			super.close();
			XFacade.instance.disposeView(this);
		}

		override public function createUI():void
		{
			this._view=new ArmyGroupSeasonRewardUI();
			this.addChild(_view);
			
			this._closeOnBlank = true;
			
			view.rankInfoList.itemRender = SeasonRewardItem;
			view.rankInfoList.scrollBar.sizeGrid = "6,0,6,0";
		}
		
		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_GUILD_RANK), this, this.serviceResultHandler, [ServiceConst.ARMY_GROUP_GET_GUILD_RANK]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_SEASON_REWARD), this, this.serviceResultHandler, [ServiceConst.ARMY_GROUP_GET_SEASON_REWARD]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			super.addEvent();
		}


		override public function removeEvent():void
		{
			view.off(Event.CLICK, this, this.onClick);

			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_GUILD_RANK), this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_SEASON_REWARD), this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);

			super.removeEvent();
		}

		private function get view():ArmyGroupSeasonRewardUI
		{
			return _view;
		}
	}

}