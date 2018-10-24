package game.module.fighting.cell
{
	import MornUI.fightingView.failureCellUiUI;
	
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.module.fighting.panel.FightResultPanel;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class failureCell extends failureCellUiUI
	{
		public static const itemWidth:Number = 107;
		public static const itemHeight:Number = 107;
		private var _data:Object;
		
		public function failureCell()
		{
			super();
			this.cellBtn.clickHandler = Handler.create(this,this.btnClick,null,false);
		}
		
		
		public override function set dataSource(value:*):void{
			super.dataSource = _data = value;
			
			if(_data)
			{
				this.cellBtn.label = String(_data.name);
				this.iconImg.graphics.clear();
				var url:String = "appRes/icon/failureIcon/"+_data.icon+".png"
				this.iconImg.loadImage(
					url
				);
			}
		}
		
		public function btnClick(e:Event):void{
			if(!_data)
			{
				trace("failureCell _data null");
				return ;
			}
			var aid:Number = Number(_data.id);
			
			switch(aid)
			{
				case 1: //升星
					XFacade.instance.openModule("CampView");
					break;
				case 2://基因
					XFacade.instance.openModule("GeneView");
					break;
				case 3://装备养成
					XFacade.instance.openModule("EquipMainView");
					break;
				case 4://科技
					XFacade.instance.openModule(ModuleName.TechTreeMainView);
					break;
				case 5://升级
					XFacade.instance.openModule("LevelUpView");
					break;
				case 6://首冲
					XFacade.instance.openModule(ModuleName.FirstChargeView);
					break;
				case 7://活动
					XFacade.instance.openModule(ModuleName.ActivityMainView);
					break;
				default:
					break;
			}
			
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			XFacade.instance.closeModule(FightResultPanel);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy failureCell");
			_data = null;
			super.destroy(destroyChild);
		}
		
		
	}
}