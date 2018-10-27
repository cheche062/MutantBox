package game.module.MilitaryHouse 
{
	import game.common.ItemTips;
	import game.common.UIRegisteredMgr;
	import game.global.data.bag.BagManager;
	import game.global.event.BagEvent;
	import game.global.event.GuildEvent;
	import game.module.alert.ItemAlertView;
	import game.module.bingBook.ItemContainer;
	import MornUI.militaryHouse.MilitaryHouseViewUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBUnitStar;
	import game.global.event.MilitartHouseEvent;
	import game.global.event.Signal;
	import game.global.vo.FightUnitVo;
	import game.global.vo.militaryHouse.MilitaryHeroScore;
	import game.global.vo.militaryHouse.MilitaryScore;
	import game.global.vo.militaryHouse.MilitaryUnitScore;
	import game.module.camp.CampData;
	import game.module.military.MilitaryItem;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MilitartHouseView extends BaseDialog 
	{
		
		private var _typeBlockVec:Vector.<MilitaryTypeItem> = new Vector.<MilitaryTypeItem>(9);
		private var _blockData:Object = { };
		
		private var _choosenUnit:Vector.<MilitaryUnitItem> = new Vector.<MilitaryUnitItem>(6);
		
		private var _selectType:int = 0;
		private var _unitData:Array = [];
		
		private var _typeAreaY:Number = 0;
		private var _rightAreaX:Number = 0;
		private var _leftAreaX:Number = 0;
		private var _unitAreaY:Number = 0;
		private var _effAreaY:Number = 0;
		
		private var _selectUnitID:String = "";
		private var _selectBlockIndex:int = 0;
		
		private var _isDelUnit:Boolean = false;
		
		private var _isInUnit:Boolean = false;
		
		private var _buyPrice:String;
		
		//private var _upgradeItemImg:Image;
		
		private var _typeImg:Image;
		private var allScore:int;
		private var _cost:String;
		
		public function MilitartHouseView() 
		{
			super();
			m_iPositionType = LayerManager.LEFTUP;
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			var i:int = 0;
			switch(e.target)
			{
				case view.closeBtn:
					if (_isInUnit)
					{
						changeToType();
						hideUnitList();
					}
					else
					{
						close();
					}
					break;
				case view.closeUnitBtn:
					changeToType();
					hideUnitList();
					break;
				case view.hideULBtn:
					hideUnitList();
					for (i = 0; i < 6; i++ )
					{
						_choosenUnit[i].setSelectedState(false);
					}
					break;
				case view.upgradeBtn:
					XFacade.instance.openModule(ModuleName.MilitaryUpgradeView,[_selectType,_blockData[_selectType+1]["level"],allScore]);
					break;
				case view.ruleBtn:
					//XTipManager.showTip(GameLanguage.getLangByKey("L_A_53047"));
					break;
				case view.autoBtn:
					if (view.autoBtn.skin == "militaryHouse/btn_3.png")
					{
						WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_AUTO_PUT, [_selectType+1]);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_REMOVE_ALL, [_selectType+1]);
					}
					break;
				case view:
				case view.rightArea:
					hideUnitList();
					break;
				default:
					break;
			}
		}
		
		private function selectBlockType(e:Event = null):void
		{
			var i:int = 0;
			
			if(e)
			{
				var str:String = e.target.name;
				_selectType = parseInt(str.split("_")[1]);
				//sound
				SoundMgr.instance.playSound(ResourceManager.getSoundUrl("ui_common_click",'uiSound'));
			}
			var nowLv:int = _blockData[_selectType+1]["level"];
			trace("lv:", nowLv);
			trace("_selectType:", _selectType);
			switch(_selectType)
			{
				case 0:
					_unitData = CampData.getUnitList(1);
					break;
				case 1:
					_unitData = CampData.getUnitList(2, 1);
					break;
				case 2:
					_unitData = CampData.getUnitList(2, 2);
					break;
				case 3:
					_unitData = CampData.getUnitList(2, 3);
					break;
				case 4:
					_unitData = CampData.getUnitList(2, 4);
					break;
				case 5:
					_unitData = CampData.getUnitListByAttType(1);
					break;
				case 6:
					_unitData = CampData.getUnitListByAttType(2);
					break;
				case 7:
					_unitData = CampData.getUnitListByAttType(3);
					break;
				case 8:
					_unitData = CampData.getUnitListByAttType(4);
					break;
				
				default:
					break;
			}
			switch(nowLv % 3)
			{
				case 0:
					view.leftBg.skin = "militaryHouse/bg4.png";
					break;
				case 1:
					view.leftBg.skin = "militaryHouse/bg4_1.png";
					break;
				case 2:
					view.leftBg.skin = "militaryHouse/bg4_2.png";
					break;
			}
			
			refreshUnitView();
			if(e)
			{
				changToUnit();
			}
			
		}
		
		private function refreshUnitView():void
		{
			allScore = 0;
			var i:int = 0;
			var openid:int = 0;
			var nowLv:int = _blockData[_selectType+1]["level"];
			
			var upgradVo:MilitaryScore = GameConfigManager.military_score[nowLv + 1];
			
			if (upgradVo)
			{
				switch(_selectType)
				{
					case 0:
						_cost = upgradVo.cost_1;
						break;
					case 1:
						_cost = upgradVo.cost_2;
						break;
					case 2:
						_cost = upgradVo.cost_3;
						break;
					case 3:
						_cost = upgradVo.cost_4;
						break;
					case 4:
						_cost = upgradVo.cost_5;
						break;
					case 5:
						_cost = upgradVo.cost_6;
						break;
					case 6:
						_cost = upgradVo.cost_7;
						break;
					case 7:
						_cost = upgradVo.cost_8;
						break;
					case 8:
						_cost = upgradVo.cost_9;
						break;
					default:
						break;
				}
				view.upgradeItemImg.skin = GameConfigManager.getItemImgPath(_cost.split("=")[0]);
				if (BagManager.instance.getItemNumByID(_cost.split("=")[0]) == 0)
				{
					BagManager.instance.initBagData();
				}
				view.upgradeNumTF.text = BagManager.instance.getItemNumByID(_cost.split("=")[0]) + "/" + _cost.split("=")[1];
			}
			else
			{
				view.upgradeNumTF.text = GameLanguage.getLangByKey("L_A_38052");
			}
			
			//trace("_blockData:", _blockData);
			for (var key in _blockData) 
			{
				//trace("key:", key, ": ", _blockData[key]);
				for (var iid in _blockData[key]['slots'])
				{
					//trace("iid:", iid, ": ", _blockData[key]['slots'][iid]);
					if (_blockData[key]['slots'][iid]!="")
					{
						delUnitFromStandbyList(_blockData[key]['slots'][iid]);
					}
				}
			}
			view.autoBtn.skin = "militaryHouse/btn_3.png";
			for (i = 0; i < 6; i++) 
			{
				//trace("state:", _blockData[_selectType+1]["slots"][i + 1]);
				if (_blockData[_selectType+1]["slots"][i + 1] || _blockData[_selectType+1]["slots"][i + 1] == "")
				{
					openid++;
					if (_blockData[_selectType+1]["slots"][i + 1] == "")
					{
						_choosenUnit[i].setState(1);
					}
					else
					{
						_choosenUnit[i].setState(3);
						view.autoBtn.skin = "militaryHouse/btn_4.png";
						var cData:Object = CampData.getUintById(_blockData[_selectType+1]["slots"][i + 1]);
						cData['militaryScore'] = countScore(cData.level, (DBUnitStar.getStarData(cData.starId).star_level), cData.advLv, (GameConfigManager.unit_dic[cData.unitId] as FightUnitVo).rarity);
						_choosenUnit[i].dataSource = cData;
						/*trace("cData: ", cData);
						trace("militaryScore: ", cData['militaryScore']);*/
						allScore+= cData['militaryScore'];
					}
				}
				else
				{
					_choosenUnit[i].setState(0);
				}
				
			}
			
			var _upgradeInfo:MilitaryScore;
			var addNum:Number = 0;
			if (nowLv > 0)
			{
				_upgradeInfo = GameConfigManager.military_score[nowLv + 1];
				if (!_upgradeInfo)
				{
					addNum =  Math.ceil(allScore * (nowLv * 6 / 100));
					view.upgradeBtn.disabled = true;
				}
				else
				{
					addNum =  Math.ceil(allScore * (nowLv * _upgradeInfo.inc / 100));
					view.upgradeBtn.disabled = false;
					
				}
				view.scoreTF.text = parseInt(allScore+addNum)+"(+"+addNum+")";
				
			}
			else
			{
				view.scoreTF.text = allScore+"(+"+addNum+")";
			}
			
			
			
			var ef:Number = 0;
			if (allScore > 0)
			{
				if (_selectType == 0)
				{
					var hs:MilitaryHeroScore = GameConfigManager.intance.getHeroScoreVo(allScore+addNum);
					if (!hs.lj)
					{
						hs.lj = 0;
					}
					ef = parseFloat((allScore+addNum-hs.CD_down) * hs.stage_price)+parseFloat(hs.lj);
				}
				else
				{
					var us:MilitaryUnitScore = GameConfigManager.intance.getUnitScoreVo(allScore+addNum);
					if (!us.lj)
					{
						us.lj = 0;
					}
					ef = parseFloat((allScore+addNum-us.CD_down) * us.stage_price)+parseFloat(us.lj);
				}
			}
			
			view.effectScore.text = XUtils.toFixed(ef,2)+"%";
			
			if (openid < 6)
			{
				_buyPrice = GameConfigManager.military_price_info[openid - 2].price
				_choosenUnit[openid].setState(2, _buyPrice);
			}
			
			
			/*trace("asdfa:",view.typeTF.width)
			trace("asdfa:",view.typeTF.wordWrap)*/
			view.typeTF.text = GameLanguage.getLangByKey(GameConfigManager.military_block_info[_selectType].name);
			view.typeDesTF.text = GameLanguage.getLangByKey(GameConfigManager.military_block_info[_selectType].dec).replace(/##/g, "\n");
			view.typeStateTF.text = GameLanguage.getLangByKey(GameConfigManager.military_block_info[_selectType].re_dec).replace(/##/g, "\n");
			
			var ta:Array = GameConfigManager.military_block_info[_selectType].req.split("|");
			
			if (ta[0] == 256)
			{
				_typeImg.skin = "militaryHouse/icon_256.png";
			}
			else if (parseInt(ta[1])!=0)
			{
				_typeImg.skin = "militaryHouse/icon_"+ ta[1] +".png";
			}
			else
			{
				_typeImg.skin = "militaryHouse/icon_"+ ta[2] +".png";
			}
			
			
			checkStandbyList();			
			view.unitList.dataSource = _unitData;
		}
		
		
		private function sortByScore(a1:Object, a2:Object)
		{
			if (parseInt(a1['militaryScore']) < parseInt(a2['militaryScore']))
			{
				return 1;
			}
			return - 1;
		}
		
		private function checkStandbyList():void
		{
			var len:int = _unitData.length;
			
			
			for (var i:int = 0; i <len ; i++) 
			{
				//trace(i, ": ", _unitData[i]);
				/*trace("level: ", _unitData[i].level);
				trace("star: ", (DBUnitStar.getStarData(_unitData[i].starId).star_level));
				trace("advLv: ", _unitData[i].advLv);
				trace("rarity: ", (GameConfigManager.unit_dic[_unitData[i].unitId] as FightUnitVo).rarity);*/
				_unitData[i]['militaryScore'] = countScore(_unitData[i].level, (DBUnitStar.getStarData(_unitData[i].starId).star_level), _unitData[i].advLv, (GameConfigManager.unit_dic[_unitData[i].unitId] as FightUnitVo).rarity);
				//trace("militaryScore: ",_unitData[i]['militaryScore']);
			}
			_unitData.sort(sortByScore);	
			var noQyArr:Array = [];
			var len:int = _unitData.length;	
			
			for (i = 0; i <len ; i++) 
			{
				
				if (parseInt(_unitData[i].level) < GameConfigManager.military_block_info[_selectType].req_l)
				{
					_unitData[i]['qy'] = 0;
					noQyArr.push(_unitData.splice(i, 1)[0]);
					len--;
					i--
				}
				else
				{
					_unitData[i]['qy'] = 1;
				}
				
			}
			_unitData = _unitData.concat(noQyArr);
		}
		
		public static function countScore(lv:int=0,star:int=0,advLv:int=0,raty:int=1):int
		{
			var scoreFormula:String;
			var parameterJson:* = ResourceManager.instance.getResByURL("config/militaryHouse/res_param.json");
			if(parameterJson)
			{
				scoreFormula = parameterJson['5']['value'];
				
			}else
			{
				trace("config/unit_parameter.json未载入");
			}
			
			while (scoreFormula.search("\\$param1") > 0)
			{
				scoreFormula = scoreFormula.replace("\\$param1",lv);
			}
			while (scoreFormula.search("\\$param2") > 0)
			{
				scoreFormula = scoreFormula.replace("\\$param2",star);
			}
			while (scoreFormula.search("\\$param3") > 0)
			{
				scoreFormula = scoreFormula.replace("\\$param3",advLv);
			}
			while (scoreFormula.search("\\$param4") > 0)
			{
				scoreFormula = scoreFormula.replace("\\$param4",raty);
			}
			
			return __JS__("eval(scoreFormula)");
		}
		
		
		
		private function delUnitFromStandbyList(id:String):void
		{
			var len:int = _unitData.length;
			for (var i:int = 0; i <len ; i++) 
			{
				if (id == _unitData[i].unitId)
				{
					_unitData.splice(i, 1);
					return;
				}
			}
		}
		
		/**获取服务器消息*/
		private function militartEventHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case MilitartHouseEvent.SELECT_UNIT:
					_selectUnitID = args[0];
					WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_CHANGE, [_selectType+1,_selectBlockIndex+1,_selectUnitID,1]);
					break;
				case MilitartHouseEvent.OPEN_UNIT_LIST:
					if(view.unitArea.y != _unitAreaY)
					{
						showUnitList();
					}
					_selectBlockIndex = args[0];
					
					for (i = 0; i < 6; i++ )
					{
						if (i == args[0])
						{
							_choosenUnit[i].setSelectedState(true);
						}
						else
						{
							_choosenUnit[i].setSelectedState(false);
						}
					}
					
					break;
				case MilitartHouseEvent.BUY_BLOCK:
					
					/*ItemAlertView.showItemAlert("开启此模块需花费{0}{1},确认开启？",_buyPrice.split("=")[0],_buyPrice.split("=")[1],
												function() { WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_BUY_BLOCK, [_selectType+1]); } );*/
					
					XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_15014"),
																			_buyPrice.split("=")[0],
																			_buyPrice.split("=")[1],
																			function(){									
																			WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_BUY_BLOCK, [_selectType+1]); }]);
									
					break;
				case MilitartHouseEvent.DEL_UNIT_LIST:
					/*trace("");
					trace("delID:", args[0]);
					trace("");*/
					_selectBlockIndex = args[1];
					_isDelUnit = true;
					WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_CHANGE, [_selectType+1, _selectBlockIndex + 1, args[0], 2]);
					
					break;
				default:
					break;
			}
		}
		
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			trace("militaryHouserServiceData: ", args);
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.MILITARY_HOUSE_INIT:
					_blockData = args[1];
					refreshBlockType();
					selectBlockType();
					
					break;
				case ServiceConst.MILITARY_HOUSE_CHANGE:
					
					if (_isDelUnit)
					{
						_blockData[_selectType+1]["slots"][_selectBlockIndex + 1] = "";
					}
					else
					{
						_blockData[_selectType+1]["slots"][_selectBlockIndex + 1] = _selectUnitID;
					}
					selectBlockType();
					_isDelUnit = false;
					WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_INIT, []);
					break;
				case ServiceConst.MILITARY_HOUSE_BUY_BLOCK:
					_blockData[_selectType+1]["slots"][args[1]] = "";
					refreshBlockType();
					selectBlockType();
					break;
				case ServiceConst.MILITARY_HOUSE_AUTO_PUT:
				case ServiceConst.MILITARY_HOUSE_REMOVE_ALL:
					WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_INIT, []);
					break;
				default:
					break;
			}
		}
		
		private function refreshBlockType():void
		{
			for (var i:int = 0; i < 9; i++) 
			{
				_typeBlockVec[i].dataSource = _blockData[i + 1];
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			//AnimationUtil.flowIn(this);
			
			
			
			WebSocketNetService.instance.sendData(ServiceConst.MILITARY_HOUSE_INIT, []);
			_isInUnit = false;
			view.selectTypeArea.alpha = 1;
			view.selectTypeArea.visible = true;
			view.effectArea.y = 58;
			hideUnit();
			stageSizeChange();
		}
		
		public function showUnitList():void
		{
			view.unitArea.visible = true;
			view.unitArea.y = Laya.stage.height + 300;
			Tween.to(view.unitArea, { y:_unitAreaY }, 250);
		}
		
		public function hideUnitList():void
		{
			Tween.to(view.unitArea, { y:Laya.stage.height + 300 }, 250);
		}
		
		public function changToUnit():void
		{
			Tween.to(view.selectTypeArea, { y:_typeAreaY + 50, alpha:0 }, 250,Ease.linearNone,new Handler(this,hideSelectType));
			
			view.rightArea.visible = true;
			view.rightArea.x = Laya.stage.width;
			Tween.to(view.rightArea, { x:_rightAreaX }, 250);
			
			view.effectArea.visible = true;
			view.effectArea.y = _effAreaY - 20;
			view.effectArea.alpha = 0;
			Tween.to(view.effectArea, { y: _effAreaY,alpha:1 }, 250);
			
			
			
			view.leftArea.visible = true;
			view.leftArea.x = -600;
			Tween.to(view.leftArea, { x:0 }, 250);
			_isInUnit = true;
		}
		
		public function hideSelectType():void
		{
			view.selectTypeArea.visible = false;
		}
		
		public function changeToType():void
		{
			_isInUnit = false;
			view.selectTypeArea.alpha = 0;
			view.selectTypeArea.visible = true;
			Tween.to(view.selectTypeArea, { y:_typeAreaY, alpha:1 }, 250, Ease.linearNone, new Handler(this, hideUnit));
			
			Tween.to(view.rightArea, { x:Laya.stage.width }, 250);
			
			Tween.to(view.leftArea, { x: -600 }, 250);
			
			Tween.to(view.effectArea, { y: _effAreaY-20,alpha:0 }, 250);
			
			
		}
		
		public function showTips():void
		{
			ItemTips.showTip(_cost.split("=")[0]);
		}
		
		public function hideUnit():void
		{
			view.rightArea.visible = false;
			view.leftArea.visible = false;
			view.effectArea.visible = false;
		}
		
		override public function close():void
		{
			onClose();
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			/*UIRegisteredMgr.DelUi("AreaDeployBtn");
			UIRegisteredMgr.DelUi("ChallengeArea");*/
		}
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		protected function stageSizeChange(e:Event = null):void
		{
			view.size(Laya.stage.width , Laya.stage.height);
			var scaleNum:Number =  Laya.stage.width / view.mhBg.width;
			
			view.mhBg.scaleX = view.mhBg.scaleY = scaleNum;
			view.mhBg.y = ( Laya.stage.height - view.mhBg.height * scaleNum ) / 2;
			
			view.titleArea.x = (Laya.stage.width - 1022) / 2;
			
			
			view.closeBtn.x = Laya.stage.width-view.closeBtn.width;
			
			view.selectTypeArea.x = (Laya.stage.width - 978) / 2;
			_typeAreaY = view.selectTypeArea.y = (Laya.stage.height - 497) / 2;
			
			
			view.leftArea.y = ( Laya.stage.height - 489) / 2 + 30;
			
			_rightAreaX = view.rightArea.x = Laya.stage.width - 400;
			view.rightArea.y = ( Laya.stage.height - 431 ) / 2 + 30;
			
			view.unitArea.scaleX = view.unitArea.scaleY = scaleNum;
			_unitAreaY = view.unitArea.y = Laya.stage.height - 180;
			view.unitArea.y = Laya.stage.height + 300;
			
			
			_effAreaY = view.effectArea.y;
			view.effectArea.x = (Laya.stage.width - 316 * scaleNum) / 2;
		}
		
		override public function createUI():void
		{
			this.closeOnBlank = true;
			
			this._view = new MilitaryHouseViewUI();
			this.addChild(_view);
			
			view.typeTF.wordWrap = true;
			view.typeDesTF.wordWrap = true;
			view.typeStateTF.wordWrap = true;
			
			view.selectTypeArea.visible = true;
			
			view.rightArea.visible = false;
			view.leftArea.visible = false;
			view.unitArea.visible = false;
			view.autoBtn.visible = false;
			
			view.unitList.itemRender = MilitaryUnitItem;
			view.unitList.spaceX = -10;
			view.unitList.hScrollBarSkin = "";
			
			_typeImg = new Image();
			_typeImg.skin = "militaryHouse/icon_1.png";
			_typeImg.x = -30;
			_typeImg.y = -50;
			view.rightArea.addChild(_typeImg);
			
			for (var i:int = 0; i < 9; i++) 
			{
				_typeBlockVec[i] = new MilitaryTypeItem();
				_typeBlockVec[i].setMC(view['type_' + i]);
				_typeBlockVec[i].view.on(Event.CLICK, this, selectBlockType);
				
				if (i < 6)
				{
					_choosenUnit[i] = new MilitaryUnitItem();
					_choosenUnit[i].setMC(view['choosen_'+i],i);
				}
			}
			
			view.upgradeItemImg.on(Event.CLICK, this, showTips);
			
			UIRegisteredMgr.AddUI(view.type_0, "MilitaryTypeUnit");
			UIRegisteredMgr.AddUI(view.choosen_0, "MilitaryHeroUnit");
			UIRegisteredMgr.AddUI(view.unitList, "MilitaryHeroList");
			UIRegisteredMgr.AddUI(view.sArea,"MilitarySArea")
			UIRegisteredMgr.AddUI(view.effectArea,"MilitaryEArea")
			UIRegisteredMgr.AddUI(view.upgradeBtn,"MilitaryUpgrade")
			UIRegisteredMgr.AddUI(view.closeBtn,"MilitaryCloseBtn")
			
			GameConfigManager.intance.initMilitaryData();		
		}
		
		public override function destroy(destroyChild:Boolean = true):void {
			
			UIRegisteredMgr.DelUi("MilitaryTypeUnit");
			UIRegisteredMgr.DelUi("MilitaryHeroUnit");
			UIRegisteredMgr.DelUi("MilitaryHeroList");
			UIRegisteredMgr.DelUi("MilitarySArea");
			UIRegisteredMgr.DelUi("MilitaryEArea");
			UIRegisteredMgr.DelUi("MilitaryUpgrade");
			UIRegisteredMgr.DelUi("MilitaryCloseBtn");
			
			super.destroy(destroyChild);
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_INIT),this,serviceResultHandler,[ServiceConst.MILITARY_HOUSE_INIT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_CHANGE),this,serviceResultHandler,[ServiceConst.MILITARY_HOUSE_CHANGE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_BUY_BLOCK),this,serviceResultHandler,[ServiceConst.MILITARY_HOUSE_BUY_BLOCK]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_AUTO_PUT),this,serviceResultHandler,[ServiceConst.MILITARY_HOUSE_AUTO_PUT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_REMOVE_ALL),this,serviceResultHandler,[ServiceConst.MILITARY_HOUSE_REMOVE_ALL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.on(MilitartHouseEvent.SELECT_UNIT, this, militartEventHandler,[MilitartHouseEvent.SELECT_UNIT]);
			Signal.intance.on(MilitartHouseEvent.OPEN_UNIT_LIST, this, militartEventHandler,[MilitartHouseEvent.OPEN_UNIT_LIST]);
			Signal.intance.on(MilitartHouseEvent.BUY_BLOCK, this, militartEventHandler,[MilitartHouseEvent.BUY_BLOCK]);
			Signal.intance.on(MilitartHouseEvent.DEL_UNIT_LIST, this, militartEventHandler, [MilitartHouseEvent.DEL_UNIT_LIST]);
			
			Signal.intance.on(GuildEvent.HIDE_MILITARYHOUSE_UNIT_LIST, this, hideUnitList);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, refreshUnitView);
			
			
			Laya.stage.on(Event.RESIZE,this,stageSizeChange);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_INIT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_CHANGE),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_BUY_BLOCK),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_AUTO_PUT),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.MILITARY_HOUSE_REMOVE_ALL),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			Signal.intance.off(MilitartHouseEvent.SELECT_UNIT, this, militartEventHandler);
			Signal.intance.off(MilitartHouseEvent.OPEN_UNIT_LIST, this, militartEventHandler);
			Signal.intance.off(MilitartHouseEvent.BUY_BLOCK, this, militartEventHandler);
			Signal.intance.off(MilitartHouseEvent.DEL_UNIT_LIST, this, militartEventHandler);
			
			Signal.intance.off(GuildEvent.HIDE_MILITARYHOUSE_UNIT_LIST, this, hideUnitList);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, refreshUnitView);
			
			Laya.stage.off(Event.RESIZE,this,stageSizeChange);
			super.removeEvent();
		}
		
		
		
		private function get view():MilitaryHouseViewUI{
			return _view;
		}
	}

}