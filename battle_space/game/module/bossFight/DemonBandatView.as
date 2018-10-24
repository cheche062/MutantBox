package game.module.bossFight
{
	import MornUI.bossFight.DemonBandatViewUI;
	
	import game.common.ItemTips;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.WorldBossBaseParamVo;
	import game.global.vo.worldBoss.BossBuyVo;
	import game.global.vo.worldBoss.BossFightInfoVo;
	import game.global.vo.worldBoss.BossLevelVo;
	import game.global.vo.worldBoss.BossSellItemVo;
	import game.global.vo.worldBoss.RewardVo;
	import game.module.camp.ProTipUtil;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class DemonBandatView extends BaseDialog
	{
		private var m_progressMax:int=0;
		private var m_fightBoss:BossFightInfoVo;
		private var m_worldBossBaseParamVo:WorldBossBaseParamVo;
		
		//购买物品的信息
		private var m_type:int;
		private var m_itemId:int;
		
		private var m_solderType:int;
		
		public function DemonBandatView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new DemonBandatViewUI();
			this.addChild(_view);
		}
		
		/**初始化ui*/
		private function onInitUI():void
		{
			this.view.TimeText.text=GameLanguage.getLangByKey("L_A_46028");
			this.view.DropText.text=GameLanguage.getLangByKey("L_A_46026");
			this.view.RewardText.text=GameLanguage.getLangByKey("L_A_46002");
			this.view.RewardText0.text=GameLanguage.getLangByKey("L_A_46016");
			this.view.DeployLimtText.text=GameLanguage.getLangByKey("L_A_46025");
			this.view.TitleProgressText.text=GameLanguage.getLangByKey("L_A_46004");
			this.view.TitleText.text=GameLanguage.getLangByKey("L_A_46000");
			this.view.FightBtn.text=GameLanguage.getLangByKey("L_A_46029");
			this.view.RankingText.text=GameLanguage.getLangByKey("L_A_46009");
			this.view.ItemText.text=GameLanguage.getLangByKey("L_A_46027");
			GameConfigManager.intance.InitBossFightParam();
			m_worldBossBaseParamVo=GameConfigManager.boss_param;
			this.view.BossFightTips.visible=false;
			m_progressMax=10;
			m_fightBoss.level=1;
//			this.timer.loop(1000,this,updateTime);
			setBtnInfo();
			initBoss();
		}
		
		/**设置按钮*/
		private function setBtnInfo():void
		{
			if(m_fightBoss.freeFightTime>0)
			{
				this.view.FightImage.visible=false;
				this.view.FightBtn.text.text=GameLanguage.getLangByKey("L_A_34039");
			}
			else
			{
				var num:int=m_fightBoss.todayBoughtTimes+1;
				var l_data:BossBuyVo;
				for (var i:int = 0; i < GameConfigManager.boss_buy_arr.length; i++) 
				{
					var l_bossBuyVo:BossBuyVo= GameConfigManager.boss_buy_arr[i];
					if(l_bossBuyVo.up>=num && l_bossBuyVo.down<=num)
					{
						l_data=l_bossBuyVo;
						break;
					}
				}
				this.view.FightImage.visible=true;
				ItemUtil.formatIcon(this.view.FightImage, l_data.price);
				this.view.FightBtn.text.text=l_data.getPrice();
			}
			setLightType(m_fightBoss.freeFightTime+m_fightBoss.boughtTimes);
			this.view.ProgressText.text=m_fightBoss.fightStep+"/"+m_progressMax;
		}
		
		/**
		 * 挑战次数
		 */
		private function setLightType(p_num:int):void
		{
			view.TimeText.text=GameLanguage.getLangByKey("L_A_46028")+p_num;
		}
		
		/**
		 * 
		 */
		override public function show(...args):void
		{
			super.show(args);
			m_fightBoss=args[0][0];
			onInitUI();
		}
		
		/**
		 *boss物品掉落 
		 */		
		private function initBoss():void
		{
			var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_fightBoss.fightStep-1];
			this.view.DeployLimtTips.visible=false;
			this.view.typeIcon.skin=l_bossLevelVo.getTypeIcon();
			this.view.tiaojianLbl.text=l_bossLevelVo.getTypeText();
			this.view.DeployLimtITipsText.text=GameLanguage.getLangByKey(l_bossLevelVo.des2);
			var l_randomRewardArr:Array=l_bossLevelVo.getRandomRewardArr();
			var l_rewardArr:Array=l_bossLevelVo.getRewardArr();
			view.DropList.itemRender=ItemCell;
			view.RewardList.itemRender=ItemCell;
			view.DropList.array=l_rewardArr;
			view.RewardList.array=l_randomRewardArr;
		}
		
		/**
		 *倒计时 
		 * @return 
		 */
		private function updateTime()
		{
//			if(m_fightBoss.fightCoolDownTime>0)
//			{
//				this.view.RemainTimeText.text=TimeUtil.getBossFightTimeStr(m_fightBoss.fightCoolDownTime*1000);
//			}
		}
		
		/**加入监听*/
		override public function addEvent():void
		{
			this.on(Event.CLICK,this,this.onClickHander);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FIGHTINGMAP_INFO_DATA),this,sendMapInfoBack);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_BUY_TIME),this,onResult,[ServiceConst.WORLD_BOSS_BUY_TIME]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_ITEM_BUY),this,onResult,[ServiceConst.WORLD_BOSS_ITEM_BUY]);
		}
		
		
		/**移除监听*/
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FIGHTINGMAP_INFO_DATA),this,sendMapInfoBack);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_BUY_TIME),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_ITEM_BUY),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		/**
		 * 回调消息
		 * @param cmd
		 * @param args
		 * 
		 */		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.WORLD_BOSS_BUY_TIME:
					GlobalRoleDataManger.instance.user.bossFightInfo.boughtTimes++;
					setBtnInfo();
					this.view.BossFightTips.visible=false;
					FightingManager.intance.getSquad(3,null,Handler.create(this,fightCallBackHandler));
					break;
				case ServiceConst.WORLD_BOSS_ITEM_BUY:
					this.view.BossFightTips.visible=false;
					break;
			}
		}
		
		/**
		 *战斗返回 
		 */		
		private function fightCallBackHandler():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,3]);
