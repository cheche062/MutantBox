package game.module.camp
{
	import MornUI.camp.NewUnitInfoOperViewUI;
	import MornUI.componets.SkillItemUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.UIHelp;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.starBar;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.data.DBSkill2;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.view.BaseChapetrView;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Animation;
	import laya.display.Node;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Image;
	import laya.utils.Handler;
	
	public class NewUnitInfoOperView extends BaseChapetrView
	{
		public var muUi:NewUnitInfoOperViewUI;
		/**当前技能列表*/
		private var _currentSkillList:Array;
		/**技能上限列表*/
		private var _limitSkillList:Array;
		private var _starVo:Object;
		private var _starLv:starBar;
		private var _selectAmData:ArmyData;
		public var isUpdateAble:Boolean; // 是否可升星
		
		public function NewUnitInfoOperView()
		{
			super();
			
			muUi = new NewUnitInfoOperViewUI();
			addChild(muUi);
			
			this.mouseThrough = muUi.mouseThrough = true;
			
			for(var i:String in muUi.dataInfo){
				if(muUi.dataInfo[i] is HTMLDivElement){
					muUi.dataInfo[i].style.fontFamily = XFacade.FT_Futura;
					muUi.dataInfo[i].style.fontSize = 16;
					muUi.dataInfo[i].style.color = "#ffffff";
					muUi.dataInfo[i].style.align = "right";
				}
			}
			
			this._starLv = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10, 5);
			_starLv.scaleX = _starLv.scaleY = 0.8;
			muUi.needBox.addChildAt(this._starLv , 0);
			
			
			UIRegisteredMgr.AddUI(this.muUi.upgradeBtn,"ComposeBtn");
			muUi.upgradeBtn['clickSound'] = ResourceManager.getSoundUrl("ui_unit_upgrade",'uiSound')
		}
		
	
		public function set selectAmData(v:ArmyData):void
		{
			if(_selectAmData != v)
			{
				_selectAmData = v;
				bindAmData();
			}
		} 
		
		public function get selectAmData():ArmyData
		{
			return _selectAmData;
		}
		
		
		private function bindAmData():void
		{
			//绑定数据显示
			this.muUi.upgradeBtn.disabled = true;
			this.muUi.addBtn.visible = false;
			this.muUi.numTF.text = "";
			this._starLv.visible = false;
			if(!selectAmData)
			{
				this.muUi.upgradeBtn.label = GameLanguage.getLangByKey("L_A_701");
				for each(var _node:* in muUi.dataInfo){
					if(_node is HTMLDivElement){
						(_node as HTMLDivElement).innerHTML = "";
					}else if(_node is Image)
					{
						XTipManager.removeTip(_node);
					}
				}
				return;
			}
			this.muUi.upgradeBtn.label = selectAmData.serverData ? "L_A_702":"L_A_701";
			this._starLv.visible = true;
			_starLv.maxStar = selectAmData.unitVo.star;

			this._starLv.y =  (muUi.needBox.height - this._starLv.height + 5) >> 1;
			
			var _info = selectAmData.getInfoObj();
			_starVo = _info["vo"];
			
			// 进度条
			_starLv.barValue = selectAmData.serverData && selectAmData.serverData.hasOwnProperty("starId")
				? Number(_starVo.star_level) : selectAmData.unitVo.initial_star;
			
			muUi.dataInfo.attackTF.innerHTML = _info["attack"];
			muUi.dataInfo.critTF.innerHTML = _info["crit"];
			muUi.dataInfo.critDamageTF.innerHTML = _info["critDamage"];
			muUi.dataInfo.critDamReductTF.innerHTML = _info["critDamReduct"];
			muUi.dataInfo.defenseTF.innerHTML = _info["defense"];
			muUi.dataInfo.dodgeTF.innerHTML = _info["dodge"];
			muUi.dataInfo.hitTF.innerHTML = _info["hit"];
			muUi.dataInfo.hpTF.innerHTML = _info["hp"];
			muUi.dataInfo.resilienceTF.innerHTML = _info["resilience"];
			muUi.dataInfo.speedTF.innerHTML = _info["speed"];
			muUi.lvTF.text = _info["level"];
			
			muUi.popTF.text = selectAmData.unitVo.population
				
			if(selectAmData.unitVo.population > 0){
				muUi.popTF.text = selectAmData.unitVo.population+""
				muUi.poIcon.visible = true;
				muUi.maxTF.text = selectAmData.unitVo.num_limit+""
				muUi.maxIcon.visible = true;
			}else{
				muUi.popTF.text = "";
				muUi.poIcon.visible = false;
				muUi.maxTF.text = ""
				muUi.maxIcon.visible = false;
			}
			muUi.nameTF.text = selectAmData.unitVo.name;
			ProTipUtil.addTip(muUi.dataInfo, selectAmData.serverData ? selectAmData.serverData : selectAmData.unitVo);
			UIHelp.crossLayout(muUi.pListBox,true,0,50,20,-3);
			
			_limitSkillList = getLimitSkills(_starVo);
			_currentSkillList = getCurrentSkills(selectAmData.serverData);
			
//			trace('当前：', _currentSkillList)
//			trace('上限：', _limitSkillList)
			
			renderSkillsBox();
			
			onBagInit(null);
		}
		
		/**获取当前 [技能id, 技能类型, 是否含有该技能] = [[1000, 1, true], ...,[50180, 2, false]]*/
		private function getCurrentSkills(data):Array {
			if (!data) {
				var skills:Array = selectAmData.unitVo.skill_id.split("|").map(function(item) {
					return [item, 1, false];
				});
				var skill2Id = selectAmData.unitVo.skill2_id.split("|");
				skills.push([skill2Id[0], 2, false]);
				return skills;
			}
			var skills:Array = data["skillId"].split("|").map(function(item) {
				return [item, 1, true];
			});
			// 截掉可能存在的皮肤技能
			skills = skills.slice(0, 2);
			if (data["skillId2"]) {
				skills.push([data["skillId2"], 2, true]);
			} else {
				var skill2Id = selectAmData.unitVo.skill2_id.split("|");
				skills.push([skill2Id[0], 2, false]);
			}
			
			return skills;
		}
		
		/**获取技能上限 [技能id，技能类型，是否显示（不灰阶）] = [[1000, 1, true], ...]*/
		private function getLimitSkills(vo):Array {
			var hasUnit:Boolean = !!CampData.hasUnit(selectAmData.unitId);
			var result:Array = vo.skill_id.split("|").map(function(item) {
				return [item, 1, hasUnit];
			});
			var hasSkill2:Boolean = vo.skill2_id != "0";
			var skill2 = hasSkill2 ? vo.skill2_id : selectAmData.unitVo.skill2_id;
			
			var tmp = hasSkill2 ? [skill2, 0] : skill2.split("|");
			var isShow = (hasUnit && vo.star_level >= tmp[1]);
			result.push([tmp[0], 2, isShow]);
			
			return result;
		}
		
		/**渲染技能总和*/
		private function renderSkillsBox():void {
			muUi.dom_skill_box.destroyChildren();
			var data = _currentSkillList.map(function(item, index, thisArray) {
				// 没有相同的则可以升级
				var isUpable:Boolean = _limitSkillList.every(function(itemIner) {
					return itemIner[0] != item[0];
				});
				if (_limitSkillList[index]&&!_limitSkillList[index][2]) isUpable = false;
				if (!isUniteLevelEnough(item[0])[0]) isUpable = false;
				
				return [].concat(item, isUpable);
			});
			var unit_parameter_json:Object=ResourceManager.instance.getResByURL("config/unit_parameter.json");
		
//			trace("unit_parameter_json:"+JSON.stringify(unit_parameter_json));
			var value:String = unit_parameter_json["skillup_open"]["value"];
            trace("value:"+value);
	        var aid:String = value.split("=")[0];
			var anum:Number = Number(value.split("=")[1]);
			var info:Object = DBBuilding.getBuildingById(aid);
			var aName:String = info.name;
			data.forEach(function(item:Array, index, thisArray) {
				var _child:SkillItemUI = new SkillItemUI();
				var _source = getSkillData(item[0], item[1], item[2]);
				var ifLvUp:Boolean = false;
				
				//开启条件
				if(User.getInstance().sceneInfo.getBuildingLv(aid)>anum)
				{
					ifLvUp = true;
				}else if(User.getInstance().sceneInfo.getBuildingLv(aid)==anum)
				{
					if(User.getInstance().sceneInfo.hasBuildingInQueue(Number(aid)))
					{
						ifLvUp = false;
					}else
					{
						ifLvUp = true;
					}
				}
				
				// 可升星 && 材料够 && 已经解锁
				if (item[3] && cailiaoEnough(item[0]) && !_source.gray && ifLvUp) {
					addAnimation(_child);
				}
				_child.on(Event.CLICK, this, function(i, skillId) {
					aName = GameLanguage.getLangByKey(aName);
					var str:String = GameLanguage.getLangByKey("L_A_156").replace('{0}', aName);
					str = str.replace("{1}",anum);
					
					if (!ifLvUp) return XTip.showTip(str);
					XFacade.instance.openModule(ModuleName.SkillInfoView, [ToolFunc.extendDeep(data), i, selectAmData.unitId, false]);
					trace(i, skillId);
				}, [index, item[0]]);
				
				_child.dataSource = _source;
				if(index==0)
				{
					trace("添加技能UI");
					UIRegisteredMgr.AddUI(_child,"Skill1Btn");
				}
			
				muUi.dom_skill_box.addChild(_child);
			});
			
			muUi.dom_skill_box.space = muUi.dom_skill_box.numChildren == 3 ? 0 : 50;
			
			// 主动让它更新
			var skillInfoViewInstance:SkillInfoView = XFacade.instance.getView(SkillInfoView);
			if (skillInfoViewInstance && skillInfoViewInstance.displayedInStage) {
				skillInfoViewInstance.updateView([ToolFunc.extendDeep(data), 0, selectAmData.unitId, true]);
			}
		}
		
		/**技能升级对应的兵等级限制   [是否足够， 需要的兵等级]*/
		private function isUniteLevelEnough(skillId):Array {
			trace("skillId:"+skillId);
			var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId] || DBSkill2.getSkillInfo(skillId);
			trace("vo:"+JSON.stringify(vo));
			var _level:int = Number(vo.skill_restrict);
			if (selectAmData.serverData && selectAmData.serverData.level >= _level) {
				return [true, _level];
			}
			return [false, _level];
		}
		
		/**材料道具是否够用*/
		private function cailiaoEnough(skillId):Boolean {
			var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId] || DBSkill2.getSkillInfo(skillId);
			var _conArr:Array = vo.skill_consume.split(";");
			// 可能需要多个材料
			return _conArr.every(function(item) {
				var _id_num = item.split("=");
				var _userNum = User.getInstance().getResNumByItem(_id_num[0]);
				var _needNum = Number(_id_num[1]);
				return _userNum >= _needNum;
			});
		}
		
		/**添加箭头动画*/
		private function addAnimation(node:Node):void {
			var _ani:Animation = new Animation();
			_ani.loadAtlas("appRes/atlas/camp/effect.json", Handler.create(this, function() {
				_ani.play();
			}));
			_ani.pos(-24, -24);
			node.addChild(_ani);
		}
		
		/**计算技能渲染数据*/
		private function getSkillData(skillId, skillType, isGray):void{
			var vo:SkillVo = skillType == 1 ? GameConfigManager.unit_skill_dic[skillId] : DBSkill2.getSkillInfo(skillId);
			return {
				"dom_skillBg": skillType == 2 ? "common/skill_bg1.png": "common/skill_bg.png",
				"dom_icon": "appRes/icon/skillIcon/" + vo.skill_icon + ".png",
				"dom_nameTF": vo.skill_name,
				"dom_lvBG": skillType == 2 ? "common/skill_bg1_1.png" : "common/skill_bg_1.png",
				"dom_lvTF": vo.skill_level,
				"gray": !isGray
			}
		}
		
		private function onBagInit(e:Event):void{
			if(!_starVo)return;
			var	arr:Array = BagManager.instance.getItemListByIid((_starVo.star_cost+"").split("=")[0]);
			if(!arr) return ;
			var num:Number = 0;
			for(var i:int=0; i<arr.length; i++){
				num += parseInt(ItemData(arr[i]).inum+"")
			}
			
			var actNum:Number = (_starVo.star_cost+"").split("=")[1];
			//是需要激活
			if(!selectAmData.serverData){
				actNum = selectAmData.getActNum();
			}
			actNum = Number(actNum);
			
			if(actNum){
				if(num < actNum){
					muUi.upgradeBtn.disabled = true;
				}else{
					muUi.upgradeBtn.disabled = false;
				}
				this.muUi.numTF.text = num+"/"+actNum;
				muUi.addBtn.visible = true;
				
			}else{
				this.muUi.numTF.text = "MAX";
				muUi.upgradeBtn.disabled = true;
				muUi.addBtn.visible = false;
			}
			
			// 最大值
			if (_starLv.barValue == _starLv.maxStar) {
				this.muUi.numTF.text = "MAX";
				muUi.upgradeBtn.disabled = true;
				muUi.addBtn.visible = false;
			}
			
			
			UIHelp.crossLayout(muUi.needBox,true,0,5,5);
			muUi.needBox.x = muUi.upgradeBtn.x - muUi.needBox.width - 15;
			
			// 是否可升星
			isUpdateAble = !muUi.upgradeBtn.disabled;
		}
		
		public override function addEvent():void
		{
			super.addEvent();
			Signal.intance.on(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, onBagInit);
			
			muUi.addBtn.on(Event.CLICK,this,addBtnClick);
			muUi.upgradeBtn.on(Event.CLICK,this,upgradeBtnClick);
			muUi.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.BINGZHONG_UPDATE_SKILL), this, onResult);
			
			bindAmData();
		}
		public override function removeEvent():void
		{
			super.removeEvent();
			Signal.intance.off(BagEvent.BAG_EVENT_INIT, this, onBagInit);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, onBagInit);
			
			muUi.addBtn.off(Event.CLICK,this,addBtnClick);
			muUi.upgradeBtn.off(Event.CLICK,this,upgradeBtnClick);
			muUi.off(Event.CLICK, this, this.onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.BINGZHONG_UPDATE_SKILL), this, onResult);
			
		}
		
		
		private function onResult():void{
			bindAmData();
		}
		
		
		private function addBtnClick(e:Event):void
		{
			if(!selectAmData)return ;
			XFacade.instance.showModule(UnitSrcView, [selectAmData.unitId, function() {
				XFacade.instance.closeModule(CampView);
				XFacade.instance.closeModule(UnitInfoView);
				XFacade.instance.closeModule(NewUnitInfoView);
			}]);
		}
		
		private function upgradeBtnClick(e:Event):void
		{
			if(!selectAmData)return ;
			if(selectAmData.serverData){
				WebSocketNetService.instance.sendData(ServiceConst.C_Star,[selectAmData.unitId]);
			}else {
				
				WebSocketNetService.instance.sendData(ServiceConst.C_COMPOSE, [selectAmData.unitId]);
				
			}
		}
		
		//显示TIP
		private function onClick():void{
			if(XUtils.checkHit(muUi.poIcon)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_909"));
			}else if(XUtils.checkHit(muUi.maxIcon)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_919"));
			}
		}
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			muUi.size(width,height);
			muUi.showBox.pos(width >> 1 , height - muUi.showBox.height >> 1);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("ComposeBtn");
			UIRegisteredMgr.DelUi("Skill1Btn");
			for each(var _node:* in muUi.dataInfo){
				if(_node is Image)
				{
					XTipManager.removeTip(_node);
				}	
			}
			
			super.destroy(destroyChild);
			muUi = null;
			_currentSkillList = null;
			_starVo = null;
			_starLv = null;
			_selectAmData = null;
		}
	}
}