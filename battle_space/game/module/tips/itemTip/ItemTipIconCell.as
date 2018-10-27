package game.module.tips.itemTip
{
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.module.tips.itemTip.base.BaseItemTipCell;
	
	import laya.display.Stage;
	import laya.ui.Image;
	import laya.ui.Label;
	
	public class ItemTipIconCell extends BaseItemTipCell
	{
		private var iconBg:Image;
		private var flag:Image;
		private var itemIcon:Image;
		private var nameLab:Label;
		private var heroNameOnly:Label;
		private var level:Label;
		private var equipLevel:Label;
		
		public function ItemTipIconCell()
		{
			super();
			
			size(232,95);
		}
		
		
		public override function bindData():void{
			if(!iconBg)
			{
				iconBg = new Image();
				addChild(iconBg);
				iconBg.size(79,79);
				iconBg.pos(10,height - iconBg.height >> 1);
			}
			if(!flag)
			{
				flag = new Image();
				iconBg.addChild(flag);
//				flag.pos(17,3)
			}
			if(!itemIcon)
			{
				itemIcon = new Image();
				iconBg.addChild(itemIcon);
				itemIcon.pos(-13,-13)
			}	
			
			var obj:Object = JSON.parse(data);
			iconBg.skin = "common/item_bg0.png";
			flag.skin = "common/item_bar"+(obj.quality-1)+".png";
			var equipvo:EquipmentListVo=GameConfigManager.EquipmentList[obj.id];
			var l_fightVo:FightUnitVo=GameConfigManager.unit_dic[equipvo.hero];
			
			if(equipvo!=null)
			{
				if(!nameLab)
				{
					nameLab=new Label();
					nameLab.font = XFacade.FT_Futura;
					nameLab.fontSize = 14;
					nameLab.color = "#9fd5ff";
					nameLab.width = width;
					nameLab.align = Stage.ALIGN_CENTER;
					nameLab.y=12;
					nameLab.x=35;
					addChild(nameLab);
				}
				nameLab.text=GameLanguage.getLangByKey("L_A_"+parseInt(48006+equipvo.location));	
				if(!heroNameOnly)
				{
					heroNameOnly=new Label();
					heroNameOnly.font = XFacade.FT_Futura;
					heroNameOnly.fontSize = 14;
					heroNameOnly.color = "#9fd5ff";
					heroNameOnly.width = width;
					heroNameOnly.align = Stage.ALIGN_CENTER;
					
					heroNameOnly.y=30;
					heroNameOnly.x=35;
					addChild(heroNameOnly);
				}
				heroNameOnly.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_48013"),GameLanguage.getLangByKey(l_fightVo.name));
				if(!level)
				{
					level=new Label();
					level.font = XFacade.FT_Futura;
					level.fontSize = 14;
					level.color = "#9fd5ff";
					level.width = width;
					level.align = Stage.ALIGN_CENTER;
					level.y=48;
					level.x=35;
					addChild(level);
				}
				if(equipvo.level<=obj.playerLevel)
				{
					level.color = "#9fd5ff";
				}
				else
				{
					level.color = "#ff7d7d";
				}
				level.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_48015"),obj.level);
				if(!equipLevel)
				{
					equipLevel=new Label();
					equipLevel.font = XFacade.FT_Futura;
					equipLevel.fontSize = 14;
					if(equipvo.level>=obj.playerLevel)
					{
						equipLevel.color = "#9fd5ff";
					}
					else
					{
						equipLevel.color = "#ff7d7d";
					}
					equipLevel.width = width;
					equipLevel.align = Stage.ALIGN_CENTER;
					equipLevel.y=66;
					equipLevel.x=35;
					addChild(equipLevel);
				}
				if(equipvo.level<=obj.playerLevel)
				{
					equipLevel.color = "#9fd5ff";
				}
				else
				{
					equipLevel.color = "#ff7d7d";
				}
				equipLevel.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_48014"),equipvo.level);
			}
			else
			{
				if(name)
				{
					name.visible=false;
				}
				if(heroNameOnly)
				{
					heroNameOnly.visible=false;
				}
				if(level)
				{
					level.visible=false;
				}
				if(equipLevel)
				{
					equipLevel.visible=false;
				}
			}
			
			itemIcon.graphics.clear();
			itemIcon.loadImage(obj.icon);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy ItemTipIconCell");
			iconBg = null;
			flag = null;
			itemIcon = null;
			nameLab = null;
			heroNameOnly = null;
			level = null;
			equipLevel = null;
			super.destroy(destroyChild);
		}
	}
}