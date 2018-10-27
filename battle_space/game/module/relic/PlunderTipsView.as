package game.module.relic
{
	import game.global.vo.User;
	import laya.display.Text;
	import MornUI.relic.EscortSelectViewUI;
	import MornUI.relic.PlunderMainViewUI;
	import MornUI.relic.PlunderTipsViewUI;
	
	import game.common.ItemTips;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.event.TrainBattleLogEvent;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.ItemVo;
	import game.global.vo.relic.EnemieVo;
	import game.global.vo.relic.TransportPriceVo;
	import game.global.vo.relic.TransportVehicleVo;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	public class PlunderTipsView extends BaseDialog
	{
//		private var view:PlunderTipsViewUI;
		private var m_data:EnemieVo;
		private var m_transportVehicle:TransportVehicleVo;
		public function PlunderTipsView()
		{
			super();
//			view=p_ui;
//			m_data=p_data;
//			initUI();
		}
		
		override public function createUI():void
		{
			super.createUI();
			this._view = new PlunderTipsViewUI();
			this.addChild(_view);
		}
		
		override public function show(...args):void
		{
			super.show(args);
			m_data=args[0];
			initUI();
		}
		
		
		
		private function initUI():void
		{
			view.oldInfo.visible = false;
			
			view.NameText.text=m_data.userName;
			view.LevelText.text=GameLanguage.getLangByKey("L_A_73")+m_data.userLevel;
			view.MyVechlieText.visible=true;
			view.MyVechlieText.text=GameLanguage.getLangByKey("L_A_34024");
			view.CompteleBtn.text.text=GameLanguage.getLangByKey("L_A_34027");
			view.DetailBtn.text.text=GameLanguage.getLangByKey("L_A_34027");
			view.PlunderBtn.text.text=GameLanguage.getLangByKey("L_A_34030");
			view.CompteleBtn.mouseEnabled=true;
			view.DetailBtn.mouseEnabled=true;
			view.PlunderBtn.mouseEnabled=true;
			view.BtnBox.mouseEnabled=true;
			view.BtnBox.mouseThrough=true;
			view.BgImage.mouseEnabled=false;
			view.mouseThrough=true;
			this.view.FightingText.text=m_data.totalPower;
			this.timer.loop(1000,this,setTime);
			for (var i:int = 0; i < GameConfigManager.TransportVehicleList.length; i++) 
			{
				var l_vehicleVo:TransportVehicleVo=GameConfigManager.TransportVehicleList[i];
				if(l_vehicleVo.id==m_data.Vehicle)
				{
					this.view.VehicleImage.skin="appRes/Transport/"+l_vehicleVo.tupian+".png";
				}
			}
			
			
			if(m_data.isSelf==true)
			{
				view.BgImage.skin="common/bg_dialog_1s.png";
				view.CloseBtn.visible=false;
				view.NameText.visible=false;
				view.LevelText.visible=false;
				this.view.PlunderBtn.visible=false;
				view.PlayerBox.visible=true;
				view.RewardList.itemRender=ItemCell;
				view.RewardList.hScrollBarSkin="";
				view.RewardList.selectEnable = true;
				view.RewardList.selectHandler=new Handler(this, onHeroSelect);
				view.RewardList.array=getList(m_data.getItem);
				view.PlayerTimeText.text = TimeUtil.getTimeStr((m_data.endTime-m_data.nowTime) * 1000);
				
				this.view.PlunderBox.y = 121;
				view.oldInfo.visible = false;
				view.vipInfo.visible = true;
				view.TimeText.text="";
				
				if(m_data.endTime<=m_data.nowTime)
				{
					view.MyVechlieText.text=GameLanguage.getLangByKey("L_A_34026");
					this.view.CompteleBtn.visible=true;
					this.view.DetailBtn.visible=false;
					this.view.FightingIconImage.visible=false;
					this.view.FightingImage.visible=false;
					this.view.FightingText.visible=false;
					this.view.RewardTimeText.text=GameLanguage.getLangByKey("L_A_34072");
					this.view.GetRewardText.text=GameLanguage.getLangByKey("L_A_34073");
					this.view.RewardText.text=GameLanguage.getLangByKey("L_A_34075");
					this.view.RemainTimeText.text=GameLanguage.getLangByKey("L_A_34074");
				}
				else
				{
					this.view.CompteleBtn.visible=false;
					this.view.DetailBtn.visible=true;
					this.view.FightingIconImage.visible=true;
					this.view.FightingImage.visible=true;
					this.view.FightingText.visible=true;
					this.view.RewardTimeText.text=GameLanguage.getLangByKey("L_A_34072");
					this.view.GetRewardText.text=GameLanguage.getLangByKey("L_A_34073");
					this.view.RewardText.text=GameLanguage.getLangByKey("L_A_34075");
					this.view.RemainTimeText.text=GameLanguage.getLangByKey("L_A_34074");
				}
				if(m_data.lostItems!=null)
				{
					if(m_data.lostItems.length>0)
					{
						view.LostRewardList.itemRender=ItemCell;
						view.LostRewardList.hScrollBarSkin="";
						view.LostRewardList.selectEnable = true;
						view.LostRewardList.selectHandler=new Handler(this, onLostSelect);
						view.LostRewardList.array=getList(m_data.lostItems);		
					}
					else
					{
						view.LostRewardList.itemRender=ItemCell;
						view.LostRewardList.hScrollBarSkin="";
						view.LostRewardList.selectEnable = true;
						view.LostRewardList.selectHandler=new Handler(this, onLostSelect);
						view.LostRewardList.array=getList(m_data.getItem,0);
					}
				}
				
				view.vipInfo.visible = false;
				
				if (m_data.vipItems)
				{
					if (User.getInstance().VIP_LV > 3)
					{
						view.vipTips.visible = false;
						view.vipRewardList.gray = false;
					}
					else
					{
						view.vipTips.visible = true;
						view.vipRewardList.gray = true;
					}
					
					view.vipInfo.visible = true;
					view.vipRewardList.itemRender=ItemCell;
					view.vipRewardList.hScrollBarSkin="";
					view.vipRewardList.selectEnable = true;
					view.vipRewardList.selectHandler=new Handler(this, onLostSelect);
					view.vipRewardList.array=getList(m_data.vipItems);
				}
				
			}
			else
			{
				this.view.FightingIconImage.visible=true;
				this.view.FightingImage.visible=true;
				this.view.FightingText.visible=true;
				
				view.BgImage.skin="common/bg_dialog.png";
				view.CloseBtn.visible=true;
				view.LostRewardList.itemRender=ItemCell;
				view.LostRewardList.hScrollBarSkin="";
				view.LostRewardList.selectEnable = true;
				view.LostRewardList.selectHandler=new Handler(this, onLostSelect);
				view.LostRewardList.array=getList(m_data.getItem);
				view.RewardText.text=GameLanguage.getLangByKey("L_A_34029");
				view.RemainTimeText.text=GameLanguage.getLangByKey("L_A_34072");
				view.PlayerBox.visible=false;
//				view.PlunderNumText.text=m_data.getItem[0].num;
				view.TimeText.text=TimeUtil.getTimeStr((m_data.endTime-m_data.nowTime)*1000);
				view.MyVechlieText.visible=false;
				this.view.CompteleBtn.visible=false;
				this.view.PlunderBtn.visible = true;
				
				this.view.PlunderBox.y = 191;
				view.oldInfo.visible = true;
				view.vipInfo.visible = false;
				
				view.NameText.visible=true;
				view.LevelText.visible=true;
				this.view.DetailBtn.visible=false;
			}
		}
		
		private function onLostSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			for (var i:int = 0; i < view.LostRewardList.array.length; i++) 
			{
				var l_cell:PlanRewardCell=this.view.LostRewardList.getCell(i) as PlanRewardCell;
				if(l_cell!=null)
				{
					l_cell.selected=false;
				}
			}
			var l_selectCell:PlanRewardCell=this.view.LostRewardList.getCell(p_index) as PlanRewardCell;
			var l_data:ItemData=this.view.LostRewardList.getItem(p_index);
			var itemvo:ItemVo=GameConfigManager.items_dic[l_data.iid];
			ItemTips.showTip(itemvo.id);
		}
		
		private function onHeroSelect(p_index:int):void
		{
			// TODO Auto Generated method stub
			for (var i:int = 0; i < view.RewardList.array.length; i++) 
			{
				var l_cell:PlanRewardCell=this.view.RewardList.getCell(i) as PlanRewardCell;
				if(l_cell!=null)
				{
					l_cell.selected=false;
				}
			}
			var l_selectCell:PlanRewardCell=this.view.RewardList.getCell(p_index) as PlanRewardCell;
			var l_data:ItemData=this.view.RewardList.getItem(p_index);
			var itemvo:ItemVo=GameConfigManager.items_dic[l_data.iid];
			ItemTips.showTip(itemvo.id);
			
		}
		
		private function getList(p_arr:Array,p_num:int=-1):Array
		{
			var l_arr:Array=new Array();
			for(var i:int=0;i<p_arr.length;i++)
			{
				var l_vo:ItemData=new ItemData();
				l_vo.iid=p_arr[i].id;
				l_vo.inum=p_arr[i].num;
				if(p_num!=-1)
				{
					l_vo.inum=p_num;
				}
				l_arr.push(l_vo);
			}
			return l_arr;
		}
		
		
		public function setTime():void
		{
			if((m_data.endTime-m_data.nowTime)>=0)
			{
				m_data.nowTime++;
				if(m_data.isSelf==true)
				{
					view.PlayerTimeText.text=TimeUtil.getTimeStr((m_data.endTime-m_data.nowTime)*1000);
				}
				else
				{
					view.TimeText.text=TimeUtil.getTimeStr((m_data.endTime-m_data.nowTime)*1000);     
				}
			}
		}
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK,this,this.onClickHandler);
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			this.on(Event.CLICK,this,this.onClickHandler);
		}
		
		
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			// trace("onClickHandler"+e.target);
			switch(e.target)
			{
				case this.view.DetailBtn:
				{
					this.close();
					break;
				}
				case this.view.PlunderBtn:
				{
					Signal.intance.event(TrainBattleLogEvent.PLUNDERBTN_EVENT_CLICK,m_data);
//					this.close();
					break;
				}
				case this.view.CompteleBtn:
				{
					WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETREWARD,[]);
					this.close();
					return;
				}
				case this.view.CloseBtn:
				{
					close();
					break;
				}
				default:
				{
					if(e.target.name.indexOf("RewardImage_")!=-1)
					{
						var l_str:String=e.target.name;
						var l_arr:Array=l_str.split("_");
						var itemvo:ItemVo=GameConfigManager.items_dic[l_arr[1]];
						ItemTips.showTip(itemvo.id);
						return;
					}
					if(m_data.isSelf==true)
					{
						if(m_data.endTime<=m_data.nowTime)
						{
							WebSocketNetService.instance.sendData(ServiceConst.TRAN_GETREWARD,[]);
							this.close();
						}
					}
					break;
				}
			}
		}		
		
		private function get view():PlunderTipsViewUI{
			return _view;
		}
		
	}
}