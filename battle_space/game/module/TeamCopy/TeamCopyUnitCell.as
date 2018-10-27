package game.module.TeamCopy
{
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.data.DBUnit;
	import game.global.data.DBUnitStar;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.teamCopy.TeamCopySoldierVo;
	import game.module.camp.UnitItem;
	
	public class TeamCopyUnitCell extends UnitItem
	{
		public var teamCopyData:TeamCopySoldierVo;
		
		public function TeamCopyUnitCell()
		{
			super();
		}
		
		/**value Object类型 ，必须有key——"id/unitId/unit_id"*/
		override public function set dataSource(value:*):void{
//			super.dataSource=value;
			teamCopyData=value;
			if(value==null)
			{
				minusBtn.visible=false;
				this.FightingText.visible=false;
				this.FightingImage.visible=false;
				this.FightingBgImage.visible=false;
				attackIcon.visible=false;
				defendIcon.visible=false;
				this._starLv.visible=false;
				this.LevelText.visible=false;
				this.HeroImage.skin="";
				bg.gray=true;
				AddBtn.visible=true;
				iconCamp.skin = ""
			}
			else
			{
				bg.gray=false;
				AddBtn.visible=false;
				this._starLv.visible=true;
				if(teamCopyData.isOwn==true)
				{
					this.minusBtn.visible=true;
				}
				else
				{
					this.minusBtn.visible=false;
				}
				var fightvo:FightUnitVo=GameConfigManager.unit_json[teamCopyData.unitId];
				_starLv.maxStar = fightvo.star;
				if(_starLv.maxStar > 5){
					this._starLv.y = 126;
				}else{
					this._starLv.y = 130;
				}
				this.FightingText.visible=false;
				this.FightingImage.visible=false;
				this.FightingBgImage.visible=false;
				var vo:Object = DBUnitStar.getStarData(teamCopyData.starLevel);
				_starLv.barValue=vo.star_level;
				LevelText.text=GameLanguage.getLangByKey("L_A_73")+teamCopyData.level;
				bg.skin = "common/bg6_"+(fightvo.rarity)+".png";
//				if(fightvo.unit_type == DBUnit.TYPE_HERO){
//					bg.skin = "common/bg6_hero.png";
//				}else{
//					bg.skin = "common/bg6_"+(fightvo.rarity)+".png";
//				}
				HeroImage.skin=UnitPicUtil.getUintPic(teamCopyData.unitId,UnitPicUtil.PIC_HALF);
				iconCamp.skin = "common/icons/camp_1"+fightvo.camp+".png"
			}
		}
		
	}
}