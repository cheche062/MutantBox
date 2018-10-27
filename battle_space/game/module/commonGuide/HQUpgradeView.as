package game.module.commonGuide 
{
	import MornUI.commonGuide.HQUpgradeViewUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingNum;
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.global.vo.funGuide;
	import game.module.story.StoryManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Tween;
	
	/**
	 * ...
	 * @author ...
	 */
	public class HQUpgradeView extends BaseDialog 
	{
		private var _guideID:int = 0;
		
		private var _funOpenVo:funGuide;
		
		private var _buildImgVec:Vector.<Image> = new Vector.<Image>(3);
		private var _buildNameVec:Vector.<Text> = new Vector.<Text>(3);
		
		private var _nowLv:int=1;
		
		public function HQUpgradeView() 
		{
			super();
			this.m_iLayerType = LayerManager.M_GUIDE;
			this.name = "HQUpgradeView";
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var cost:String = "";
			switch(e.target)
			{
				case this.view.closeBtn:
						
					close();
					break;
				
				case this.view.conBtn:
					
					/*User.getInstance().isInGuilding = false;
					
					if (_funOpenVo.lx == 3)
					{
						User.getInstance().isInGuilding = true;
						XFacade.instance.openModule(ModuleName.FunctionGuideView,_funOpenVo.g_id);
					}
					else
					{
						User.getInstance().curGuideArr.shift();
						User.getInstance().checkHasNextGuide();
						if (User.getInstance().curGuideArr.length > 0)
						{
							_guideID = User.getInstance().curGuideArr[0];
							Tween.to(view, { scaleX:0, scaleY:0,x:LayerManager.instence.stageWidth/2,y:LayerManager.instence.stageHeight/2 }, 300,Ease.linearNone,new Handler(this,showView));
							return;
						}
					}*/
					//showView();
					
					
					if(GlobalRoleDataManger.instance.ShareState)
					{
						GlobalRoleDataManger.instance.shareGame(GameConfigManager.ShareInfo[1]);
					}
					
					User.getInstance().curGuideArr.shift();
					User.getInstance().isInGuilding = false;
					close();
					StoryManager.intance.activeStory();
					
					/*if (_guideArr.length > 0)
					{
						Tween.to(view, { scaleX:0, scaleY:0,x:LayerManager.instence.stageWidth/2,y:LayerManager.instence.stageHeight/2 }, 300,Ease.linearNone,new Handler(this,showView));
						return;
					}
					close();*/
					//XFacade.instance.openModule(ModuleName.GuildBossView);
					break;
				case view.shareBtn:
					GlobalRoleDataManger.instance.ShareState = !GlobalRoleDataManger.instance.ShareState;
					view.gouImg.visible = GlobalRoleDataManger.instance.ShareState;
					break;
				default:
					break;
				
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			_guideID = args[0];
			showView();
			Tween.from(view, { scaleX:0, scaleY:0,x:LayerManager.instence.stageWidth/2,y:LayerManager.instence.stageHeight/2 }, 300);
			view.gouImg.visible = GlobalRoleDataManger.instance.ShareState;
			WebSocketNetService.instance.sendData(ServiceConst.GET_ACT_LIST);
		}
		
		private function showView():void
		{
			_funOpenVo = GameConfigManager.fun_open_vec[_guideID];
			
			_nowLv = User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_BASE);
			
			view.HQinfo.text = GameLanguage.getLangByKey("L_A_6013").replace("{0}", _nowLv);
			
			view.oBLV.text = GameLanguage.getLangByKey("L_A_6015").replace("{0}", _nowLv-1);
			view.nowBLv.text = GameLanguage.getLangByKey("L_A_14").replace("{0}", _nowLv);
			
			var nextVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(DBBuilding.B_BASE, _nowLv);
			view.oFNum.text = GameLanguage.getLangByKey("L_A_6014").replace("{0}", DBBuildingUpgrade.getBuildingLv(DBBuilding.B_BASE, _nowLv-1).buldng_capacty);
			view.nFNum.text = nextVo.buldng_capacty;
			
			
			//新增建筑
			var buildList:Array = DBBuildingNum.getNewBuingList(_nowLv-1);
			var len:int = Math.min(buildList.length,3);
			
			if (len == 0)
			{
				view.buildInfo.visible = false;
				view.lvInfo.y = 132;
			}
			else
			{
				view.lvInfo.y = 62;
				view.buildInfo.visible = true;
				for (var i:int = 0; i < 3; i++) 
				{
					
					_buildImgVec[i].visible = false;
					_buildImgVec[i].x = 180 + (3 - len) * 60 + i * 140;
					
					_buildNameVec[i].visible = false;
					_buildNameVec[i].x = _buildImgVec[i].x - 20;
					
					if (buildList[i])
					{
						var buInfo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(buildList[i],1);
						_buildImgVec[i].skin = "appRes/building/" + buInfo.building_id + ".png";
						_buildImgVec[i].visible = true;
						
						_buildNameVec[i].text = DBBuilding.getBuildingById(buInfo.building_id).name;
						//_buildNameVec[i].visible = true;
					}
				}
			}
			
		}
		
		override public function close():void{
			super.close();
			
			//AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new HQUpgradeViewUI();
			this.addChild(_view);
			
			for (var i:int = 0; i < 3; i++) 
			{
				_buildImgVec[i] = new Image();
				_buildImgVec[i].x = 180 + i * 140;
				_buildImgVec[i].y = 25;
				_buildImgVec[i].scaleX = _buildImgVec[i].scaleY = 0.5;
				view.buildInfo.addChild(_buildImgVec[i]);
				
				_buildNameVec[i] = new Text();
				_buildNameVec[i].font = "Futura";
				_buildNameVec[i].fontSize = 24;
				_buildNameVec[i].color = "#ffffff";
				_buildNameVec[i].x = _buildImgVec[i].x - 1;
				_buildNameVec[i].y = 100;
				_buildNameVec[i].width = 150;
				_buildNameVec[i].wordWrap = true;
				_buildNameVec[i].align = "center";
				view.buildInfo.addChild(_buildNameVec[i]);
			}
		}
		
		private function get view():HQUpgradeViewUI{
			return _view;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
	}

}