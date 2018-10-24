package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.BuildingUpgrade_1UI;
	import MornUI.homeScenceView.BuildingUpgrade_2UI;
	
	import game.common.ItemTips;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBBuildingAttribute;
	import game.global.data.DBBuildingUpgrade;
	import game.global.vo.SkillVo;
	import game.module.camp.ProTipUtil;
	
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;

	/**
	 * DenfendBUView 箭塔啥的
	 * author:huhaiming
	 * DenfendBUView.as 2017-4-18 下午4:17:52
	 * version 1.0
	 *
	 */
	public class DefendBUView extends BaseBUpView
	{
		public function DefendBUView()
		{
			super();
		}
		
		override protected function format():void{
			super.format();
			var vo:Object = DBBuildingAttribute.getAttr(_lvData.buldng_stats);
			var tmp:Object = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level+1);
			var nextVo:Object
			if(tmp){
				nextVo = DBBuildingAttribute.getAttr(tmp.buldng_stats);
			}
			if(vo){
				if(nextVo){
					var tmpObj:Object = XUtils.copyObj(nextVo);
					tmpObj = XUtils.separateObj(tmpObj, vo);
					view.dataInfo.attackTF.innerHTML = Math.round(vo.ATK)+"\t<font color='#79ff8f'>+"+tmpObj.ATK+"</font>";
					view.dataInfo.critTF.innerHTML = Math.round(vo.crit) +"\t<font color='#79ff8f'>+"+tmpObj.crit+"</font>";
					view.dataInfo.critDamageTF.innerHTML = Math.round(vo.CDMG)+"\t<font color='#79ff8f'>+"+tmpObj.CDMG+"</font>";
					view.dataInfo.critDamReductTF.innerHTML = Math.round(vo.CDMGR)+"\t<font color='#79ff8f'>+"+tmpObj.CDMGR+"</font>";
					view.dataInfo.defenseTF.innerHTML = Math.round(vo.DEF)+"\t<font color='#79ff8f'>+"+tmpObj.DEF+"</font>";
					view.dataInfo.dodgeTF.innerHTML = Math.round(vo.dodge)+"\t<font color='#79ff8f'>+"+tmpObj.dodge+"</font>";
					view.dataInfo.hitTF.innerHTML = Math.round(vo.hit)+"\t<font color='#79ff8f'>+"+tmpObj.hit+"</font>";
					view.dataInfo.hpTF.innerHTML = Math.round(vo.HP)+"\t<font color='#79ff8f'>+"+tmpObj.HP+"</font>";
					view.dataInfo.resilienceTF.innerHTML = Math.round(vo.RES)+"\t<font color='#79ff8f'>+"+tmpObj.RES+"</font>";
					view.dataInfo.speedTF.innerHTML = Math.round(vo.SPEED)+"\t<font color='#79ff8f'>+"+tmpObj.SPEED+"</font>";
				}else{
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
				}
				view.defenceAreaTF.text  ="Defence Area:"+_lvData.param1
				var skillInfo:SkillVo = GameConfigManager.unit_skill_dic[vo.skill];
				if(skillInfo){
					var str:String = "";
					str+=GameLanguage.getLangByKey(skillInfo.skill_describe);
					tmp = skillInfo.skill_value.split("|");
					for(var i:int=0; i<tmp.length; i++){
						str = str.replace(/{(\d+)}/,XUtils.toFixed(tmp[i]));
					}
					this.view.skillTF.text = str+"";
				}else{
					this.view.skillTF.text = "";
				}
				
				trace("vo........................................",vo);
				//ProTipUtil.addTip(view.dataInfo, vo)
			}
		}
		
		override protected function showTip():void{
			if(XUtils.checkHit(view.upBox.icon_0)){
				var id:* = (_nextLvData.cost1+"").split("=")[0]
				id && ItemTips.showTip(id);
				//XTipManager.showTip(GameLanguage.getLangByKey("L_A_400001"));
			}else if(XUtils.checkHit(view.upBox.icon_1)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_400002"));
			}else if(XUtils.checkHit(view.upBox.expIcon)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_44"));
			}else if(XUtils.checkHit(view.upBox.icon_2)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_46"));
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
		
		override public function addEvent():void{
			super.addEvent();
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			ProTipUtil.removeTip(view.dataInfo);
		}
		
		private function get view():BuildingUpgrade_2UI{
			return this._view as BuildingUpgrade_2UI;
		}
	}
}