//			WebSocketNetService.instance.sendData(ServiceConst.FIGHTINGMAP_INFO_DATA,[]);
		}
		
		private function sendMapInfoBack(... args):void
		{
			// TODO Auto Generated method stub
			var dObj:Object = args[1];
			var bossArr:Array=dObj.boss
			if(bossArr!=null)
			{
				m_fightBoss=new BossFightInfoVo();
				m_fightBoss.fightStage=bossArr.stage;
				m_fightBoss.fightCoolDownTime=bossArr.info.time;
				m_fightBoss.freeFightTime=bossArr.info.freeTimes;
				m_fightBoss.boughtTimes=bossArr.info.boughtTimes;
				m_fightBoss.todayBoughtTimes=bossArr.info.todayBoughtTimes;
				m_fightBoss.fightStep=bossArr.info.step;
				GlobalRoleDataManger.instance.user=m_fightBoss;
				if(m_fightBoss.fightStage==0)
				{
					this.close();
				}
			}
			else
			{
				this.close();
			}
		}		
		
		/**按键监听*/
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
					this.close();
					break;
				case this.view.FightBtn:
					this.onFightHandler();
					break;
				case this.view.AddFightTimeBtn:
					if(m_fightBoss.freeFightTime<=0)
					{
						this.view.BossFightTips.visible=true;
						m_type=0;	
						var item:BossFightTipsView=new BossFightTipsView(this.view.BossFightTips,0,m_fightBoss.todayBoughtTimes+1);
					}
					else
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_910004"));
					}
					break;
				case this.view.RewardTipsBtn:
					XFacade.instance.openModule("RankingRewardView",[]);
					break;
				case this.view.TipInfoBtn:
					XFacade.instance.openModule("BossFightRuleView",[]);
					break;
				case this.view.RankBtn:
					XFacade.instance.openModule("BossFightItemView",m_fightBoss);
					break;
				case this.view.RewardBtn:
					XFacade.instance.openModule("BossFightRankView",[]);
					break;
				case this.view.BossFightTips.CloseBtn:
					this.view.BossFightTips.visible=false;
					break;
				case this.view.BossFightTips.BuyBtn:
					var user:User = GlobalRoleDataManger.instance.user;
					if(user.water>=parseInt(this.view.BossFightTips.BuyBtn.text.text))
					{
						if(m_type==0)
						{
							WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_BUY_TIME,[]);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_ITEM_BUY,[m_itemId]);
						}
					}
					else
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
					}
					break;
				case this.view.typeIcon:
					var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_fightBoss.fightStep-1];
					var l_arr:Array=l_bossLevelVo.getSolderTypeArr();
					if(l_arr[0]==7||l_arr[0]==9){
						ProTipUtil.showAttTip(l_arr[1]);
					}else if(l_arr[0]==8||l_arr[0]==10){
						ProTipUtil.showDenTip(l_arr[1]);
					}
					break;
				default:
				{
					if(e.target.name.indexOf("RandomRewardImage")!=-1){
						var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_fightBoss.fightStep-1];
						var l_randomRewardArr:Array=l_bossLevelVo.getRandomRewardArr();
						var l_index:int=e.target.name.substr(17,18);
						var itemvo:ItemVo=GameConfigManager.items_dic[l_randomRewardArr[l_index].id];
						ItemTips.showTip(itemvo.id);
					}
					else if(e.target.name.indexOf("RewardImage")!=-1)
					{
						var l_bossLevelVo:BossLevelVo=GameConfigManager.boss_level_arr[m_fightBoss.fightStep-1];
						var l_rewardArr:Array=l_bossLevelVo.getRewardArr();
						var l_index:int=e.target.name.substr(11,12);
						var itemvo:ItemVo=GameConfigManager.items_dic[l_rewardArr[l_index].id];
						ItemTips.showTip(itemvo.id);
					}
					break;
				}
				
			}
			this.view.DeployLimtTips.visible=false;
		}
		
		/**进入战斗*/
		private function onFightHandler():void
		{
			// TODO Auto Generated method stub
			if(m_fightBoss.fightCoolDownTime>0)
			{
				this.view.FightBtn.disabled=false;
				if(m_fightBoss.freeFightTime==0 && m_fightBoss.boughtTimes<=0)
				{
					this.view.BossFightTips.visible=true;
					m_type=0;	
					var item:BossFightTipsView=new BossFightTipsView(this.view.BossFightTips,0,m_fightBoss.todayBoughtTimes+1);
				}
				else
				{
//					WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_FIGHT,[]);
					FightingManager.intance.getSquad(3,null,Handler.create(this,fightCallBackHandler));
				}
			}
			else
			{
				this.view.FightBtn.disabled=true;
			}
		}		
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		
		private function get view():DemonBandatViewUI{
			return _view;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy DemonBandatView");
			m_fightBoss = null;
			m_worldBossBaseParamVo = null;
			super.destroy(destroyChild);
		} 
		
	}
}