package game.module.military
{
	import MornUI.military.MilitaryViewUI;
	
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBInvasion;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.User;
	
	import laya.events.Event;
	import laya.utils.Handler;

	/**
	 * MainCom主界面====
	 * author:huhaiming
	 * MainCom.as 2017-6-20 下午5:42:28
	 * version 1.0
	 *
	 */
	public class MainCom implements IMilitaryCom
	{
		private var _ui:*;
		private var _view:MilitaryViewUI;
		public function MainCom(ui:*, view:MilitaryViewUI)
		{
			this._ui = ui;
			this._view = view;
			init();
			
			UIRegisteredMgr.AddUI(_view.attackBtn,"MilitaryAtkBtn");
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case _view.attackBtn:
					//
					var price:String = DBInvasion.getBuyPrice(User.getInstance().sceneInfo.base_rob_info.search_number);
					var arr:Array = price.split("=")
					
					var data:ItemData = new ItemData;
					data.iid = arr[0];
					data.inum = arr[1];
					ConsumeHelp.Consume([data],Handler.create(this,onConsum));
					
					function onConsum():void{
						XFacade.instance.openModule("InvasionView");
						Signal.intance.event(MilitaryView.CLOSE);
					}
					break;
				case _view.cupBtn:
					_view.tab.selectedIndex = 2;
					//XTip.showTip("还在开发呐");
					break;
				case _view.logBtn:
					XFacade.instance.openModule("ReplayView");
					break;
				case _view.shopBtn:
//					XFacade.instance.openModule("StoreView",0);
					XFacade.instance.openModule("StoreView",[0,0]);
					//Signal.intance.event(MilitaryView.CLOSE);
					break;
				case _view.btnRward:
					if(User.getInstance().day_box_reward){
						MilitaryView.getDailyReward(this, setBtnState);
					}
					break;
			}
		}
		
		private function setBtnState(){
			if(User.getInstance().day_box_reward){
				_view.btnRward.skin = "military/reward_1.png";
				_view.btnRward.gray = false;
			}else{
				_view.btnRward.skin = "military/reward_1_1.png";
				_view.btnRward.gray = true;
			}
		}
		
		public function show(...args):void
		{
			this._ui.visible = true;
			this._view.on(Event.CLICK, this, this.onClick);
			
			if(User.getInstance().sceneInfo.base_rob_info){
				var delTimes:int = DBInvasion.getFreeBuyTime()-User.getInstance().sceneInfo.base_rob_info.search_number;
				var price:String = DBInvasion.getBuyPrice(User.getInstance().sceneInfo.base_rob_info.search_number);
				if(delTimes <= 0){
					var arr:Array = price.split("=");
					ItemUtil.formatIcon(_view.currencyIcon, price);
					_view.timesTF.text = arr[1]+"";
					this._view.currencyIcon.visible = true;
					_view.timesLabel.visible = false;
					if(User.getInstance().getResNumByItem(arr[0]) >= parseInt(arr[1])){
						_view.timesTF.color = "#ffffff"
					}else{
						_view.timesTF.color = "#ffabab"
					}
				}else{
					_view.timesTF.color = "#ffffff"
					_view.timesTF.text  = delTimes+"/5";
					this._view.currencyIcon.visible = false;
					_view.timesLabel.visible = true;
				}
				
			}
			this._view.cupLabel.text = XUtils.formatNumWithSign(User.getInstance().cup);
			var str:String = "";
			this._view.snatchTF.text = (User.getInstance().sceneInfo.base_rob_info.daily_forecast_get || 0)+"";
			str = GameLanguage.getLangByKey("L_A_49613");
			str = str.replace(/{(\d+)}/,User.getInstance().substitute)
			this._view.totalDBTF.text = str;
			if(MilitaryView.data){
				this._view.loseTF.text = MilitaryView.data.base_rob_info.daily_forecast_lose+""
			}
			setBtnState();
		}
		
		public function close():void
		{
			this._ui.visible = false;
			this._view.off(Event.CLICK, this, this.onClick);
		}
		
		private function init():void{
		}
	}
}