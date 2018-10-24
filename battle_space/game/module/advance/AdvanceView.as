package game.module.advance 
{
	import MornUI.advance.AdvanceViewUI;
	
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.UIRegisteredMgr;
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.event.Signal;
	import game.module.fighting.view.BaseChapetrView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	/**
	 * 战况升阶
	 * @author ...
	 */
	public class AdvanceView extends BaseChapetrView
	{
		private var _view:AdvanceViewUI;
		
		/**当前的队伍id*/
		private var _sUnitID:String;
		
		private var _heroName:TextArea;
		private var _heroLv:TextArea;
		
		private var _costIcon:Image;
		private var _costTF:Text;
		
		private var i1:Image;
		
		private var sy:Number = 0;
		
		/**自否自动玩*/
		private var _autoAdvance:Boolean = false;
		
		/**当前甲种*/ 
		private var _curUnitDT:String;
		/**icon顺序*/
		private var iconList:Array = ["HP", "ATK", "DEF", "SPEED", "hit", "dodge", "crit", "RES", "CDMG", "CDMGR"];
		private var _callback:Function;
		/**节流函数  发送获取信息 */ // 未知原因会被连续调用两次
		private var sendGetInfoHandler:Function;
		
		/**强化解锁数据*/
		private var degree_deblocking_data:Object;
		private var target_degree_config_data
		
		/**资源升阶数据*/
		private var degree_config_data:Object;
		private var target_degree_deblocking_data
		
		/**当前要加强的属性*/
		private var current_attribute:String;
		/**当前属性等级*/
		private var _currentLevel:String;
		/**当前属性经验值*/
		private var _currentRate:String;
		/**该属性共需要花费*/
		private var _need_total:String;
		/**当前兵种的类型*/
		private var unitType:String;
		/**当前兵种的等级*/
		private var unitLevel:String;
		
		/**甲种对应表*/
		private var jia_map:Object = {
			//1重甲，2中甲，3轻甲，4无甲
			"1": "95000",
			"2": "95001",
			"3": "95002",
			"4": "95003"
		}
		
		public function AdvanceView() 
		{
			super();
			createUI();
		}
		
		public function show(unitId, cb):void
		{
			setAutoPlay(false);
			view.addNumTF.alpha = 0;
			
			_sUnitID = unitId;
			_callback = cb;
			
			sendGetInfoHandler();
		}
		public override function destroy(destroyChild:Boolean=true):void{
			
			super.destroy(destroyChild);
			_view  = null;
			
			UIRegisteredMgr.DelUi("JinJieXiaoGuo");
			UIRegisteredMgr.DelUi("JinJieFangShi");
		}
		private function createUI():void
		{
			this._view = new AdvanceViewUI();
			this.pos(50, 20);
			this.addChild(_view);
			UIRegisteredMgr.AddUI(_view.fArea,"JinJieXiaoGuo");
			UIRegisteredMgr.AddUI(_view.lArea,"JinJieFangShi");

			if (BagManager.instance.getItemNumByID(13) == 0)
			{
				BagManager.instance.initBagData();
			}
			
			sy = view.addNumTF.y;
			
			_heroName = new TextArea();
			_heroName.font = "BigNoodleToo";
			_heroName.fontSize = 24;
			_heroName.color = "#ffffff";
			_heroName.height = 20;
			_heroName.x = 93;
			_heroName.y = 296;
			_heroName.width = 100;
			_heroName.height = 25;
			_heroName.align = "left";
			view.addChild(_heroName);
			
			_heroLv = new TextArea();
			_heroLv.font = "BigNoodleToo";
			_heroLv.fontSize = 20;
			_heroLv.color = "#b1f6ff";
			_heroLv.height = 20;
			_heroLv.x = 188;
			_heroLv.y = 300;
			_heroLv.width = 55;
			_heroLv.height = 25;
			_heroLv.align = "right";
			view.addChild(_heroLv);
			
			i1 = new Image();
			i1.skin = GameConfigManager.getItemImgPath(13);
			i1.x = 160;
			i1.y = 422;
			i1.width = i1.height = 50;
			i1.on(Event.CLICK, this, onClick);
			view.addChild(i1);
			
			view.itemNumTF.text = "0";
			
			_costIcon = new Image();
			_costIcon.skin = GameConfigManager.getItemImgPath(13);
			_costIcon.x = 5;
			_costIcon.y = 2;
			_costIcon.width = _costIcon.height = 50;
			view.oneUpBtn.addChild(_costIcon);
			
			_costTF = new Text();
			_costTF.font = "Futura";
			_costTF.fontSize = 14;
			_costTF.color = "#ffffff";
			_costTF.height = 20;
			_costTF.x = 20;
			_costTF.y = 30;
			_costTF.width = 30;
			_costTF.height = 25;
			_costTF.align = "right";
			_costTF.text = "";
			view.oneUpBtn.addChild(_costTF);
			
			view.mPro.visible = false;
			
			view.dom_list.itemRender = AdvanceItemNew;
			view.dom_list.array = [];
			
			degree_deblocking_data = ResourceManager.instance.getResByURL("config/degree/degree_deblocking.json");
			degree_config_data = ResourceManager.instance.getResByURL("config/degree/degree_config.json");
			
			sendGetInfoHandler = ToolFunc.throttle(function() {
				WebSocketNetService.instance.sendData(ServiceConst.ASCENDING_GET_INFO, [_sUnitID]);
			}, this);
			
			UIRegisteredMgr.AddUI(view.oneUpBtn, "AdvBtn");
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(...args):void
		{
			var max:int = 0;
			var _data = args[1];
			trace("【战况升阶】: ", args[0], _data);
			switch(args[0])
			{
				case ServiceConst.ASCENDING_ONE_UPGRADE:
					var infoArr = _data["unitDegreeInfo"][current_attribute];
					var isAddLevel:Boolean = infoArr[0] > _currentLevel;
					
					view.addNumTF.text = isAddLevel ? "+" + (_need_total - _currentRate) : "+" + (infoArr[1] - _currentRate);
					view.addNumTF.y = sy;
					view.addNumTF.alpha = 1;
					Tween.to(view.addNumTF, { y:sy - 10, alpha:0 }, 300);
					
					// 判断是否升级
					if (isAddLevel) {
						setAutoPlay(false);
						
						view.rateTF.text = _need_total + " / " + _need_total;
						
						// 升级后的动画
						view.mp_img.skin = "common/icons/" + current_attribute + ".png";
						view.mp_0.text = "+" + target_degree_config_data[infoArr[0]][current_attribute] + "%";
						view.mPro.visible = true;
						view.mPro.x = 48;
						view.mPro.y = 46 + iconList.indexOf(current_attribute) * 31 + 10;
						Tween.to(view.mPro,{x: 218}, 300, Ease.linearNone, Handler.create(this, function() {
							view.mPro.visible = false;
							// 强制更新
							_callback();
						}));
						
						Tween.to(view.rateBar, { value: 1}, 250, Ease.linearNone);
						
					} else {
						refreshAdvInfo(_data["defense_type"], _data.unitDegreeInfo[current_attribute]);
						if (_autoAdvance) {
							timerOnce(500, this, sendUpdate);
						}
					}
					
					break;
				
				case ServiceConst.ASCENDING_GET_INFO:
					view.oneUpBtn.disabled = view.autoUpBtn.disabled = _data.unitInfo.length == 0;
					// 未拥有该兵种
					if (_data.unitInfo.length == 0) {
						setCurrentUnitType(GameConfigManager.unit_dic[_sUnitID]["unit_type"]);
						// 添加数据
						_data["unitDegreeInfo"] = {};
						var _arr = [0, 0];
						iconList.forEach(function(item) {
							_data["unitDegreeInfo"][item] = _arr;
						});
						_data["unitInfo"] = {"unitType": unitType,"level": 1};
					}
						
					setCurrentUnitType(_data.unitInfo.unitType);
					unitLevel = _data.unitInfo.level;
					
					// 可强化的属性列表
					var _listData = updateListData(_data);
					// 可强化的属性列表
					var upAbleList:Array = _listData[0];
					view.dom_list.array = _listData[1];
					
					// 上次加强的属性
					var latest:String = _data.unitDegreeInfo["latest"] || iconList[iconList.length - 1];
					var _current_index = iconList.indexOf(latest) + 1;
					if (_current_index == iconList.length) _current_index = 0;
					// 本次要加强的属性
					current_attribute = iconList[_current_index];
					
					if (upAbleList.indexOf(current_attribute) == -1) {
						if (upAbleList.length == 0) {
							_current_index = 0;
							current_attribute = iconList[_current_index];
						} else {
							current_attribute = upAbleList[0];
							_current_index = iconList.indexOf(current_attribute);
						}
					}
					
					updateDomLightPos(_current_index);
					
					refreshAdvInfo(_data["defense_type"], _data.unitDegreeInfo[current_attribute]);
					
					break;
				
				default:
					break;
			}
		}
		
		/**发送升级*/
		private function sendUpdate():void {
			// 首先判断当次升阶的兵种等级是否够
			var unit_level_up = Number(target_degree_config_data[_currentLevel]["unit_level_up"]);
			if (unitLevel < unit_level_up) {
				setAutoPlay(false);
				return XTip.showTip(GameLanguage.getLangByKey("L_A_156").replace("{0}", unit_level_up));
			}
			WebSocketNetService.instance.sendData(ServiceConst.ASCENDING_ONE_UPGRADE,[_sUnitID, current_attribute]);
		}
		
		/**设置当前兵种*/
		private function setCurrentUnitType(type):void {
			unitType = type;
			// 筛选出英雄 or 普通兵种的数据
			target_degree_config_data = ToolFunc.objectValues(degree_config_data).filter(function(item) {
				return item["type"] == unitType;
			});
			target_degree_deblocking_data = ToolFunc.objectValues(degree_deblocking_data).filter(function(item) {
				return item["type"] == unitType;
			});
		}
		
		/**列表更新*/
		private function updateListData(_data):Array {
			// 可强化的属性
			var upAbleList = [];
			var result:Array = target_degree_deblocking_data.map(function(item) {
				var _attribute_type = item["attribute_type"];
				// 兵种等级是否达到
				var isLevelOk:Boolean = _data.unitInfo["level"] >= item.unit_level;
				// 解锁强化等级是否到达
				var isUpgradeLevelOk:Boolean;
				if (item["upgrade_level"]) {
					var _upgradeArr = item["upgrade_level"].split("=");
					var _targetType = ToolFunc.getTargetItemData(degree_deblocking_data, "ID", _upgradeArr[0])["attribute_type"];
					isUpgradeLevelOk = _data.unitDegreeInfo[_targetType][0] >= Number(_upgradeArr[1]);
					
				} else {
					isUpgradeLevelOk = true;
				}
				var _isLock =  !isLevelOk || !isUpgradeLevelOk
				// 当前属性等级
				var _level = Number(_data.unitDegreeInfo[_attribute_type][0]);
				// 对应属性等级的属性加成
				var _addTxt = target_degree_config_data[_level][_attribute_type];
				var _isMax = _level == item["level_max"];
				// 下一级加成的预览
				var _addTxtNext = _isMax ? "" : target_degree_config_data[_level + 1][_attribute_type];
				if (!_isLock && !_isMax) upAbleList.push(_attribute_type);
				
				return {
					isLock: _isLock, // 判断是否开锁
					icon: "common/icons/" + _attribute_type + ".png",
					level: _level,
					isMax: _isMax,
					addTxt: "+" + _addTxt + "%",
					addTxtNext: "+" + _addTxtNext + "%",
					msg: item["language"] // 解锁说明
				};
			});
			
			return [upAbleList, result];
		}
		
		/**高光的位置更新*/
		private function updateDomLightPos(index):void {
			view.dom_light.y = 46 + index * 31;
		}
		
		/**更新所需材料和目前拥有材料       defense_type：材料甲种, infoArr:当前属性的等级 & 经验值*/
		private function refreshAdvInfo(defense_type, infoArr):void {
			_curUnitDT = jia_map[defense_type];
			_currentLevel = infoArr[0];
			_currentRate = infoArr[1];
			// 当前材料我所有的总数
			view.itemNumTF.text = BagManager.instance.getItemNumByID(_curUnitDT);
			// 甲种材料的皮肤
			i1.skin = _costIcon.skin = GameConfigManager.getItemImgPath(_curUnitDT);
			
			var _config = ToolFunc.getTargetItemData(target_degree_config_data, "level", _currentLevel);		
			var _deblocking = ToolFunc.getTargetItemData(target_degree_deblocking_data, "attribute_type", current_attribute);
			
			// 首先判断是否达到最大等级
			var isMaxLevel = _currentLevel >= _deblocking["level_max"];
			// 经验比例
			var _barValue;
			if (!isMaxLevel) {
				// 所需要花费的
				var _cost:String = ToolFunc.find(_config.cost.split("|"), function(item:String) {
					return item.indexOf(_curUnitDT) > -1;
				});
				_costTF.text = _cost.split("=")[1] * _deblocking["cost"];
				
				// 该甲种材料    目前拥有的  / 一共需要
				_need_total = _config.rate.split("|")[3].split(":")[0].split("-")[1] * _deblocking["rate"];
				view.rateTF.text = _currentRate + " / " + _need_total;
				_barValue = _currentRate / _need_total;
				if (_barValue < 0.03) {
					_barValue = 0.03;
					view.rateBar.value = _barValue;
					
				} else {
					Tween.to(view.rateBar, { value: _barValue }, 250, Ease.linearNone);
				}
				
			} else {
				_costTF.text = "";
				view.rateTF.text = "MAX";
				_barValue = 1;
				view.rateBar.value = _barValue;
			}
			
			view.dom_tips.visible = !isMaxLevel;
			
			var valueType:Array = rateBarValueType(_barValue);
			view.rateFlagTF.text = GameLanguage.getLangByKey(valueType[0]);
			view.rateFlagTF.color = valueType[1];
		}
		
		/**风格样式*/
		private function rateBarValueType(value):Array {
			if (value < 0.33) return ["L_A_110", "#46ff72"]; // "low";
			if (value < 0.66) return ["L_A_111", "#46c0ff"]; //"medium";
			return ["L_A_112", "#cd46ff"]; //"high";
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case i1:
					ItemTips.showTip(_curUnitDT);
					break;
				case view.oneUpBtn:
					setAutoPlay(false);
					sendUpdate();
					break;
				
				case view.autoUpBtn:
					setAutoPlay(!_autoAdvance);
					
					if (_autoAdvance) {
						sendUpdate();
					}
					
					break;
				
				default:
					break;
			}
		}
		
		/**设置自动玩*/
		private function setAutoPlay(bool):void {
			_autoAdvance = bool;
			view.autoUpBtn.label = _autoAdvance ? "stop" : GameLanguage.getLangByKey("L_A_55006");
			if (!_autoAdvance) {
				clearTimer(this, sendUpdate);
			}
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			setAutoPlay(false);
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_GET_INFO),this,serviceResultHandler)
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_ONE_UPGRADE), this, serviceResultHandler)
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_GET_INFO), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ASCENDING_ONE_UPGRADE), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
			_callback = null;
			setAutoPlay(false);
			super.removeEvent();
		}
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			view.size(width, view.height);
			view.pos(width / 2, (Laya.stage.height - view.height) / 2);
		}
		
		private function get view():AdvanceViewUI{
			return _view;
		}
		
	}

}