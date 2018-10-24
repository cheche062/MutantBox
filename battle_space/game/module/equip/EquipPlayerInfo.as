package game.module.equip
{
	import MornUI.equip.EquipPlayerInfoUI;
	import MornUI.friend.ChatInfoCellUI;
	import MornUI.friend.FriendRequestCellUI;
	
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.starBar;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.DBSkill2;
	import game.global.data.DBUnitStar;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.SkillVo;
	import game.global.vo.equip.EquipInfoVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.EquipmentSuitVo;
	import game.global.vo.equip.HeroEquipVo;
	import game.global.vo.friend.ChatVo;
	import game.module.camp.ProTipUtil;
	
	import laya.display.Animation;
	import laya.display.Stage;
	import laya.display.Text;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.Panel;
	import laya.utils.Dictionary;
	
	public class EquipPlayerInfo extends Box
	{
		private var m_ui:EquipPlayerInfoUI;
		private var m_data:Object;
		private var m_isShow:Boolean;
		private var m_playerEquipVo:HeroEquipVo;
		private var m_sult:Array;
		private var _starBar:starBar;
		private var m_BR:int;
		private var _selectEff:Animation;
		
		private var m_panel:Panel;
		
		
		public function EquipPlayerInfo(p_ui:EquipPlayerInfoUI,p_data:Object)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			initUI();
		}
		
		public function update(p_data:Object)
		{
			m_data=p_data;
			initUI();
		}
		
		
		private function initUI():void
		{
			var l_vo:FightUnitVo=GameConfigManager.unit_dic[m_data.unitId];
			this.m_ui.NameText.text=l_vo.name;
			//保证内存
			var url:String = UnitPicUtil.getUintPic(m_data.unitId,UnitPicUtil.PIC_FULL);
			if(this.m_ui.PlayerImage.skin != url){
				Loader.clearRes(this.m_ui.PlayerImage.skin)
			}
			this.m_ui.PlayerImage.skin="";
			this.m_ui.PlayerImage.skin = url;
			this.m_ui.LevelText.text=GameLanguage.getLangByKey("L_A_73")+m_data.level;
			if(_starBar==null)
			{
				this._starBar = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10,5);
				this.m_ui.addChild(this._starBar);
			}
			var obj = DBUnitStar.getStarData(m_data.starId);
			_starBar.maxStar=l_vo.star;
			_starBar.barValue=obj.star_level;
			this._starBar.pos(410,42);
			playerProperty();
			setSultInfo(false);
			m_ui.eff.skin="";
			m_ui.eff.skin="equip/bg0_"+l_vo.rarity+".png";
			selectEff(l_vo.rarity);
//			trace("稀有度"+l_vo.rarity);
		}
		
		private function playerProperty():void
		{
			this.m_ui.ValueText0.text=m_data.hp;
			this.m_ui.ValueText1.text=m_data.attack;
			this.m_ui.ValueText2.text=m_data.hit;
			this.m_ui.ValueText3.text=m_data.crit;
			this.m_ui.ValueText4.text=m_data.critDamage;
			this.m_ui.RightValueText0.text=m_data.defense;
			this.m_ui.RightValueText1.text=m_data.speed;
			this.m_ui.RightValueText2.text=m_data.dodge;
			this.m_ui.RightValueText3.text=m_data.resilience;
			this.m_ui.RightValueText4.text=m_data.critDamReduct;
			m_ui.icon_0.skin="common/icons/HP.png";
			m_ui.icon_1.skin="common/icons/ATK.png";
			m_ui.icon_4.skin="common/icons/hit.png";
			m_ui.icon_7.skin="common/icons/crit.png";
			m_ui.icon_6.skin="common/icons/CDMG.png";
			m_ui.icon_2.skin="common/icons/DEF.png";
			m_ui.icon_3.skin="common/icons/SPEED.png";
			m_ui.icon_5.skin="common/icons/dodge.png";
			m_ui.icon_8.skin="common/icons/RES.png";
			m_ui.icon_9.skin="common/icons/CDMGR.png";
			ProTipUtil.addTip(m_ui, m_data);
		}
		
		public function setEquipAddProperty(p_vo:HeroEquipVo):void
		{
			m_BR=0;
			m_playerEquipVo=p_vo;
			for(var i:int=0;i<5;i++)
			{
				var text:Text=this.m_ui.LeftPropertyBox.getChildByName("ValueAddText"+i)as Text;
				var text1:Text=this.m_ui.RightPropertyBox.getChildByName("RightValueAddText"+i)as Text;
				text.text="(0)";
				text1.text="(0)";
			}
			
			
			if(p_vo!=null)
			{
				var l_dic:Dictionary=p_vo.getEquipProperty();
				if(l_dic["HP"]!=null)
				{
					this.m_ui.ValueAddText0.text="("+l_dic["HP"]+")";
					m_BR+=parseInt(l_dic["HP"])*parseInt(GameConfigManager.UnitParameterList["hp_BR"].value);
				}
				if(l_dic["ATK"]!=null)
				{
					this.m_ui.ValueAddText1.text="("+l_dic["ATK"]+")";
					m_BR+=parseInt(l_dic["ATK"])*parseInt(GameConfigManager.UnitParameterList["attack_BR"].value);
				}
				if(l_dic["hit"]!=null)
				{
					this.m_ui.ValueAddText2.text="("+l_dic["hit"]+")";
					m_BR+=parseInt(l_dic["hit"])*parseInt(GameConfigManager.UnitParameterList["hit_BR"].value);
				}
				if(l_dic["crit"]!=null)
				{
					this.m_ui.ValueAddText3.text="("+l_dic["crit"]+")";
					m_BR+=parseInt(l_dic["crit"])*parseInt(GameConfigManager.UnitParameterList["crit_BR"].value);
				}
				if(l_dic["CDMG"]!=null)
				{
					this.m_ui.ValueAddText4.text="("+l_dic["CDMG"]+")";
					m_BR+=parseInt(l_dic["CDMG"])*parseInt(GameConfigManager.UnitParameterList["critical_damage_BR"].value);
				}
				if(l_dic["DEF"]!=null)
				{
					this.m_ui.RightValueAddText0.text="("+l_dic["DEF"]+")";
					m_BR+=parseInt(l_dic["DEF"])*parseInt(GameConfigManager.UnitParameterList["defense_BR"].value);
				}
				if(l_dic["SPEED"]!=null)
				{
					this.m_ui.RightValueAddText1.text="("+l_dic["SPEED"]+")";
					m_BR+=parseInt(l_dic["SPEED"])*parseInt(GameConfigManager.UnitParameterList["speed_BR"].value);
				}
				if(l_dic["dodge"]!=null)
				{
					this.m_ui.RightValueAddText2.text="("+l_dic["dodge"]+")";
					m_BR+=parseInt(l_dic["dodge"])*parseInt(GameConfigManager.UnitParameterList["dodge_BR"].value);
				}
				if(l_dic["RES"]!=null)
				{
					this.m_ui.RightValueAddText3.text="("+l_dic["RES"]+")";
					m_BR+=parseInt(l_dic["RES"])*parseInt(GameConfigManager.UnitParameterList["resilience_BR"].value);
				}
				if(l_dic["CDMGR"]!=null)
				{
					this.m_ui.RightValueAddText4.text="("+l_dic["CDMGR"]+")";
					m_BR+=parseInt(l_dic["CDMGR"])*parseInt(GameConfigManager.UnitParameterList["critical_damage_reduction_BR"].value);
				}
			}
		}
		
		public function setSelectType():void
		{
			
			
		}
		
		public function setSultInfo(isShow:Boolean):void
		{
			if(m_panel==null)
			{
				m_panel=new Panel();
				m_panel.name="equipTips";
				this.m_ui.TipImage.addChild(m_panel);
				m_panel.y=20;
				m_panel.mouseThrough=true;
			}
			
			if(m_sult!=null)
			{
				for (var i:int = 0; i < m_sult.length; i++) 
				{
					m_panel.removeChild(m_sult[i]);
				}
			}
			m_sult=new Array();
			m_isShow=isShow;
			num=0;
			var l_suitVoList:Array=new Array();
			
			if(m_isShow==true)
			{
				this.m_ui.TipImage.height=200;
				this.m_ui.TipImage.y=293;
				m_ui.SuitEquipTipsBtn.skewX=180;
				m_ui.SuitEquipTipsBtn.y=20;
				m_panel.width=this.m_ui.TipImage.width;
				m_panel.height=150;
				m_panel.vScrollBarSkin="";
				m_panel.visible=true;
			}
			else
			{
				this.m_ui.TipImage.height=70;
				this.m_ui.TipImage.y=422;
				m_ui.SuitEquipTipsBtn.skewX=0;
				m_ui.SuitEquipTipsBtn.y=2;
				m_panel.visible=false;
			}
			if(m_isShow==true)
			{
				var l_dic:Dictionary=new Dictionary();
				if(m_playerEquipVo.equipList!=null)
				{
					for(var i:int=0;i<m_playerEquipVo.equipList.length;i++)
					{
						var l_equipVo:EquipInfoVo=m_playerEquipVo.equipList[i];
						var l_equipBaseInfo:EquipmentListVo=GameConfigManager.EquipmentList[l_equipVo.equip_item_id];
						if(l_equipBaseInfo.suit>0)
						{
							var l_equipSuitNum:int=l_dic.get(l_equipBaseInfo.suit);
							if(l_equipSuitNum==null||l_equipSuitNum==undefined)
							{
								l_equipSuitNum=1;
							}
							else
							{
								l_equipSuitNum+=1;
							}
							l_dic.set(l_equipBaseInfo.suit,l_equipSuitNum);
						}
					}
				}

				var num:Number=0;
				for (var i:int = 0; i < l_dic.keys.length; i++) 
				{
					var l_sultid:int=l_dic.keys[i];
					var l_num:int=l_dic.values[i];
					if(l_num>1)
					{
						
						for (var j:int = 0; j < GameConfigManager.EquipmentSuitList.length; j++) 
						{
							var l_suitVo:EquipmentSuitVo=GameConfigManager.EquipmentSuitList[j]
							if(l_sultid==l_suitVo.suit)
							{
								l_suitVoList.push(l_suitVo);
							}
						}
					}
				}
				var l_br:Label=new Label();
				l_br.font = XFacade.FT_Futura;
				l_br.fontSize = 14;
				l_br.color = "#ffffff";
				l_br.width = width;
				l_br.align = Stage.ALIGN_CENTER;
				l_br.text=GameLanguage.getLangByKey("L_A_48001")+" "+m_BR;
				m_panel.addChild(l_br);
				m_sult.push(l_br);
				l_br.x=0;
				l_br.y=0;
				l_br.width=182;
				
				if(l_dic.keys.length==0||l_suitVoList.length==0)
				{
					var l_suitName:Label=new Label();
					l_suitName.font = XFacade.FT_Futura;
					l_suitName.fontSize = 14;
					l_suitName.color = "#9fd5ff";
					l_suitName.width = width;
					l_suitName.align = Stage.ALIGN_CENTER;
					l_suitName.text=GameLanguage.getLangByKey("L_A_48050");
					m_panel.addChild(l_suitName);
					m_sult.push(l_suitName);
					l_suitName.x=0;
					l_suitName.y=40;
					l_suitName.width=182;
					return;
				}
				for (var i:int = 0; i < l_dic.keys.length; i++) 
				{
					l_num=l_dic.values[i]
					if(l_num<2)
					{
						break;
					}
					var l_sultid:int=l_dic.keys[i];
					var l_num:int=l_dic.values[i];
					var l_suitName:Label=new Label();
					l_suitName.font = XFacade.FT_Futura;
					l_suitName.fontSize = 14;
					l_suitName.color = "#9fd5ff";
					l_suitName.width = width;
					l_suitName.align = Stage.ALIGN_CENTER;
					l_suitName.text = l_suitVoList[i].name;
					l_suitName.x=0;
					l_suitName.width=182;
					num+=20;
					l_suitName.y=num;
					var att2:Array=l_suitVoList[i].getAttr2();
					var att4:Array=l_suitVoList[i].getAttr4();
					var att6:Array=l_suitVoList[i].getAttr6();
					if(l_num>=2)
					{
						var l_label:Label=new Label();
						l_label.text=GameLanguage.getLangByKey("L_A_48003");
						l_label.font = XFacade.FT_Futura;
						l_label.fontSize = 14;
						l_label.color = "#9fd5ff";
						l_label.width = width;
						l_label.align = Stage.ALIGN_CENTER;
						l_label.x=15;
						num+=20;
						l_label.y=num;
						m_panel.addChild(l_label);
						m_panel.addChild(l_suitName);
						m_sult.push(l_label);
						m_sult.push(l_suitName);
						for (var j:int = 0; j < att2.length; j++) 
						{
							num+=20;
							getImage(att2[j].name,m_sult,num,50);
							getLabel(att2[j].num,m_sult,num,80);
						}
					}
					if(l_num>=4)
					{
						var l_label:Label=new Label();
						l_label.text=GameLanguage.getLangByKey("L_A_48004");
						l_label.font = XFacade.FT_Futura;
						l_label.fontSize = 14;
						l_label.color = "#9fd5ff";
						l_label.width = width;
						l_label.x=15;
						l_label.align = Stage.ALIGN_CENTER;
						m_panel.addChild(l_label);
						m_sult.push(l_label);
						num+=20;
						l_label.y=num;
						for (var j:int = 0; j < att4.length; j++) 
						{
							num+=20;
							if(att4[j].name!="skill2")
							{
								getImage(att4[j].name,m_sult,num,50);
								getLabel(att4[j].num,m_sult,num,80);
							}
							else
							{
								num+=getSkilldes(att4[j].num,m_sult,num,50);
							}
						}
					}
					
					if(l_num>=6)
					{
						var l_label:Label=new Label();
						l_label.text=GameLanguage.getLangByKey("L_A_48005");
						l_label.font = XFacade.FT_Futura;
						l_label.fontSize = 14;
						l_label.color = "#9fd5ff";
						l_label.width = width;
						l_label.x=15;
						l_label.align = Stage.ALIGN_CENTER;
						m_panel.addChild(l_label);
						m_sult.push(l_label);
						num+=20;
						l_label.y=num;
						for (var j:int = 0; j < att6.length; j++) 
						{
							num+=20;
							if(att6[j].name!="skill2")
							{
								getImage(att6[j].name,m_sult,num,50);
								getLabel(att6[j].num,m_sult,num,80);
							}
							else
							{
								num+=getSkilldes(att6[j].num,m_sult,num,50);
							}
						}
					}
				}
			}
				
		}
		public function resetAni():void{
			_selectEff.clear();

			
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
		/**
		 * 
		 */
		private function getSkilldes(p_id:int,p_arr:Array,p_y:Number,p_x:Number,p_color="#ffffff"):Number
		{
			var f:SkillVo;
			f = DBSkill2.getSkillInfo(p_id);
			var l_attlabel:Label=new Label();
			l_attlabel.font = XFacade.FT_Futura;
			l_attlabel.fontSize = 14;
			l_attlabel.color =p_color;
			l_attlabel.align = Stage.ALIGN_LEFT;
			l_attlabel.text=GameLanguage.getLangByKey(f.skill_name);
			l_attlabel.y = p_y;
			l_attlabel.x=p_x;
			m_panel.addChild(l_attlabel);
			p_arr.push(l_attlabel);
			var l_attlabel1:Label=new Label();
			l_attlabel1.font = XFacade.FT_Futura;
			l_attlabel1.fontSize = 14;
			l_attlabel1.color =p_color;
			l_attlabel1.align = Stage.ALIGN_LEFT;
			l_attlabel1.text=StringUtil.substitute(GameLanguage.getLangByKey(f.skill_describe),XUtils.toFixed(f.skill_value,1));
			l_attlabel1.width=120;
			l_attlabel1.y = p_y+20;
			l_attlabel1.wordWrap=true;
			l_attlabel1.x=p_x;
			m_panel.addChild(l_attlabel1);
			p_arr.push(l_attlabel1);
			return l_attlabel1.textField.textHeight+6;
		}
		
		
		private function getImage(p_str:String,p_arr:Array,p_y:Number,p_x:Number):void
		{
			var l_image:Image=new Image();
			l_image.skin="common/icons/"+p_str+".png";
			l_image.y=p_y-5;
			l_image.x=p_x;
			m_panel.addChild(l_image);
			p_arr.push(l_image);
		}
		
		private function selectEff(rarity:uint):Animation
		{	
			if(!_selectEff)
			{
				_selectEff = new Animation();
				_selectEff.autoPlay = true;
				_selectEff.mouseEnabled = _selectEff.mouseThrough = false;
				m_ui.eff.addChild(_selectEff);
				_selectEff.x = -72;
				_selectEff.y = -205;
			}
			var jsonStr:String = "appRes/atlas/effects/chestEffects_"+rarity+".json";
			_selectEff.loadAtlas(jsonStr);
			return _selectEff;
		}
		
		
		/**
		 *	创建文字
		 */
		private function getLabel(p_str:String,p_arr:Array,p_y:Number,p_x:Number):void
		{
			var l_attlabel:Label=new Label();
			l_attlabel.font = XFacade.FT_Futura;
			l_attlabel.fontSize = 14;
			l_attlabel.color = "#ffffff";
			l_attlabel.align = Stage.ALIGN_LEFT;
			l_attlabel.text=p_str;
			l_attlabel.y = p_y-2;
			l_attlabel.x = p_x;
			m_panel.addChild(l_attlabel);
			p_arr.push(l_attlabel);
		}
		
		//销毁图像图集
		public function clearHeroSkin():void{
			Loader.clearRes(this.m_ui.PlayerImage.skin);
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			super.destroy(destroyChild);
			//Loader.clearRes(this.m_ui.PlayerImage.skin);
			Loader.clearRes("appRes/atlas/effects/chestEffects.json");
		}
	}
}