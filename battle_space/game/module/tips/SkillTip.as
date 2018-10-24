package game.module.tips
{
	import MornUI.tips.SkillTipUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBSkill2;
	import game.global.data.DBUnitStar;
	import game.global.vo.SkillVo;
	import game.module.camp.CampData;
	
	import laya.net.URL;
	
	/**
	 * SkillTip
	 * author:huhaiming
	 * SkillTip.as 2017-5-22 下午4:37:17
	 * version 1.0
	 *
	 */
	public class SkillTip extends BaseDialog
	{
		public function SkillTip()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
			this._m_iPositionType = LayerManager.CENTER;
			this.bg.alpha = 0.01;
		}
		
		override public function show(...args):void{
			super.show();
			var id:* = args[0][0];
			var passive:Boolean = args[0][1];
			var vo:SkillVo = GameConfigManager.unit_skill_dic[id];
			view.skillBG.skin = "common/skill_bg.png";
			//兼容被动技能
			if(passive){
				vo = DBSkill2.getSkillInfo(id);
				view.skillBG.skin = "common/skill_bg1.png";
			}
			
			if(!vo){
				this.close();
				return;
			}
			
			view.nameTf.innerHTML = GameLanguage.getLangByKey(vo.skill_name)+" Lv."+vo.skill_level;
			view.icon.skin = URL.formatURL("appRes/icon/skillIcon/"+vo.skill_icon+".png");
			view.icon.gray = false;
			view.skillBG.gray = false;
			
			
			//
			var arr:Array = (vo.skill_value+"").split("|");
			var str:String = GameLanguage.getLangByKey(vo.skill_describe);
			for(var i:int=0; i<arr.length; i++){
				str = str.replace(/{(\d+)}/, XUtils.toFixed(arr[i]));
			}
			view.infoTF.text = str+"";
			var str:String = "";
			if(passive){
				view.bg.height = 200;
				view.line.visible = false;
				view.attLabel.visible = false;
				view.damLabel.visible = false;
				view.attIcon.visible = false;
				view.damIcon.visible = false;
				this.height = this.view.height = 200;
				
				var acted:Boolean = false;
				var unitId:* = args[0][2];
				if(unitId){
					var db:Object  = GameConfigManager.unit_json[unitId]
					var info:Object = (CampData.getUintById(unitId) || {});
					var starInfo:Object = DBUnitStar.getStarData(info.starId || db.star_id)
					var starLv:int = (starInfo?starInfo.star_level:1);
					
					var tmp:Array = ((db.skillId2 || db.skill2_id) +"").split(";");
					tmp = (tmp[0]+"").split("|");
					if(starLv >= tmp[1]){
						acted = true
					}else{
						str = GameLanguage.getLangByKey("L_A_745");
						str = str.replace(/{(\d+)}/,tmp[1]);
					}
				}
				if(!acted){
					view.icon.gray = true;
					view.skillBG.gray = true;
					view.nameTf.innerHTML = GameLanguage.getLangByKey(vo.skill_name)+"<font color='#ff0000'>"+str+"</font>";
				}
				trace("str----------------------------------->>",acted,str)
			}else{
				view.line.visible = true;
				view.attLabel.visible = true;
				view.damLabel.visible = true;
				view.attIcon.visible = true;
				view.damIcon.visible = true;
				
				this.view.line.y = Math.max(180,view.infoTF.y + view.infoTF.height);
				view.attLabel.y = view.damLabel.y = this.view.line.y+22;
				view.attIcon.y = view.damIcon.y = view.attLabel.y+view.attLabel.height+10;
				view.bg.height = view.attIcon.y + 60;
				this.height = this.view.height = view.bg.height
				view.attIcon.skin = URL.formatURL("appRes/icon/skillRange/"+vo.skill_node+"_1.png");
				view.damIcon.skin = URL.formatURL("appRes/icon/skillRange/"+vo.skill_node+"_2.png");
			}
			
			LayerManager.instence.setPosition(this, this._m_iPositionType);
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new SkillTipUI();
			this.addChild(this._view);
			view.infoTF.autoSize = true;
			
			view.nameTf.style.fontFamily = XFacade.FT_BigNoodleToo;
			view.nameTf.style.fontSize = 28;
			view.nameTf.style.color = "#ffffff";
			
			this.mouseEnabled = true;
			closeOnBlank = true;
		}
		
		private function get view():SkillTipUI{
			return this._view as SkillTipUI;
		}
	}
}