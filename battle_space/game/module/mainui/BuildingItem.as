package game.module.mainui
{
	import MornUI.homeScenceView.BuildingItemUI;
	
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingNum;
	import game.global.data.DBBuildingUpgrade;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.BuildingVo;
	import game.global.vo.User;
	
	import laya.display.Text;
	import laya.net.URL;
	import laya.ui.UIUtils;
	
	/**
	 * BuildingItem 建筑单元条，人工布局
	 * author:huhaiming
	 * BuildingItem.as 2017-3-6 下午2:19:05
	 * version 1.0
	 *
	 */
	public class BuildingItem extends BuildingItemUI
	{
		
		private var _data:BuildingVo;
		//记录消耗
		private var _cost1:Number;
		private var _cost2:Number;
		//是否已达最大数量
		private var _isMax:Boolean;
		/**定义宽度*/
		public static const WIDTH:Number = 267;
		/**定义高度*/
		public static const HEIGHT:Number = 364;
		public function BuildingItem()
		{
			super();
		}
		
		/**赋值*/
		public function set data(v:BuildingVo):void{
			this._data = v;
			this.fullTF.text = this.lockTF.text = "";
			var tmp:Array;
			if(this._data){
				//
				var buildInfo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(data.building_id,1);
				if(!buildInfo){
					//alert("====>>"+_data.building_id);
					return;
				}else{
					this.icon.skin = URL.formatURL("appRes/building/"+data.building_id+".png");
				}
				this.nameTF.text = GameLanguage.getLangByKey(_data.name);
				this.desTF.text = GameLanguage.getLangByKey(_data.dec_s);
				
				this.expTF.text = parseInt(buildInfo.get_exp)+"";
				var maxNum:Number;
				var curMax:Number;
				var curNum:Number;
				var sceInfo:SceneVo = User.getInstance().sceneInfo;
				if(data.building_id == DBBuilding.B_BASE){
					maxNum = curNum = 1;
				}else{
					var baseLv:Number = sceInfo.getBaseLv();
					maxNum = DBBuildingNum.getBuildingMax(data.building_id);
					curMax = DBBuildingNum.getBuildingNum(data.building_id, baseLv);
					curNum = sceInfo.getBuildingNum(data.building_id);
				}
				
				
				UIUtils.gray(this, false);
				if(curNum >= maxNum || maxNum == 0){
					this.buildSp.visible = false;
					UIUtils.gray(this);
					this._isMax = true;	
					this.fullTF.text = GameLanguage.getLangByKey("L_A_12");
				}else{
					if(curNum >= curMax){
						this.buildSp.visible = false;
						this._isMax = true;	
						UIUtils.gray(this);
						var str:String = GameLanguage.getLangByKey("L_A_11");
						str = str.replace(/{(\d+)}/g, DBBuildingNum.getBaseLv(data.building_id, curNum+1));
						
						if(buildInfo.param1 && buildInfo.param1.indexOf("=")!=-1 && data.building_id.replace("B","") == DBBuilding.B_GENE){
							tmp = (buildInfo.param1+"").split("=");
							str = GameLanguage.getLangByKey("L_A_22");
							str = str.replace(/{(\d+)}/g, tmp[1]);
							
						}
						
						this.lockTF.text = str+"";
						
					}else{
						this._isMax = false;
						if(buildInfo.param1 && buildInfo.param1.indexOf("=")!=-1 && data.building_id.replace("B","") == DBBuilding.B_GENE){
							var tmp:Array = buildInfo.param1.split("=");
							trace("DBBuilding.B_GENE-----------------------------------------------",tmp);
							if(tmp.length > 1){
								if(sceInfo.getBuildingLv(tmp[0]) < parseInt(tmp[1])){//等级不足
									this.buildSp.visible = false;
									//bg.skin = "buildingMenu/bg1.png"
									UIUtils.gray(this);
									str = GameLanguage.getLangByKey("L_A_22");
									str = str.replace(/{(\d+)}/g, tmp[1]);
									this.lockTF.text = str+"";
									this._isMax = true;	
								}else{
									//bg.skin = "buildingMenu/bg2.png"
									this.buildSp.visible = true;
									if(buildInfo.cost1){
										tmp = buildInfo.cost1.split("=")
										this._cost1 = tmp[1]
										steelTF.text = XUtils.formatNumWithSign(this._cost1);
										//需要根据数量判定颜色，并且判定是否可以建造
										if(User.getInstance().getResNumByItem(tmp[0]) < this._cost1){
											steelTF.color = "#ff0000";
										}else{
											steelTF.color = "#ffffff";
										}
										ItemUtil.formatIcon(this.steelIcon, buildInfo.cost1);
									}
									if(buildInfo.cost2){
										tmp = buildInfo.cost2.split("=")
										this._cost2 = tmp[1];
										stoneTF.text = XUtils.formatNumWithSign(this._cost2);
										ItemUtil.loadIcon(this.stoneIcon, buildInfo.cost2);
										//需要根据数量判定颜色，并且判定是否可以建造
										if(User.getInstance().getResNumByItem(tmp[0]) < this._cost2){
											stoneTF.color = "#ff0000";
										}else{
											stoneTF.color = "#ffffff";
										}
									}
									timeTF.text = TimeUtil.getTimeStr(buildInfo.CD*60*1000);					
								}
							}
						}else{
							//bg.skin = "buildingMenu/bg2.png"
							this.buildSp.visible = true;
							if(buildInfo.cost1){
								tmp = buildInfo.cost1.split("=")
								this._cost1 = tmp[1]
								steelTF.text = XUtils.formatNumWithSign(this._cost1);
								ItemUtil.loadIcon(this.steelIcon, buildInfo.cost1);
								//需要根据数量判定颜色，并且判定是否可以建造
								if(User.getInstance().getResNumByItem(tmp[0]) < this._cost1){
									steelTF.color = "#ff0000";
								}else{
									steelTF.color = "#ffffff";
								}
								if(buildInfo.ornot != 1){
									steelTF.text = User.getInstance().getResNumByItem(tmp[0]) + "/" +this._cost1
								}
							}else{
								steelTF.text = "";
								ItemUtil.formatIcon(this.stoneIcon, buildInfo.cost2);
							}
							if(buildInfo.cost2){
								tmp = buildInfo.cost2.split("=")
								this._cost2 = tmp[1];
								stoneTF.text = XUtils.formatNumWithSign(this._cost2);
								ItemUtil.formatIcon(this.stoneIcon, buildInfo.cost2);
								//需要根据数量判定颜色，并且判定是否可以建造
								if(User.getInstance().getResNumByItem(tmp[0]) < this._cost2){
									stoneTF.color = "#ff0000";
								}else{
									stoneTF.color = "#ffffff";
								}
							}else{
								stoneTF.text = "";
								ItemUtil.formatIcon(this.stoneIcon, buildInfo.cost2);
							}
							timeTF.text = TimeUtil.getShortTimeStr(buildInfo.CD*1000);						
						}
					}
				}
				if(maxNum == 0){
					this.numTF.text = "";
				}else{
					this.numTF.text = curNum+"/"+maxNum;
				}
			}
			this.cacheAsBitmap = true;
		}
		
		/***/
		public function get canBuild():Boolean{
			return DBBuildingUpgrade.checkCanUp(parseInt(data.building_id), 0) && !isMax;
		}
		
		public function get data():BuildingVo{
			return this._data;
		}
		
		public function get isMax():Boolean{
			return DBBuildingUpgrade.isMax(data.building_id);
		}
		
		public function get isMaxNum():Boolean{
			return DBBuildingUpgrade.isMaxNum(data.building_id);
		}
	}
}