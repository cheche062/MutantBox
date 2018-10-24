/***
 *作者：罗维
 */
package game.module.gm
{
	import MornUI.panels.BagViewUI;
	import MornUI.panels.GmPanelUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.global.data.DBItem;
	import game.global.data.DBUintUpgradeExp;
	import game.global.data.bag.ItemData;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.event.GameEvent;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.module.bag.BagPanel;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.adata.frSoldierData;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	import org.hamcrest.mxml.object.Null;
	
	public class GmToolPanel extends BaseDialog
	{
		public function GmToolPanel()
		{
			super();
		}
		
		public function get view():GmPanelUI{
			if(!_view)
				_view = new GmPanelUI();
			return _view as GmPanelUI;
		}
		
		override public function createUI():void
		{
			super.createUI();
			
			this.addChild(view);
			
		}
		
		  
		override public function addEvent():void{
			super.addEvent();
			view.closeBtn.on(Event.CLICK,this,closeFun);
			view.gmInput.focus = true;
			view.gmInput.on(Event.KEY_DOWN,this,inputKeyDown);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.closeBtn.off(Event.CLICK,this,closeFun);
			view.gmInput.off(Event.KEY_DOWN,this,inputKeyDown);
		}
		
		private function inputKeyDown(e:Event):void
		{
			if(e.keyCode == 13){
				var gmStr:String = view.gmInput.text;
				view.gmInput.text = "";
				sendGm(gmStr);
				super.close();
			}
		}
		
		private function sendGm(gmStr:String):void
		{
			gmStr = gmStr.replace("\r","");
			var gmAr:Array = gmStr.split(" ");
			if(!gmAr.length)
				return ;
			var gmKey:String = gmAr[0]; 
			var obj:Object;
			switch(gmKey)
			{
				case "#additem":
				{
					
					break;
				}
				case "#f1":
				{
					obj  = ResourceManager.instance.getResByURL("staticConfig/testFightJson.json");
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT,false,1,{type:"report",data:obj});
					break;
				}
				case "#f2":
				{
					FightingManager.intance.getSquad();
//					Signal.intance.event(GameEvent.EVENT_OPEN_MODULE, [ModuleName.FightingView] );//
					break;
				}
				case "#f4":
				{
					FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_SIMULATION);
					break;
				}
				case "#f5":
				{
//					FightSimulationManger.intance.pushBu();
					Signal.intance.event(gmAr[1]);
					break;
				}
				case "#g1":
				{
//					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP);
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[2]);
					break;
				}
				case "#b1":
				{
					XFacade.instance.openModule(ModuleName.IntroducePanel);
					break;
				}
				case "#ebl":
				{
					var obj:Object = DBUintUpgradeExp.getLevelAndExpByAllExp(Number(gmAr[1]),DBUintUpgradeExp.TYPE_HERO,1);
					trace("级别"+obj.level+"经验"+obj.exp+"当前级别需要升级经验"+obj.lexp);
					break;
				}
				case "#lbe":
				{
					var all:Number = DBUintUpgradeExp.getAllExpByLevelAndExp(Number(gmAr[1]), Number(gmAr[2]),DBUintUpgradeExp.TYPE_HERO,1);
					trace("换算经验："+all);
					break;
				}	
				case "#showFR":
				{
//					XFacade.instance.openModule(ModuleName.FightReportOverView);
//					XFacade.instance.openModule(ModuleName.EquipMainView);
//					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[1,1]);
//					var ar:Array = ItemManager.StringToReward("1=100;2=105;2=105");
////					ItemUtil.showItems(ar,view.closeBtn);
//					XFacade.instance.openModule(ModuleName.ShowRewardPanel,[ar]);
					XFacade.instance.openModule(ModuleName.NewUnitInfoView);
					break;
				}
				case "#setAllModel":
				{
					fightUnitData.allModel = gmAr[1];
					break;
				}
				case "#showAlert":
				{
//					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,gmAr[1]);
					XFacade.instance.openModule(ModuleName.ItemAlertView, ["aaaaaaaaaaaaaaa",
						0,
						0,
						function(){									
							
						}]
					);
					break;
					
				}
				
				case "#pvp":
				{
						XFacade.instance.openModule(ModuleName.PvpMainPanel);
				}
				default:
				{
					//服务器命令
//					super.sendData();
				}
			}
			
		}
		
		
		private function closeFun(e:Event = null):void{
			//			super.dispose();
			super.close();
		}
		
		
		public override function close():void {
			super.close();
		}
		
	}
}