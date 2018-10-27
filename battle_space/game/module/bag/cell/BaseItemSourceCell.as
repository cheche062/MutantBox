package game.module.bag.cell
{
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.User;
	import game.global.vo.itemSourceVo;
	
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	public class BaseItemSourceCell extends Box
	{
		protected var _bg:Image;
		protected var _text:Label;
		protected var _data:itemSourceVo;
		
		public function BaseItemSourceCell()
		{
			super();
			init();
		}
		
		protected function init():void
		{
			_bg = new Image();
			addChild(_bg);
			_text = new Label();
			addChild(_text);
		}

		public function get text():Label
		{
			return _text;
		}

		public function get bg():Image
		{
			return _bg;
		}
		
		protected function bindData():void{
			if(_data)
			{
				_text.text = _data.des;
			}
		}
		
		
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			bindData();
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			_data = null;
			_bg = null;
			_text= null;
			super.destroy(destroyChild);
		}
		
		public static function sourceClick(_data:itemSourceVo, callBackHandler:Handler):void
		{
			if(!_data)return ;
			switch(Number(_data.type))
			{
				case 1:  //主线 ：章节ID ， 关卡ID
				{	trace("跳转数据:", _data);
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[0,Number(_data.params[0]) - 1,Number(_data.params[1])]);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 2: //精英：章节ID ， 关卡ID 
				{
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[2,Number(_data.params[0]) - 1,Number(_data.params[1])]);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 3: //抽卡
				{
					XFacade.instance.openModule(ModuleName.ChestsMainView);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 4: //商城
				{
					XFacade.instance.openModule(ModuleName.StoreView, [0,0]);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 5: //基因副本
				{
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,1]);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 6: //雷达
				{
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 7: //武器副本
				{
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,2]);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 8: //运镖
				{
					XFacade.instance.openModule(ModuleName.TrainLoadingView);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 9: //运营活动：活动ID
				{
					XFacade.instance.openModule(ModuleName.ActivityMainView,[Number(_data.params[0])]);
					callBackHandler && callBackHandler.run();
					break;
				}
				case 10: //爬塔玩法：活动ID，直接从基地进入，退出后到基地
				{
					XFacade.instance.openModule(ModuleName.NewPataView);
					callBackHandler && callBackHandler.run();
					break;
				}
					
				case 11: //竞技场				
				{
					XFacade.instance.openModule(ModuleName.ArenaMainView);
					callBackHandler && callBackHandler.run();
					break;
				}
					
				case 12: //组队副本				
				{
					XFacade.instance.openModule(ModuleName.TeamCopyMainView);
					callBackHandler && callBackHandler.run();
					break;
				}
					
				case 13: //矿场
				{
					XFacade.instance.openModule(ModuleName.MineFightView);
					callBackHandler && callBackHandler.run();
					break;
				}
					
				case 14: // 军团
				{
					var juntuan_data = ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
					var needBaseLv = Number(juntuan_data["72"].value);
					if (User.getInstance().level < needBaseLv) {
						var text = GameLanguage.getLangByKey("L_A_170").replace("{0}", needBaseLv); 
						return XTip.showTip(text);
					}
					var buildInfo:Array = juntuan_data["74"].value.split("=");
					if (User.getInstance().sceneInfo.getBuildingLv(buildInfo[0]) < buildInfo[1]) {
						return XTip.showTip("L_A_21039");
					}
					
					XFacade.instance.openModule(ModuleName.ArmyGroupMapView);
					
					break;
				}
					
				case 100: //限时活动的来源
				{
//					XFacade.instance.openModule(ModuleName.MineFightView);
					break;
				}
			}
			
}

	}
}