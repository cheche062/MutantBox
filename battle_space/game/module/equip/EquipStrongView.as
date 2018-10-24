package game.module.equip
{
	import MornUI.equip.EquipStrongViewUI;
	
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.data.ItemCostCell;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.equip.AttVo;
	import game.global.vo.equip.EquipInfoVo;
	import game.global.vo.equip.EquipmentBaptizeVo;
	import game.global.vo.equip.EquipmentIntensifyVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.EquipmentMaxVo;
	import game.global.vo.equip.EquipmentSuitVo;
	import game.global.vo.equip.WashFightVo;
	
	import laya.display.Text;
	import laya.ui.Image;
	import laya.utils.Dictionary;
	
	public class EquipStrongView extends BaseDialog
	{
		private var m_ui:EquipStrongViewUI;
		private var m_data:Object;
		private var m_type:int;
		private var m_isbag:Boolean;
		private var m_maxLevel:int;
		private var m_attList:Array;
		private var m_wash:EquipmentMaxVo;
		private var m_washEquip:EquipmentBaptizeVo;
		private var m_changeList:Array;
		private var m_nowList:Array;
		private var m_washfightVO:WashFightVo;
		private var m_selffightVO:WashFightVo;
		public function EquipStrongView(p_ui:EquipStrongViewUI,p_data:Object,p_type:int,p_isbag:Boolean)
		{
			super();
			m_ui=p_ui;
			m_data=p_data;
			m_type=p_type;
			m_isbag=p_isbag;
			initUI();
		}
		
		/**
		 * 初始化
		 */
		private function initUI():void
		{
			m_ui.RefreshBtn.text.text=GameLanguage.getLangByKey("L_A_48046");
			m_ui.RetainBtn.text.text=GameLanguage.getLangByKey("L_A_48047");
			m_ui.EnhanceBtn.text.text=GameLanguage.getLangByKey("L_A_48037");
			m_ui.Time5EnhanceBtn.text.text=GameLanguage.getLangByKey("L_A_48036");
			m_ui.NewStatesText.text=GameLanguage.getLangByKey("L_A_48043");
			m_ui.CurrentstatesText.text=GameLanguage.getLangByKey("L_A_48044");
			m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_48219");
			this.m_ui.SelectEquipCell.BgImage.visible=false;
			this.m_ui.SelectEquipCell.EquipLevelText.visible=false;
			this.m_ui.SelectEquipCell.ItemBarImage.visible=false;
			this.m_ui.SelectEquipCell.EquipImage.visible=false;
			this.m_ui.ItemList.array=new Array();
			this.m_ui.CostList.array=new Array();
			this.m_ui.WashPropertyList.array=new Array();
			this.m_ui.WashChangePropertyList.array=new Array();
			this.m_ui.NextLevelText.visible=false;
			this.m_ui.NowLevelText.visible=false;
			m_washfightVO=new WashFightVo();
			m_selffightVO=new WashFightVo();
			m_ui.ChangeFightingCell.visible=false;
			m_ui.SelfFightingCell.visible=false;
			for(var i:int = 0; i < 3; i++)
			{
				var l_text:Text=this.m_ui.StrongProperty.getChildByName("PropertyText"+i) as Text;
				var l_text1:Text=this.m_ui.StrongProperty.getChildByName("NowPropertyText"+i) as Text;
				var l_image:Image=this.m_ui.StrongProperty.getChildByName("PropertyImage"+i)as Image;
				l_text.visible=false;
				l_text1.visible=false;
				l_image.visible=false;
			}
			if(m_type==1)
			{
				m_ui.EquipWash.visible=false;
				m_ui.StrongProperty.visible=true;
				m_ui.bgImage.skin="equip/bg2_2.png";
				setStrongUI();
			}
			else
			{
				m_ui.EquipWash.visible=true;
				m_ui.StrongProperty.visible=false;
				m_ui.bgImage.skin="equip/bg2_3.png";
				setWashUI();
			}
			var equipinfo:EquipInfoVo=new EquipInfoVo();
			var l_item:EquipCell;
			if(m_data==null)
			{
				this.m_ui.NoEquipBox.visible=true;
				this.m_ui.EnhanceBtn.gray=true;
				this.m_ui.Time5EnhanceBtn.gray=true;
				this.m_ui.RefreshBtn.gray=true;
				this.m_ui.RetainBtn.gray=true;
				this.m_ui.EnhanceBtn.mouseEnabled=this.m_ui.Time5EnhanceBtn.mouseEnabled=this.m_ui.RefreshBtn.mouseEnabled=this.m_ui.RetainBtn.mouseEnabled=false;
				return;
			}
			else
			{
				this.m_ui.EnhanceBtn.gray=false;
				this.m_ui.Time5EnhanceBtn.gray=false;
				this.m_ui.RefreshBtn.gray=false;
				this.m_ui.NoEquipBox.visible=false;
				this.m_ui.RetainBtn.gray=false;
				this.m_ui.EnhanceBtn.mouseEnabled=this.m_ui.Time5EnhanceBtn.mouseEnabled=this.m_ui.RefreshBtn.mouseEnabled=this.m_ui.RetainBtn.mouseEnabled=true;
			}
			this.m_ui.NextLevelText.visible=true;
			this.m_ui.NowLevelText.visible=true;
			if(m_isbag==true)
			{
				equipinfo.equip_item_id=m_data.iid;
				equipinfo.strong_level=m_data.exPro.strong_level;
				setQuality(equipinfo.equip_item_id);
				l_item=new EquipCell(this.m_ui.SelectEquipCell,equipinfo);
			}
			else
			{
				setQuality(m_data.equip_item_id);
				l_item=new EquipCell(this.m_ui.SelectEquipCell,m_data);
			}
			
		}
		
		private function setQuality(p_id:int):void
		{
			var l_itemVo:ItemVo=GameConfigManager.items_dic[p_id]
			m_ui.QualityImage.skin="common/i"+(l_itemVo.quality-1)+".png";
		}
		
		
		public function saveWashInfo():void
		{
			m_ui.WashPropertyList.visible=true;
			m_ui.WashPropertyList.array=m_changeList;
			m_ui.WashChangePropertyList.visible=false;
			m_ui.ChangeFightingCell.visible=false;
			if(m_changeList.length>0)
			{
				m_ui.SelfFightingCell.visible=true;
				m_selffightVO.now=getWashFighting(m_changeList);
				var l_cell:WashFightingCell=new WashFightingCell(m_ui.SelfFightingCell,m_selffightVO);
			}
		}

		/**
		 * 洗练
		 */
		private function setWashUI():void
		{
			var l_id:int;
			var l_arr:Array;
			if(m_data==null)
			{
				return;
			}
			if(m_isbag==true)
			{
				l_id=m_data.iid;
				m_nowList=getItemWashInfo(l_id,m_data.exPro.wash_effect);
			}
			else
			{
				l_id=m_data.equip_item_id;
				m_nowList=m_data.wash_effect;
			}
			m_wash=getWashInfo(l_id);
			m_washEquip=getEquipWash(l_id);
			if(m_wash!=null)
			{
				m_attList=m_wash.getAttr();
				m_ui.WashPropertyList.itemRender=WashPropertyCell;
				m_ui.WashPropertyList.selectEnable=true;
				m_ui.WashPropertyList.visible=false;
				m_ui.SelfFightingCell.visible=false;
				if(m_nowList.length>0)
				{
					m_ui.WashPropertyList.visible=true;
					m_ui.SelfFightingCell.visible=true;
					m_ui.WashPropertyList.array=m_nowList;
					m_selffightVO.now=getWashFighting(m_nowList);
					m_ui.SelfFightingCell.visible=true;
					var l_cell:WashFightingCell=new WashFightingCell(m_ui.SelfFightingCell,m_selffightVO);
				}
				
				m_ui.WashChangePropertyList.itemRender=WashPropertyChange;
				m_ui.WashChangePropertyList.visible=false;
				setWashCost(0);
			}
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
		 * 洗练的消耗
		 */
		public function setWashCost(p_type:int):void
		{
			m_ui.ItemList.itemRender=ItemCostCell;
			m_ui.ItemList.selectEnable=false;
			if(m_washEquip!=null)
			{
				m_ui.ItemList.array=m_washEquip.getCost(p_type);
			}
			m_ui.ItemList.refresh();
			
		}
		
		
		private function getWashInfo(p_id:int):EquipmentMaxVo
		{
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentMaxList.length; i++) 
			{
				var l_vo:EquipmentMaxVo=GameConfigManager.EquipmentMaxList[i];
				if(l_equipVo&&l_equipVo.level==l_vo.level && l_equipVo.quality==l_vo.quality)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		private function getEquipWash(p_id:int):EquipmentBaptizeVo
		{
			
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentBaptizeList.length; i++) 
			{
				var l_vo:EquipmentBaptizeVo=GameConfigManager.EquipmentBaptizeList[i];
				if(l_equipVo&&l_equipVo.level==l_vo.level && l_equipVo.quality==l_vo.quality)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		/**
		 *强化ui 
		 * 
		 */
		private function setStrongUI():void
		{	
			var itemvo:ItemVo=GameConfigManager.items_dic[10000];
			m_ui.HasImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
			m_ui.NumText.text=BagManager.instance.getItemNumByID(10000);
			if(m_data==null)
			{
				return;
			}
			if(m_isbag==true)
			{
				m_maxLevel=getEquipMaxLevel(m_data.iid);
				var level:int=0;
				if(m_data.exPro.strong_level==undefined)
				{
					level=0;
				}
				else
				{
					level=m_data.exPro.strong_level;
				}
				m_ui.NowLevelText.text=GameLanguage.getLangByKey("L_A_73")+level+"/"+m_maxLevel;
				if(m_data.exPro.level<m_maxLevel)
				{
					m_ui.NextLevelText.text=GameLanguage.getLangByKey("L_A_73")+(level+1)+"/"+m_maxLevel;
				}
				else
				{
					m_ui.NextLevelText.text=m_ui.NowLevelText.text;
				}
				this.m_ui.NextLevelText.visible=true;
				this.m_ui.NowLevelText.visible=true;
				setStrongProperty(m_data.iid,level);
			}
			else
			{
				m_maxLevel=getEquipMaxLevel(m_data.equip_item_id);
				m_ui.NowLevelText.text=GameLanguage.getLangByKey("L_A_73")+m_data.strong_level+"/"+m_maxLevel;
				if(m_data.strong_level<m_maxLevel)
				{
					m_ui.NextLevelText.text=GameLanguage.getLangByKey("L_A_73")+(m_data.strong_level+1)+"/"+m_maxLevel;
				}
				else
				{
					m_ui.NextLevelText.text=m_ui.NowLevelText.text;
				}
				setStrongProperty(m_data.equip_item_id,m_data.strong_level);
			}
		}
		
		/**
		 * 
		 * @param p_id
		 * @param p_level
		 * 
		 */
		private function setStrongProperty(p_id:int,p_level:int):void
		{
			var l_baseVO:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			var l_equipvo:EquipmentIntensifyVo=getEquipStringInfo(p_id,p_level);
			var l_nextequipvo:EquipmentIntensifyVo=getEquipStringInfo(p_id,p_level+1);
			var l_arr:Array=new Array();
			var l_nowArr:Array=new Array();
			if(l_equipvo!=null)
			{
				l_arr=l_baseVO.getStrongAttr();
			}
			
			if(l_nextequipvo!=null)
			{
				l_nowArr=l_baseVO.getStrongAttr();
			}
			for(var i:int = 0; i < 3; i++)
			{
				var l_text:Text=this.m_ui.StrongProperty.getChildByName("PropertyText"+i) as Text;
				var l_text1:Text=this.m_ui.StrongProperty.getChildByName("NowPropertyText"+i) as Text;
				var l_image:Image=this.m_ui.StrongProperty.getChildByName("PropertyImage"+i)as Image;
				l_text.visible=false;
				l_text1.visible=false;
				l_image.visible=false;
			}
			
			for (var i:int = 0; i < l_arr.length; i++) 
			{
				var l_text:Text=this.m_ui.StrongProperty.getChildByName("PropertyText"+i) as Text;
				var l_image:Image=this.m_ui.StrongProperty.getChildByName("PropertyImage"+i)as Image;
				l_image.skin="common/icons/"+l_arr[i].name+".png";
				l_text.text=l_arr[i].num*p_level;
				l_text.visible=true;
				l_image.visible=true;
			}
			for (var i:int = 0; i < l_nowArr.length; i++) 
			{
				var l_text:Text=this.m_ui.StrongProperty.getChildByName("NowPropertyText"+i) as Text;
				l_text.text="+"+l_nowArr[i].num;
				l_text.visible=true;
			}
			
			var itemvo:ItemVo=GameConfigManager.items_dic[l_equipvo.cost.split("=")[0]];
			m_ui.CostImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
			m_ui.CostImage.visible=false;
			m_ui.HasImage.skin="appRes/icon/itemIcon/"+itemvo.icon+".png";
			if(l_equipvo.getCost()!=null)
			{
//				m_ui.CostNumText.text=l_equipvo.getCost();
			}
			
			this.m_ui.CostList.itemRender=ItemCostCell;
			this.m_ui.CostList.array=getStrengthArr(p_id,p_level);
			this.m_ui.CostList.visible=true;
			var l_id:int=l_equipvo.getCostId();
			m_ui.NumText.text=0;
			m_ui.NumText.text=XUtils.formatResWith(BagManager.instance.getItemNumByID(l_id));
		}
		
		private function getStrengthArr(p_id:int,p_level:int):Array
		{
			var l_arr:Array=new Array();
			var l_equipvo:EquipmentIntensifyVo=getEquipStringInfo(p_id,p_level);
			var itemData:ItemData=new ItemData();
			itemData.iid=l_equipvo.cost.split("=")[0];
			itemData.inum=l_equipvo.cost.split("=")[1];
			itemData.isShowMax=false;
			l_arr.push(itemData);
//			var l_maxlevel:int=getEquipMaxLevel(p_id);
//			var l_level5:int=p_level+5;
//			if(l_level5>l_maxlevel)
//			{
//				l_level5=l_maxlevel;
//			}
//			var l_itemData5:ItemData=new ItemData();
//			for(var i:int=p_level;i<l_level5;i++)
//			{
//				var l_vo:EquipmentIntensifyVo=getEquipStringInfo(p_id,i);
//				if(l_vo!=null)
//				{
//					l_itemData5.iid=l_vo.cost.split("=")[0];
//					l_itemData5.isShowMax=false;
//					l_itemData5.inum+=parseInt(l_vo.cost.split("=")[1]);
//				}
//			}
//			l_arr.push(l_itemData5);
			return l_arr;
		}
		
		/**
		 * 
		 * @param p_id
		 * @param p_level
		 * @return 
		 * 
		 */
		private function getEquipStringInfo(p_id:int,p_level:int):EquipmentIntensifyVo
		{
			var l_vo:EquipmentIntensifyVo;		
			var l_equipvo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentIntensifyList.length; i++) 
			{
				var l_vo:EquipmentIntensifyVo= GameConfigManager.EquipmentIntensifyList[i];
				if(l_equipvo &&l_vo.node_id==l_equipvo.streng_id && l_vo.level==p_level)
				{
					return l_vo;
				}
			}
			return null;
		}
		
		
		/**
		 * 装备最大等级
		 */
		private function getEquipMaxLevel(p_id:int):int
		{
			var l_maxLevel:int=0;		
			var l_equipvo:EquipmentListVo=GameConfigManager.EquipmentList[p_id];
			for (var i:int = 0; i < GameConfigManager.EquipmentIntensifyList.length; i++) 
			{
				var l_vo:EquipmentIntensifyVo= GameConfigManager.EquipmentIntensifyList[i];
				if(l_equipvo && l_vo.node_id==l_equipvo.streng_id)
				{
					l_maxLevel++;
				}
			}
			l_maxLevel=l_maxLevel-1;
			var user:User = GlobalRoleDataManger.instance.user;
			if(user.level<l_maxLevel)
			{
				l_maxLevel=user.level;
			}
			return l_maxLevel;
		}
		
		private function getWashFighting(p_arr:Array):int
		{
			var l_br:int=0;
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				var l_attVo:AttVo=p_arr[i];
				if(l_attVo.name=="HP")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["hp_BR"].value);
				}
				if(l_attVo.name=="ATK")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["attack_BR"].value);
				}
				if(l_attVo.name=="hit")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["hit_BR"].value);
				}
				if(l_attVo.name=="crit")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["crit_BR"].value);
				}
				if(l_attVo.name=="CDMG")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["critical_damage_BR"].value);
				}
				if(l_attVo.name=="DEF")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["defense_BR"].value);
				}
				if(l_attVo.name=="SPEED")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["speed_BR"].value);
				}
				if(l_attVo.name=="dodge")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["dodge_BR"].value);
				}
				if(l_attVo.name=="RES")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["resilience_BR"].value);
				}
				if(l_attVo.name=="CDMGR")
				{
					l_br+=parseInt(l_attVo.num)*parseInt(GameConfigManager.UnitParameterList["critical_damage_reduction_BR"].value);
				}
			}
			return l_br;
		}
		
		/**
		 * 洗练属性
		 */
		public function setWashChangeProperty(p_obj:Object,p_arr:Array):void
		{
			m_changeList=new Array();
			
			m_changeList=p_arr.concat();
			
			for(var i:int=0;i<m_attList.length;i++)
			{
				var key:int=-1;
				var l_attVo:AttVo=m_attList[i];
				var l_change:int= p_obj[l_attVo.name];
				if(l_change!=null && l_change!=undefined)
				{
					l_attVo.change=l_change;
					l_attVo.num=l_change;
					m_attList[i]=l_attVo;
					var isnew:Boolean=true;
					for(var j:int = 0; j < p_arr.length; j++)
					{
						if (p_arr[j]!=null) 
						{
							if(p_arr[j].name==l_attVo.name)
							{
								p_arr[j].change=p_arr[j].num;
								isnew=false;
								break;
							}
						}
					}
					if(isnew==true)
					{
						for(var j:int = 0; j < m_changeList.length; j++)
						{
							if (m_changeList[j]==null) 
							{
								m_changeList[j]=l_attVo;
								break;
							}
						}
							
					}
				}
			}
			m_ui.WashChangePropertyList.visible=true;
			m_ui.WashChangePropertyList.array=m_changeList;
			m_washfightVO.change=m_selffightVO.now;
			m_washfightVO.now=getWashFighting(m_changeList);
			m_ui.ChangeFightingCell.visible=true;
			var l_cell:WashFightingCell=new WashFightingCell(m_ui.ChangeFightingCell,m_washfightVO);
			
		}
	}
}