package game.module.mainui.infoViews
{
	import MornUI.homeScenceView.BuildingUpgrade_2UI;
	
	import game.common.XFacade;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBBuildingAttribute;
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.SkillVo;
	import game.module.mainui.upgradeViews.BaseBUpView;
	
	import laya.html.dom.HTMLDivElement;
	
	/**
	 * DefendBIView
	 * author:huhaiming
	 * DefendBIView.as 2017-4-19 上午10:43:49
	 * version 1.0
	 *
	 */
	public class DefendBIView extends BaseBUpView
	{
		public function DefendBIView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			this.view.upBox.visible = false;
			this.view.tipBox.visible = false;
			this.view.infoTF.text = _buildVo.dec+"";
			view.defenceAreaTF.text  =GameLanguage.getLangByKey("L_A_54")+_lvData.param1
			
			var vo:Object = DBBuildingAttribute.getAttr(_lvData.buldng_stats);
			if(vo){
				view.dataInfo.attackTF.innerHTML = Math.round(vo.ATK)+"";
				view.dataInfo.critTF.innerHTML = Math.round(vo.crit) +"";
				view.dataInfo.critDamageTF.innerHTML = Math.round(vo.CDMG)+"";
				view.dataInfo.critDamReductTF.innerHTML = Math.round(vo.CDMGR)+"";
				view.dataInfo.defenseTF.innerHTML = Math.round(vo.DEF)+"";
				view.dataInfo.dodgeTF.innerHTML = Math.round(vo.dodge)+"";
				view.dataInfo.hitTF.innerHTML = Math.round(vo.hit)+"";
				view.dataInfo.hpTF.innerHTML = Math.round(vo.HP)+"";
				view.dataInfo.resilienceTF.innerHTML = Math.round(vo.RES)+"";
				view.dataInfo.speedTF.innerHTML = Math.round(vo.SPEED)+"";
				
				var skillInfo:SkillVo = GameConfigManager.unit_skill_dic[vo.skill];
				if(skillInfo){
					var str:String = "";
					str+=GameLanguage.getLangByKey(skillInfo.skill_describe);
					var tmp:Array = skillInfo.skill_value.split("|");
					for(var i:int=0; i<tmp.length; i++){
						str = str.replace(/{(\d+)}/,XUtils.toFixed(tmp[i]));
					}
					this.view.skillTF.text = str+"";
				}else{
					this.view.skillTF.text = "";
				}
			}
		}
		
		override public function createUI():void{
			this._view = new BuildingUpgrade_2UI();
			this.addChild(_view);
			
			var tmp:* = view.dataInfo
			for(var i:String in tmp){
				if(tmp[i] is HTMLDivElement){
					tmp[i].style.fontFamily = XFacade.FT_BigNoodleToo;
					tmp[i].style.fontSize = 18;
					tmp[i].style.color = "#ffffff";
					tmp[i].style.align = "right";
				}
			}
		}
		
		private function get view():BuildingUpgrade_2UI{
			return this._view as BuildingUpgrade_2UI;
		}
	}
}