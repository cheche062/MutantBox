package game.module.fighting.view
{
	import MornUI.fightingChapter.FightingOtherUIUI;
	
	import game.common.BufferView;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.cond.ConditionsManger;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.GameEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.worldBoss.BossFightInfoVo;
	import game.module.fighting.scene.FightingMapScene;
	import game.module.mainui.BtnDecorate;
	import game.module.mainui.SceneVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.utils.Handler;

	public class FightingOtherView extends BaseChapetrView
	{
		private var geneBtn:Image;
		private var equipfBtn:Image;
		private var starTrekBtn:Image;
		private var m_bossBtn2:Button;
		private var m_bossLevel:Text;
		private var m_bossTime:Text;
		private var m_worldBoss:BossFightInfoVo;
		private var _pArgs:Array;
		private var view:FightingOtherUIUI;
		
//		private var 
		
		/**事件-打开子界面*/
		public static const OPEN_WIN:String = "openWin"

		
		public function FightingOtherView()
		{
			super();
			view = new FightingOtherUIUI();
			bgBox.addChild(view);
			bgImg.loadImage("appRes/fightingMapImg/yh.jpg");
			
			geneBtn = view.geneBtn;
			equipfBtn = view.equipfBtn;
			starTrekBtn = view.starTrekBtn;
			m_bossBtn2 = view.bossBtn;
			m_bossTime=view.BossTimeText;
			m_bossLevel=view.BossLevelText;
			m_bossBtn2.visible = false;
			
			starTrekBtn.visible = false;
			
			UIRegisteredMgr.AddUI(geneBtn,"GenRaid");
			UIRegisteredMgr.AddUI(starTrekBtn,"StarTrekBtn");
			UIRegisteredMgr.AddUI(view.btn_pata,"pataBtn");
		}
		
		public function get pArgs():Array
		{
			return _pArgs;
		} 
                  
		public function set pArgs(value:Array):void
		{ 
			_pArgs = value;
		}

		public function setBossCoolDown(p_time:Number):void
		{
			m_bossTime.text=TimeUtil.getBossFightTimeStr(p_time*1000);
		}
		
		public function setBossInfo(p_vo:BossFightInfoVo):void
		{
			//m_bossBtn2.visible=true;
			GameConfigManager.intance.InitBossFightParam();
			m_bossLevel.text=(p_vo.fightStep)+"/"+GameConfigManager.boss_level_arr.length;
//			m_bossBtn2.text.text=GameLanguage.getLangByKey("L_A_46000");
		}
		
		private function openStarTrekMenu(e:Event):void
		{
			if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP)<2)
			{
				return;
			}else 
			{
				if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP)==2)
				{
					var vo:SceneVo = User.getInstance().sceneInfo;
					var ifIqueue:Boolean = vo.hasBuildingInQueue(Number(DBBuilding.B_CAMP));
					trace("兵营是否在建筑队列中:"+ifIqueue);
					if(ifIqueue)
					{
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_150"));
					}else 
					{
						var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
						SoundMgr.instance.playSound(mp3Url);
						XFacade.instance.openModule(ModuleName.StarTrekMainView);
					}
				}else
				{
					var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
					SoundMgr.instance.playSound(mp3Url);
					XFacade.instance.openModule(ModuleName.StarTrekMainView);
				}
			
			}
		
		}
		
		private function geneBtnClickFun(e:Event):void{
			var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
			SoundMgr.instance.playSound(mp3Url);
			var json:Object = ResourceManager.instance.getResByURL("config/convict_param.json");
			var cStr:String;
			if(json)
			{
				cStr = json[2].value;
			}
			var er:Array = ConditionsManger.cond(cStr);
			if(er && er.length)
			{
				XTip.showTip(er[0].toString());
				return ;
			}
			if(	User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GENE)>1)
			{
				Signal.intance.event(FightingMapScene.SHOWPANEL_EVENT,FightingMapScene.SHOWPANELID_GENE);
				Signal.intance.event(OPEN_WIN);

			}else if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_GENE)==1)
			{	var vo:SceneVo = User.getInstance().sceneInfo;
				var ifIqueue:Boolean = vo.hasBuildingInQueue(Number(DBBuilding.B_GENE));
				trace("酒馆是否在建筑队列中:"+ifIqueue);
				if(ifIqueue)
				{
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_154"));
				}else
				{
					Signal.intance.event(FightingMapScene.SHOWPANEL_EVENT,FightingMapScene.SHOWPANELID_GENE);
					Signal.intance.event(OPEN_WIN);
				}
			}	

		}
		
		private function equipBtnClick(e:Event):void
		{
			var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
			SoundMgr.instance.playSound(mp3Url);
			var json:Object = ResourceManager.instance.getResByURL("config/galaxy_param.json");
			var lv:Number = 0;
			var bType:String = "";
			var cStr:String;
			if(json)
			{
				cStr = json[3].value;
			}
			var er:Array = ConditionsManger.cond(cStr);
			if(er && er.length)
			{
				XTip.showTip(er[0].toString());
				return ;
			}
			if(	User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_HOTRL)>1)
			{
				sendEquipInfoData();
			}else if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_HOTRL)==1)
			{	var vo:SceneVo = User.getInstance().sceneInfo;
				var ifIqueue:Boolean = vo.hasBuildingInQueue(Number(DBBuilding.B_HOTRL));
				trace("酒馆是否在建筑队列中:"+ifIqueue);
				if(ifIqueue)
				{
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_153"));
				}else
				{
					sendEquipInfoData();
				}
			}	
		}
		
		private function sendEquipInfoData():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTINGEQUIP_INFO_DATA,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTINGEQUIP_INFO_DATA),
				this,sendEquipInfoBack);
		}
		
		private function sendEquipInfoBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendBossInfoBack);
			
			var _galaxy:Object = args[1];
			
			XFacade.instance.openModule(ModuleName.EquipFightInfoView,_galaxy?Number(_galaxy.currentChapter):0);
			
			Signal.intance.event(OPEN_WIN);
		}
		
		private function checkSTBtn():void
		{
			if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) < 2)
			{
				starTrekBtn.visible = false;
			}
			else
			{
				starTrekBtn.visible = true;
			}
		}
		
		
		private function bossBtnClickFun(e:Event):void{
			if(m_worldBoss!=null)
			{
				XFacade.instance.openModule("DemonBandatView",[m_worldBoss]);
				Signal.intance.event(OPEN_WIN);
			}
			else
			{
				XTip.showTip("L_A_46111");
			}
		}
		
		private function gotoPata():void {
			if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP)<3)
			{
				return;
			}else 
			{
				if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP)==3)
				{
					var vo:SceneVo = User.getInstance().sceneInfo;
					var ifIqueue:Boolean = vo.hasBuildingInQueue(Number(DBBuilding.B_CAMP));
					trace("兵营是否在建筑队列中:"+ifIqueue);
					if(ifIqueue)
					{
						XTipManager.showTip(GameLanguage.getLangByKey("L_A_151"));
					}else 
					{
						XFacade.instance.openModule(ModuleName.NewPataView);
					}
				}else
				{
					XFacade.instance.openModule(ModuleName.NewPataView);
				}
			}
		}
		
		
		public override function addEvent():void
		{
			super.addEvent();
			geneBtn.on(Event.CLICK,this,geneBtnClickFun);
			starTrekBtn.on(Event.CLICK,this,openStarTrekMenu);
			equipfBtn.on(Event.CLICK,this,equipBtnClick);
			m_bossBtn2.on(Event.CLICK,this,bossBtnClickFun);
			view.btn_pata.on(Event.CLICK, this, gotoPata);
			
			sendBossInfoData();
			timer.once(100, this, bindArgs);
			
			Signal.intance.on(GameEvent.CHECK_OPEN_ST, this, checkSTBtn);
			
			BufferView.instance.close();
			
			// 暂时屏蔽爬塔入口
			pataViewShow();
			
		}
		public override function removeEvent():void
		{
			super.removeEvent();
			geneBtn.off(Event.CLICK,this,geneBtnClickFun);
			starTrekBtn.off(Event.CLICK,this,openStarTrekMenu);
			equipfBtn.off(Event.CLICK,this,equipBtnClick);
			m_bossBtn2.off(Event.CLICK, this, bossBtnClickFun);
			view.btn_pata.off(Event.CLICK, this, gotoPata);
			Signal.intance.off(GameEvent.CHECK_OPEN_ST, this, checkSTBtn);
		}
		
		
		
		private function bindArgs():void
		{
			if(pArgs && pArgs.length)
			{
				var i:Number = pArgs[0];
				switch(i)
				{
					case 1:
					{
						geneBtnClickFun(null);
						break;
					}
					case 2:
					{
						equipBtnClick(null);
						break;
					}
					case 3:
					{
						bossBtnClickFun(null);
						break;
					}
				}
			}
			
			pArgs = null;
		}
		
		/**等级是否够爬塔玩法*/
		private function pataViewShow():void {
			var _url:String = ResourceManager.instance.setResURL("config/pvepata_config.json");
			Laya.loader.load(_url, Handler.create(this, function(data) {
				var _info:Array = data["2"]["value"].split("=");
				view.btn_pata.visible = User.getInstance().sceneInfo.getBuildingLv(_info[0]) >= _info[1];
			}));
		}
		
		private function sendBossInfoData():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTINGBOSS_INFO_DATA,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTINGBOSS_INFO_DATA),
				this,sendBossInfoBack);
		}
		
		private function sendBossInfoBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendBossInfoBack);
			
			var bossArr:Object = args[1];
			
			if(bossArr!=null && bossArr.info)
			{
				m_worldBoss=new BossFightInfoVo();
				m_worldBoss.fightStage=bossArr.stage;
				m_worldBoss.fightCoolDownTime=bossArr.info.time;
				m_worldBoss.freeFightTime=bossArr.info.freeTimes;
				m_worldBoss.boughtTimes=bossArr.info.boughtTimes;
				m_worldBoss.todayBoughtTimes=bossArr.info.todayBoughtTimes;
				m_worldBoss.fightStep=bossArr.info.step;
				GlobalRoleDataManger.instance.user.bossFightInfo=m_worldBoss;
				if(m_worldBoss.fightStage!=0)
				{
					setBossInfo(m_worldBoss);
					this.timer.loop(1000,this,updateTime);
				}
			}
		}
		
		private function updateTime():void
		{
			if(!m_worldBoss.fightCoolDownTime)
			{
				return;
			}
			
			if(m_worldBoss.fightCoolDownTime>0)
			{
				m_worldBoss.fightCoolDownTime--;
				setBossCoolDown(m_worldBoss.fightCoolDownTime);
			}
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy FightingOtherView");
			geneBtn = null;
			equipfBtn = null;
			m_bossBtn2 = null;
			m_bossLevel = null;
			m_bossTime = null;
			m_worldBoss = null;
			_pArgs = null;
			
			super.destroy(destroyChild);
		}

	}
}