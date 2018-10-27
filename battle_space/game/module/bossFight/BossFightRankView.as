package game.module.bossFight
{
	import MornUI.bossFight.BossFightRankViewUI;
	
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.worldBoss.BossRankPlayerInfoVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class BossFightRankView extends BaseDialog
	{
		private var m_selectType:int;
		private var m_rankList:Array;
		private var m_myRank:BossRankPlayerInfoVo;
		
		public function BossFightRankView()
		{
			super();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new BossFightRankViewUI();
			BossFightRankViewUI(this._view).myRank.bg.visible = false;
			this.addChild(_view);
			view.RankList.vScrollBarSkin = '';
			m_selectType=0;
			onInitUI();
		}
		
		/**初始化ui*/
		private function onInitUI():void
		{
//			WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_RANK,[1,1]);
			
			this.view.RankingText.text=GameLanguage.getLangByKey("L_A_46009");
			this.view.TurnsText.text=GameLanguage.getLangByKey("L_A_46032");
			this.view.LevelText.text=GameLanguage.getLangByKey("L_A_46011");
			this.view.ProgerssText.text=GameLanguage.getLangByKey("L_A_46012");
			this.view.NameText.text=GameLanguage.getLangByKey("L_A_46010");
			this.view.LevelText.text=GameLanguage.getLangByKey("L_A_46011");
			this.view.TitleText.text=GameLanguage.getLangByKey("L_A_46009");
			this.view.LocalBtn.text.text=GameLanguage.getLangByKey("L_A_46009");
			this.view.GroupBtn.text.text=GameLanguage.getLangByKey("L_A_46016");
			this.view.LocalRankText.text=GameLanguage.getLangByKey("L_A_46009");
			this.view.RewardText.text=GameLanguage.getLangByKey("L_A_46001");
			
			this.onSelectBtnHandler(1);
		}
		
		private function setRank()
		{
			this.view.RankList.itemRender=RankInfoCell;
			this.view.RankList.selectEnable=true;
			this.view.RankList.array=m_rankList;
			
			this.view.myRank.RankText0.color="#5de590";
			this.view.myRank.RankText1.color="#5de590";
			this.view.myRank.RankText2.color="#5de590";
			this.view.myRank.RankText3.color="#5de590";
			this.view.myRank.RankText4.color="#5de590";
			this.view.myRank.MyIconImage.visible=true;
			this.view.myRank.RankText0.text=m_myRank ? String(m_myRank.rank) : "-";
			this.view.myRank.RankText1.text=m_myRank ? String(m_myRank.name) : "-";
			this.view.myRank.RankText2.text=m_myRank ? String(m_myRank.level) : "-";
			this.view.myRank.RankText3.text=m_myRank ? m_myRank.progress + "%" : "-";
			this.view.myRank.RankText4.text=m_myRank ? String(m_myRank.rounds) : "-";
		}
		
		override public function addEvent():void
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_RANK),this,onResult,[ServiceConst.WORLD_BOSS_RANK]);
			this.on(Event.CLICK,this,this.onClickHander);
		}
		
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.WORLD_BOSS_RANK:
				{
					var l_obj:Object=args[1];
					m_rankList=new Array();
					for (var i:int = 0; i < l_obj.list.length; i++) 
					{
						var l_o:Object=l_obj.list[i];
						var l_vo:BossRankPlayerInfoVo=new BossRankPlayerInfoVo();
						l_vo.rank=l_o.rank;
						l_vo.name=l_o.name;
						l_vo.level=l_o.step;
						l_vo.progress=l_o.progress;
						l_vo.rounds=l_o.rounds;
						m_rankList.push(l_vo);
					}
					l_obj.userRank = null;
					if(l_obj.userRanking)
					{
						m_myRank ||= new BossRankPlayerInfoVo();
						m_myRank.rank=l_obj.userRanking.rank;
						m_myRank.name=l_obj.userRanking.name;
						m_myRank.level=l_obj.userRanking.step;
						m_myRank.progress=l_obj.userRanking.progress;
						m_myRank.rounds=l_obj.userRanking.rounds;
					}else
					{
						m_myRank = null;
					}
					setRank();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
					this.close();
					break;
				case this.view.TipInfoBtn:
					XFacade.instance.openModule("BossFightRuleView",[]);
					break;
				case this.view.LocalBtn:
					onSelectBtnHandler(1);
					break;
				case this.view.GroupBtn:
					onSelectBtnHandler(2);
					break;
//				case this.view.FriendBtn:
//					onSelectBtnHandler(3);
//					break;
			}
		}
		
		/**
		 *选择按钮 
		 * @param p_type
		 * 
		 */		
		private function onSelectBtnHandler(p_type:int):void
		{
			if(m_selectType!=p_type)
			{
				m_selectType=p_type;
				switch(m_selectType)
				{
					case 2:
						this.view.LocalBtn.selected=false;
						this.view.GroupBtn.selected=true;
//						this.view.FriendBtn.selected=false;
						view.RankBox.visible=false;
						view.RewardBox.visible=true;
						
						view.MyRankImage.visible=false;
						view.myRank.visible=false;
						onInitReward();
						//WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_RANK,[1]);
						break;
					case 1:
						this.view.GroupBtn.selected=false;
						this.view.LocalBtn.selected=true;
						view.RankBox.visible=true;
						view.RewardBox.visible=false;
						view.MyRankImage.visible=true;
						view.myRank.visible=true;
//						this.view.FriendBtn.selected=false;
						WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_RANK,[1]);
						break;
//					case 3:
////						this.view.FriendBtn.selected=true;
//						this.view.GroupBtn.selected=false;
//						this.view.LocalBtn.selected=false;
//						WebSocketNetService.instance.sendData(ServiceConst.WORLD_BOSS_RANK,[3]);
//						break;
				}
			}
		}
		
		private function onInitReward():void
		{
			// TODO Auto Generated method stub
			this.view.RewardList.itemRender=RankRewardInfoCell;
			this.view.RewardList.vScrollBarSkin="";
			this.view.RewardList.selectEnable=true;
			this.view.RewardList.renderHandler = new Handler(this, updateItem);
			this.view.RewardList.array=GameConfigManager.boss_rank_arr;
		}		
		
		private function updateItem():void
		{
			// TODO Auto Generated method stub
			
		}
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHander);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.WORLD_BOSS_RANK),this,onResult);
		}
		
		private function get view():BossFightRankViewUI{
			return _view as BossFightRankViewUI;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BossFightRankView");
			m_rankList = null;
			m_myRank = null;
			
			super.destroy(destroyChild);
		} 
		
	}
}