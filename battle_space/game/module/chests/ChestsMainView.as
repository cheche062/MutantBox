package game.module.chests
{
	import MornUI.chests.ChestMainCardItemUI;
	import MornUI.chests.ChestsMainViewUI;
	
	import game.common.AndroidPlatform;
	import game.common.ItemTips;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.DrawCardVo;
	import game.global.vo.FightUnitVo;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.Card.CardCostVo;
	import game.global.vo.Card.CardFreeItemVo;
	import game.global.vo.Card.CardPayItemVo;
	import game.global.vo.Card.CardPvwVo;
	import game.module.camp.CampData;
	import game.module.camp.ProTipUtil;
	import game.module.camp.UnitItem;
	import game.module.camp.UnitItemVo;
	import game.module.friend.MailCell;
	import game.module.tips.SkillTip;
	import game.module.train.TrainItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.ui.Image;
	import laya.ui.List;
	import laya.ui.UIUtils;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class ChestsMainView extends BaseView
	{
		private var m_cardItemList:Array;
		private static const DRAWCARD:int=1;
		private static const SHOWCARDLIST:int=2;
		private var m_stageType:int=0;
		private var m_selectCardIndex:int=0;
		private var duration:int=1000;
		private var m_drawCardVo:DrawCardVo;
		private var m_drawCardTypeArr:Array=["free_prop_","water_"];
		private var m_drawCardType:String="";
		
		private var m_drawCardSRMaxTime=10;
		private var m_nextDrawCardSRTime=0;
		private var m_cardChildIndex=0;
		private var m_drawInfo:Object;
		
		private var m_addNumLength:int=0;
		private var m_index:int;
		private var m_display_rewards:Array;
		private var m_add_result:Array;
		
		private var m_cardMaxIndex=0;
		
		private var m_DardCardType:int=0;
		
		private var m_onceCostNum:int=0;
		private var m_tenTimeNum:int=0;
		private var m_chestsMainShowView:ChestsMainShowView;
		private var m_heroList:Array;
		
		private var m_cardItem0:ChestMainCardItem;
		private var m_cardItem1:ChestMainCardItem;
		private var m_cardItem2:ChestMainCardItem;
		private var m_Blevel:int;
		private var m_BMaxLevel:int;
		private var m_cardCostVo:CardCostVo;
		
		//查看掉落     
		private var m_chestItemDrop:ChestItemDropView;
		
		private var m_heroType:int;
		
		private var m_itemDropList:Array;
		
		private var m_effectList:Array=new Array();
		
		private var m_closeWin:Boolean;
		
		private var m_itemArr:Array;
		
		private var m_drawCallEffectList:Array;
		
		private var m_isShowCard:Boolean;
		
		/**打折信息*/
		private var exploration_sale;
		
		
		public function ChestsMainView()
		{
			super();
		}
		
		/**布局*/
		override public function onStageResize():void
		{
			view.top_box.width = view.width = Laya.stage.width;
			view.height = Laya.stage.height;
			var delScale:Number = LayerManager.fixScale;
			if(delScale > 1){
				this.view.bg.scale(delScale,delScale);
			}
			
			view.middle_box.y = (view.height - view.middle_box.height) / 2;
			
			// 可见时
			if(view.showBgBox.visible){
				resizeShowBgImage();
			}
			
			view.bottom_box.y = view.height - view.bottom_box.height; 
			
		}
		
		/**初始化UI*/
		override public function createUI():void
		{
			m_drawCallEffectList=new Array();
			GameConfigManager.intance.InitDrawCardParam();
			//			this._view.mouseThrough = true;
			//			this.mouseThrough = true;
			this.addChild(view);
			this.view.DrawRuleView.visible=false;
			this.view.ChestItemDrop.visible=false;
			this.view.ShowPlayerBox.visible=false;
			this.view.showBgBox.visible=false;
			//			onStageResize();
			
			//			AndroidPlatform.instance.FGM_CustumEvent("ceshi");
			
			this.view.NextLevelBtn.visible = this.view.PreviousLevelBtn.visible = false;
			this.view.NextLevelTipsText.visible = this.view.NextLevelText.visible = false;
			
		}
		
		override public function show(...args):void
		{
			m_closeWin=true;
			m_isShowCard=false;
			m_heroList=new Array();
			m_itemArr=new Array();
			super.show(args);
			setStage();
			WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD_INFO,[]);
			
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.ENTER_LOTTER_VIEW);
			}
			
			// 首先布局一下
			this.timerOnce(100, this, onStageResize);
		}
		
		override public function close():void{
			m_chestsMainShowView && m_chestsMainShowView.resetAni();
			super.close();
			if(!User.getInstance().hasFinishGuide){
				XFacade.instance.disposeView(this);
			}
		}
		
		override public function dispose():void{
			Laya.loader.clearRes("chests/bg0.jpg");
			Laya.loader.clearRes("chests/bg1.png");
			Laya.loader.clearRes("chests/bg4.png");
			Laya.loader.clearRes("chests/bg6.png");
			super.dispose();
		}
		
		/**初始化ui数据*/
		private function initUI():void
		{
			
			m_nextDrawCardSRTime=m_drawCardSRMaxTime-m_drawCardVo.prop_1_card;
			m_stageType=DRAWCARD;
			m_drawCardType=m_drawCardTypeArr[1];
			WebSocketNetService.instance.sendData(ServiceConst.C_INFO,[]);
			setStage();
			m_cardItemList=new Array();
			m_Blevel=m_drawCardVo.use_level;
			m_BMaxLevel = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BOX);
			m_cardCostVo = GameConfigManager.CardCostList[(m_Blevel-1)];
			//抽卡三种品质初始化
			setDrawCardInfo();
			m_cardMaxIndex=4;
			
			
			initUIBtn();
			if(m_effectList.length==0)
			{
				setCardEffect();
			}
		}
		
		private function initUIBtn():void
		{
			this.view.NextLevelText.text=GameLanguage.getLangByKey("L_A_45027");
			this.view.PreviousLevelText.text=GameLanguage.getLangByKey("L_A_45026");
			this.view.ChannelBtn.text.text=GameLanguage.getLangByKey("L_A_45010");
			for (var i:int = 0; i < 10; i++) 
			{
				var l_image:Image=this.view.dom_times_box.getChildByName("scheduleImage0"+i.toString()) as Image;
				l_image.visible=false;
			}
			this.view.NextNumText.visible=false;
			this.view.OnceCostTxt.visible=false;
			this.view.OnceImage.visible=false;
			this.view.ChannelBtn.visible=false;
			this.view.TenTimeBtn.visible=false;
			this.view.TenTimesCostTxt.visible=false;
			this.view.TenTimeImage.visible=false;
			this.view.OnceBtn.visible=false;
			this.view.itemList.mouseThrough=true;
		}
		
		private function setDrawCardInfo():void
		{
			m_cardCostVo = GameConfigManager.CardCostList[(m_Blevel-1)];
			view.TitleText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45012"),m_Blevel);
			m_drawCardVo.cardCost=m_cardCostVo;
			m_cardItem0=new ChestMainCardItem(view.cardItem01,1,m_drawCardVo);
			//			m_cardItem0.width = 306;
			//			m_cardItem0.height = 393;
			m_cardItem1=new ChestMainCardItem(view.cardItem02,2,m_drawCardVo);
			
			m_cardItem2=new ChestMainCardItem(view.cardItem03,3,m_drawCardVo);
			if(m_Blevel>=m_BMaxLevel)
			{
				view.NextLevelBtn.gray=true;
				view.NextLevelBtn.mouseEnabled=false;
				view.NextLevelText.color="#afafaf";
				
				//				view.NextLevelTipsText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45013"),parseInt(m_Blevel+1));
			}
			else
			{
				view.NextLevelBtn.mouseEnabled=true;
				view.NextLevelBtn.gray=false;
				view.NextLevelText.color="#75d0ff";
			}
			
			// 下一级提示 (只是三级时不提示)
			if(m_Blevel === 3){
				view.NextLevelTipsText.text = "";
			}else {
				view.NextLevelTipsText.text = StringUtil.substitute(GameLanguage.getLangByKey("L_A_45013"), parseInt(m_Blevel+1));
			}
			
			// 向左按钮是否禁用判断
			if(m_Blevel==1)
			{
				view.PreviousLevelBtn.gray=true;
				view.PreviousLevelBtn.mouseEnabled=false;
			}
			else
			{
				view.PreviousLevelBtn.mouseEnabled=true;
				view.PreviousLevelBtn.gray=false;		
			}
			
			
			this.view.TextTips.text=GameLanguage.getLangByKey("L_A_"+parseInt(45015+m_Blevel));
			
			if(m_Blevel === 2){
				this.view.TextTips.text=GameLanguage.getLangByKey("L_A_45017");
				
			}else if(m_Blevel === 3){
				this.view.TextTips.text=GameLanguage.getLangByKey("L_A_45018");
				
			}
			
			setUserResourceInfo();
		}
		
		/**玩家资源信息设置*/
		private function setUserResourceInfo():void
		{
			var user:User = GlobalRoleDataManger.instance.user;
			var l_arr:Array=BagManager.instance.getItemListByIid(GameConfigManager.card_param.freeId);
			var l_costArr:Array=m_drawCardVo.cardCost.getNoCost(1,1,1);
			var l_id:int=m_drawCardVo.cardCost.getFreeCostId();
			var l_itemVo:ItemVo=GameConfigManager.items_dic[l_id];
			m_itemArr.push(l_id);
			this.view.CostImage0.skin= "appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			
			this.view.freeCostText.text=BagManager.instance.getItemNumByID(l_costArr[0]);
			var l_id:int=m_drawCardVo.cardCost.getCostId();
			l_itemVo=GameConfigManager.items_dic[l_id];
			m_itemArr.push(l_id);
			this.view.CostImage1.skin= "appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			
			this.view.chargeCostText.text=BagManager.instance.getItemNumByID(l_id);
			l_itemVo=GameConfigManager.items_dic[4];
			m_itemArr.push(4);
			//			this.view.CostImage2.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			//			this.view.GoldCostText.text=XUtils.formatResWith(user.gold);
			//			this.view.CostImage2.mouseEnabled=this.view.CostImage0.mouseEnabled=this.view.CostImage1.mouseEnabled=true;
			
			l_itemVo=GameConfigManager.items_dic[1];
			m_itemArr.push(1);
			this.view.CostImage3.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			this.view.PayCostText.text=XUtils.formatResWith(user.water);
			this.view.CostImage3.mouseEnabled=this.view.CostImage0.mouseEnabled=this.view.CostImage1.mouseEnabled=true;			
		}
		
		override public function addEvent():void
		{
			this.on(Event.CLICK, this, this.onClickHandler);	
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD),this,onResult,[ServiceConst.DRAW_CARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD_CHANGELEVEL),this,onResult,[ServiceConst.DRAW_CARD_CHANGELEVEL]);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE,this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT,this,baginit,[BagEvent.BAG_EVENT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult,[ServiceConst.C_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD_INFO), this, onResult, [ServiceConst.DRAW_CARD_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SUPER_DRAW_CARD), this, onResult, [ServiceConst.SUPER_DRAW_CARD]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.SUPER_DRAW_CARD_ONE), this, onResult, [ServiceConst.SUPER_DRAW_CARD_ONE]);
		}
		
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK, this, this.onClickHandler);
			ProTipUtil.removeTip(view.ChestItemDrop.HeroProperty);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT,this,baginit);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE,this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD_CHANGELEVEL),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.DRAW_CARD_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SUPER_DRAW_CARD), this, onResult, [ServiceConst.SUPER_DRAW_CARD]);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.SUPER_DRAW_CARD_ONE), this, onResult, [ServiceConst.SUPER_DRAW_CARD_ONE]);
		}
		
		private function baginit():void
		{
			// TODO Auto Generated method stub
			setUserResourceInfo();
			setDrawCardInfo();
		}
		
		/**点击事件的监听*/
		private function onClickHandler(e:Event):void
		{
			switch(e.target){
				case this.view.ReturnBtn:
					this.view.DrawRuleView.visible=true;
					var l_str:String=GameLanguage.getLangByKey("L_A_45036");
					l_str = l_str.replace(/##/g, "\n");
					
					this.view.DrawRuleView.RuleText.text=l_str;
					break;
				case this.view.closeBtn:
					m_closeWin=true;
					this.close();
					break;
				case this.view.OnceBtn:
					if(getCanDrawCard(1)==true)
					{
						this.view.TenTimeBtn.visible=true;
						this.view.ChannelBtn.visible=true;
						this.view.TenTimeImage.visible=true;
						this.view.TenTimesCostTxt.visible=true;
						view.OnceBgImage.visible=true;
						WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,[m_drawCardType+"1"]);
						m_DardCardType=1;
						setDrawCardNumTip();
					}
					break;
				case this.view.TenTimeBtn:
					if(m_DardCardType==1)
					{
						m_DardCardType=1;
						if(getCanDrawCard(1))
						{
							this.view.TenTimeBtn.visible=true;
							this.view.ChannelBtn.visible=true;
							this.view.TenTimeImage.visible=true;
							this.view.TenTimesCostTxt.visible=true;
							view.OnceBgImage.visible=true;
							WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["free_prop_1"]);
						}
					}
					else if(m_DardCardType==2)
					{
						m_DardCardType=2;
						if(getCanDrawCard(10))
						{
							view.OnceBgImage.visible=false;
							WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["free_prop_10"]);
						}
					}
					else if(m_DardCardType==3)
					{
						m_DardCardType=3;
						if(getCanDrawCard(1))
						{
							this.view.TenTimeBtn.visible=true;
							this.view.ChannelBtn.visible=true;
							this.view.TenTimeImage.visible=true;
							this.view.TenTimesCostTxt.visible=true;
							view.OnceBgImage.visible=true;
							WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["water_1"]);
						}
					}
					else if(m_DardCardType == 4)
					{
						m_DardCardType=4;
						if(getCanDrawCard(10))
						{
							view.OnceBgImage.visible=false;
							WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["water_10"]);
						}
					}else if (m_DardCardType == 5)
					{
						m_DardCardType=5;
						if(getCanDrawCard(10))
						{
							view.OnceBgImage.visible=false;
							WebSocketNetService.instance.sendData(ServiceConst.SUPER_DRAW_CARD);
						}
					}else if (m_DardCardType == 6)
					{
						m_DardCardType=6;
						if(getCanDrawCard(10))
						{
							this.view.TenTimeBtn.visible=true;
							this.view.ChannelBtn.visible=true;
							this.view.TenTimeImage.visible=true;
							this.view.TenTimesCostTxt.visible=true;
							view.OnceBgImage.visible=true;
							WebSocketNetService.instance.sendData(ServiceConst.SUPER_DRAW_CARD_ONE);
						}
					}
					onSetDrawCardBtn();
					
					break;
				case this.view.ChannelBtn:
					m_stageType=DRAWCARD;
					setStage();
					initUIBtn();
					break
				case this.view.cardItem01:
					m_cardItem0.selectCard();
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.SELECT_NORMAL_LOTTER);
					}
					break;
				case this.view.cardItem02:
					m_cardItem1.selectCard();
					break;
				case this.view.cardItem03:
					m_cardItem2.selectCard();
					break;
				case this.view.cardItem01.OnceBtn:
					m_DardCardType=1;
					if(getCanDrawCard(1))
					{
						this.view.TenTimeBtn.visible=true;
						this.view.ChannelBtn.visible=true;
						this.view.TenTimeImage.visible=true;
						this.view.TenTimesCostTxt.visible=true;
						view.OnceBgImage.visible=true;
						setBtnType(false);
						WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["free_prop_1"]);
					}
					break;
				case this.view.cardItem01.TenTimeBtn:
					m_DardCardType=2;
					if(getCanDrawCard(10))
					{
						view.OnceBgImage.visible=false;
						setBtnType(false);
						WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["free_prop_10"]);
					}
					break;
				case this.view.cardItem02.OnceBtn:
					m_DardCardType=3
					if(getCanDrawCard(1))
					{
						this.view.TenTimeBtn.visible=true;
						this.view.ChannelBtn.visible=true;
						this.view.TenTimeImage.visible=true;
						this.view.TenTimesCostTxt.visible=true;
						view.OnceBgImage.visible=true;
						setBtnType(false);
						WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["water_1"]);
					}
					break;
				case this.view.cardItem02.TenTimeBtn:
					m_DardCardType=4
					if(getCanDrawCard(10))
					{	
						view.OnceBgImage.visible=false;
						setBtnType(false);
						WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["water_10"]);
					}
					break;
				case this.view.cardItem03.OnceBtn:
					m_DardCardType=6;
					if(getCanDrawCard(1))
					{
						this.view.TenTimeBtn.visible=true;
						this.view.ChannelBtn.visible=true;
						this.view.TenTimeImage.visible=true;
						this.view.TenTimesCostTxt.visible=true;
						view.OnceBgImage.visible=true;
						setBtnType(false);
						WebSocketNetService.instance.sendData(ServiceConst.SUPER_DRAW_CARD_ONE);
					}
					break;
				case this.view.cardItem03.TenTimeBtn:
					m_DardCardType=5;
					if(getCanDrawCard(10))
					{	
						view.OnceBgImage.visible=false;
						setBtnType(false);
						WebSocketNetService.instance.sendData(ServiceConst.SUPER_DRAW_CARD);
					}
					break;
				case this.view.ChestItemDrop.CloseBtn:
					this.view.ChestItemDrop.visible=false;
					break;
				case this.view.ShowPlayerBox.ShadowBox:
					setTransitionItemList();
					break;
				case this.view.ShowBgImage:
					m_isShowCard=true;
					this.view.TenTimeBtn.visible=true;
					this.view.ChannelBtn.visible=true;
					this.view.TenTimeImage.visible=true;
					this.view.TenTimesCostTxt.visible=true;
					break;
				case this.view.PreviousLevelBtn:
					WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD_CHANGELEVEL,[m_Blevel-1]);
					break;
				case this.view.NextLevelBtn:
					WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD_CHANGELEVEL,[m_Blevel+1]);
					break;
				case this.view.cardItem01.CheckBtn:
					var l_vo:CardPvwVo=GameConfigManager.CardPvwList[m_Blevel-1];
					var l_arr:Array=l_vo.getFree();
					m_itemDropList=l_arr;
					openItemDropView(l_arr);
					onClickChestItemDrop(6);
					break;
				case this.view.cardItem02.CheckBtn:
					var l_vo:CardPvwVo=GameConfigManager.CardPvwList[m_Blevel-1];
					var l_arr:Array=l_vo.getPay();
					m_itemDropList=l_arr;
					openItemDropView(l_arr);
					onClickChestItemDrop(6);
					break;
				case this.view.cardItem03.CheckBtn:
					var l_vo:CardPvwVo=GameConfigManager.CardPvwList[m_Blevel-1];
					var l_arr:Array=l_vo.getHigh();
					m_itemDropList=l_arr;
					openItemDropView(l_arr);
					onClickChestItemDrop(6);
					break;
				case this.view.ChestItemDrop.btn_0:
					onClickChestItemDrop(6);
					break;
				case this.view.ChestItemDrop.btn_1:
					onClickChestItemDrop(1);
					break;
				case this.view.ChestItemDrop.btn_2:
					onClickChestItemDrop(2);
					break;
				case this.view.ChestItemDrop.btn_3:
					onClickChestItemDrop(3);
					break;
				case this.view.ChestItemDrop.btn_4:
					onClickChestItemDrop(4);
					break;
				case this.view.ChestItemDrop.btn_5:
					onClickChestItemDrop(5);
					break;
				case this.view.DrawRuleView.CloseBtn:
					this.view.DrawRuleView.visible=false;
					break;
				case this.view.CostImage0:
					ItemTips.showTip(m_itemArr[0]);
					break;
				case this.view.CostImage1:
					ItemTips.showTip(m_itemArr[1]);
					break;
				//				case this.view.CostImage2:
				//					ItemTips.showTip(m_itemArr[2]);
				//					break;
				case this.view.CostImage3:
					ItemTips.showTip(m_itemArr[3]);
					break;
				default:
					if(m_chestItemDrop!=null)
					{
						if(view.ChestItemDrop.visible==true)
						{
							m_chestItemDrop.onClickSkill();
						}	
					}
					if(m_chestsMainShowView!=null)
					{
						if(this.view.ShowPlayerBox.visible==true)
						{
							m_chestsMainShowView.onClickSkill();
						}	
					}
					break;
			}
		}
		
		
		private function setBtnType(p_bool:Boolean):void
		{
			this.view.cardItem01.OnceBtn.mouseEnabled=p_bool;
			this.view.cardItem01.TenTimeBtn.mouseEnabled=p_bool;
			this.view.cardItem02.OnceBtn.mouseEnabled=p_bool;
			this.view.cardItem02.TenTimeBtn.mouseEnabled=p_bool;
		}
		
		
		/**
		 * 
		 */
		private function onClickChestItemDrop(p_index:int):void
		{
			m_heroType=p_index;
			this.view.ChestItemDrop.btn_0.selected=(m_heroType==6);
			this.view.ChestItemDrop.btn_1.selected=(m_heroType==1);
			this.view.ChestItemDrop.btn_2.selected=(m_heroType==2);
			this.view.ChestItemDrop.btn_3.selected=(m_heroType==3);
			this.view.ChestItemDrop.btn_4.selected=(m_heroType==4);
			this.view.ChestItemDrop.btn_5.selected=(m_heroType==5);
			if(m_heroType==6)
			{
				this.view.ChestItemDrop.TitleText.text=GameLanguage.getLangByKey("L_A_45019");
			}
			else if(m_heroType==1)
			{
				this.view.ChestItemDrop.TitleText.text=GameLanguage.getLangByKey("L_A_45021");
			}
			else if(m_heroType==2)
			{
				this.view.ChestItemDrop.TitleText.text=GameLanguage.getLangByKey("L_A_45022");
			}
			else if(m_heroType==3)
			{
				this.view.ChestItemDrop.TitleText.text=GameLanguage.getLangByKey("L_A_45023");
			}
			else if(m_heroType==4)
			{
				this.view.ChestItemDrop.TitleText.text=GameLanguage.getLangByKey("L_A_45024");
			}
			else if(m_heroType==5)
			{
				this.view.ChestItemDrop.TitleText.text=GameLanguage.getLangByKey("L_A_45020");
			}
			onSortList();
		}
		
		/**
		 * 
		 */
		private function onSortList()
		{
			var l_arr:Array=new Array();
			if(m_heroType==6)
			{
				l_arr=m_itemDropList;
			}
			for (var i:int = 0; i < m_itemDropList.length; i++) 
			{
				var l_fight:FightUnitVo=m_itemDropList[i];
				if(m_heroType==5)
				{
					if(l_fight.unit_type==1)
					{	
						l_arr.push(l_fight);
					}
				}
				else
				{
					if(l_fight.defense_type==m_heroType)
					{
						l_arr.push(l_fight);
					}
				}
			}
			m_chestItemDrop.setHeroList(l_arr);
			onSelect(0);
		}
		
		/**
		 * 设置按钮
		 */
		private function onSetDrawCardBtn():void
		{
			var l_arr:Array=new Array();
			if(m_DardCardType==1)
			{
				l_arr=m_drawCardVo.cardCost.getCost(1,1);
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45007");
			}
			else if(m_DardCardType==2)
			{//十连抽1
				this.view.TenTimeBtn.visible=false;
				this.view.ChannelBtn.visible=false;
				this.view.TenTimeImage.visible=false;
				this.view.TenTimesCostTxt.visible=false;
				l_arr=m_drawCardVo.cardCost.getCost(1,2);
				if(exploration_sale.length !=0 && Number(exploration_sale[1].discount)){
					l_arr[1] *= (Number(exploration_sale[1].discount/100));
				}
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45008");
			}
			else if(m_DardCardType==3)
			{
				l_arr=m_drawCardVo.cardCost.getCost(2,1);
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45007");
			}
			else if(m_DardCardType==4)
			{//十连抽2
				this.view.TenTimeBtn.visible=false;
				this.view.ChannelBtn.visible=false;
				this.view.TenTimeImage.visible=false;
				this.view.TenTimesCostTxt.visible=false;
				l_arr=m_drawCardVo.cardCost.getCost(2,2);
				if(exploration_sale.length !=0 && Number(exploration_sale[2].discount)){
					l_arr[1] *= (Number(exploration_sale[2].discount/100));
				}
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45008");
			}else if(m_DardCardType==5)
			{//十连抽3
				this.view.TenTimeBtn.visible=false;
				this.view.ChannelBtn.visible=false;
				this.view.TenTimeImage.visible=false;
				this.view.TenTimesCostTxt.visible=false;
				l_arr=m_drawCardVo.cardCost.getCost(3,2);
				if(exploration_sale.length !=0 && Number(exploration_sale[3].discount)){
					l_arr[1] *= (Number(exploration_sale[3].discount/100));
				}
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45008");
			}
			else if(m_DardCardType==6)
			{//抽奖3的单抽
				l_arr=m_drawCardVo.cardCost.getCost(3,1);
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45007");
			}
			var l_itemVo:ItemVo=GameConfigManager.items_dic[l_arr[0]];
			this.view.TenTimeImage.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			this.view.TenTimesCostTxt.text=l_arr[1];
		}
		
		/**
		 * 
		 */
		private function openItemDropView(p_arr:Array):void
		{
			this.view.ChestItemDrop.visible=true;
			m_chestItemDrop=new ChestItemDropView(view.ChestItemDrop,p_arr);
			view.ChestItemDrop.HeroList.selectHandler=new Handler(this, onSelect);
			view.ChestItemDrop.SelectList.mouseHandler = new Handler(this, this.onSelectHandler);
			view.ChestItemDrop.HeroList.selectedIndex=0;
			onSelect(0);
		}
		
		
		private function onSelectHandler(e:Event,index:int):void
		{
			if(e.type != Event.CLICK){
				return;
			}
			var _selectedItem:UnitItem = view.ChestItemDrop.SelectList.getCell(index) as UnitItem;
			var data:UnitItemVo = _selectedItem.data;
			if(data){
				if(XUtils.checkHit(_selectedItem.attackIcon)){
					ProTipUtil.showAttTip(_selectedItem.data.id);
				}else if(XUtils.checkHit(_selectedItem.defendIcon)){
					ProTipUtil.showDenTip(_selectedItem.data.id);
				}else{
					
				}		
			}
		}
		
		/**
		 * 选择列表控件
		 */
		private function onSelect(p_index:int):void
		{
			if(view.ChestItemDrop.HeroList.length<=0)
			{
				return;
			}
			for (var i:int = 0; i < view.ChestItemDrop.HeroList.array.length; i++) 
			{
				var l_cell:TrainItem=view.ChestItemDrop.HeroList.getCell(i);
				if(l_cell!=null)
				{
					l_cell.selected=false;
				}
			}
			var l_cell:TrainItem=view.ChestItemDrop.HeroList.getCell(p_index);
			var l_data:FightUnitVo=view.ChestItemDrop.HeroList.getItem(p_index);
			l_cell.selected=true;
			m_chestItemDrop.getIItemInfo(l_data);
		}
		
		
		/**判断是否可以抽卡*/
		private function getCanDrawCard(p_type:int):Boolean
		{
			var user:User = GlobalRoleDataManger.instance.user;
			var l_num=0;
			var l_name:String="";
			var l_arr:Array;
			if(m_DardCardType==1)
			{
				l_arr=m_cardCostVo.getCost(1,1);
				m_onceCostNum=parseInt(l_arr[1]);
			}
			else if(m_DardCardType==2)
			{
				l_arr=m_cardCostVo.getCost(1,2);
				m_tenTimeNum=parseInt(l_arr[1]);
			}
				
			else if(m_DardCardType==3)
			{
				l_arr=m_cardCostVo.getCost(2,1);
				m_onceCostNum=parseInt(l_arr[1]);
				
			}
			else if(m_DardCardType==4)
			{
				l_arr=m_cardCostVo.getCost(2,2);
				m_tenTimeNum=parseInt(l_arr[1]);
			}else if(m_DardCardType==5)
			{
				//第三个的十连抽
				l_arr=m_cardCostVo.getCost(3,2);
				m_tenTimeNum=parseInt(l_arr[1]);
			}else if(m_DardCardType==6)
			{
				//第三个的单抽
				l_arr=m_cardCostVo.getCost(3,1);
				m_onceCostNum=parseInt(l_arr[1]);
			}
			
			if(l_arr[0]!=1&&l_arr[0]!=4)
			{
				l_num=BagManager.instance.getItemNumByID(l_arr[0]);
				l_name=GameConfigManager.items_dic[l_arr[0]].name;
			}
			else if(l_arr[0]==1)
			{
				l_num=user.water;
				l_name="水";
			}
			else if(l_arr[0]==4)
			{
				l_num=user.gold;
				l_name=GameConfigManager.items_dic[l_arr[0]].name;
			}
			
			if(p_type==1)
			{
				if(l_num>=m_onceCostNum)
				{
					return true;
				}
			}
			else if(p_type==10)
			{
				if(l_num>=m_tenTimeNum)
				{
					return true;
				}
			}
			var itemD:ItemData=new ItemData();
			itemD.iid=l_arr[0];
			itemD.inum=l_arr[1];
			if(l_arr[0]==1)
			{
				XFacade.instance.openModule(ModuleName.ChargeView);
			}
			else
			{
				ConsumeHelp.Consume([itemD],Handler.create(this,gotoSendStartBack));
			}
			return false;
		}
		
		private function gotoSendStartBack():void
		{
			// TODO Auto Generated method stub
			if(m_DardCardType==1)
			{
				view.OnceBgImage.visible=true;
				WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["free_prop_1"]);
			}
			else if(m_DardCardType==2)
			{
				view.OnceBgImage.visible=false;
				WebSocketNetService.instance.sendData(ServiceConst.DRAW_CARD,["free_prop_10"]);
			}
		}
		
		/**根据抽卡的次数改变十连抽按钮的显示*/
		private function setDrawCardNumTip()
		{
			if(m_DardCardType==1)
			{
				if(m_drawCardVo.prop_1_card<=0)
				{
					m_drawCardVo.prop_1_card=10;		
				}
				m_drawCardVo.prop_1_card--;
			}
			else if(m_DardCardType==3)
			{
				if(m_drawCardVo.water_1_card<=0)
				{
					m_drawCardVo.water_1_card=10;
				}
				m_drawCardVo.water_1_card--;
				
				view.NextNumText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45009"),(m_drawCardVo.water_1_card+1));
				view.NextNumText.visible=true;
				var l_index:int=m_drawCardSRMaxTime-m_drawCardVo.water_1_card;
				for(var i:int=0;i<10;i++)
				{
					var l_image:Image=this.view.dom_times_box.getChildByName("scheduleImage0"+i.toString()) as Image;
					l_image.visible=true;
					if((l_index-1)>i)
					{
						l_image.skin="chests/progress11.png";
					}
					else
					{
						l_image.skin="chests/progressbg.png";
					}
				}
			}
		}
		
		/**设置页面状态*/
		private function setStage():void
		{
			if(m_stageType==1)
			{
				this.view.ChannelBtn.visible=false;
				this.view.showBgBox.visible=false;
				this.view.TextTips.visible=true;
				this.view.itemList.visible=false;
				this.view.TipImage.visible=true;
				this.view.iconImage.visible=true;
				this.view.ShowPlayerBox.visible=false;
				this.view.OnceImage.visible=true;
				this.view.OnceCostTxt.visible=true;
				this.view.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45008");
				this.view.OnceitemList.visible=false;
				this.view.specialItemList.visible=false;
				m_DardCardType=0;
				setBtnText();
			}
			else
			{
				//				this.view.ChannelBtn.visible=true;
				this.view.showBgBox.visible=true;
				this.view.showBgBox.mouseEnabled = this.view.showBgBox.mouseThrough = true;
				
				// 第二个背景图显示出来需要计算大小及坐标
				resizeShowBgImage();
				
				this.view.itemList.visible=true;
				this.view.TipImage.visible=false;
				this.view.iconImage.visible=false;
				this.view.TextTips.visible=false;
				this.view.OnceImage.visible=false;
				this.view.OnceCostTxt.visible=false;
			}
		}
		
		/**
		 * 重新布局第二层背景图 
		 * 
		 */
		private function resizeShowBgImage():void{
			var showbgimage:Image = this.view.ShowBgImage;
			var middle_box = this.view.middle_box;
			
			var rate = Math.max(this.stage.width / showbgimage.width, this.stage.height / showbgimage.height);
			
			showbgimage.scale(rate, rate);
			showbgimage.pos(-middle_box.x, -middle_box.y);
			
		}
		
		public function setBtnText():void
		{
			var l_id:int=0;
			switch(m_selectCardIndex)
			{
				case 1:
					m_onceCostNum=GameConfigManager.card_param.freeCostOnce;
					m_tenTimeNum=GameConfigManager.card_param.freeCostTen;
					l_id=GameConfigManager.card_param.freeId;
					if(exploration_sale.length !=0 && Number(exploration_sale[1].discount)){
						m_tenTimeNum *= (Number(exploration_sale[1].discount/100));
					}
					break;
				case 2:
					m_onceCostNum=GameConfigManager.card_param.waterCostOnce;
					m_tenTimeNum=GameConfigManager.card_param.waterCostTen ;
					l_id=GameConfigManager.card_param.waterId;
					if(exploration_sale.length !=0 && Number(exploration_sale[2].discount)){
						m_tenTimeNum *= (Number(exploration_sale[2].discount/100));
					}
					break;
				case 3:
					m_onceCostNum=GameConfigManager.card_param.waterCostOnce;
					m_tenTimeNum=GameConfigManager.card_param.waterCostTen;
					l_id=GameConfigManager.card_param.waterId;
					if(exploration_sale.length !=0 && Number(exploration_sale[3].discount)){
						m_tenTimeNum *= (Number(exploration_sale[3].discount/100));
					}
					break;
			}
			this.view.iconImage.skin= "appRes/icon/itemIcon/"+l_id+".png";
			this.view.iconImage1.skin= "appRes/icon/itemIcon/"+l_id+".png";
			this.view.OnceImage.skin= "appRes/icon/itemIcon/"+l_id+".png";
			this.view.TenTimeImage.skin= "appRes/icon/itemIcon/"+l_id+".png";
			this.view.OnceCostTxt.text=m_onceCostNum;
			this.view.TenTimesCostTxt.text=m_tenTimeNum;
		}
		
		/**获取服务器消息*/
		private function onResult(cmd:int, ...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.DRAW_CARD:
				{
					//					m_isShowCard=false;
					setBtnType(true);
					m_closeWin=false;
					setDrawCardNumTip();
					onSetDrawCardBtn();
					setDrawCardItem(args);
					setDrawCardInfo();
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.GET_LOTTER_RESULT);
					}
					break;
				}
				case ServiceConst.DRAW_CARD_INFO:
				{
					var l_drawCardVo:DrawCardVo=new DrawCardVo();
					var l_info:Object=args[1];
					l_drawCardVo.first_prop_10=l_info.first_prop_10;
					l_drawCardVo.first_water_10=l_info.first_water_10;
					l_drawCardVo.prop_1_card=l_info.prop_1_card;
					l_drawCardVo.water_1_card=l_info.water_1_card;
					l_drawCardVo.use_level=l_info.use_level;
					exploration_sale = l_drawCardVo.exploration_sale=l_info.exploration_sale;
					l_drawCardVo.template_info=l_info.template_info;
					m_drawCardVo=l_drawCardVo;
					initUI();
					break;
				}
				case ServiceConst.DRAW_CARD_CHANGELEVEL:
				{
					
					m_Blevel=args[1];
					m_drawCardVo.use_level=m_Blevel;
					var l_info:Object=args[2];
					m_drawCardVo.prop_1_card=l_info.prop_1_card;
					m_drawCardVo.water_1_card=l_info.water_1_card;
					setDrawCardInfo();
					break;
				}
				case ServiceConst.SUPER_DRAW_CARD:
				{
					//					trace("aaaaaaaaaaa");
					//					m_isShowCard=true;
					setBtnType(true);
					m_closeWin=false;
					setDrawCardNumTip();
					onSetDrawCardBtn();
					setDrawCardItem(args);
					setDrawCardInfo();
					
					m_DardCardType=5;
					
					break;
				}
				case ServiceConst.SUPER_DRAW_CARD_ONE:
				{
					//					m_isShowCard=true;
					setBtnType(true);
					m_closeWin=false;
					setDrawCardNumTip();
					onSetDrawCardBtn();
					setDrawCardItem(args);
					setDrawCardInfo();
					
					m_DardCardType=6;
					
					break;
				}
				case ServiceConst.C_INFO:
				{
					var l_c_info:Object=args[1];
					var fvo:Object
					var srcList:Array;//静态数据源
					var heroList:Array;
					srcList = GameConfigManager.getUnitList(FightUnitVo.SOLDIER);
					heroList=GameConfigManager.getUnitList(FightUnitVo.HERO);
					for(var m:int=0; m<heroList.length; m++){
						//如果在返回数据中
						fvo = heroList[m];
						if (l_c_info.hero_list[fvo.unit_id + ""])
						{
							m_heroList.push(fvo.unit_id)
						}
					}
					for (var m:int = 0; m < srcList.length; m++)
					{
						fvo = srcList[m];
						if(l_c_info.solier_list[fvo.unit_id+""]){
							m_heroList.push(fvo.unit_id);
						}
					}
					break;
				}
			}
		}
		
		/**抽卡消息处理*/
		private function setDrawCardItem(...args):void
		{
			m_display_rewards=new Array();
			m_add_result=new Array();
			this.view.itemList.array=null;
			this.view.itemList.refresh();
			m_drawInfo=args[0][1];
			var display_rewards:Array=m_drawInfo.display_rewards;
			m_addNumLength=display_rewards.length;
			m_stageType=SHOWCARDLIST;
			setStage();
			this.view.itemList.itemRender=DrawCardItemCell;
			this.view.OnceitemList.itemRender=DrawCardItemCell;
			this.view.specialItemList.itemRender=DrawCardItemCell;
			this.view.itemList.renderHandler = new Handler(this, updateHeroItem);
			this.view.OnceitemList.renderHandler=new Handler(this,updateHeroItem);
			this.view.specialItemList.renderHandler=new Handler(this,updateHeroItem)
			m_index=0;
			updateItemList();
			setUserResourceInfo();
		}
		
		private function updateHeroItem(p_cell:DrawCardItemCell,p_index:int):void
		{
			// TODO Auto Generated method stub
			var l_list:List;
			if(m_DardCardType==1&&m_DardCardType==3)
			{
				l_list=this.view.OnceitemList;
			}
			else
			{
				l_list=this.view.itemList;
			}
			
			//trace("updateHeroItem_   "+p_index);
			if(m_isShowCard==false)
			{
				if(m_display_rewards.length>1)
				{
					if(this.view.itemList.array.length-1==p_index)
					{
						p_cell.setDrawCell();
						setDrawCallEffect(p_cell,p_index);
					}
				}
				else
				{
					p_cell.setDrawCell();
					setDrawCallEffect(p_cell,p_index);
				}
			}
			
		}
		
		/**更新抽卡列表*/
		private function updateItemList():void
		{
			//			trace("bbbbbbbbbbbbbb");
			var l_str:String=m_drawInfo.display_rewards[m_index];
			var l_arr:Array=l_str.split("=");
			var l_itemData:ItemData=new ItemData();
			var l_itemVO:ItemVo=GameConfigManager.items_dic[l_arr[0]];
			var l_unitVO:FightUnitVo=GameConfigManager.unit_json[l_itemVO.param1];
			l_itemData.iid=l_arr[0];
			l_itemData.inum=l_arr[1];
			m_display_rewards.push(l_itemData);
			if(m_DardCardType==1 || m_DardCardType==3||m_DardCardType==6)
			{
				this.view.OnceitemList.array=m_display_rewards;
				this.view.OnceitemList.visible=true;
				this.view.itemList.visible=false;
				this.view.specialItemList.visible=false;
			}
			else if(m_DardCardType==2 || m_DardCardType==4 || m_DardCardType==5)
			{
				this.view.itemList.array=m_display_rewards;
				this.view.OnceitemList.visible=false;
				this.view.itemList.visible=true;
				this.view.specialItemList.visible=false;
			}
			if((m_DardCardType==1 && m_index==1) || (m_DardCardType==3 && m_index==1) ||(m_DardCardType==2 && m_index==10)|| (m_DardCardType==4 && m_index==10)
				|| (m_DardCardType==5 && m_index==10)||(m_DardCardType==6 && m_index==1))
			{
				var l_arr1:Array=new Array();
				l_arr1.push(l_itemData);
				this.view.specialItemList.visible=true;
				this.view.specialItemList.array=l_arr1;
			}
			if(l_unitVO!=null && (l_itemData.vo.type==14 || l_itemData.vo.type==15)&&l_itemData.vo.subType==2)
			{
				if(m_chestsMainShowView!=null)
				{
					m_chestsMainShowView.removeAction();
				}
				if(m_closeWin==false)
				{
					//					trace("m_isShowCard:"+m_isShowCard);
					//					if(m_DardCardType==5)
					//					{
					//						setTransitionItemList();
					//					}else
					//					{
					//						
					//					}
					if(m_isShowCard==false)
					{
						m_chestsMainShowView=new ChestsMainShowView(this.view.ShowPlayerBox,l_unitVO,m_selectCardIndex);
						this.view.ShowPlayerBox.visible=true;
					}
					else
					{
						setTransitionItemList();
					}
					//					setTransitionItemList();
				}
			}
			else
			{
				updateItemHandler();
			}
		}
		
		
		public function selectCard1():void
		{
			if(m_cardItem0!=null)
			{
				m_cardItem0.selectCard();
			}
			
		}
		
		private function setCardEffect():void
		{
			if(m_effectList.length==9)
			{
				return;
			}
			if(m_effectList.length<3)
			{
				setEffect(0,m_effectList.length);
			}
			else
			{
				setEffect(1,m_effectList.length-3);
			}
		}
		
		private function setEffect(p_type:int,p_num:int):void
		{
			var l_type:int=Math.round(Math.random());
			var l_effect=new Animation();
			var jsonStr:String;
			if(l_type==1)
			{
				jsonStr = "appRes/atlas/effects/star.json";	
			}
			else
			{
				jsonStr = "appRes/atlas/effects/dot.json";
			}
			l_effect.autoPlay=true;
			l_effect.loadAtlas(jsonStr);
			if(p_type==0)
			{
				view.cardItem01.CardImage.addChild(l_effect);
			}
			else
			{
				view.cardItem02.CardImage.addChild(l_effect);
			}
			l_effect.interval = 20*p_num;
			if(p_num==0)
			{
				l_effect.x=100;
				l_effect.y=50;
			}
			else if(p_num==1)
			{
				l_effect.x=300;
				l_effect.y=180;
			}
			else if(p_num==2)
			{
				l_effect.x=60;
				l_effect.y=130;
			}
			else if(p_num==3)
			{
				l_effect.x=70;
				l_effect.y=100;
			}
			else
			{
				l_effect.x=200;
				l_effect.y=200;
			}
			m_effectList.push(l_effect);
			timer.once(500,this,setCardEffect);
		}
		
		
		/**兵种出现之后如果有了转换成碎片*/
		public function setTransitionItemList():void
		{
			trace("setTransitionItemList");
			this.view.ShowPlayerBox.visible=false;
			var l_str:String=m_drawInfo.display_rewards[m_index];
			var l_arr:Array=l_str.split("=");
			var ishas:Boolean=false;
			var itemVO:ItemVo=GameConfigManager.items_dic[l_arr[0]];
			//			var l_obj:Object=CampData.hasUnit(itemVO.param1);
			for(var i:int=0;i<m_heroList.length;i++)
			{
				if(m_heroList[i]==itemVO.param1)
				{
					ishas=true;
				}
			}
			var l_itemData:ItemData=new ItemData();
			l_itemData.iid=l_arr[0];
			if(ishas==true)
			{
				var l_data:FightUnitVo=GameConfigManager.unit_json[itemVO.param1];
				if(l_data.unit_type==1)
				{
					l_itemData.iid=parseInt(l_itemData.iid-1000);
					l_itemData.inum=itemVO.param2;
				}
				else
				{
					l_itemData.iid=parseInt(l_itemData.iid-5000);
					l_itemData.inum=itemVO.param2;
				}
			}
			else
			{
				l_itemData.inum=l_arr[1];
				m_heroList.push(itemVO.param1);
			}
			m_display_rewards[m_index]=l_itemData;
			updateItemHandler();
			if(m_DardCardType==1||m_DardCardType==3)
			{
				this.view.OnceitemList.array=m_display_rewards;
				this.view.OnceitemList.visible=true;
				this.view.itemList.visible=false;
				this.view.specialItemList.visible=false;
				this.view.OnceitemList.refresh();
			}
			else if(m_DardCardType==2||m_DardCardType==4 || m_DardCardType == 5)
			{
				this.view.itemList.array=m_display_rewards;
				this.view.OnceitemList.visible=false;
				this.view.itemList.visible=true;
				this.view.specialItemList.visible=false;
				this.view.itemList.refresh();
			}
			if((m_DardCardType==1 && m_index==1) || (m_DardCardType==2 && m_index==10)||(m_DardCardType==3 && m_index==1) || (m_DardCardType==4 && m_index==10)
				|| (m_DardCardType==5 && m_index==10))
			{
				var l_arr1:Array=new Array();
				l_arr1.push(l_itemData);
				this.view.specialItemList.visible=true;
				this.view.specialItemList.array=l_arr1;
			}
		}
		
		private function updateItemHandler():void
		{	
			if(m_index<m_addNumLength-1)
			{
				m_index++;
				if(m_isShowCard==false)
				{
					Laya.timer.once(300, this, updateItemList);
				}
				else
				{
					updateItemList();
				}
			}
			else
			{
				this.view.TenTimeBtn.visible=true;
				this.view.ChannelBtn.visible=true;
				this.view.TenTimeImage.visible=true;
				this.view.TenTimesCostTxt.visible=true;
			}
			if((m_DardCardType==1 && m_index==1) || (m_DardCardType==2 && view.itemList.array.length==10)||(m_DardCardType==3 && m_index==1) || 
				(m_DardCardType==4 && view.itemList.array.length==10)||(m_DardCardType==5 && view.itemList.array.length==10))
			{
				this.view.TenTimeBtn.visible=true;
				this.view.ChannelBtn.visible=true;
				this.view.TenTimeImage.visible=true;
				this.view.TenTimesCostTxt.visible=true;
			}
		}
		
		public function HideShowPlayerBox():void
		{
			//			m_isShowCard=true;
			setTransitionItemList();
		}
		
		
		private function setDrawCallEffect(p_cell:ItemCell,p_index:int):void
		{
			var l_effect:Animation;
			l_effect=new Animation();
			var jsonStr:String = "appRes/atlas/effects/drawCard.json";	
			l_effect.loadAtlas(jsonStr, null, "draw_call_effect");
			l_effect.play(0,false, "draw_call_effect");
			l_effect.once(Event.COMPLETE, this, function():void{
				l_effect.destroy(true);
			});
			this.view.middle_box.addChild(l_effect);
			var l:int=0;
			var h:int=p_index;
			if(p_index>=5)
			{
				l=1;
				h=p_index-5;
			}
			l_effect.x=p_cell.parent._parent.x-60+20*h+p_cell.width*h;
			l_effect.y=p_cell.parent._parent.y-60+60*l+p_cell.height*l;
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			if(cmd==ServiceConst.DRAW_CARD)
			{
				this.view.TenTimeBtn.visible=true;
				this.view.ChannelBtn.visible=true;
				this.view.TenTimeImage.visible=true;
				this.view.TenTimesCostTxt.visible=true;
			}
			XTip.showTip( GameLanguage.getLangByKey(errStr));
			setBtnType(true);
		}
		
		private function get view(): ChestsMainViewUI{
			return _view = _view || new ChestsMainViewUI();		
		}
	}
}