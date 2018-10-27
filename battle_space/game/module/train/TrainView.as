package game.module.train
{
	import MornUI.componets.SkillItemUI;
	import MornUI.train.TrainViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XGroup;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.data.DBSkill2;
	import game.global.data.DBUnitStar;
	import game.global.data.bag.ItemData;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.util.PreloadUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.FightUnitVo;
	import game.global.vo.SkillVo;
	import game.global.vo.User;
	import game.global.vo.VIPVo;
	import game.module.alert.XAlert;
	import game.module.camp.CampData;
	import game.module.camp.ProTipUtil;
	import game.module.camp.UnitItem;
	import game.module.camp.UnitItemVo;
	import game.module.mainScene.TrainInfoCom;
	import game.module.tips.SkillTip;
	import game.net.socket.WebSocketNetService;
	
	import laya.ani.bone.Templet;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.net.URL;
	import laya.ui.Box;
	import laya.ui.Clip;
	import laya.utils.Handler;
	
	/**
	 * TrainView
	 * author:huhaiming
	 * TrainView.as 2017-3-16 下午1:55:00
	 * version 1.0
	 *
	 */
	public class TrainView extends BaseDialog
	{
		private var _data:Object
		private var _ids:Array
		private var _skills:Array;
		private var _selectedItem:UnitItem;
		//刷新时间
		private var _giveTime:Number;
		private var _group:XGroup;
		//
		private var _currentVo:FightUnitVo;
		private var _firstItem:TrainingItem;
		private var _skillVo:SkillVo;
		/**训练列表*/
		private var _trainList:Array;
		public function TrainView()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.trainBtn:
					this.view.editBtn.visible = true;
					this.view.confirmBtn.visible = false;
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.CLICK_TRAIN_BTN);
						WebSocketNetService.instance.sendData(ServiceConst.T_TRAIN, [_selectedItem.data.id]);
					}else{
						var item:ItemData = new ItemData;
						item.iid = DBItem.GOLD;
						item.inum = view.costTF.text;
						var h:Handler = Handler.create(WebSocketNetService.instance,WebSocketNetService.instance.sendData,
							[ServiceConst.T_TRAIN, [_selectedItem.data.id]]);
						ConsumeHelp.Consume([item],h)
					}
					break;
				case view.closeBtn:
					this.close();
					break;
				case view.editBtn:
					this.view.editBtn.visible = false;
					this.view.confirmBtn.visible = true;
					for(var i:int=0; i<this._ids.length; i++){
						_ids[i].se = true;
					}
					this.view.list.refresh();
					break;
				case view.confirmBtn:
					this.view.editBtn.visible = true;
					this.view.confirmBtn.visible = false;
					for(var i:int=0; i<this._ids.length; i++){
						_ids[i].se = false;
					}
					this.view.list.refresh();
					break;
				case view.speedBtn:
					if (!User.getInstance().hasFinishGuide) {
						WebSocketNetService.instance.sendData(ServiceConst.T_SPEED, null);
						Signal.intance.event(NewerGuildeEvent.CLICK_SPEED_UP);
						return;
					}
					//计算费用
					var cost:Number = caculate();
					var str:String = GameLanguage.getLangByKey("L_A_913");
					item = new ItemData;
					item.iid = DBItem.GOLD;
					item.inum = cost;
					ConsumeHelp.Consume([item],
						Handler.create(WebSocketNetService.instance,WebSocketNetService.instance.sendData,[ServiceConst.T_SPEED]),str, true)
					break;
				default:
					if(e.target.name == "delBtn"){
						var data:Object
						if(e.target.parent.name == "exItem"){//样例，特殊处理
							data = _firstItem.data;
						}else{
							data = Object(e.target.parent.parent).data;
						}
						WebSocketNetService.instance.sendData(ServiceConst.T_CANCEL, [data.unitId]);
					}else{
						if(XUtils.checkHit(view.skillCom.item_0)){
							_skills[0] && XTipManager.showTip([_skills[0]],SkillTip, false);
						}else if(XUtils.checkHit(view.skillCom.item_1)){
							_skills[1] && XTipManager.showTip([_skills[1]],SkillTip, false);
						}else if(XUtils.checkHit(view.skillCom.item_2)){
							_skills[2] && XTipManager.showTip([_skills[2],true, _selectedItem.data.id],SkillTip, false);
						}else if(XUtils.checkHit(view.puIcon)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_735"));
						}else if(XUtils.checkHit(view.goldIcon)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_736"));
						}else if(XUtils.checkHit(view.kpiIcon)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_737"));
						}else if(XUtils.checkHit(view.timeIcon)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_738"));
						}else if(XUtils.checkHit(view.goldIcon2)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_739"));
						}else if(XUtils.checkHit(view.puIcon2)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_740"));
						}else if(XUtils.checkHit(view.maxIcon)){
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_919"));
						}
					}
					break;
			}
		}
		
		private function onRender(cell:Box,index:int):void{
			if(index == view.list.selectedIndex){
				cell.selected = true;
			}else{
				cell.selected = false;
			}
		}
		
		private function onChange(reset:Boolean = true):void{
			var index:int = _group.selectedIndex;
			if(index == 0){
				this.view.list.array  = _ids;
			}else if(index == 1){
				this.view.list.array = getList(1);
			}else if(index == 2){
				this.view.list.array = getList(2);
			}else if(index == 3){
				this.view.list.array = getList(3);
			}else if(index == 4){
				this.view.list.array = getList(4);
			}
			this.view.list.refresh();
			
			if(reset || !_selectedItem){
				this.view.list.selectedIndex = 0;
				this.view.trainBtn.disabled = (this.view.list.array.length < 1);
				this.selectedItem = this.view.list.getCell(0) as UnitItem;
			}
			Laya.timer.once(120,this,formatData);
			//formatData();
		}
		
		private function updateGold():void{
			this.view.totalGoldTF.text = User.getInstance().gold+"";
		}
		
		private function getList(armType:int, unitType:int = 2):Array{
			var arr:Array = [];
			var vo:Object;
			for(var i:int=0; i<_ids.length; i++){
				vo = GameConfigManager.unit_json[_ids[i].id];
				if(vo.defense_type == armType){
					arr.push(_ids[i]);
				}
			}
			return arr;
		}
		
		private function caculate():Number{
			var time:Number = 0;
			var delTime:Number = 0;
			if(_currentVo){
				var totalTime:Number = parseFloat(_currentVo.unit_training_time)*1000;
				delTime = TimeUtil.now - _giveTime*1000;
			}else{
				return time;
			}
			time += (totalTime - delTime)/1000;
			
			var vo:Object;
			var data:Object = _firstItem.data;
			vo = GameConfigManager.unit_json[data.unitId];
			time += vo.unit_training_time * Math.round(data.make_number-1);
			
			for(var i:int=0; i<_trainList.length; i++){
				vo = GameConfigManager.unit_json[_trainList[i].unitId];
				time += vo.unit_training_time * _trainList[i].make_number;
			}
			//trace("time-----------------------------------------",time);
			view.totalTimeTF.text = TimeUtil.getShortTimeStr(time * 1000);
			
			//VIP特权
			var vipInfo:VIPVo = VIPVo.getVipInfo();
			time = Math.max(0,time - vipInfo.train_speed_up);
			
			var data = ResourceManager.instance.getResByURL("config/unit_parameter.json");
			
			return Math.ceil(time/60) * Number(data["train_CD_cost"]["value"]);
		}
		
		private function showTip():void{
			var str:String = GameLanguage.getLangByKey(_skillVo.skill_name)+"\n";
			str+=GameLanguage.getLangByKey(_skillVo.skill_describe);
			
			var tmp:Array = _skillVo.skill_value.split("|");
			for(var i:int=0; i<tmp.length; i++){
				str = str.replace(/{(\d+)}/,tmp[i]);
			}
			XTipManager.showTip(str);
		}
		
		private function onSelect(e:Event,index:int):void
		{
			if(e.type != Event.CLICK){
				return;
			}
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.SELECT_SOILDER);
			}
			selectedItem = view.list.getCell(index) as UnitItem;
			var data:UnitItemVo = _selectedItem.data;
			if(data){
				formatData();
				if(XUtils.checkHit(_selectedItem.attackIcon)){
					ProTipUtil.showAttTip(_selectedItem.data.id);
				}else if(XUtils.checkHit(_selectedItem.defendIcon)){
					ProTipUtil.showDenTip(_selectedItem.data.id);
				}else{
					/**如果是解散*/
					if(!_selectedItem.minusBtn.disabled && _selectedItem.minusBtn.visible && _selectedItem.minusBtn.mouseX > 0 && _selectedItem.minusBtn.mouseY > 0){
						WebSocketNetService.instance.sendData(ServiceConst.C_DISMISS,[data.id]);
					}
				}		
			}
		}
		
		private function formatData():void{
			var data:Object = (_selectedItem && _selectedItem.data);
			if(data){
				//关联数据
				data = _data.solier_list[data.id]
				
				var starId:String = (data.starId || data.star_id);
				var vo:Object = (DBUnitStar.getStarData(starId) || {});
				
				view.powerTF.text = data.power+"";
				//兼容原始数据
				view.dataInfo.attackTF.innerHTML = (data.attack || vo.ATK)+"";
				view.dataInfo.critTF.innerHTML = (data.crit || vo.crit) +"";
				view.dataInfo.critDamageTF.innerHTML = (data.critDamage || vo.CDMG)+"";
				view.dataInfo.critDamReductTF.innerHTML = (data.critDamReduct|| vo.CDMGR)+"";
				view.dataInfo.defenseTF.innerHTML = (data.defense || vo.DEF)+"";
				view.dataInfo.dodgeTF.innerHTML = (data.dodge || vo.dodge)+"";
				view.dataInfo.hitTF.innerHTML = (data.hit || vo.hit)+"";
				view.dataInfo.hpTF.innerHTML = (data.hp || vo.HP)+"";
				view.dataInfo.resilienceTF.innerHTML = (data.resilience || vo.RES)+"";
				view.dataInfo.speedTF.innerHTML = (data.speed || vo.SPEED)+"";
				
				var vo2:Object = GameConfigManager.unit_json[data.unitId || data.unit_id];
				if(data){
					view.costTF.text = Math.ceil(Math.pow((data.power/10), 8.5/10)*2)+""
				}
				
				view.poNumTF.text = vo2.population+"";
				view.maxTF.text = vo2.num_limit+"";
				view.trainTimeTF.text = TimeUtil.getShortTimeStr(vo2.unit_training_time*1000)
				
				//技能
				//主动技能
				var tmp:Array = (data.skillId+"").split("|");
				formatSkill(view.skillCom.item_0, tmp[0]);
				formatSkill(view.skillCom.item_1, tmp[1]);
				if(_skills){
					_skills.length = 0;
				}else{
					_skills = [];
				}
				_skills.push(tmp[0],tmp[1]);
				//被动技能
				if(data.skillId2){
					tmp = data.skillId2.split("|");
					tmp[1] = 0;
				}else{
					tmp = ((vo2.skillId2 || vo2.skill2_id) +"").split(";");
					tmp = (tmp[0]+"").split("|")
				}
				
				formatSkill(view.skillCom.item_2, tmp[0],tmp[1],vo);
				if(tmp.length && tmp[0]+"" != "undefined"){
					_skills.push(tmp[0]);
				}
				
				setSkillPosition();
				
				
				ProTipUtil.addTip(view.dataInfo,data)
			}else{
				
				
				//兼容原始数据
				view.dataInfo.attackTF.innerHTML = "";
				view.dataInfo.critTF.innerHTML = "";
				view.dataInfo.critDamageTF.innerHTML = "";
				view.dataInfo.critDamReductTF.innerHTML = "";
				view.dataInfo.defenseTF.innerHTML = "";
				view.dataInfo.dodgeTF.innerHTML = "";
				view.dataInfo.hitTF.innerHTML = "";
				view.dataInfo.hpTF.innerHTML = "";
				view.dataInfo.resilienceTF.innerHTML = "";
				view.dataInfo.speedTF.innerHTML = "";
				
				view.costTF.text = "";
				view.poNumTF.text = "";
				view.trainTimeTF.text = "";
				
				formatSkill(view.skillCom.item_0, null);
				formatSkill(view.skillCom.item_1, null);
				formatSkill(view.skillCom.item_2, null);
				ProTipUtil.removeTip(view.dataInfo)
			}
		}
		
		/**设定位置*/
		private function setSkillPosition():void{
			if(view.skillCom.item_1.visible){
				view.skillCom.item_0.x = 7;
				view.skillCom.item_2.x = 245;
			}else{
				view.skillCom.item_0.x = 50;
				view.skillCom.item_2.x = 210;
			}
		}
		
		private function formatSkill(item:SkillItemUI, skillId:*, starLv:int=-1, starVo:Object=null):void{
			if(skillId && skillId != "undefined"){
				item.visible = true;
				var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId];
				//兼容被动技能
				if(starLv != -1){
					vo = DBSkill2.getSkillInfo(skillId);
					item.skillBg.skin = "common/skill_bg1.png";
					item.lvBG.skin = "common/skill_bg1_1.png";
				}else{
					item.skillBg.skin = "common/skill_bg.png";
					item.lvBG.skin = "common/skill_bg_1.png";
				}
				item.lvTF.text = vo.skill_level+"";
				
				if(vo){
					item.nameTF.text = vo.skill_name+"";
					item.icon.skin = URL.formatURL("appRes/icon/skillIcon/"+vo.skill_icon+".png");
				}else{
					item.nameTF.text = "NoDataSource"
				}
				trace("vo-----------------------",starVo,starLv)
				if(!starVo || (starVo && starVo.star_level >= starLv)){
					item.gray = false
				}else{
					item.gray = true;
				}
			}else{
				item.visible = false;
			}
		}
		
		private function onResult(cmd:int, ...args):void{
			trace("T_OnResult",args);
			switch(cmd){
				case ServiceConst.T_INFO:
					this._data = args[1];
					format();
					TrainInfoCom.updateData(args[1]);
					break;
				case ServiceConst.T_TRAIN:
					if(args[1][0] == true){
						WebSocketNetService.instance.sendData(ServiceConst.T_INFO, null);	
					}
					break;
				case ServiceConst.T_SPEED:
					if(args[1][0] == true){
						WebSocketNetService.instance.sendData(ServiceConst.T_INFO, null);	
					}
					break;
				case ServiceConst.T_CANCEL:
					if(args[1][0] == true){
						WebSocketNetService.instance.sendData(ServiceConst.T_INFO, null);	
					}
					break;
				case ServiceConst.C_COMPOSE:
					
					WebSocketNetService.instance.sendData(ServiceConst.T_INFO, null);
					break;
				case ServiceConst.C_Star:
					WebSocketNetService.instance.sendData(ServiceConst.T_INFO, null);
					break
				case ServiceConst.C_DISMISS:
					var info:Object = CampData.getUintById(args[1][0]);
					trace("info...............................",info);
					if(info){
						info.have_number = parseInt(info.have_number) - 1;
						var db:Object = GameConfigManager.unit_dic[info.unitId];
						var tmp:Array = view.conTF.text.split("/");
						view.conTF.text = (parseInt(tmp[0]) - db.population)  + "/" + tmp[1]
					}
					this.view.list.refresh();
					break;
			}
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			switch(cmd){
				case ServiceConst.T_SPEED:
					XTip.showTip( GameLanguage.getLangByKey(errStr));
					break;
				case ServiceConst.T_TRAIN:
					XTip.showTip( GameLanguage.getLangByKey(errStr));
					break;
				case ServiceConst.C_COMPOSE:
				case ServiceConst.C_Star:
					XTip.showTip( GameLanguage.getLangByKey(errStr));
					break
			}
		}
		
		private function format():void{
			if(!this._data){
				return;
			}
			var info:Object = this._data;
			
			//同步数据员
			CampData.update(info);
			
			trace("info::::::::::::::::::::::::::::::::::::::::",info);
			var arr:Array = []
			var fvo:Object
			var tmp:Array = [];
			for(var i:String in info.solier_list){
				tmp.push(info.solier_list[i]);
			}
			tmp.sort(onSort);
			for(var j:int=0; j<tmp.length; j++){
				arr.push({id:tmp[j].unitId, sn:true});
			}
			_ids = arr;
			//Laya.timer.once(200, this, onChange, [false]);
			onChange(false);
			
			//计算人口上线
			var lv:Number = GlobalRoleDataManger.instance.user.sceneInfo.getBuildingLv(DBBuilding.B_TRAIN);
			var blvo:BuildingLevelVo = DBBuildingUpgrade.getBuildingLv(DBBuilding.B_TRAIN,lv);
			if(lv > 0){
				view.conTF.text = info.total_pop+"/"+blvo.buldng_capacty;
			}else{
				view.conTF.text = "0/0";
			}
			
			
			
			var trainInfo:Object;
			arr = [];
			if(info.train_list){
				trainInfo = info.train_list.queue;
				for(i in trainInfo){
					arr.push(trainInfo[i]);
				}
				arr.sort(sortFun)
			}
			this._trainList = arr;
			if(arr.length){//格式化第一个时间
				var first:Object = arr.shift();
				_firstItem.dataSource = first;
				_giveTime = info.train_list.last_give_time;
				_currentVo = GameConfigManager.unit_dic[first.unitId];
				view.exItem.visible = true;
				view.timeBar.visible = true;
				updateTime();
				Laya.timer.loop(1000,this, updateTime);
				//UIUtils.gray(this.view.speedBtn, false);
				this.view.speedBtn.disabled = false;
			}else{
				view.exItem.visible = false;
				view.timeTF.text = "";
				view.totalTimeTF.text = "";
				view.timeBar.visible = false;
				Laya.timer.clear(this, updateTime);
				//UIUtils.gray(this.view.speedBtn, true);
				this.view.speedBtn.disabled = true;
			}
			view.nowList.array  = arr;
		}
		
		private function onSort(obj1:Object, obj2:Object):int{
			if(obj1.power < obj2.power){
				return 1
			}
			return -1;
		}
		
		private function sortFun(a:*, b:*):Number{
			return a.start_make_time > b.start_make_time ? 1 : -1
		}
		
		private var _flag:Boolean = false
		private function updateTime():void{
			var totalTime:Number = parseFloat(_currentVo.unit_training_time)*1000;
			var delTime:Number = TimeUtil.now - _giveTime*1000;
			view.timeTF.text = TimeUtil.getShortTimeStr(totalTime - delTime);
			view.timeBar.value = delTime/totalTime
			if(totalTime - delTime < 1000){//时间到，重新获取
				if(!_flag){
					Laya.timer.clear(this, updateTime);
					_flag = true
					Laya.timer.once(2000, this, reset);
					WebSocketNetService.instance.sendData(ServiceConst.T_INFO,null);
				}
			}
			caculate();
			
			function reset():void{
				_flag = false;
			}
		}
		
		override public function show(...args):void{
			super.show();
			WebSocketNetService.instance.sendData(ServiceConst.T_INFO,null);
			
			this.view.editBtn.visible = true;
			this.view.confirmBtn.visible = false;
			view.list.mouseHandler = new Handler(this, this.onSelect);
			AnimationUtil.flowIn(this);
			
			//训练
			view.exItem.visible = false;
			view.timeTF.text = "";
			view.totalTimeTF.text = "";
			view.timeBar.visible = false;
			view.totalGoldTF.text = User.getInstance().gold+"";
			
			
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.ENTER_TRAIN_VIEW);
			}
		}
		
		override public function close():void{
			//selectedItem = null;
			//this._data = null;
			//this._skillVo = null;
			//view.list.selectedIndex = 0;
			_flag = false;
			//this._trainList = null;
			view.list.mouseHandler.recover();
			view.list.mouseHandler = null;
			AnimationUtil.flowOut(this, onClose);
			Laya.timer.clear(this, updateTime);
			
			//预加载第三场战斗
			PreloadUtil.preloadThirdBattle();
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function dispose():void{
			Laya.loader.clearRes("train/bg0.png");
			super.dispose();
		}
		
		private function set selectedItem(item:UnitItem):void{
			if(this._selectedItem){
				this._selectedItem.selected = false;
			}
			this._selectedItem = item;
			if(this._selectedItem){
				this._selectedItem.selected = true;
			}
		}
		
		override public function createUI():void{
			this._view = new TrainViewUI();
			this.addChild(_view);
			view.list.hScrollBarSkin=""
			view.list.itemRender = UnitItem;
			view.list.selectEnable = true;
			view.list.array = [];
			
			view.nowList.vScrollBarSkin = "";
			view.nowList.itemRender = TrainingItem;
			view.nowList.selectEnable = true;
			view.nowList.array = [];
			
			var btns:Array = [];
			for(var j:int=0; j<5; j++){
				btns.push(view["btn_"+j]);
			}
			_group = new XGroup(btns);
			_group.selectedBtn = btns[0];
			
			_firstItem = new TrainingItem(view.exItem);
			
			for(var i:String in view.dataInfo){
				if(view.dataInfo[i] is HTMLDivElement){
					view.dataInfo[i].style.fontFamily = XFacade.FT_Futura;
					view.dataInfo[i].style.fontSize = 16;
					view.dataInfo[i].style.color = "#ffffff";
					view.dataInfo[i].style.align = "right";
				}
			}
			UIRegisteredMgr.AddUI(this.view.list,"TrainSoilderList");
			UIRegisteredMgr.AddUI(this.view.trainBtn,"TrainBtn");
			
			view.speedBtn['clickSound'] = ResourceManager.getSoundUrl("ui_training_boost",'uiSound')
			
			closeOnBlank = true;
			this.cacheAsBitmap = true;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("TrainSoilderList");
			UIRegisteredMgr.DelUi("TrainBtn");
			super.destroy(destroyChild);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			//view.skillInfo.infoBtn.on(Event.CLICK, this, this.showTip);
			view.list.renderHandler = Handler.create(this, this.onRender, null, false)
			this._group.on(Event.CHANGE, this, this.onChange);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.T_INFO),this,onResult,[ServiceConst.T_INFO]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.T_TRAIN),this,onResult,[ServiceConst.T_TRAIN]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.T_SPEED),this,onResult,[ServiceConst.T_SPEED]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.T_CANCEL),this,onResult,[ServiceConst.T_CANCEL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult,[ServiceConst.C_COMPOSE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult,[ServiceConst.C_Star]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.C_DISMISS),this,onResult,[ServiceConst.C_DISMISS]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.on(User.PRO_CHANGED, this, updateGold);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			this._group.off(Event.CHANGE, this, this.onChange);
			//view.skillInfo.infoBtn.off(Event.CLICK, this, this.showTip);
			view.list.renderHandler = null;
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.T_INFO),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.T_TRAIN),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.T_SPEED),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.T_CANCEL),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_COMPOSE),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_Star),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.C_DISMISS),this,onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,onError);
			Signal.intance.off(User.PRO_CHANGED, this, updateGold);
			super.removeEvent();
			ProTipUtil.removeTip(view.dataInfo)
		}
		
		public function get view():TrainViewUI{
			return _view as TrainViewUI;
		}
	}
}