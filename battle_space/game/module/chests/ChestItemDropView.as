package game.module.chests
{
	import MornUI.chests.ChestItemDropViewUI;
	import MornUI.componets.SkillItemUI;
	
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.data.DBSkill2;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.vo.FightUnitVo;
	import game.global.vo.ItemVo;
	import game.global.vo.SkillVo;
	import game.module.camp.ProTipUtil;
	import game.module.camp.UnitItem;
	import game.module.tips.SkillTip;
	import game.module.train.TrainItem;
	
	import laya.ui.Box;
	
	public class ChestItemDropView extends Box
	{
		private var m_ui:ChestItemDropViewUI;
		private var m_arr:Array;
		private var m_data:FightUnitVo;
		private var _skillArr:Array;
		public function ChestItemDropView(p_ui:ChestItemDropViewUI,p_arr:Array)
		{
			m_ui=p_ui;
			m_arr=p_arr;
			super();
			initUI();
		}
		
		/**初始化ui数据*/
		private function initUI():void
		{
			this.m_ui.HeroList.itemRender=TrainItem;
			this.m_ui.HeroList.selectEnable=true;
			this.m_ui.HeroList.vScrollBarSkin="";
			this.m_ui.HeroList.array=m_arr;
		}
		
		/**
		 * 修改掉落
		 */
		public function setHeroList(p_arr:Array):void
		{
			this.m_ui.HeroList.itemRender=TrainItem;
			this.m_ui.HeroList.array=p_arr;
		}
		
		
		/**
		 * 选择物品
		 */
		public function getIItemInfo(p_itemData:FightUnitVo):void
		{
			var l_hero:FightUnitVo=p_itemData;
			var l_arr:Array=new Array();
			
			if(l_hero!=null)
			{
				m_ui.SelectList.visible=true;
				m_data=l_hero;
				l_arr.push(l_hero);
				m_ui.SelectList.itemRender=UnitItem;
				m_ui.SelectList.array=l_arr;
				var l_cell:UnitItem=m_ui.SelectList.getCell(0);
				l_cell.mPic.visible=false;
				l_cell.rebornBtn.visible=false;
				l_cell.stateTF.visible=false;
				l_cell.stateIcon.visible=false;
				setUnitInfo(l_hero);
				var tmp:Array = (m_data.skill_id+"").split("|");
				if(_skillArr){
					_skillArr.length = 0;
				}else{
					_skillArr = [];
				}
				formatSkill(m_ui.skillCom.item_0, tmp[0]); 
				formatSkill(m_ui.skillCom.item_1, tmp[1]);
				_skillArr.push(tmp[0], tmp[1]);
				tmp = (m_data.skill2_id+"").split(";");
				tmp = (tmp[0]+"").split("|")
				formatSkill(m_ui.skillCom.item_2, tmp[0],tmp[1]);
				if(tmp.length && tmp[0]+"" != "undefined"){
					_skillArr.push(tmp[0]);
				}
				setSkillPosition();
			}
			else
			{
				m_ui.SelectList.visible=false;
				m_ui.HeroProperty.attackTF.text = "";
				m_ui.HeroProperty.critTF.text = "";
				m_ui.HeroProperty.critDamageTF.text = "";
				m_ui.HeroProperty.critDamReductTF.text = "";
				m_ui.HeroProperty.defenseTF.text = "";
				m_ui.HeroProperty.dodgeTF.text = "";
				m_ui.HeroProperty.hitTF.text = "";
				m_ui.HeroProperty.hpTF.text = "";
				m_ui.HeroProperty.resilienceTF.text = "";
				m_ui.HeroProperty.speedTF.text = "";
				m_ui.skillCom.visible=false;
			}
		}
		
		/**设定位置*/
		private function setSkillPosition():void{
			if(m_ui.skillCom.item_1.visible){
				m_ui.skillCom.item_0.x = 7;
				m_ui.skillCom.item_2.x = 245;
			}else{
				m_ui.skillCom.item_0.x = 50;
				m_ui.skillCom.item_2.x = 210;
			}
		}
		
		
		public function onClickSkill():void
		{
			m_ui.skillCom.visible=true;
			if(XUtils.checkHit(m_ui.skillCom.item_0)){
				_skillArr[0] && XTipManager.showTip([_skillArr[0]],SkillTip, false);
			}else if(XUtils.checkHit(m_ui.skillCom.item_1)){
				_skillArr[1] && XTipManager.showTip([_skillArr[1]],SkillTip, false);
			}else if(XUtils.checkHit(m_ui.skillCom.item_2)){
				_skillArr[2] && XTipManager.showTip([_skillArr[2],true,m_data.unit_id],SkillTip, false);
			}
		}

		private function setUnitInfo(p_data:FightUnitVo):void
		{
			m_ui.HeroProperty.attackTF.text = parseInt(p_data.ATK);
			m_ui.HeroProperty.critTF.text = parseInt(p_data.crit);
			m_ui.HeroProperty.critDamageTF.text = parseInt(p_data.CDMG);
			m_ui.HeroProperty.critDamReductTF.text = parseInt(p_data.CDMGR);
			m_ui.HeroProperty.defenseTF.text = parseInt(p_data.DEF);
			m_ui.HeroProperty.dodgeTF.text = parseInt(p_data.dodge);
			m_ui.HeroProperty.hitTF.text = parseInt(p_data.hit);
			m_ui.HeroProperty.hpTF.text = parseInt(p_data.HP);
			m_ui.HeroProperty.resilienceTF.text = parseInt(p_data.RES);
			m_ui.HeroProperty.speedTF.text = parseInt(p_data.SPEED);
			ProTipUtil.addTip(m_ui.HeroProperty, m_data);
		}
		
		private function formatSkill(item:SkillItemUI, skillId:*, starLv:int=-1):void{
			if(skillId && skillId != "undefined"){
				item.visible = true;
				var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId];
				//兼容被动技能
				if(starLv != -1){
					vo = DBSkill2.getSkillInfo(skillId);
					item.skillBg.skin = "common/skill_bg1.png";
					item.lvBG.skin = "common/skill_bg1_1.png";
				}else{
					item.skillBg.skin = "common/skill_bg.png";
					item.lvBG.skin = "common/skill_bg_1.png";
				}
				

				if(vo){
					item.nameTF.text = vo.skill_name+"";
					item.icon.skin = "appRes/icon/skillIcon/"+vo.skill_icon+".png";
					item.lvTF.text = vo.skill_level+"";
				}else{
					item.nameTF.text = "NoDataSource"
				}
				if(this.m_data && this.m_data.initial_star>= starLv){
					item.gray = false
				}else{
					item.gray = true;
				}
			}else{
				item.visible = false;
			}
		}
	}
}