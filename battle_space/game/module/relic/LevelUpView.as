package game.module.relic
{
	import MornUI.relic.LevelUpViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.DBUnit;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.vo.FightUnitVo;
	import game.global.vo.ItemVo;
	import game.global.vo.relic.TransportBaseInfo;
	import game.global.vo.relic.TransportBookVo;
	import game.global.vo.unit.UnitUpgradeExpVo;
	import game.module.camp.CampData;
	import game.module.camp.ProTipUtil;
	import game.module.camp.UnitItem;
	import game.module.camp.UnitItemVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class LevelUpView extends BaseDialog
	{
		private var m_selectIndex:int;
		private var m_heroData:Object;
		private var m_itemData:ItemData;
		private var m_ishero:int;
		private var m_heroList:Array;
		private var m_itemList:Array;
		private var m_heroType:int;
		
		private var m_bookVo:TransportBookVo;
		
		private var m_selectHero:UnitItem;
		
		
		public function LevelUpView()
		{
			super();
		}
		
		override public function createUI():void
		{
			this._view = new LevelUpViewUI();
			this.addChild(_view);
			
			UIRegisteredMgr.AddUI(view.UpgradeBtn,"UpgradeBtn");
			UIRegisteredMgr.AddUI(view.BattleBtn,"GoRadioBtn");
			
			view.UpgradeBtn['clickSound'] = ResourceManager.getSoundUrl("ui_unit_upgrade",'uiSound')
			view.AtuoUpgradeBtn['clickSound'] = ResourceManager.getSoundUrl("ui_unit_upgrade",'uiSound')
			this.closeOnBlank=true;
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			m_heroList=new Array();
			m_selectHero=0;
			GameConfigManager.intance.getTransport();
			WebSocketNetService.instance.sendData(ServiceConst.C_INFO,[]);
			//WebSocketNetService.instance.sendData(ServiceConst.ADD_ITEM,["80017=1000"]);
			initUI();
		}
		
		override public function dispose():void{
			Laya.loader.clearRes("relic/bg5.png");
			super.destroy();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			view.TitleText.text=GameLanguage.getLangByKey("L_A_34102");
			view.HeroText.text=GameLanguage.getLangByKey("L_A_34076");
			view.AllText.text=GameLanguage.getLangByKey("L_A_34089");
			view.HarmorText.text=GameLanguage.getLangByKey("L_A_34077");
			view.MediumArmorText.text=GameLanguage.getLangByKey("L_A_34078");
			view.LarmorText.text=GameLanguage.getLangByKey("L_A_34079");
			view.MorionText.text=GameLanguage.getLangByKey("L_A_34080");
			view.UpgradeBtn.text.text=GameLanguage.getLangByKey("L_A_34081");
			view.AtuoUpgradeBtn.text.text=GameLanguage.getLangByKey("L_A_34082");
			view.GoToGetBtn.text.text=GameLanguage.getLangByKey("L_A_34105");
			view.GoToGetBtn.visible=false;
		}
		
		
		private function createItemView(p_type:int):void
		{
			m_itemList=new Array();
			var l_arr:Array=BagManager.instance.getItemListByType([18]);
			m_itemList=new Array();
			if(l_arr!=null)
			{
				for (var i:int = 0; i < GameConfigManager.TransportBookList.length; i++) 
				{
					var l_bookVo:TransportBookVo=GameConfigManager.TransportBookList[i];
					var l_vo:ItemData;
					var l_itemVo:ItemData=new ItemData();
					var l_bookType:int=0;
					l_bookType=m_heroType;
					var l_heroType:int=0;
					if(p_type==5)
					{
						m_ishero=1;
						l_heroType=5;
						view.GoToGetBtn.visible=true;
						view.UpgradeBtn.x=419;
						view.AtuoUpgradeBtn.x=696;
					}
					else
					{
						m_ishero=0;
						l_heroType=p_type;
						view.GoToGetBtn.visible=false;
						view.UpgradeBtn.x=230;
						view.AtuoUpgradeBtn.x=588;
					}
					if(l_bookVo.type==l_bookType || l_heroType==l_bookVo.type || l_bookVo.type==6)
					{
						l_itemVo.iid=l_bookVo.id;
						for (var j:int = 0; j < l_arr.length; j++) 
						{
							l_vo=l_arr[j];
							if(l_bookVo.id==l_vo.iid)
							{
								l_itemVo.inum=BagManager.instance.getItemNumByID(l_vo.iid);
							}
						}
						m_itemList.push(l_itemVo);
					}	
				}
				if(m_itemList.length>0)
				{
					this.view.ItemList.visible=true;
				}
				else
				{
					this.view.ItemList.visible=false;
				}
				this.view.ItemList.itemRender = LevelItemCell;
				this.view.ItemList.hScrollBarSkin = "";
				this.view.ItemList.selectEnable = true;
				
				this.view.ItemList.array = m_itemList;
				for (var i:int = 0; i < this.view.ItemList.array.length; i++) 
				{
					var l_cell:LevelItemCell=this.view.ItemList.getCell(i)as LevelItemCell;
					if(l_cell!=null)
					{
						l_cell.selected=false;
					}
				}
				this.view.ItemList.selectedIndex = m_selectIndex;
				onSelect(m_selectIndex);
			}
			else
			{
				this.view.ItemList.visible=false;
			}
		}

		
		/**
		 * 创建物品列表
		 */
		private function createItemList():void
		{
			m_itemList=new Array();
			var l_arr:Array=BagManager.instance.getItemListByType([18]);
			var l_fight:FightUnitVo;
			l_fight=new FightUnitVo();
			if(m_heroData!=null)
			{
				if(m_heroData.unit_id!=undefined && m_heroData.unit_id!=null)
				{
					l_fight=GameConfigManager.unit_dic[m_heroData.unit_id];
				}
				else
				{
					l_fight=GameConfigManager.unit_dic[m_heroData.unitId];
				}
			}
			
			m_itemList=new Array();
			if(l_arr!=null)
			{
				for (var i:int = 0; i < GameConfigManager.TransportBookList.length; i++) 
				{
					var l_bookVo:TransportBookVo=GameConfigManager.TransportBookList[i];
					var l_vo:ItemData;
					var l_itemVo:ItemData=new ItemData();
					var l_bookType:int=0;
					l_bookType=m_heroType;
					var l_fightUnit:FightUnitVo=GameConfigManager.unit_dic[m_heroData.unitId];
					var l_heroType:int=0;
					if(l_fightUnit.unit_type==1)
					{
						m_ishero=1;
						l_heroType=5;
						view.GoToGetBtn.visible=true;
						view.UpgradeBtn.x=419;
						view.AtuoUpgradeBtn.x=696;
					}
					else
					{
						m_ishero=0;
						l_heroType=l_fightUnit.defense_type;
						view.GoToGetBtn.visible=false;
						view.UpgradeBtn.x=230;
						view.AtuoUpgradeBtn.x=588;
					}
					if(l_bookVo.type==l_bookType || l_heroType==l_bookVo.type || l_bookVo.type==6)
					{
						l_itemVo.iid=l_bookVo.id;
						for (var j:int = 0; j < l_arr.length; j++) 
						{
							l_vo=l_arr[j];
							if(l_bookVo.id==l_vo.iid)
							{
								l_itemVo.inum=BagManager.instance.getItemNumByID(l_vo.iid);
							}
						}
						m_itemList.push(l_itemVo);
					}	
				}
				if(m_itemList.length>0)
				{
					this.view.ItemList.visible=true;
				}
				else
				{
					this.view.ItemList.visible=false;
				}
				this.view.ItemList.itemRender = LevelItemCell;
				this.view.ItemList.hScrollBarSkin = "";
				this.view.ItemList.selectEnable = true;
				
				this.view.ItemList.array = m_itemList;
				for (var i:int = 0; i < this.view.ItemList.array.length; i++) 
				{
					var l_cell:LevelItemCell=this.view.ItemList.getCell(i)as LevelItemCell;
					if(l_cell!=null)
					{
						l_cell.selected=false;
					}
				}
				this.view.ItemList.selectedIndex = m_selectIndex;
				onSelect(m_selectIndex);
			}
			else
			{
				this.view.ItemList.visible=false;
			}
		}
		
		/**
		 * 选择物品
		 */
		private function onSelect(p_index:int):void
		{
			for (var i:int = 0; i < this.view.ItemList.array.length; i++) 
			{
				var l_cell:LevelItemCell=this.view.ItemList.getCell(i)as LevelItemCell;
				if(l_cell!=null)
				{
					l_cell.selected=false;
				}
			}
			m_selectIndex=p_index;
			// TODO Auto Generated method stub
			m_itemData=this.view.ItemList.getItem(m_selectIndex);
			var l_cell:LevelItemCell=this.view.ItemList.getCell(m_selectIndex) as LevelItemCell;
			l_cell.selected=true;
			setHeroInfo();
		}
		
		/**
		 * 英雄信息
		 */
		private function setHeroInfo():void
		{
			var l_ExpVo:UnitUpgradeExpVo;
			this.view.ExpText.text="";
			var maxExp:int;
			if(m_heroData!=null)
			{
				this.view.NowExpBar.visible=true;
				this.view.AddExpBar.visible=true;
				this.view.AddExpText.visible=true;
				this.view.MaxExpText.visible=true;
				this.view.NowLevelText.visible=true;
				var l_fight:FightUnitVo=GameConfigManager.unit_dic[m_heroData.unitId];
				if(m_heroData.level!=undefined)
				{
					l_ExpVo=GameConfigManager.UnitUpgradeExpList[parseInt(parseInt(m_heroData.level))];
					this.view.NowLevelText.text=GameLanguage.getLangByKey("L_A_73")+m_heroData.level+" - "+GameLanguage.getLangByKey("L_A_73")+(parseInt(m_heroData.level)+1);
				}
				else
				{
					l_ExpVo=GameConfigManager.UnitUpgradeExpList[1];
					this.view.NowLevelText.text=GameLanguage.getLangByKey("L_A_73")+"1 - "+GameLanguage.getLangByKey("L_A_73")+"2";
				}
				if(l_ExpVo!=null)
				{
					if(m_ishero==1)
					{
						maxExp=l_ExpVo.getHeroExp(l_fight.rarity);
					}
					else
					{
						maxExp=l_ExpVo.getSoldierExp(l_fight.rarity);
					}
					if(m_heroData.exp!=undefined)
					{
						this.view.ExpText.text=m_heroData.exp;
					}
					else
					{
						m_heroData.exp=0;
						this.view.ExpText.text=0;
					}
					var l_value:Number=((m_heroData.exp)/maxExp)
					if(l_value>1)
					{
						l_value=1;	
					}
					this.view.NowExpBar.width=355*(l_value);
					this.view.MaxExpText.text="/"+maxExp;
					
				}
				else
				{
					maxExp=m_heroData.exp;
					var l_value:Number=((m_heroData.exp)/maxExp)
					if(l_value>1)
					{
						l_value=1;	
					}
					this.view.NowExpBar.width=355*(l_value);
					this.view.ExpText.text=m_heroData.exp;
					this.view.MaxExpText.text="/"+maxExp;
				}
			}
			else
			{
				this.view.NowExpBar.visible=false;
				this.view.AddExpBar.visible=false;
				this.view.AddExpText.visible=false;
				this.view.MaxExpText.visible=false;
				this.view.NowLevelText.visible=false;
			}
			this.view.AddExpText.text="";
			if(m_itemData!=null)
			{
				for (var i:int = 0; i < GameConfigManager.TransportBookList.length; i++) 
				{
					var l_bookVo:TransportBookVo=GameConfigManager.TransportBookList[i];
					if(l_bookVo.id==m_itemData.iid)
					{
						if(m_heroData!=null)
						{
							var l_value:Number=((m_heroData.exp+l_bookVo.exp)/maxExp)
							if(l_value>1)
							{
								l_value=1;	
							}
							this.view.AddExpBar.width=355*l_value;
						}
						else
						{
							var l_value:Number=((0+l_bookVo.exp)/maxExp)
							if(l_value>1)
							{
								l_value=1;	
							}
							this.view.AddExpBar.width=355*l_value;
						}
						this.view.AddExpText.text="+"+l_bookVo.exp;
					}
				}
			}
		}
		
		/**
		 * 创建英雄列表
		 */
		private function createHeroList(p_type:int):void
		{
			
			m_heroType=p_type;
			var l_heroList:Array=new Array();
			if(p_type==6)
			{
				l_heroList=m_heroList;
			}
			else
			{
				
				createItemView(p_type);
				
				for (var i:int = 0; i < m_heroList.length; i++) 
				{
					var l_vo:Object=m_heroList[i];
					var l_fight:FightUnitVo=GameConfigManager.unit_dic[m_heroList[i].unitId];
					if(l_fight!=undefined &&l_fight!=null)
					{
						if(p_type==1 || p_type==2|| p_type==3||p_type==4)
						{
							if(l_fight.defense_type==p_type && l_fight.unit_type==2)
							{
								l_heroList.push(l_vo);
							}
						}
						else if(p_type==5)
						{
							if(l_vo.unitType==1)
							{
								l_heroList.push(l_vo);
							}
						}
					}
				}	
			}
			
			if(l_heroList.length>0)
			{
				this.view.HeroList.visible=true;
				this.view.HeroList.itemRender=LevelUpCell;
				this.view.HeroList.hScrollBarSkin="";
				this.view.HeroList.selectEnable = true;
				this.view.HeroList.selectHandler=new Handler(this, onHeroSelect);
				view.HeroList.mouseHandler = new Handler(this, this.onSelectHandler);
				
				// 添加是否选中状态
				l_heroList.forEach(function(item) {
					item["isSelected"] = false;
				});
				
				this.view.HeroList.array=l_heroList;
				m_heroData=null;
				view.HeroList.selectedIndex = -1;
				view.HeroList.selectedIndex = 0;
//				onHeroSelect(0);
			}
			else
			{
				m_heroData=null;
				setHeroInfo();
				this.view.HeroList.visible=false;
			}
			setBtnType();
			
		}
		
		private function onSelectHandler(e:Event,index:int):void
		{
			// TODO Auto Generated method stub
			if(e.type != Event.CLICK){
				return;
			}
			var _selectedItem:LevelUpCell = view.HeroList.getCell(index) as LevelUpCell;
			var data:UnitItemVo = _selectedItem.data;
			if(data){
				if(XUtils.checkHit(_selectedItem.attackIcon)){
					ProTipUtil.showAttTip(_selectedItem.data.id);
				}else if(XUtils.checkHit(_selectedItem.defendIcon)){
					ProTipUtil.showDenTip(_selectedItem.data.id);
				}else{
					
				}		
			}
		}
		
		private function onHeroSelect(p_index:int):void
		{
			if (p_index == -1) return;
			
			view.HeroList.array.forEach(function(item, index) {
				item["isSelected"] = index == p_index;
			});
			
			view.HeroList.refresh();
			
			m_selectHero = p_index;
			var l_heroCell:LevelUpCell=this.view.HeroList.getCell(m_selectHero)as LevelUpCell;
			// TODO Auto Generated method stub
			m_heroData=this.view.HeroList.getItem(m_selectHero);
			l_heroCell=this.view.HeroList.getCell(m_selectHero) as LevelUpCell;
			m_selectHero=l_heroCell;
			m_selectIndex=0;
			
			createItemList();
			setHeroInfo();
		}
		
		override public function addEvent():void
		{
			super.addEvent();
			// TODO Auto Generated method stub
			this.on(Event.CLICK,this,this.onClickHander);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE),this,onResult,[ServiceConst.TRAN_GETTRANSPORTTYPE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult,[ServiceConst.C_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ADD_ITEM),this,onResult,[ServiceConst.ADD_ITEM]);
			Signal.intance.on(BagEvent.BAG_EVENT_INIT,this,baginit,[BagEvent.BAG_EVENT_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_USETRAINBOOK),this,onResult,[ServiceConst.TRAN_USETRAINBOOK]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TRAN_ATUOLEVELUP),this,onResult,[ServiceConst.TRAN_ATUOLEVELUP]);
			this.view.ItemList.selectHandler = new Handler(this,onSelect);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
		}
		
		override public function removeEvent():void
		{
			super.removeEvent();
			this.off(Event.CLICK,this,this.onClickHander);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_GETTRANSPORTTYPE),this,onResult,[ServiceConst.TRAN_GETTRANSPORTTYPE]);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ADD_ITEM),this,onResult);
			Signal.intance.off(BagEvent.BAG_EVENT_INIT,this,baginit);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_USETRAINBOOK),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TRAN_ATUOLEVELUP),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			this.view.ItemList.selectHandler =  null;
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			switch(cmd)
			{
				case ServiceConst.TRAN_USETRAINBOOK:
				{
					var l_arr:Array=errStr.split(" ");
					if(l_arr.length>1)
					{
						var l_item:ItemVo=GameConfigManager.items_dic[l_arr[0]];
						var l_name:String=GameLanguage.getLangByKey(l_item.name);
						XTip.showTip(StringUtil.substitute(GameLanguage.getLangByKey(l_arr[1]),l_name));
					}
					else
					{
						XTip.showTip( GameLanguage.getLangByKey(errStr));
					}
					break;
				}
					
				default:
				{
					XTip.showTip( GameLanguage.getLangByKey(errStr));
					break;
				}
			}
		}
		
		
		private function baginit():void
		{
			// TODO Auto Generated method stub
			createItemList();
		}
		
		private function setBtnType():void
		{
			this.view.AllBtn.selected=(m_heroType==6);
			this.view.HarmorBtn.selected=(m_heroType==1);
			this.view.MediumArmorBtn.selected=(m_heroType==2);
			this.view.LarmorBtn.selected=(m_heroType==3);
			this.view.MorionBtn.selected=(m_heroType==4);
			this.view.HeroBtn.selected=(m_heroType==5);
		}
		
		/**
		 * 接受消息
		 */
		private function onResult(cmd:int,...args):void
		{
			// TODO Auto Generated method stub
			switch(cmd)
			{
				case ServiceConst.C_INFO:
					var l_c_info:Object=args[1];
					
					//更新数据源,不能删
					CampData.update(l_c_info);
					//end==========
					
					var fvo:Object
					var srcList:Array;//静态数据源
					var heroList:Array;
					srcList = GameConfigManager.getUnitList(FightUnitVo.SOLDIER);
					heroList=GameConfigManager.getUnitList(FightUnitVo.HERO);
					for(var m:int=0; m<heroList.length; m++){
						//如果在返回数据中
						fvo = heroList[m];
						if(l_c_info.hero_list[fvo.unit_id+""]){
							m_heroList.push(l_c_info.hero_list[fvo.unit_id+""]);
						}
					}
					for(var m:int=0;m<srcList.length;m++)
					{
						fvo = srcList[m];
						if(l_c_info.solier_list[fvo.unit_id+""]){
							m_heroList.push(l_c_info.solier_list[fvo.unit_id+""]);
						}
					}
					m_heroList.sort(sortHeroHandler);
					createHeroList(6);
					break;
				case ServiceConst.TRAN_USETRAINBOOK:
				{
					if(m_heroData.level!=parseInt(args[1])||m_heroData.exp!=parseInt(args[2]))
					{
						levelUpEffect(m_selectHero);
					}
					m_heroData.exp=args[2];
					m_heroData.level=args[1];
					setHeroInfo();
					view.HeroList.refresh();
					createItemList();
					//createHeroList(m_heroType);
					DBUnit.isRadioCanUp();
					break;
				}
				case ServiceConst.TRAN_ATUOLEVELUP:
				{
					if(m_heroData.level!=parseInt(args[1])||m_heroData.exp!=parseInt(args[2]))
					{
						levelUpEffect(m_selectHero);
					}
					m_heroData.exp=args[2];
					m_heroData.level=args[1];
					setHeroInfo();
					view.HeroList.refresh();
					createItemList();
					//createHeroList(m_heroType);
					DBUnit.isRadioCanUp();
					break;
				}
				case ServiceConst.TRAN_GETTRANSPORTTYPE:
				{
					var l_info:Object=args[1];
					var l_data:TransportBaseInfo=new TransportBaseInfo();
					l_data.status=l_info.status;
					l_data.endTime=l_info.endTime;
					if(l_data.status==0)
					{
						XFacade.instance.openModule("EscortMainView",l_data);
					}
					else
					{
						XFacade.instance.openModule("PlunderMainView",l_data);
					}
					this.close();
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		private function sortHeroHandler(a:Object,b:Object):void
		{
			if(a.power>b.power)
			{
				return -1;
			}
			return 1;
		}

		/**
		 * 按键事件
		 */
		private function onClickHander(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case this.view.CloseBtn:
				{
					this.close();
					break;
				}
				case this.view.BattleBtn:
					XFacade.instance.openModule(ModuleName.BingBookMainView);
					close();
					break;
				case this.view.AtuoUpgradeBtn:
					var heroid:int;
					if(m_heroData)
					{
						heroid=m_heroData.unitId;
						WebSocketNetService.instance.sendData(ServiceConst.TRAN_ATUOLEVELUP,[heroid]);
					}
					break;
				case this.view.UpgradeBtn:
					var heroid:int;
					if(m_heroData)
					{
						heroid=m_heroData.unitId;
						WebSocketNetService.instance.sendData(ServiceConst.TRAN_USETRAINBOOK,[heroid,m_itemData.iid]);
					}
					break;
				case this.view.AllBtn:
					createHeroList(6);
					break;
				case this.view.HarmorBtn:
					createHeroList(1);
					break;
				case this.view.MediumArmorBtn:
					createHeroList(2);
					break;
				case this.view.LarmorBtn:
					createHeroList(3);
					break;
				case this.view.MorionBtn:
					createHeroList(4);
					break;
				case this.view.HeroBtn:
					createHeroList(5);
					break;
				case this.view.GoToGetBtn:
					SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP,true,1,[2]);
					close();
					break;
				default:
				{
					break;
				}
			}
			
		}
		
		private function levelUpEffect(p_cell:LevelUpCell):void
		{
			levelCellEffect();
			var l_effect:Animation;
			l_effect=new Animation();
			var jsonStr:String = "appRes/atlas/effects/levelupCell.json";	
			l_effect.loadAtlas(jsonStr);
			l_effect.play(0,false);
			l_effect.once(Event.COMPLETE,this,onCompleteHandler,[l_effect]);
			p_cell.addChild(l_effect);
			l_effect.x=-5;
			l_effect.y=0;
		}
		
		private function levelCellEffect():void
		{
			var l_effect:Animation;
			l_effect=new Animation();
			var jsonStr:String = "appRes/atlas/effects/expCell.json";	
			l_effect.loadAtlas(jsonStr);
			l_effect.play();
			l_effect.once(Event.COMPLETE,this,onCompleteEffectHandler,[l_effect]);
			view.addChild(l_effect);
			l_effect.scaleX=0.56;
			l_effect.x=96;
			l_effect.y=443;
			
			var l_effect1:Animation;
			l_effect1=new Animation();
			var jsonStr1:String = "appRes/atlas/effects/expLine.json";	
			l_effect1.loadAtlas(jsonStr1);
			l_effect1.play();
			l_effect1.once(Event.COMPLETE,this,onCompleteEffectHandler,[l_effect1]);
			view.addChild(l_effect1);
			l_effect1.scaleX=0.55; 
			l_effect1.x=98;
			l_effect1.y=443;
		}
		
		private function onCompleteHandler(...arg):void
		{
			// TODO Auto Generated method stub
			trace("onCompleteHandler");
			this.m_selectHero.removeChild(arg[0]);
		}
		
		
		private function onCompleteEffectHandler(...arg):void
		{
			// TODO Auto Generated method stub
			trace("onCompleteHandler");
			this.view.removeChild(arg[0]);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function get view():LevelUpViewUI{
			return _view as LevelUpViewUI;
		}
		
	}
}