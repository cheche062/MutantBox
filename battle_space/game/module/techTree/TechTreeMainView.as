package game.module.techTree 
{
	import MornUI.tech.TechMainViewUI;
	
	import game.common.AnimationUtil;
	import game.common.FilterTool;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.event.Signal;
	import game.global.event.TechEvent;
	import game.global.vo.User;
	import game.global.vo.relic.TransportBaseInfo;
	import game.global.vo.tech.TechUpdateVo;
	import game.global.vo.tech.UserTechInfoVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.net.URL;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.View;
	
	/**
	 * ...
	 * @author ...
	 */
	public class TechTreeMainView extends Box 
	{
		
		private var _view:View;
		private var selectedIcon:Image;
		
		private var _lvBg:Image;
		private var _lvTF:Text;
		private var _maxImg:Image;
		
		public var user:User = User.getInstance();
		
		public var currentID:String = "1000";
		
		private var techTreeArr:Array = [];
		
		private var techLvArr:Array = [];
		
		private var lvLanArr:Array = [];
		
		private var _techBlockContainer:TechBlockContainer;
		
		private var _nowPage:int = 0;
		private var _allPage:int = 1;
		
		private var _resetCost:String = "1=50";
		
		public function TechTreeMainView() 
		{
			super();
			init();
		}
		
		private function init():void {
			createUI();
		}
		
		public function show(...args):void{
			addEvent();
			if (!User.getInstance().isInGuilding)
			{
//				AnimationUtil.flowIn(this);
			}
			
			_lvBg.visible = false;
			_maxImg.visible = false;
			_lvTF.text = "";
			
			view.addBtn.disabled = true;
		}
		
		public function update():void {
			WebSocketNetService.instance.sendData(ServiceConst.TECH_INIT_DATA, []);
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			
			switch(e.target)
			{
				
				case this.view.addBtn:
					XFacade.instance.openModule(ModuleName.TechBuyPointView,[1]);
					break;
				case this.view.resetBtn:
					
					//str = "重置需要花费水" + _resetCost.split("=")[1] + "\n\n确认重置？";
					str = GameLanguage.getLangByKey("L_A_57003");
					str = str.replace("{0}", _resetCost.split("=")[1]);
					str = str.replace("##", "\n\n");
					function callBack(){									
						if (User.getInstance().water < parseInt(_resetCost.split("=")[1]))
						{
							XFacade.instance.openModule(ModuleName.ChargeView);
						}
						else
						{
							WebSocketNetService.instance.sendData(ServiceConst.TECH_RESETE, [_nowPage+1]);
						} 
					}
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [ 
						GameLanguage.getLangByKey("L_A_57003"),
						_resetCost.split("=")[0],
						_resetCost.split("=")[1],
						callBack
					]
					);
					
					break;
				case this.view.upgradeBtn:
					if (currentID == "")
					{
						return;
					}
					if (user.currentTechPoint == 0)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_923005"));
						return;
					}
					WebSocketNetService.instance.sendData(ServiceConst.TECH_UPDATE, [currentID]);
					break;
				case this.view.rightBtn:
					_techBlockContainer.hideAllSelectState();
					_nowPage++;
					if (_nowPage >= _allPage)
					{
						_nowPage = _allPage-1;
					}
					setLayerData();
					break;
				case this.view.leftBtn:
					_techBlockContainer.hideAllSelectState();
					_nowPage--;
					if (_nowPage < 0)
					{
						_nowPage = 0;
					}
					//trace("_nowpage: " + _nowPage);
					setLayerData();
					break;
				default:
					break;
				
			}
		}
		
		private function techEveneHandler(cmd:String,...args):void 
		{
//			trace("techEvent: ", args);
			if (cmd == TechEvent.SELECT_TECH)
			{
				_techBlockContainer.hideAllSelectState();
			}
			view.selectedIcon.skin = URL.formatURL("appRes/tech/techIcon/" + parseInt(args[0]) + ".png");
			view.selectedIcon.filters = [];
			//trace("args[1]:", args[1]);
			if (args[1])
			{
				view.selectedIcon.filters = [FilterTool.grayscaleFilter];
			}
			
			
			view.warningTF.visible = false;
			view.upgradNameTF.text = GameLanguage.getLangByKey("L_A_42006");
			view.costTF.visible = view.upgradeBtn.visible = view.upgradNameTF.visible = true;
			currentID = parseInt(args[0]);
			var std:UserTechInfoVo = User.getInstance().getUserTech(currentID)
			var lv:int = std?std.lv:0;
			var techInfo:TechUpdateVo = GameConfigManager.intance.getTechUpdateInfo(parseInt(args[0]), lv);
			//trace("techInfo: ", techInfo);
			if (!techInfo)
			{
				techInfo = GameConfigManager.intance.getTechUpdateInfo(parseInt(args[0]), 1);
				if (techInfo.condition == "")
				{
					if(user.currentTechPoint == 0){
						view.warningTF.text = 'L_A_42024';
					}
					else{
						view.warningTF.text = 'L_A_42025';
					}
					if (user.getUserAllTechPoint() < GameConfigManager.intance.getLowLayerFinishPoint(techInfo.tier - 1))
					{
						view.warningTF.text = GameLanguage.getLangByKey("L_A_42020")
					}	
				}
				else
				{
					var conInfo:TechUpdateVo = GameConfigManager.intance.getTechUpdateInfo(techInfo.condition.split(":")[0], 1);
//					trace("conInfo:", conInfo);
					var wStr:String = GameLanguage.getLangByKey("L_A_42019").toUpperCase();
					wStr = wStr.replace("{0}", techInfo.condition.split(":")[1]);
					wStr = wStr.replace("{1}",GameLanguage.getLangByKey(conInfo.name).toUpperCase())
					view.warningTF.text = wStr;
				}
				view.warningTF.visible = true;
				
			}
//			trace("techInfo: ", techInfo);
			view.techNameTF.text = GameLanguage.getLangByKey(techInfo.name);
			
			
			view.nowLvTF.visible = true;
			view.nowEffectTF.visible = true;
			view.nowTF.visible = true;
			view.nowTF.color = "#ffffff";
			view.nowLvTF.color = "#55fb7c";
			view.nowEffectTF.color = "#55fb7c";
			view.nowTF.text = "Current Level";
			
			_lvBg.visible = false;
			_maxImg.visible = false;
			_lvTF.text = "";
			
			if (lv == 0)
			{
				view.nowTF.visible = false;
				view.nowLvTF.visible = false;
				view.nowEffectTF.visible = false;
				view.upgradNameTF.text = GameLanguage.getLangByKey("L_A_42008");
			}
			else
			{
				_lvBg.visible = true;
				_lvTF.text = lv;
			}
			
			view.nextLvTF.visible = true;
			view.nextEffectTF.visible = true;
			view.nlTF.visible = true;
			if (lv>=techInfo.max)
			{
				_maxImg.visible = true;
				
				view.nlTF.visible = false;
				view.nextLvTF.visible = false;
				view.nextEffectTF.visible = false;
				view.nowTF.text = "Max Level";
				view.nowTF.color = "#ffdc52";
				view.nowLvTF.color = "#ffdc52";
				view.nowEffectTF.color = "#ffdc52";
				view.costTF.visible = view.upgradeBtn.visible = view.upgradNameTF.visible = false;
			}
			
			var paramArr:Array = techInfo.param.split('|');
			var len:int = paramArr.length;
			var s:String = "";
			var i:int = 0;
			if (this.view.nowEffectTF.visible)
			{
				view.nowLvTF.text = GameLanguage.getLangByKey("L_A_73") + lv;
				s = GameLanguage.getLangByKey(techInfo.des);
				for (i = 0; i < len; i++ )
				{
					s = s.replace("{" + i + "}", paramArr[i]);
				}
				view.nowEffectTF.text = "              " + s;
			}
			
			
			if (this.view.nextEffectTF.visible)
			{
				view.nextLvTF.text = GameLanguage.getLangByKey("L_A_73") + parseInt(++lv);
				paramArr = GameConfigManager.intance.getTechUpdateInfo(parseInt(args[0]), lv).param.split('|');
				len = paramArr.length;
				
				s = GameLanguage.getLangByKey(techInfo.des);
				for (i = 0; i < len; i++ )
				{
					s = s.replace("{"+i+"}", paramArr[i]);
				}
				view.nextEffectTF.text = "              " + s;
			}
			
		}
		
		private function checkNowLayer():void
		{
			for (var i:int = 0; i < _allPage; i++) 
			{
				if (user.getUserAllTechPoint() < GameConfigManager.intance.getLowLayerFinishPoint(i+1))
				{
					_nowPage = i;
					break;
				}
			}
			setLayerData();
			
		}
		
		private function setLayerData():void
		{
			_techBlockContainer.dataSource = techTreeArr[_nowPage];
			view.layerTF.color = "#9ce4ff";
			view.layerTF.text = GameLanguage.getLangByKey(lvLanArr[_nowPage]);
			view.layerBg.filters = [];
			view.requirelayerTF.visible = false;
			
			if (User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_TRANSPORT) < techLvArr[_nowPage])
			{
				view.layerBg.filters = [FilterTool.grayscaleFilter];
				view.layerTF.color = "#d1d1d1";
				view.requirelayerTF.text = GameLanguage.getLangByKey('L_A_42001').replace("{0}",techLvArr[_nowPage]);
				view.requirelayerTF.visible = true;
			}
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			//trace("techServiceInfo: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				
				case ServiceConst.TECH_INIT_DATA:
					
					user.currentTechPoint = args[1].point;
					
					view.presentPointsTF.text = user.currentTechPoint;
					for (var c in args[1].tech_list )
					{
						user.updateUserTech(c, args[1].tech_list[c]);
					}
					view.totalPointsTF.text = user.getUserAllTechPoint();
					_resetCost = args[1].tech_param_cose;
					checkNowLayer();
					user.updateTechEvent();
					cacheAsBitmap = true;
					
					currentID = techTreeArr[_nowPage][0].id;
					techEveneHandler(0, [currentID]);
					
					break;
				case ServiceConst.TECH_UPDATE:
					if (!user.getUserTech(currentID))
					{
						user.updateUserTech(currentID, 1);
					}
					else
					{
						user.updateUserTech(currentID, ++user.getUserTech(currentID).lv);
					}
					user.currentTechPoint--;
					user.updateTechEvent();
					
					break;
				case ServiceConst.TECH_RESETE:
					
					len = techTreeArr[_nowPage].length;					
					var resetPoint:int = 0;
					var rp:UserTechInfoVo
					for (i = 0; i < len; i++) 
					{
						rp = user.getUserTech(techTreeArr[_nowPage][i].id)
						if (rp)
						{
							resetPoint += rp.lv;
							user.updateUserTech(techTreeArr[_nowPage][i].id, 0);
						}
						
					}
					
					user.currentTechPoint += resetPoint;
					user.updateTechEvent();
					
					break;
				case ServiceConst.TRAN_GETTRANSPORTTYPE:
					var l_info:Object=args[1];
					var l_data:TransportBaseInfo=new TransportBaseInfo();
					l_data.status=l_info.status;
					l_data.endTime=l_info.endTime;
					if(l_data.status==0)
					{
						XFacade.instance.openModule("EscortMainView",l_data);
					}
					else
					{
						XFacade.instance.openModule("PlunderMainView",l_data);
					}
					
					break;
				default:
					break;
			}
		}
		
		private function updateData():void 
		{
			view.presentPointsTF.text = user.currentTechPoint;
			view.totalPointsTF.text = user.getUserAllTechPoint();
			
			_techBlockContainer.refreshBlockData();
			
			techEveneHandler(0, [currentID]);
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		public function createUI():void{
			this._view = new TechMainViewUI();
			this.addChild(_view);
			
			view.resetTF.text = GameLanguage.getLangByKey("L_A_42003");
			view.tpTF.text = GameLanguage.getLangByKey("L_A_42004").replace("{0}", "");
			view.ppTF.text = GameLanguage.getLangByKey("L_A_42005").replace("{0}", "");
			view.upgradNameTF.text = GameLanguage.getLangByKey("L_A_42006");
			
			_techBlockContainer = new TechBlockContainer()
			_techBlockContainer.x = this.view.techContainerArea.x;
			_techBlockContainer.y = this.view.techContainerArea.y;
			this.view.addChild(_techBlockContainer);
			
			this.view.techContainerArea.visible = false;
			
			_lvBg = new Image();
			_lvBg.skin = URL.formatURL("appRes/tech/skill_bg_1.png");
			_lvBg.x = 745-23;
			_lvBg.y = 149 - 23.5;
			this.addChild(_lvBg);
			
			_maxImg = new Image();
			_maxImg.skin = URL.formatURL("appRes/tech/bg_max.png");
			_maxImg.x = 745-15;
			_maxImg.y = 149 - 15;
			this.addChild(_maxImg)
			
			_lvTF = new Text();
			_lvTF.font = "Futura";
			_lvTF.fontSize = 18;
			_lvTF.color = "#ffffff";
			_lvTF.text = 99;
			_lvTF.width = 18;
			_lvTF.align = "center";
			_lvTF.x = 745-15;
			_lvTF.y = 149 - 15;			
			this.addChild(_lvTF);
			
			view.techNameTF.text = "";
			view.nowLvTF.text = "";
			view.nowEffectTF.text = "";
			view.nowEffectTF.wordWrap = true;
			
			view.nextLvTF.text = "";
			view.nextEffectTF.text = "";
			view.nextEffectTF.wordWrap = true;
			view.nlTF.text = "L_A_85";
			
			view.warningTF.wordWrap = true;
			view.warningTF.visible = false;
			
			view.presentPointsTF.text = "0";
			view.totalPointsTF.text = "0";
			
			GameConfigManager.intance.getTechInitData();
			
			var len:int = GameConfigManager.tech_level_vec.length;
			
			var a1:Array = [];
			for (var i:int = 0; i < len; i++) 
			{
				a1 = GameConfigManager.tech_level_vec[i].tech_id.split("|");
				
				techLvArr.push(GameConfigManager.tech_level_vec[i].level);
				lvLanArr.push(GameConfigManager.tech_level_vec[i].lau);
				var layaData:Array = [];
				for (var j:int = 0; j < a1.length; j++) 
				{
					layaData.push( {
						h:j%4,
						v:parseInt(j/4),
						id:a1[j].split(":")[0],
						isEnd:Boolean(j >7)
					})
				}
				techTreeArr.push(layaData);
			}
			_allPage = techTreeArr.length;
			setLayerData();
			UIRegisteredMgr.AddUI(view.addBtn,"BuyPointBtn");
			UIRegisteredMgr.AddUI(view.upgradeBtn, "ActivePointBtn");
			UIRegisteredMgr.AddUI(view.resetBtn, "resetTechBtn");
			
			
		}
		
		public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(TechEvent.SELECT_TECH, this, this.techEveneHandler, [TechEvent.SELECT_TECH]);
			Signal.intance.on(User.TECH_UPDATE, this, this.updateData);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECH_INIT_DATA),this,serviceResultHandler,[ServiceConst.TECH_INIT_DATA]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECH_UPDATE),this,serviceResultHandler,[ServiceConst.TECH_UPDATE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECH_RESETE), this, serviceResultHandler, [ServiceConst.TECH_RESETE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE), this, serviceResultHandler, [ServiceConst.TRAN_GETTRANSPORTTYPE]);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(TechEvent.SELECT_TECH, this, this.techEveneHandler);
			Signal.intance.off(User.TECH_UPDATE, this, this.updateData);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TECH_INIT_DATA),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TECH_UPDATE),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TECH_RESETE),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE),this,serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("BuyPointBtn");
			UIRegisteredMgr.DelUi("ActivePointBtn");
			super.destroy(destroyChild);
		}
		
		/**关闭*/
		public function close():void {
			removeEvent();
		}
		
		private function get view():TechMainViewUI{
			return _view;
		}
	}

}