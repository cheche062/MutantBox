package game.module.tips.itemTip
{
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.DBSkill2;
	import game.global.vo.ItemVo;
	import game.global.vo.SkillVo;
	import game.global.vo.equip.AttVo;
	import game.global.vo.equip.EquipmentBaptizeVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.EquipmentMaxVo;
	import game.global.vo.equip.EquipmentSuitVo;
	import game.module.tips.itemTip.base.BaseItemTipCell;
	
	import laya.display.Node;
	import laya.display.Stage;
	import laya.display.Text;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.Panel;
	import laya.ui.ProgressBar;
	
	import org.hamcrest.collection.array;
	
	public class ItemTipEquipCell extends BaseItemTipCell
	{
		private var m_equipBase:Label;
		private var m_washAtt:Label;
		private var m_sult:Label;
		private var m_sult2:Label;
		private var m_sult3:Label;
		private var m_sultName:Label;
		private var m_attLabelList:Array;
		private var m_attWaskList:Array;
		private var m_equipNameList:Array;
		private var m_suitList:Array;
		private var m_equipBtn:Button;
		private var m_strengBtn:Button;
		private var m_panel:Panel;
		public function ItemTipEquipCell()
		{
			super();
			this.size(262,40);
		}
		
		public override function bindData():void
		{
			clear();
			m_attLabelList=new Array();
			m_attWaskList=new Array();
			m_equipNameList=new Array();
			m_suitList=new Array();
			var obj:Object = JSON.parse(data);
			var maxy:Number=0;
			var listy:Number=0;
			var suitNum:int=obj.hasSuit;
			if(!m_equipBase && obj.equipBaseAtt)
			{
				var l_attLabelList:Array=new Array();
				m_equipBase=new Label();
				m_equipBase.font = XFacade.FT_Futura;
				m_equipBase.fontSize = 16;
				m_equipBase.color = "#9fd5ff";
				m_equipBase.width = width;
				m_equipBase.align = Stage.ALIGN_LEFT;
				m_equipBase.text=GameLanguage.getLangByKey("L_A_48017");
				m_equipBase.x=30;
				m_panel.addChild(m_equipBase);	
			}
			var l_equipVo:EquipmentListVo;
			var l_level:int;
			if(obj.type==1)
			{
				m_equipBtn.skin="common/buttons/btn_8_1.png";
				//m_equipBtn.text.font="BigNoodleToo";
				m_equipBtn.label=GameLanguage.getLangByKey("L_A_48217");
				l_equipVo=GameConfigManager.EquipmentList[obj.itemData.iid];
				l_level=obj.itemData.level;
			}
			else
			{
				m_equipBtn.skin="common/buttons/btn_8_1.png";
				m_equipBtn.label=GameLanguage.getLangByKey("L_A_48218");
				//m_equipBtn.text.font="BigNoodleToo";
				l_equipVo=GameConfigManager.EquipmentList[obj.itemData.equip_item_id];
				l_level=obj.itemData.strong_level;
			}
			if(obj.equipBaseAtt)
			{
				m_equipBase.visible=true;
				for (var i:int = 0; i < obj.equipBaseAtt.length; i++) 
				{
					maxy+=27;
					var l_attVo:AttVo=obj.equipBaseAtt[i];
					for (var j:int = 0; j < l_equipVo.getStrongAttr().length; j++) 
					{
						var l_addAttVo:AttVo=l_equipVo.getStrongAttr()[j];
						if(l_addAttVo.name==l_attVo.name&&l_level>0)
						{
							var l_add:Label=new Label();
							l_add.font = XFacade.FT_Futura;
							l_add.fontSize = 14;
							l_add.color = "#70ff8e";
							l_add.align = Stage.ALIGN_LEFT;
							l_add.text="(+"+parseInt(l_addAttVo.num*l_level)+")";
							l_add.y =maxy;
							l_add.x=110;
							m_panel.addChild(l_add);
							m_attLabelList.push(l_add);
						}
					}
					getLabel(l_attVo.num,m_attLabelList,maxy,80);
					getImage(l_attVo.name,m_attLabelList,maxy,50);
				}
			}

			if(obj.type==1)
			{
				if(!m_washAtt && obj.itemData.exPro.wash_effect)
				{
					m_washAtt=new Label();
					m_washAtt.font = XFacade.FT_Futura;
					m_washAtt.fontSize = 16;
					m_washAtt.color = "#9fd5ff";
					m_washAtt.width = width;
					m_washAtt.align = Stage.ALIGN_LEFT;
					m_washAtt.text=GameLanguage.getLangByKey("L_A_48018");
					m_panel.addChild(m_washAtt);
					m_washAtt.x=30;
					m_washAtt.visible=false;
				}
				if(obj.itemData.exPro.wash_effect &&obj.itemData.exPro.wash_effect!=undefined)
				{
					m_washAtt.visible=false;
					maxy+=27;
					m_washAtt.y=maxy;
					m_washAtt.visible=true;
					var l_washAttList:Array=new Array();
					var l_washInfo:Array=getItemWashInfo(obj.itemData.iid,obj.itemData.exPro.wash_effect);
					for(var i:int = 0; i < l_washInfo.length; i++)
					{
						var l_attVo:AttVo=l_washInfo[i];
						maxy+=27;
						getLabel(l_attVo.num,m_attWaskList,maxy,80);
						getImage(l_attVo.name,m_attWaskList,maxy,50);
						getProProgress(l_attVo.num/l_attVo.max,m_attWaskList,maxy,120);
					}
				}
			}
			else
			{
				if(!m_washAtt && obj.itemData.wash_effect)
				{
					m_washAtt=new Label();
					m_washAtt.font = XFacade.FT_Futura;
					m_washAtt.fontSize = 16;
					m_washAtt.color = "#9fd5ff";
					m_washAtt.width = width;
					m_washAtt.align = Stage.ALIGN_LEFT;
					m_washAtt.text=GameLanguage.getLangByKey("L_A_48018");
					m_washAtt.x=30;
					m_panel.addChild(m_washAtt);
				}
				if(obj.itemData.wash_effect)
				{
					m_washAtt.visible=false;
					maxy+=27;
					m_washAtt.y=maxy;
					m_washAtt.visible=true;
					var l_washAttList:Array=new Array();
					var l_washInfo:Array=obj.itemData.wash_effect;
					for(var i:int = 0; i < l_washInfo.length; i++)
					{
						var l_attVo:AttVo=l_washInfo[i];
						maxy+=27;
						getLabel(l_attVo.num,m_attWaskList,maxy,80);
						getImage(l_attVo.name,m_attWaskList,maxy,50);
						getProProgress(l_attVo.num/l_attVo.max,m_attWaskList,maxy,120);
					}
				}
			}
			if(!m_sult && obj.suitBase && obj.suitBase!=undefined)
			{
				m_sult=new Label();
				m_sult2=new Label();
				m_sultName=new Label();
				m_sult3=new Label();
				m_sult.text=GameLanguage.getLangByKey("L_A_48003");
				m_sultName.font=m_sult3.font=m_sult.font=m_sult2.font = XFacade.FT_Futura;
				m_sultName.fontSize=m_sult.fontSize=m_sult2.fontSize=m_sult3.fontSize = 16;
				m_sultName.color="#5de590";
				m_sult.color=m_sult3.color=m_sult2.color = "#9fd5ff";
				m_sult.width=m_sult3.width=m_sult2.width = width;
				m_sult.align=m_sult3.align=m_sult2.align = Stage.ALIGN_LEFT;
				m_sult2.text=GameLanguage.getLangByKey("L_A_48004");
				m_sult3.text=GameLanguage.getLangByKey("L_A_48005");
				m_sultName.x=m_sult.x=m_sult2.x=m_sult3.x=30;
				m_panel.addChild(m_sultName);
				m_panel.addChild(m_sult);
				m_panel.addChild(m_sult2);
				m_panel.addChild(m_sult3);
			}
			if( obj.suitBase && obj.suitBase!=undefined)
			{
				maxy+=27;
				m_sultName.y=maxy;
				maxy+=27;
				m_sult.visible=true;
				m_sult2.visible=true;
				m_sult3.visible=true;
				m_sultName.visible=true;
				m_sult.y=maxy;
				var l_suitVo:EquipmentSuitVo=new EquipmentSuitVo()
				l_suitVo.attr2 =obj.suitBase.attr2;
				l_suitVo.attr4=obj.suitBase.attr4;
				l_suitVo.attr6=obj.suitBase.attr6;
				l_suitVo.suit=obj.suitBase.suit;
				m_sultName.text=obj.suitBase.name;
				var l_attsuit2:Array=l_suitVo.getAttr2();
				var color:String="";
				var isGray:Boolean=false;
				if(suitNum>=2)
				{
					color="#ffffff";
					isGray=false;
				}
				else
				{
					color="#cfcfcf";
					isGray=true;
				}
				for (var i:int = 0; i < l_attsuit2.length; i++) 
				{
					var l_attVo:AttVo=l_attsuit2[i];
					maxy+=27;
					getLabel(l_attVo.num,m_suitList,maxy,80,color);
					getImage(l_attVo.name,m_suitList,maxy,50,isGray);
				}
				maxy+=27;
				m_sult2.y=maxy;
				if(suitNum>=4)
				{
					color="#ffffff";
					isGray=false;
				}
				else
				{
					color="#cfcfcf";
					isGray=true;
				}
				var l_attsuit4:Array=l_suitVo.getAttr4();
				for (var i:int = 0; i < l_attsuit4.length; i++) 
				{
					var l_attVo:AttVo=l_attsuit4[i];
					maxy+=27;
					if(l_attVo.name!="skill2")
					{
						getLabel(l_attVo.num,m_suitList,maxy,80,color);
						getImage(l_attVo.name,m_suitList,maxy,50,isGray);
					}
					else
					{
						maxy+=getSkilldes(l_attVo.num,m_suitList,maxy,50,color);
					}
					
				}
				maxy+=27;
				m_sult3.y=maxy;
				if(suitNum>=6)
				{
					color="#ffffff";
					isGray=false;
				}
				else
				{
					color="#cfcfcf";
					isGray=true;
				}
				var l_attsuit6:Array=l_suitVo.getAttr6();
				for (var i:int = 0; i < l_attsuit6.length; i++) 
				{
					var l_attVo:AttVo=l_attsuit6[i];
					maxy+=27;
					if(l_attVo.name!="skill2")
					{
						getLabel(l_attVo.num,m_suitList,maxy,80,color);
						getImage(l_attVo.name,m_suitList,maxy,50,isGray);
					}
					else
					{
						maxy+=getSkilldes(l_attVo.num,m_suitList,maxy,50,color);
					}
				}
			}

			if(obj.type==1)
			{
				m_equipBtn.name="itemEquipBtn";
				m_strengBtn.name = "itemStrengBtn";
				
				UIRegisteredMgr.AddUI(m_strengBtn,"EqEnhanceBtn");
			}
			else
			{
				m_equipBtn.name="nowEquipBtn";
				m_strengBtn.name="nowStrengBtn";
			}
			if(obj.btntype==1)
			{
				m_equipBtn.visible=true;
				m_strengBtn.visible=true;
			}
			else
			{
				m_equipBtn.visible=false;
				m_strengBtn.visible=false;
			}
			m_panel.width=262;
			m_panel.vScrollBarSkin="";
			if(maxy>=240)
			{
				maxy=240
			}
			m_panel.height=maxy;
			m_panel.refresh();
			m_equipBtn.y=maxy+15;
			m_equipBtn.x=150;
			m_strengBtn.y=maxy+15;
			m_strengBtn.x=40;
			size(262,maxy+30);
		}
		
		/**
		 * 洗练的信息
		 */
		private function getItemWashInfo(p_id:int,p_obj:Object):Array
		{
			var l_arr:Array=new Array();
			var l_vo:EquipmentMaxVo=getWashInfo(p_id);
			if(l_vo!=null && p_obj!=undefined)
			{
				var l_attArr:Array=l_vo.getAttr();
				for(var i:int=0;i<l_attArr.length;i++)
				{
					var l_attVo:AttVo=l_attArr[i];
					var l_change:int= p_obj[l_attVo.name];
					if(l_change!=null && l_change!=undefined)
					{
						l_attVo.num=l_change;
						l_attArr[i]=l_attVo;
						l_arr.push(l_attVo);
					}
				}
			}
			return l_arr;
		}
		
		/**
		 * 获取洗练信息
		 */
		private function getWashInfo(p_id:int):EquipmentMaxVo
		{
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentMaxList.length; i++) 
			{
				var l_vo:EquipmentMaxVo=GameConfigManager.EquipmentMaxList[i];
				if(l_equipVo.level==l_vo.level && l_equipVo.quality==l_vo.quality)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		private function getImage(p_str:String,p_arr:Array,p_y:Number,p_x:Number,p_isgray=false):void
		{
			var l_image:Image=new Image();
			l_image.skin="common/icons/"+p_str+".png";
			l_image.y=p_y-5;
			l_image.x=p_x;
			l_image.gray=p_isgray;
			m_panel.addChild(l_image);
			p_arr.push(l_image);
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
			l_attlabel1.width=160;
			l_attlabel1.y = p_y+27;
			l_attlabel1.wordWrap=true;
			l_attlabel1.x=p_x;
			m_panel.addChild(l_attlabel1);
			p_arr.push(l_attlabel1);
			return l_attlabel1.textField.textHeight+13;
		}
		
		/**
		 * 
		 */
		private function getProProgress(p_value:Number,p_arr:Array,p_y:Number,p_x:Number):void
		{
			var l_pro:ProgressBar=new ProgressBar();
			l_pro.sizeGrid="0,13,0,14";
			l_pro.skin="equip/progress.png";
			l_pro.width=90;
			l_pro.height=15;
			l_pro.x=p_x;
			l_pro.y=p_y;
			l_pro.value=p_value;
			m_panel.addChild(l_pro);
			p_arr.push(l_pro);
		}
		
		
		/**
		 *	创建文字
		 */
		private function getLabel(p_str:String,p_arr:Array,p_y:Number,p_x:Number,p_color="#ffffff"):void
		{
			var l_attlabel:Label=new Label();
			l_attlabel.font = XFacade.FT_Futura;
			l_attlabel.fontSize = 14;
			l_attlabel.color =p_color;
			l_attlabel.align = Stage.ALIGN_LEFT;
			l_attlabel.text=p_str;
			l_attlabel.y = p_y;
			l_attlabel.x=p_x;
			m_panel.addChild(l_attlabel);
			p_arr.push(l_attlabel);
		}
		
		/**
		 * 清除
		 */
		private function clear():void
		{
			if(m_panel==null)
			{
				m_panel=new Panel();
				m_panel.name="equipTips";
				addChild(m_panel);
			}
			
			if(m_equipBase)
			{
				m_equipBase.visible=false;
				
			}
			if(m_washAtt)
			{
				m_washAtt.visible=false;
			}
			if(m_sult)
			{
				m_sult.visible=false;
			}
			if(m_sult2)
			{
				m_sult2.visible=false;
			}
			if(m_sult3)
			{
				m_sult3.visible=false;
			}
			if(m_equipBtn==null)
			{
				m_equipBtn=new Button();
				m_equipBtn.skin="common/buttons/btn_8_1.png";
				m_equipBtn.labelFont="BigNoodleToo";
				m_equipBtn.labelSize=22;
				m_equipBtn.labelColors="#e4faff,#e4faff,#e4faff";
				addChild(m_equipBtn);
				
			}
			if(m_strengBtn==null)
			{
				m_strengBtn=new Button();
				m_strengBtn.skin="common/buttons/btn_8_1.png";
				m_strengBtn.labelFont="BigNoodleToo";
				m_strengBtn.labelColors="#e4faff,#e4faff,#e4faff";
				m_strengBtn.labelSize=22;
				m_strengBtn.label=GameLanguage.getLangByKey("L_A_48216");
				addChild(m_strengBtn);
				UIRegisteredMgr.AddUI(m_strengBtn,"StrengBtn");
			}
			if(m_attLabelList!=null)
			{
				for(var i:int = 0; i < m_attLabelList.length; i++)
				{
					clearNode(m_attLabelList[i]);
				}
			}
			
			if(m_suitList!=null)
			{
				for(var i:int = 0; i < m_suitList.length; i++)
				{
					clearNode(m_suitList[i]);
				}
				
			}
			
			if(m_attWaskList!=null)
			{
				for(var i:int = 0; i < m_attWaskList.length; i++)
				{
					clearNode(m_attWaskList[i]);
				}
				
			}
			if(m_equipNameList!=null)
			{
				for(var i:int = 0; i < m_equipNameList.length; i++)
				{
					clearNode(m_equipNameList[i]);
				}
			}
			if(m_sultName!=null)
			{
				m_sultName.visible=false;
			}
		}

		
		private function clearNode(node:Node):void
		{
			if(node)
				node.removeSelf();
		}
	}
}