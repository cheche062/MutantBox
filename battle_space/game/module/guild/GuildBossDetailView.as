package game.module.guild
{
	import MornUI.guild.GuildBossDetailUI;
	import MornUI.guild.GuildBossViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.global.vo.guild.GuildBossVo;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import laya.utils.Handler;
	
	public class GuildBossDetailView extends BaseDialog
	{
		private var bossData:GuildBossVo;
		
		private var rankData:Array = [];
		
		private var _reward0:Image;
		private var _rewardTF0:TextArea;
		private var _reward1:Image;
		private var _rewardTF1:TextArea;
		
		private var _rankRewardArr:Array;
		
		private var _leftFightTimes:int = 0;
		private var _hasBuyTimes:int = 0;
		
		public function GuildBossDetailView()
		{
			super();
			//this.on(Event.ADDED, this, addToStageHandler);
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				case view.tipsBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_2614"));
					break;
				case this.view.fightBtn:
					
					cost = GameConfigManager.intance.getGuildBossCost(_hasBuyTimes, bossData.type);
					/*if (bossData.fightTimes >= 0 && bossData.type == "free")
					{
						FightingManager.intance.getSquad(8, bossData.type, Handler.create(this, function():void {
							SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
							XFacade.instance.openModule(ModuleName.GuildMainView)
						}));
						return;
					}*/
					
					if (_leftFightTimes > 0)
					{
						FightingManager.intance.getSquad(8, bossData.type, Handler.create(this, function():void {
							SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
							XFacade.instance.openModule(ModuleName.GuildMainView);
							WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
						}));
						return;
					}
					
					if (parseInt(cost.split("=")[1]) == 0)
					{
						WebSocketNetService.instance.sendData(ServiceConst.BUY_BOSS_TIMES, [bossData.type]);
						return;
					}
					
					//str = "挑战此BOSS需要花费"+ GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name)+ cost.split("=")[1] +"";
					str = GameLanguage.getLangByKey("L_A_57000");
					str = str.replace("{0}", GameLanguage.getLangByKey(GameConfigManager.items_dic[cost.split("=")[0]].name));
					str = str.replace("{1}", cost.split("=")[1]);
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_57000"),
																			cost.split("=")[0],
																			cost.split("=")[1],
																			function(){									
																				if (User.getInstance().water < parseInt(cost.split("=")[1]))
																				{
																					XFacade.instance.openModule(ModuleName.ChargeView);
																				}
																				else
																				{
																					WebSocketNetService.instance.sendData(ServiceConst.BUY_BOSS_TIMES, [bossData.type]);
																				} 
																			}]);
					
					/*AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,0,function(v:int){
									if (v == AlertType.RETURN_YES)
									{
										WebSocketNetService.instance.sendData(ServiceConst.BUY_BOSS_TIMES, [bossData.type]);
									}
								});*/
					break;
				/*case this.view.rewardBtn:
					XFacade.instance.openModule(ModuleName.GuildBossReward,bossData.id);
					break;*/
				
				case this.view.closeBtn:
					close();
					//XFacade.instance.openModule(ModuleName.GuildBossView);
					break;
				
			}
		}
		
		private function serviceBackHandler(cmd:int,...args):void 
		{
			/*trace("cmd:", cmd);
			trace("args:", args);*/
			switch(cmd)
			{
				case ServiceConst.CHECK_GUILD_BOSS:
					
					
					if (bossData.state != 1)
					{
						view.bloodBar.width = 0;
						view.bloodPrecentTF.text = "0%";
					}
					else
					{
						view.bloodBar.width = parseFloat(parseFloat(args[1].progress) / 100) * 199;
						view.bloodPrecentTF.text = parseFloat(args[1].progress) + "%";
					}
					
					rankData = [];
					
					for (var key:String in args[1]['rank'])
					{
						rankData.push( {
							name:args[1]['rank'][key].name,
							rank:key,
							hurt:args[1]['rank'][key].score,
							reward:getRankReward(key)
							})
					}
					User.getInstance().guildBossRank = args[1].userRank;
					
					view.fightList.dataSource = rankData;
					view.fightList.scrollBar.height = 200;
					view.fightList.refresh();
					
					_leftFightTimes = parseInt(args[1].num);
					_hasBuyTimes = parseInt(args[1].pay);
					
					view.freeTimeTF.text = _leftFightTimes + "/" + bossData.mftz;
					
					//trace("_myRank:", User.getInstance().guildBossRank);
					break;
				case ServiceConst.BUY_BOSS_TIMES:
					//bossData.fightTimes++;
					FightingManager.intance.getSquad(8, bossData.type, Handler.create(this, function():void {
							SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
							XFacade.instance.openModule(ModuleName.GuildMainView);
							WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
						}));
					break;
				default:
					break;
			}
			
		}
		
		private function getRankReward(rank:String):Array;
		{
			var len:int = _rankRewardArr.length;
			var r:int = 0;
			for (var i:int = 0; i < len; i++) 
			{
				r = parseInt(_rankRewardArr[i].split(":")[0].split("|")[1]);
				//trace("r:", r);
				if (parseInt(rank) <= r)
				{
					return _rankRewardArr[i].split(":").slice(1);
				}
			}
			return[];
		}
		
		
		override public function show(...args):void{
			super.show();
			
			//AnimationUtil.flowIn(this);
			
			bossData = args[0] as GuildBossVo;
			WebSocketNetService.instance.sendData(ServiceConst.CHECK_GUILD_BOSS, bossData.type);
			_rankRewardArr = GameConfigManager.intance.getGuildBossInfo(bossData.id).ranking_reward.split(",");
			
			trace("bossData:", bossData);
			
			for (var i:int = 0; i < 5; i++) 
			{
				if (i < bossData.level)
				{
					view["star" + i].visible = true;
				}
				else
				{
					view["star" + i].visible = false;
				}
			}
			//trace("bossData: ", bossData);
			view.bossImg.skin = "appRes/icon/guildIcon/"+bossData.icon+".png";
			
			view.bossName.text = "『" + GameLanguage.getLangByKey(bossData.name) + "』";
			
			
			_reward0.skin = GameConfigManager.getItemImgPath(bossData.show_reward.split(";")[0].split("=")[0]);
			_rewardTF0.text = "x" + bossData.show_reward.split(";")[0].split("=")[1];
			
			if (bossData.show_reward.split(";").length>1)
			{
				_reward1.skin = GameConfigManager.getItemImgPath(bossData.show_reward.split(";")[1].split("=")[0]);
				_rewardTF1.text = "x" + bossData.show_reward.split(";")[1].split("=")[1];
				_reward1.visible = true;
				_reward1.mouseEnabled = true;
			}
			else
			{
				_reward1.skin = "";
				_reward1.visible = false;
				_reward1.mouseEnabled = false;
				_rewardTF1.text = "";
			}
			
			view.fightBtn.disabled = false;
			if (bossData.state != 1)
			{
				view.fightBtn.disabled = true;
			}
			
		}
		
		private function clickReward(index:int):void 
		{
			ItemTips.showTip(bossData.show_reward.split(";")[index].split("=")[0]);
		}
		
		override public function close():void{
			super.close();
			
			//AnimationUtil.flowOut(this, onClose);
			
		}
		
		override public function dispose():void{
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GuildBossDetailUI();
			this.addChild(_view);
			
			/*var testData:Array=[{name:"test1",rank:"1",hurt:"9999"},
				{name:"test9",rank:"2",hurt:"9999"},
				{name:"test9",rank:"3",hurt:"9999"},
				{name:"test10",rank:"4",hurt:"9999"}];*/
			//init scrollbar
			
			
			
			view.fightList.itemRender=BossRankItem;
			view.fightList.selectEnable = true;
			view.fightList.scrollBar.sizeGrid = "6,0,6,0";
			
			_reward0 = new Image();
			_reward0.skin = GameConfigManager.getItemImgPath('70000');
			_reward0.width = _reward0.height = 40;
			_reward0.x = 100;
			_reward0.y = 470;
			view.addChild(_reward0);
			_reward0.on(Event.CLICK, this, this.clickReward, [0]);
			
			_rewardTF0 = new TextArea();
			_rewardTF0.font = "Futura";
			_rewardTF0.fontSize = 16;
			_rewardTF0.color = "#ffffff";
			_rewardTF0.height = 30;
			_rewardTF0.x = 145;
			_rewardTF0.y = 485;	
			_rewardTF0.align= "left"
			_rewardTF0.text = "x1";
			_rewardTF0.mouseEnabled = false;
			view.addChild(_rewardTF0);
			
			
			_reward1 = new Image();
			_reward1.skin = GameConfigManager.getItemImgPath('70001');
			_reward1.width = _reward1.height = 40;
			_reward1.x = 180;
			_reward1.y = 470;
			view.addChild(_reward1);
			_reward1.on(Event.CLICK, this, this.clickReward, [1]);
			
			_rewardTF1 = new TextArea();
			_rewardTF1.font = "Futura";
			_rewardTF1.fontSize = 16;
			_rewardTF1.color = "#ffffff";
			_rewardTF1.height = 30;
			_rewardTF1.x = 225;
			_rewardTF1.y = 485;	
			_rewardTF1.align= "left"
			_rewardTF1.text = "x1";
			_rewardTF1.mouseEnabled = false;
			view.addChild(_rewardTF1);
			
			view.fightBtn['clickSound'] = ResourceManager.getSoundUrl("ui_start_fight_button",'uiSound')
		}	
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CHECK_GUILD_BOSS),this,serviceBackHandler,[ServiceConst.CHECK_GUILD_BOSS]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BUY_BOSS_TIMES),this,serviceBackHandler,[ServiceConst.BUY_BOSS_TIMES]);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CHECK_GUILD_BOSS), this, serviceBackHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BUY_BOSS_TIMES), this, serviceBackHandler);
			super.removeEvent();
		}
		
		private function get view():GuildBossDetailUI{
			return _view;
		}
	}
}