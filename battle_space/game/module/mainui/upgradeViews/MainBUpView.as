package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_1UI;
	import MornUI.homeScenceView.BuildingUpgrade_B1UI;
	
	import game.common.base.BaseDialog;
	import game.global.data.DBBuildingNum;
	import game.global.data.DBBuildingUpgrade;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.module.mainScene.ArticleData;
	import game.module.mainui.infoViews.InfoViewFactory;
	
	import laya.events.Event;
	
	/**
	 * MainBUpView
	 * author:huhaiming
	 * MainBUpView.as 2017-4-18 上午9:57:04
	 * version 1.0
	 *
	 */
	public class MainBUpView extends BaseBUpView
	{
		public function MainBUpView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.vTF_0.innerHTML = _lvData.buldng_capacty+"";
			
			var nextVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level+1);
			var del:Number = parseInt(nextVo.buldng_capacty) - parseInt(_lvData.buldng_capacty);
			if(del != 0){
				this.view.vTF_0.innerHTML = _lvData.buldng_capacty+"\t<font color='#79ff8f'>+"+del+"</font>";
			}else{
				this.view.vTF_0.innerHTML = _lvData.buldng_capacty;
			}
			
			var maxVo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(_data.buildId, this._buildVo.level_limit);
			
			BaseBUpView.formatPro(view.bar_0,_lvData.buldng_capacty, nextVo.buldng_capacty, maxVo.buldng_capacty)
			
			//新增建筑
			var buildList:Array = DBBuildingNum.getNewBuingList(_data.level);
			view.newLabel.visible = false;
			for(var i:int=0; i<2; i++){
				if(buildList[i]){
					view.newLabel.visible = true;
					var buInfo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(buildList[i],1);
					this.view["new_"+i].skin = "appRes/building/"+buInfo.building_id+".png";
					this.view["new_"+i].mouseEnabled = true;
					this.view["new_"+i].name = 'tipX_'+buildList[i]
				}else{
					this.view["new_"+i].skin = ""
					this.view["new_"+i].mouseEnabled = false;
				}
			}
		}
		
		override protected function onClick(e:Event):void{
			super.onClick(e);
			if(e && e.target.name.indexOf("tipX_") != -1){
				var id:String = e.target.name.split("_")[1];
				var bdData:ArticleData = new ArticleData();
				bdData.buildId  = id;
				bdData.level = (User.getInstance().sceneInfo.getBuildingLv(bdData.buildId) || 1);
				InfoViewFactory.showInfo(bdData);
			}
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_B1UI();
			this.addChild(_view);
		}
		
		private function get view():BuildingUpgrade_B1UI{
			return this._view as BuildingUpgrade_B1UI;
		}
	}
}