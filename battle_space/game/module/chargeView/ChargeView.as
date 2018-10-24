package game.module.chargeView 
{
	import MornUI.chargeView.SMTMViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.base.BaseDialog;
	import game.common.base.BaseView;
	import game.global.GameSetting;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.debug.view.nodeInfo.ToolPanel;
	import laya.events.Event;
	import laya.ui.Button;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ChargeView extends BaseDialog 
	{
		
		private var _webCharge:FaceBookChargeView;
		private var _mobilCharge:FaceBookChargeView;
		private var _vipInfo:FaceBookChargeView;
		
		private var _viewVec:Vector.<BaseView> = new Vector.<BaseView>();
		private var _tabBtnVec:Vector.<Button> = new Vector.<Button>();
		
		public function ChargeView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			var id:int = e.target.name.split("_")[1];
			switch(e.target)
			{
				case this.view.closeBtn:
					close();
					break;
				case view.tabBtn_0:
				case view.tabBtn_1:
				case view.tabBtn_2:
					//trace("chargeId:", id);
					if (!id)
					{
						return;
					}
					resetTabBtnState();
					_tabBtnVec[id].selected = true;
					view.viewContainer.addChild(_viewVec[id]);
					_viewVec[id].show();
					break;		
				default:
					
					break;
				
			}
		}
		
		override public function show(...args):void
		{
			/**不开放充值*/
			/*if(!DBBuilding.isChargeOn){
				super.close();
				return;
			}*/
			
			
			
			if(!_viewVec[0])
			{
				//if (GameSetting.isApp)
				if (GameSetting.isApp || GameSetting.Platform != GameSetting.P_GW)
				{
					_viewVec[0] = new MobileChargeView();
				}
				else
				{
					_viewVec[0] = new FaceBookChargeView();
				}
			}
			
			super.show();
			
			AnimationUtil.flowIn(this);
			
			// 已经有选中的标签了
			var _index = ToolFunc.findIndex(_tabBtnVec, function(item:Button) {
				return item.selected;
			});
			_index = _index == -1 ? 0 : _index;
			
			resetTabBtnState();
			_tabBtnVec[_index].selected = true;
			view.viewContainer.addChild(_viewVec[_index]);
			
			WebSocketNetService.instance.sendData(ServiceConst.OPEN_VIP_VIEW);
		}
		
		private function resetTabBtnState():void
		{
			var len:int = _tabBtnVec.length;
			for (var i:int = 0; i < len; i++) 
			{
				_tabBtnVec[i].selected = false;
			}
			
			while (view.viewContainer.numChildren > 0)
			{
				view.viewContainer.removeChildAt(0);
			}
			
		}
		
		
		override public function close():void {
			
			while (view.viewContainer.numChildren > 0)
			{
				view.viewContainer.removeChildAt(0);
			}
			
			/*// 子项首先关闭
			_viewVec.forEach(function(item, index){
				item.close && item.close();
			})*/
			
			
			
			AnimationUtil.flowOut(this, onClose);
		}
		
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.OPEN_VIP_VIEW:
					view.vRed.visible = false;
					
					var vState:Object = args[0].userVipInfo.reward_status;
					for (i = 0; i < User.getInstance().VIP_LV; i++ )	
					{
						if (vState[i+1] == 1)
						{
							view.vRed.visible = true;
							return;
						}
					}
					break;
				default:
					break;
			}
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void {
			this.closeOnBlank = true;
			this._view = new SMTMViewUI();
			this.addChild(_view);
			
			//if (GameSetting.isApp)
			/*if (GameSetting.isApp || GameSetting.Platform != GameSetting.P_GW)
			{
				view.bg_left.skin = "chargeView/m_bg3_1.png";
				view.bg_right.skin = "chargeView/m_bg3_2.png";
				view.tabBtn_0.skin = "chargeView/m_btn_tab1.png";
				view.tabBtn_1.skin = "chargeView/m_btn_tab2.png";
				view.closeBtn.skin = "common/buttons/btn_cancel1.png";
			}*/
			
			
			_tabBtnVec[0] = view.tabBtn_0;
			_tabBtnVec[1] = view.tabBtn_1;
			//_tabBtnVec[2] = view.tabBtn_2;
			//_tabBtnVec[0].visible =false;
			//_tabBtnVec[1].visible = false;
			
			_viewVec[1] = new VipWelfareView();
			_viewVec[2] = new VipStoreView();
		}
		
		private function get view():SMTMViewUI{
			return _view;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.OPEN_VIP_VIEW), this, this.serviceResultHandler);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.OPEN_VIP_VIEW), this, this.serviceResultHandler);
			super.removeEvent();
		}
		
	}

}