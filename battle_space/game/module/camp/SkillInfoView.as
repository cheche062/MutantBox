package game.module.camp
{
	import MornUI.camp.SkillIconUI;
	import MornUI.camp.SkillInfoViewUI;
	
	import game.common.AnimationUtil;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBSkill2;
	import game.global.data.DBUnitStar;
	import game.global.event.Signal;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	
	import laya.events.Event;
	import laya.net.URL;
	import laya.ui.Button;
	import laya.ui.Tab;
	import laya.utils.Handler;
	
	/**
	 * 技能升级弹出层
	 * @author hejianbo
	 * 
	 */
	public class SkillInfoView extends BaseDialog
	{
		//[技能id, 技能类型, 是否含有该技能, 能否升级] = [["10401", 1, true, false], ...["10401", 2, true, true]]; 
		/**当前含有的技能*/ 
		private var tabSkillList:Array = [];
		private var _unit_id:String;
		private var _currentSelectedIndex:int = -1;
		/**是否是手动更新*/
		private var _isHandUpdate:int = false;
		/**手动升级的索引列表*/
		private var _updateIndexList:Array = [];
		
		public function SkillInfoView() {
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void {
			this.addChild(view);
			view.dom_skill_title.style.fontFamily = XFacade.FT_BigNoodleToo;
			view.dom_skill_title.style.fontSize = 30;
			view.dom_skill_title.style.color = "#ffffff";
			
			view.dom_content.style.fontFamily = XFacade.FT_Futura;
			view.dom_content.style.fontSize = 18;
			view.dom_content.style.color = "#ffffff";
			
			view.dom_cl.skin = "";
		}
		
		override public function show(... args):void {
			super.show();
			AnimationUtil.flowIn(this);
			
			var data = args[0];
			updateView(data);
			trace("data:::::"+JSON.stringify(data));
			UIRegisteredMgr.AddUI(view.fArea,"SkillLvUp");
		}
		
		public function updateView(data):void {
			tabSkillList = data[0];
			_unit_id = data[2];
			_isHandUpdate = data[3];
				
			if (_currentSelectedIndex == -1) {
				_currentSelectedIndex = data[1];
			}
			 
//			trace(tabSkillList, _currentSelectedIndex);
			createTabChildren();
			view.tab_btn.selectedIndex = _currentSelectedIndex;
		}
		
		/**tab选择*/
		private function tabSelectHandler(index):void {
			_currentSelectedIndex = index;
			if (index == -1) return;
			renderCurrentSkill(tabSkillList[index]);
			renderUpdateBtnResource(tabSkillList[index]);
		}
		
		private function createTabChildren():void {
			// 不知tab如何清空子项   故重新创建一个tab
			var newTab:Tab = new Tab();
			newTab.pos(view.tab_btn.x, view.tab_btn.y);
			newTab.direction = view.tab_btn.direction;
			view.tab_btn.destroy();
			view.tab_btn = newTab;
			newTab.initItems();
			newTab.selectHandler = new Handler(this, tabSelectHandler);
			view.addChild(newTab);
			
			tabSkillList.forEach(function(item) {
				var _child:Button = new Button("newUnitInfo/btn_222.png");
				var _dom_skill:SkillIconUI = new SkillIconUI();
				_dom_skill.dataSource = getSkillDataSource(item);
				_dom_skill.pos(60, 52);
				_dom_skill.scale(0.8, 0.8);
				_child.addChild(_dom_skill);
				
				view.tab_btn.addItem(_child);
			});
		}
		
		/**获取技能皮肤*/
		private function getSkillDataSource(args):Object {
			return {
				"dom_bg": args[1] == 2 ? "common/skill_bg1.png" : "common/skill_bg.png",
				"dom_skill": URL.formatURL("appRes/icon/skillIcon/" + getVoData(args[0]).skill_icon + ".png")
			};
		}
		
		private function getVoData(id):SkillVo{
			//兼容被动技能  or 主动技能
			return DBSkill2.getSkillInfo(id) || GameConfigManager.unit_skill_dic[id];
		}
		
		private function changeFontColor(str, bool):void {
			return bool ? "<font color='#0f0'>" + str + "%</font>" : str;
		}
		
		/**渲染当前技能主题*/
		private function renderCurrentSkill(args):void {
			var id:* = args[0];
			var passive:Boolean = args[1] == 2;
			var vo:SkillVo = getVoData(args[0]);
			
			view.dom_skill_icon.dataSource = getSkillDataSource(args);
			view.dom_skill_title.innerHTML = GameLanguage.getLangByKey(vo.skill_name) + " Lv." + vo.skill_level;
			view.dom_skill_icon.gray = !CampData.hasUnit(_unit_id);
			
			var arr:Array = String(vo.skill_value).split("|");
			var str:String = GameLanguage.getLangByKey(vo.skill_describe);
			arr.forEach(function(item) {
				var changeColor:Boolean = _isHandUpdate && _updateIndexList.indexOf(_currentSelectedIndex) != -1;
				var _num:String = String(XUtils.toFixed(item));
				str = str.replace(/{(\d+)}/, changeFontColor(_num,  changeColor));
				if (changeColor) {
					str = str.replace("%</font>%", "%</font>");
				}
			});
			
			view.dom_content.innerHTML = str;
			view.dom_attack_damage.visible = !passive;
			
			if(passive) {
				var acted:Boolean = false;
				var unitId:* = _unit_id;
				var str:String = "";
				if(unitId){
					var db:Object  = GameConfigManager.unit_json[unitId];
					var info:Object = (CampData.getUintById(unitId) || {});
					var starInfo:Object = DBUnitStar.getStarData(info.starId || db.star_id);
					var starLv:int = starInfo ? starInfo.star_level : 1;
					
					var tmp:Array = ((db.skillId2 || db.skill2_id) +"").split(";");
					tmp = (tmp[0]+"").split("|");
					if(starLv >= tmp[1]){
						acted = true;
					}else{
						str = GameLanguage.getLangByKey("L_A_745").replace(/{(\d+)}/,tmp[1]);
					}
				}
				
				if(!acted){
					view.dom_skill_icon.gray = true;
					view.dom_skill_title.innerHTML = GameLanguage.getLangByKey(vo.skill_name)+"<font color='#ff0000'>"+str+"</font>";
				}
			} else {
				view.dom_attack.skin = URL.formatURL("appRes/icon/skillRange/"+vo.skill_node+"_1.png");
				view.dom_damage.skin = URL.formatURL("appRes/icon/skillRange/"+vo.skill_node+"_2.png");
			}
		}
		
		/**渲染升级的按钮和所需资源消耗*/
		private function renderUpdateBtnResource(args):void {
			var _conArr:Array = getConsumeInfo(args[0]);
			// 已解锁
			var isNotGray:Boolean = args[2];
			trace("_conArr:"+_conArr);
			var costid:Number = (_conArr[0].split("="))[0]; 
			var costNum:Number = (_conArr[0].split("="))[1];
			if(_conArr.length==1)
			{
				view.double.visible = false;
				view.single.visible = true;
				view.dom_cl.skin = GameConfigManager.getItemImgPath(costid);
				var _userNum = User.getInstance().getResNumByItem(costid);
				var _needNum = costNum;
				view.dom_num.text =  XUtils.formatResWith(_userNum)+"/"+_needNum;
				
				// 没找到即可以升级  && 材料够用 && 已解锁
				if (args[3] && _userNum >= _needNum && isNotGray) {
					view.btn_up.disabled = false;
				} else {
					view.btn_up.disabled = true;
				}
			}
			if(_conArr.length == 2)
			{
				view.double.visible = true;
				view.single.visible = false;
				view.r1.skin = GameConfigManager.getItemImgPath(_conArr[0].split("=")[0]);
				var _userNum = User.getInstance().getResNumByItem(_conArr[0].split("=")[0]);
				var _needNum = _conArr[0].split("=")[1];
				view.num1.text = XUtils.formatResWith(_userNum)+"/"+_needNum;
				
				view.r2.skin = GameConfigManager.getItemImgPath(_conArr[1].split("=")[0]);
				var _userNum1 = User.getInstance().getResNumByItem(_conArr[1].split("=")[0]);
				var _needNum1 = _conArr[1].split("=")[1];
				view.num2.text =  XUtils.formatResWith(_userNum1)+"/"+_needNum1;
				// 没找到即可以升级  && 材料够用  && 已解锁
				if (args[3] && _userNum >= _needNum && _userNum1>=_needNum1 && isNotGray) {
					view.btn_up.disabled = false;
				} else {
					view.btn_up.disabled = true;
				}
			}
		}
		
		/**获得材料耗费[材料id， 材料所需数量]*/
		private function getConsumeInfo(skillId):Array {
			var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId] || DBSkill2.getSkillInfo(skillId);
			return vo.skill_consume.split(";");
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				case view.btn_close:
					close();
					break;
				
				case view.btn_add:
					var consumeArr:Array = getConsumeInfo(tabSkillList[_currentSelectedIndex][0]);
					var id = consumeArr[0].split("=")[0];
					
					XFacade.instance.openModule(ModuleName.SkillSourceView, [id]);
					
					break;
				case view.btn1:
					var consumeArr:Array = getConsumeInfo(tabSkillList[_currentSelectedIndex][0]);
					var id = consumeArr[0].split("=")[0];
					
					XFacade.instance.openModule(ModuleName.SkillSourceView, [id]);
					
					break;
				case view.btn2:
					var consumeArr:Array = getConsumeInfo(tabSkillList[_currentSelectedIndex][0]);
					var id = consumeArr[1].split("=")[0];
					
					XFacade.instance.openModule(ModuleName.SkillSourceView, [id]);
					break;
				case view.btn_up:
					var _skill_id = tabSkillList[view.tab_btn.selectedIndex][0];
					var _skill_type = tabSkillList[view.tab_btn.selectedIndex][1];
					
					_updateIndexList.push(_currentSelectedIndex);
					sendData(ServiceConst.BINGZHONG_UPDATE_SKILL, [_unit_id, _skill_id, _skill_type]);
					
					break;
			}
		}
		
		private function onServerResult(...args):void {
			var cmd = args[0];
			var result = args[1];
			switch (cmd) {
				case ServiceConst.BINGZHONG_UPDATE_SKILL:
					
					
					break;
				
			}
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BINGZHONG_UPDATE_SKILL), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
			super.addEvent();
		}
		
		
		override public function removeEvent():void {
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BINGZHONG_UPDATE_SKILL), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			view.tab_btn.selectHandler && view.tab_btn.selectHandler.clear();
				
			super.removeEvent();
		}
		
		/**服务器报错*/
		private function onError(... args):void
		{
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void {
			AnimationUtil.flowOut(this, onClose);
			tabSkillList.length = 0;
			_updateIndexList.length = 0;
			_currentSelectedIndex = -1;
		}
		
		private function onClose():void {
			super.close();
		}
		
		private function get view():SkillInfoViewUI {
			_view = _view || new SkillInfoViewUI();
			return _view;
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
			UIRegisteredMgr.DelUi("SkillLvUp");
		}
		
	}
}