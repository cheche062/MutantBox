package game.module.guild
{
	import MornUI.guild.GuildMainViewUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.ToolFunc;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.chatNew.LiaotianView;
	import game.module.mainui.MainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.View;
	import laya.utils.Handler;
	
	/**
	 * 公会主页 
	 * @author mutantbox
	 * 
	 */
	public class GuildMainView extends BaseView
	{
		
		private var _nowPage:*;
		private var _curName:String;
		
		private var _infoView:GuildeInfoView;
		private var _goodView:GuildStoreView;
		private var _applicationView:GuildApplicationView;
		private var _rankView:GuildRankView;
		/**公会捐献*/
		private var _donateView:DonateViewNew;
		/**公会科技*/
		private var _guildKejiView:GuildKejiView;
		/**个人科技*/
		private var _personalKejiView:PersonalKejiView;
		
		private var _activityView:GuildActivityView;
		private var _welfareView:GuildWelfareView;
		
		/**首次进入*/
		private var _isFirstEnter:Boolean = true;
		
		private var _user:User = User.getInstance();

		private var _technology:TechnologyView;
		private var bg_initHeight;
		/**导航选项列表*/
		private var tab_nav_names:Array = ["L_A_2695", "L_A_2696", "L_A_2697", "L_A_2698", "L_A_2699", "L_A_96", "L_A_2701"];
		/**状态数据*/
		public static var state:GuildMainStateVo;
		/**管理员修改配置数据*/
		public static var setting_config:Array;
		
		public function GuildMainView()
		{
			super();
			_m_iLayerType = LayerManager.M_POP;
		}
		
		private function onClick(e:Event):void
		{
			switch(e.target)
			{
				case this.view.closeBtn:
					onClose();
					break;
				
				case this.view.btn_info:
					var msg:String = GameLanguage.getLangByKey("L_A_2702");
					XTipManager.showTip(msg.replace(/##/g, '\n'));
					
					break;
				
				default:
					break;
			}
		}
		
		/**获取服务器消息*/
		private function onResult(...args):void
		{
			trace("guildPanelView: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(args[0])
			{
				// 1 commander 指挥官, 2 decommander 副指挥官,3 officer 军官,  4 elite 精英, 5 member 成员
				case ServiceConst.GUILD_BASE_INFO:
					if (!User.getInstance().guildID) {
						XTip.showTip("L_A_921074");
						close();
						return;
					}
					
					state = new GuildMainStateVo();
					state.init(ToolFunc.extendDeep(args[1]));
					
					this._user.guildJob = args[1].job;
					this._user.silverContribute = args[1].donate_times[1];
					this._user.goldContribute = args[1].donate_times[2];
					this._user.guildFundation = args[1].guild_cash;
					
					// 由于长度太长空格则换行
					var mapFun  = function(item) {
//						return GameLanguage.getLangByKey(item).replace(/\s/g, "\n");
						return item;
					}
					// 会长 or 副会长
					if (this._user.guildJob == "1" || this._user.guildJob == "2") {
						view.tab_nav.labels = tab_nav_names.map(mapFun).join(",");
						
						WebSocketNetService.instance.sendData(ServiceConst.GUILD_GET_ALL_APPLICATION);
					} else {
						view.tab_nav.labels = tab_nav_names.slice(0, -1).map(mapFun).join(",");
					}
					
					
					timerOnce(50, this, function() {
						view.tab_nav.y = (view.height - (77 * view.tab_nav.items.length)) / 2 + 40;
						view.rTips.y = view.tab_nav.height + view.tab_nav.y - 70;
					});
					
					User.getInstance().event();
					
					if (view.tab_nav.selectedIndex == -1) {
						view.tab_nav.selectedIndex = 0;
					}
					
					updateCurrentView();
					
					//添加引导
					UIRegisteredMgr.AddUI(view.tab_nav.items[0], "$che_tab_nav0");
					UIRegisteredMgr.AddUI(view.tab_nav.items[1], "$che_tab_nav1");
					UIRegisteredMgr.AddUI(view.tab_nav.items[2], "$che_tab_nav2");
					UIRegisteredMgr.AddUI(view.tab_nav.items[3], "$che_tab_nav3");
					UIRegisteredMgr.AddUI(view.tab_nav.items[4], "$che_tab_nav4");
					UIRegisteredMgr.AddUI(view.dom_info, "$che_info");
					
					break;
				
				case ServiceConst.GUILD_DONATE:
				case ServiceConst.GUILD_REDUCE:
				case ServiceConst.GUILD_PROMOTE:
				case ServiceConst.GUILD_KICK_OUT_MEMBER:
				case ServiceConst.GUILD_TRANSFER_LEADER:
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_BASE_INFO);
					break;
				
				case ServiceConst.GUILD_QUIT:
					User.getInstance().guildID = "";
					close();
					
					break;
				
				case ServiceConst.GUILD_GET_ALL_APPLICATION:
					len = args[1].length;
					view.rTips.visible = len > 0;
					
					break;
				
				case ServiceConst.GUILD_CHANGE_SETTING:
					state.init(setting_config);
					setting_config = null;
					
					break;
			}
		}
		
		/**把当前页的数据更新渲染一下*/ 
		private function updateCurrentView():void {
			if (_nowPage && _nowPage.addToStageRender) {
				_nowPage.addToStageRender();
			}
		}
		
		//["公会信息", "公会捐献", "公会科技", "个人科技", "公会商店", "排行榜", "application"];
		private function changeTabView(index:int):void
		{
			if (index == -1) return;
			
 			view.tabViewContainer.removeChild(_nowPage);
			switch(index) {
				case 0:
					_infoView = _infoView || new GuildeInfoView();
					_nowPage = _infoView;
					if (!_isFirstEnter) {
						WebSocketNetService.instance.sendData(ServiceConst.GUILD_BASE_INFO);
					}
					_isFirstEnter = false;
					break;
				
				case 1:
					_donateView = _donateView || new DonateViewNew();
					_nowPage = _donateView;
					break;
				
				case 2:
					_guildKejiView = _guildKejiView || new GuildKejiView();
					_nowPage = _guildKejiView;
					break;
				
				case 3:
					_personalKejiView = _personalKejiView || new PersonalKejiView();
					_nowPage = _personalKejiView;
					
					break;
				
				case 4:
					_goodView = _goodView || new GuildStoreView();
					_nowPage = _goodView;
					break;
				
				case 5:
					_rankView = _rankView || new GuildRankView();
					_nowPage = _rankView;
					break;
				
				case 6:
					_applicationView = _applicationView || new GuildApplicationView();
					_nowPage = _applicationView;
					view.rTips.visible = false;
					
					_applicationView.getListData();
					break;
				
				default:
					break;
			}
			
			_nowPage.x = (view.tabViewContainer.width - _nowPage.width) / 2;
			view.tabViewContainer.addChild(_nowPage);
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			view.tab_nav.selectedIndex = -1;
			
			onStageResize();
			
			// 聊天
			XFacade.instance.openModule(ModuleName.LiaotianView, {
				tabs: [LiaotianView.WORLD_CHAT, LiaotianView.GUILD_CHAT, LiaotianView.FRIEND_CHAT]
			});
			LiaotianView.current_module_view = this;
			WebSocketNetService.instance.sendData(ServiceConst.GUILD_BASE_INFO);
		}
		
		override public function close():void{
			this.view.tabViewContainer.removeChild(_nowPage);
			
			([_technology, _infoView, _activityView, _goodView, _welfareView, _rankView, _applicationView])
			.forEach(function(item:View) {
				item && item.destroy();
			});
			_technology = _infoView = _activityView = _goodView = _welfareView = _rankView = _applicationView = null;
			
			super.close();
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		private function onClose():void{
			AnimationUtil.flowOut(this, close);
			
			LiaotianView.hide();
			
			var mainView:MainView = XFacade.instance.getView(MainView);
			mainView && mainView.initLiaotianView()
		}
		
		override public function createUI():void{
			this._view = new GuildMainViewUI();
			this.addChild(_view);
			
			bg_initHeight = view.dom_bg.height;
		}
		
		/**改变舞台尺寸*/
		override public function onStageResize():void {
			var stageHeight = Laya.stage.height;
			view.height = stageHeight;
			view.dom_bg.height = Math.max(bg_initHeight, stageHeight);
			view.dom_info.y = view.tabViewContainer.y = (stageHeight - view.tabViewContainer.height) / 2;
		}
		
		override public function addEvent():void {
			super.addEvent();
			view.tab_nav.selectHandler = new Handler(this, changeTabView);
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_BASE_INFO),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_PROMOTE),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_REDUCE),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_KICK_OUT_MEMBER),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_TRANSFER_LEADER), this, onResult);
			// 特殊处理
			Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.GUILD_GET_ALL_APPLICATION), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_CHANGE_SETTING), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_DONATE), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_QUIT), this, onResult);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
		}
		
		override public function removeEvent():void {
			super.removeEvent();
			view.tab_nav.selectHandler.clear();
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_BASE_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_PROMOTE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_REDUCE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_KICK_OUT_MEMBER), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_TRANSFER_LEADER), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_GET_ALL_APPLICATION), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_CHANGE_SETTING), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_DONATE), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_QUIT), this, onResult);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
		}
		
		private function get view():GuildMainViewUI{
			return _view;
		}
		
		override public function dispose():void{
			super.dispose();
			
			UIRegisteredMgr.DelUi("$che_tab_nav0");
			UIRegisteredMgr.DelUi("$che_tab_nav1");
			UIRegisteredMgr.DelUi("$che_tab_nav2");
			UIRegisteredMgr.DelUi("$che_tab_nav3");
			UIRegisteredMgr.DelUi("$che_tab_nav4");
			UIRegisteredMgr.DelUi("$che_info");
		}
	}
}