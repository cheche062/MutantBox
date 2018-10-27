package game.module.chests
{
	import MornUI.chests.ChestsMainShowViewUI;
	import MornUI.componets.SkillItemUI;
	
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.starBar;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBSkill2;
	import game.global.data.DBUnitStar;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.fighting.BaseUnit;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.SkillVo;
	import game.module.camp.ProTipUtil;
	import game.module.tips.SkillTip;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.media.SoundChannel;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.utils.Tween;
	
	public class ChestsMainShowView extends Box
	{
		private var m_data:FightUnitVo;
		private var m_type:int;
		private var _starBar:starBar;
		private var m_ui:ChestsMainShowViewUI;
		private var _baseU:BaseUnit;
		private var _skillArr:Array;
		private var _selectEff:Animation;
		private var _heroEffect:Animation;
		public function ChestsMainShowView(p_ui:ChestsMainShowViewUI,p_data:FightUnitVo,p_type:int)
		{
			m_ui=p_ui;
			m_data=p_data;
			m_type=p_type;
			super();
			initUI();
			
		}
		
		/**初始化ui数据*/
		private function initUI():void
		{
			this.m_ui.NameText.text=m_data.name;
			this.m_ui.LigntImage.skin="chests/bg2_"+m_data.rarity+".png";
			this.m_ui.ContinueText.text=GameLanguage.getLangByKey("L_A_45011");
			this.m_ui.PopulationText.text=m_data.population.toString();
			this.m_ui.LegendaryImage.skin = "chests/pinzhi_" + m_data.rarity + ".png";
			this.m_ui.infoBg.skin = "chests/info_bg_" + m_data.rarity + ".png";
			if(m_data.rarity==1)
			{
				this.m_ui.LegendaryText.text=GameLanguage.getLangByKey("L_A_45000");
				this.m_ui.LegendaryText.color="#abff47"
			}
			else if(m_data.rarity==2)
			{
				this.m_ui.LegendaryText.color="#47e8ff"
				this.m_ui.LegendaryText.text=GameLanguage.getLangByKey("L_A_45001");
			}
			else if(m_data.rarity==3)
			{
				this.m_ui.LegendaryText.text=GameLanguage.getLangByKey("L_A_45002");
				this.m_ui.LegendaryText.color="#9a47ff"
			}
			else if(m_data.rarity==4)
			{
				this.m_ui.LegendaryText.text=GameLanguage.getLangByKey("L_A_45003");
				this.m_ui.LegendaryText.color="#ff4764"
			}
			else if(m_data.rarity==5)
			{
				this.m_ui.LegendaryText.text=GameLanguage.getLangByKey("L_A_45004");
				this.m_ui.LegendaryText.color="#ffa057"
			}
			else if(m_data.rarity==5)
			{
				this.m_ui.LegendaryText.text=GameLanguage.getLangByKey("L_A_45005");
				this.m_ui.LegendaryText.color="#ffea56"
			}
			if(_starBar==null)
			{
				this._starBar = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10,10);
				this.m_ui.HeroInfoBox.addChild(this._starBar);
			}
			setEffect();
			selectEff();
			_starBar.maxStar=m_data.star;
			_starBar.barValue=m_data.initial_star;
			this.m_ui.PlayerImage.skin=UnitPicUtil.getUintPic(m_data.unit_id,UnitPicUtil.PIC_FULL);
			this._starBar.pos(900-this.m_ui.HeroInfoBox.x,175-this.m_ui.HeroInfoBox.y);
			setUnitInfo();
			this.m_ui.HeroInfoBox.alpha=0;
			Tween.to(this.m_ui.HeroInfoBox, { alpha : 1 }, 500);
			var mp3Url = ResourceManager.getSoundUrl('ui_unit_upgrade','uiSound');
			SoundMgr.instance.playSound(mp3Url);
		}
		
		private function setEffect():void
		{
			//trace("setEffect");
			var jsonStr:String = "";	
			if(m_data.isHero)
			{
				jsonStr = "appRes/atlas/effects/drawCallHero.json";
			}
			else
			{
				jsonStr = "appRes/atlas/effects/drawCallSoldier.json";
			}
			if(_heroEffect==null)
			{
				_heroEffect=new Animation();
				m_ui.addChild(_heroEffect);
			}
			_heroEffect.loadAtlas(jsonStr);
			_heroEffect.play(0,false);
			_heroEffect.visible=true;
			_heroEffect.pos(0,0);
			_heroEffect.scaleX=1.7;
			_heroEffect.scaleY=1.7;
			_heroEffect.once(Event.COMPLETE,this,onCompleteHandler);
		}
		
		private function onCompleteHandler():void
		{
			// TODO Auto Generated method stub
			_heroEffect.visible=false;
		}
		
		private function setUnitInfo():void
		{
			m_ui.HeroProperty.attackTF.text = parseInt(m_data.ATK);
			m_ui.HeroProperty.critTF.text =  parseInt(m_data.crit);
			m_ui.HeroProperty.critDamageTF.text =  parseInt(m_data.CDMG);
			m_ui.HeroProperty.critDamReductTF.text =  parseInt(m_data.CDMGR);
			m_ui.HeroProperty.defenseTF.text =  parseInt(m_data.DEF);
			m_ui.HeroProperty.dodgeTF.text =  parseInt(m_data.dodge);
			m_ui.HeroProperty.hitTF.text =  parseInt(m_data.hit);
			m_ui.HeroProperty.hpTF.text =  parseInt(m_data.HP);
			m_ui.HeroProperty.resilienceTF.text =  parseInt(m_data.RES);
			m_ui.HeroProperty.speedTF.text =  parseInt(m_data.SPEED);
			
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
			if(XUtils.checkHit(m_ui.skillCom.item_0)){
				_skillArr[0] && XTipManager.showTip([_skillArr[0]],SkillTip, false);
			}else if(XUtils.checkHit(m_ui.skillCom.item_1)){
				_skillArr[1] && XTipManager.showTip([_skillArr[1]],SkillTip, false);
			}else if(XUtils.checkHit(m_ui.skillCom.item_2)){
				_skillArr[2] && XTipManager.showTip([_skillArr[2],true,m_data.unit_id],SkillTip, false);
			}
		}
		
		private function selectEff():Animation
		{	
			if(!_selectEff)
			{
				_selectEff = new Animation();
				_selectEff.autoPlay = true;
				_selectEff.mouseEnabled = _selectEff.mouseThrough = false;
				m_ui.addChild(_selectEff);
				_selectEff.x = 55;
				_selectEff.y = 252;
			}
			var jsonStr:String = "appRes/atlas/effects/chestEffects_"+m_data.rarity+".json";
			_selectEff.loadAtlas(jsonStr);
			return _selectEff;
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
				item.lvTF.text = vo.skill_level+"";
				if(vo){
					item.nameTF.text = vo.skill_name+"";
					item.icon.skin = "appRes/icon/skillIcon/"+vo.skill_icon+".png";
					
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
		
		public function resetAni():void{
			_selectEff.clear();
			_heroEffect.clear();
			
			Loader.clearRes("appRes/atlas/effects/chestEffects_1.json");
			Loader.clearRes("appRes/atlas/effects/chestEffects_2.json");
			Loader.clearRes("appRes/atlas/effects/chestEffects_3.json");
			Loader.clearRes("appRes/atlas/effects/chestEffects_4.json");
			Loader.clearRes("appRes/atlas/effects/chestEffects_5.json");
			Loader.clearRes("appRes/atlas/effects/chestEffects_6.json");
			Loader.clearRes("appRes/atlas/effects/drawCallHero.json");
			Loader.clearRes("appRes/atlas/effects/drawCallSoldier.json");
			this.m_ui.PlayerImage && Loader.clearRes(this.m_ui.PlayerImage.skin);
		}
		
		public function removeAction():void
		{
			if(_baseU!=null)
			{
				this.m_ui.removeChild(_baseU);
			}
		}
		
		
	}
}