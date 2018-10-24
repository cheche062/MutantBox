package game.module.armyGroup.fight 
{
	import game.common.base.BaseView;
	import game.common.ImageFont;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.global.consts.ServiceConst;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.module.mainScene.HpCom;
	import game.net.socket.WebSocketNetService;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyChesspiece extends BaseView 
	{
		private var _aniContainer:Box;
		private var _armyFightRole:Animation
		
		private var _npcArmyData:Array=[];
		private var _playerArmyData:Array=[];
		
		private var _myArmyData:Object;
		protected var _pieceIndex:String;
		
		private var _symbolImg:Image;
		private var _pieceBg:Image;
		
		private var _moveTeamID:String;
		private var _initState:String = "blank";
		private var _selectState:int = 0;
		
		private var _hasMyArmy:Boolean = false;
		private var _armyType:int;
		
		private var _flagImg:Image;
		private var _myFlag:Image;
		private var _totleImg:Image;
		private var _ftImg:Image;
		
		private var _lvTxt:Text;
		private var _armyNumTxt:Text;
		private var _armyIndex:Text;
		private var _ftTxt:Text;
		
		/**动画索引*/
		private var _index:int = 0;
		//表现动画个数
		private static const ACT_SIZE:int = 3;
		/**表现时长*/
		public static const SHOW_TIME:Number = 3600;
		/**切分次数*/
		private static const TIMES:int = 3;
		
		private var _data:Object;
		private var _per:Number;
		private var _hpCom:HpCom;
		private var _nameTF:Label;
		private var _key:String;
		private var _curAct:String = '';
		private var _curIndex:int = 0;
		private var _times:int;
		
		private var _isInFighting:Boolean = false;
		
		/**飙血基础位置*/
		private static const BASE_X:Number = 50;
		private static const BASE_Y:Number = 0;
		public static const IDLE:String = "daiji";
		public static const ATTACK:String = "gongji";
		public static const DIE:String = "siwang";
		
		public function ArmyChesspiece(index:String) 
		{
			super();
			_pieceIndex = index;
		}
		
		public function setData(armyArr:Array,isNpc:Boolean = true):void{
			if (isNpc)
			{
				_npcArmyData = armyArr;
			}
			else
			{
				_playerArmyData = armyArr;
				var len:int = _playerArmyData.length;
				for (var i:int = 0; i < len; i++) 
				{
					if (_playerArmyData[i].uid == User.getInstance().uid)
					{
						_myArmyData = _playerArmyData[i]
						_hasMyArmy = true;
						break;
					}
				}
			}
			
			updateAnimation();
			//trace("_armyDataArr:", armyArr);
		}
		
		public function updateAnimation():void
		{
			_nameTF.visible = false;
			_hpCom.visible = false;
			_ftImg.visible = false;
			_ftTxt.text = "";
			if (_playerArmyData.length > 0 || _npcArmyData.length > 0)
			{
				_armyType = 1;
				_flagImg.visible = true;
				
				if (_playerArmyData.length > 0)
				{
					_armyType = _playerArmyData[0].camp;
					_hpCom.update(_playerArmyData[0].hp * 100 / _playerArmyData[0].hp_max);
					this._nameTF.text = _playerArmyData[0].name;
					_lvTxt.text = _playerArmyData[0].level;
					
					if (_playerArmyData[0].fight_times)
					{
						_ftImg.visible = true;
						_ftTxt.text = _playerArmyData[0].fight_times + "";
					}
				}
				else
				{
					_armyType = 2;
					this._nameTF.text = Boolean(_initState == "BOSS")?GameLanguage.getLangByKey("L_A_20978"):GameLanguage.getLangByKey("L_A_20977");
					_lvTxt.text = ArmyGroupFightView.CITY_LV;
					
					if (_npcArmyData[0].type == "1")
					{
						_hpCom.update(100);
					}
					else
					{
						_hpCom.update(_npcArmyData[0].restHp*100/_npcArmyData[0].hp);
					}
					
				}
				
				if (_armyType == 1)
				{
					_flagImg.skin = "armGroupFight/attFlag.png";
				}
				else
				{
					_flagImg.skin = "armGroupFight/defFlag.png";
				}
				
				
				_totleImg.visible = true;
				var allNum:int = _playerArmyData.length + _npcArmyData.length;
				_armyNumTxt.text = allNum;
				if (allNum > 9)
				{
					_armyNumTxt.x = 62;
				}
				else
				{
					_armyNumTxt.x = 66;
				}
				
				_nameTF.visible = true;
				
				if (_hasMyArmy)
				{
					_flagImg.visible = false;
					_lvTxt.text = "";
					//trace("_myArmyData:", _myArmyData);
					_myFlag.visible = true;
					_armyIndex.text = _myArmyData.team_id.split("-")[5];
					
					_hpCom.update(_myArmyData.hp * 100 / _myArmyData.hp_max)
					this._nameTF.text = _myArmyData.name;
					
					if (_myArmyData.fight_times)
					{
						_ftImg.visible = true;
						_ftTxt.text = _myArmyData.fight_times + "";
					}
					else
					{
						_ftImg.visible = false;
						_ftTxt.text = "";
					}
				}
				else
				{
					_myFlag.visible = false;
					_armyIndex.text = "";
				}
				
				if (!_armyFightRole)
				{
					_armyFightRole = new Animation();
					_aniContainer.addChild(_armyFightRole);
				}
				
				if(_armyType == 1)
				{
					_key = "gf_attacker";
					
					if (!_hasMyArmy)
					{
						if (_playerArmyData[0].uid == -1)
						{
							var ngID:int = parseInt(_playerArmyData[0].team_id.split("-")[4]);
							_key = GameConfigManager.ArmyGroupNpcList[ngID].inner_apper;
							//trace("npc team_id:",_playerArmyData[0].team_id,"ngID:", ngID,"key:", _key);
							/*trace("dasd:", GameLanguage.getLangByKey(GameConfigManager.ArmyGroupNpcList[ngID].inner_apper)); 
							trace("_playerArmyData:", _playerArmyData[0]);*/
						}
					}
					
					_aniContainer.scaleX = -1;
					_armyFightRole.loadAtlas("appRes/heroModel/" + _key + "/daiji.json",Handler.create(this,onloadedAnimation));
					
				}
				else
				{
					_key = "gf_defender";
					
					_aniContainer.scaleX = 1;
					_armyFightRole.loadAtlas("appRes/heroModel/" + _key + "/daiji.json",Handler.create(this,onloadedAnimation));
				}
				
				this._hpCom.visible = true;
				_armyFightRole.play();
				
				if (_initState == "BOSS")
				{
					_armyFightRole.visible = false;
					_armyFightRole.stop();
				}
				
			}
			else
			{
				resetState();
			}
			
		}
		
		private function onloadedAnimation():void {
			
			if (!this||!_armyFightRole)
			{
				return;
			}
			
			var p:Point = BaseUnit.getAnimationMaxSize("appRes/heroModel/" + _key + "/daiji.json");
			if (_aniContainer.scaleX == -1)
			{
				_armyFightRole.x = (139 * 0.9 - p.x) / 2 - 125;
			}
			else
			{
				_armyFightRole.x = (139 * 0.9 - p.x) / 2;
			}
			_armyFightRole.y = (155*1.2 - p.y) / 2;
		}
		
		public function findMyArmy(tid:String):void
		{
			var len:int = _playerArmyData.length;
			var i = 0;
			for (i = 0; i < len; i++)
			{
				if (_playerArmyData[i].team_id == tid)
				{
					_myArmyData = _playerArmyData[i];
					_hasMyArmy = true;
					updateAnimation();
					return;
				}
			}
			
		}
		
		public function armyMove(tid:String, isNPC:Boolean = false):void
		{
			if (_myArmyData && _myArmyData!={} && _myArmyData.team_id == tid)
			{
				_myArmyData = { };
				_hasMyArmy = false;
			}
			var len:int = _playerArmyData.length;
			var i = 0;
			for (i = 0; i < len; i++)
			{
				if (_playerArmyData[i].team_id == tid)
				{
					_playerArmyData.splice(i, 1);
					break;
				}
			}
			
			len= _playerArmyData.length;
			for (i = 0; i < len; i++) 
			{
				if (_playerArmyData[i].uid == User.getInstance().uid)
				{
					_myArmyData = _playerArmyData[i];
					_hasMyArmy = true;
					break;
				}
			}
			
			if (_playerArmyData.length == 0 && _npcArmyData.length == 0)
			{
				resetState();
			}
			
			updateAnimation();
		}
		
		public function updateData(data:Object):void
		{
			if (data.camp != _armyType )
			{
				//trace("领地被攻占 强制刷新格子数据");
				resetState();
				setData([data], false);
				return;
			}
			//trace("更新玩家数据：", data);
			var hasData:Boolean = false;
			var len:int = _playerArmyData.length;
			var i = 0;
			
			for (i = 0; i < len; i++) 
			{
				if (_playerArmyData[i].team_id == data.team_id)
				{
					hasData = true;
					_playerArmyData[i] = data;
					break;
				}
			}
			
			if(!hasData)
			{
				_playerArmyData.push(data);
			}
			
			if (data.uid == User.getInstance().uid)
			{
				_myArmyData = data;
				_hasMyArmy = true;
			}
			updateAnimation();
		}
		
		public function setState(mid:String = "" , state:int = 1, myType:int):void
		{
			
			if (_initState == "ZA" || _initState == "JG" || _initState == "FS")
			{
				_selectState = 0;
				return;
			}
			_selectState = 1;
			_moveTeamID = mid;
			_pieceBg.skin = "armGroupFight/grid_" + state+".png";
			
			if (mid == "")
			{
				_selectState = 0;
				return;
			}
			/*trace("_playerArmyData:", _playerArmyData);
			trace("_armyType:", _armyType);
			trace("_initState:", _initState);
			trace("_playerArmyData:", _playerArmyData);
			trace("_npcArmyData:", _npcArmyData);
			trace("===============================================");*/
			if (_armyType != myType && 
				//_initState != "blank" && 
				_initState != "JG" && 
				_initState != "FS")
			{
				if (_playerArmyData.length > 0 || _npcArmyData.length > 0)
				{
					_selectState = 4;
					_pieceBg.skin = "armGroupFight/grid_4.png";
				}
			}
		}
		
		public function setInitInfo(info:String):void
		{
			_initState = info.split("=")[0];
			if (_initState == "ZA")
			{
				_symbolImg = new Image("appRes/armyGroupMap/" + info + ".png");
				_symbolImg.x = 30;
				_symbolImg.y = 40;
				this.addChildAt(_symbolImg,1);
			}
			else if(_initState == "JG")
			{
				_symbolImg = new Image("armGroupFight/grid_6.png");
				_symbolImg.x = _symbolImg.y = 0;
				this.addChildAt(_symbolImg,1);
			}else if(_initState == "FS")
			{
				_symbolImg = new Image("armGroupFight/grid_5.png");
				_symbolImg.x = _symbolImg.y = 0;
				this.addChildAt(_symbolImg,1);
			}
			else if (_initState == "BOSS")
			{
				_symbolImg = new Image("appRes/armyGroupMap/boss.png");
				_symbolImg.x = 15;
				_symbolImg.y = 15;
				this.addChildAt(_symbolImg,1);
			}
		}
		
		private function updateArmyInfo(upInfo:Object):void
		{
			trace("战斗中更新未战斗部队",upInfo);
			trace("战斗中更新未战斗部队 this._data",this._data);
			trace("战斗中更新未战斗部队 _playerArmyData", _playerArmyData);
			trace("---------------------------------------------------");
			trace("");
			trace("");
			trace("");
			var i:int = 0;
			var len:int = 0;
			if (upInfo[5] == "0")
			{
				//len = _npcArmyData.length;
				if (this._data)
				{
					
					if(upInfo[0] == "0")
					{
						//trace("战斗死亡：删除NPC");
						_npcArmyData.splice(1, 1);
					}
					else
					{
						//trace("战斗胜利：更新NPC血量");
						//因为是战斗中更新，取值为数组第二位单位。
						_npcArmyData[1].hp = parseInt(upInfo[2]) - parseInt(upInfo[1]);
					}
				}
				
			}
			else
			{
				if (this._data)
				{
					if(upInfo[0] == "0")
					{
						if (_playerArmyData[1].uid == User.getInstance().uid)
						{
							_hasMyArmy = false;
							_myArmyData = { };
						}
						_playerArmyData.splice(1, 1);
					}
					else
					{
						_playerArmyData[1].hp = parseInt(upInfo[2]) - parseInt(upInfo[1]);
					}
				}
			}
		}
		
		/**
		 * 动画表现
		 * @param data,[1,117,16236,16236,"saygoodbye"], 
		 * 0:死活 0-输，1-赢
		 * 1：失血量
		 * 2：初始血量
		 * 3：总血量
		 * 4：昵称
		 * 5：玩家UID
		 * 6：消耗
		 * 7：队伍ID
		 * 8：地图坐标
		 * */
		public function fightDataformat(data:Object, times:int):void{
			
			
			if (_hasMyArmy && _myArmyData.tid != _playerArmyData[0].tid)
			{
				//trace("有我的部队且不再排头");
			}
			
			
			if (_isInFighting)
			{
				updateArmyInfo(data);
				return;
			}
			
			this._data = data;
			_times = times;
			_curIndex = 0;
			if (data) {
				_isInFighting = true;
				_per = (data[1] / TIMES);
				
				if (!_armyFightRole)
				{
					trace("nullll: ", data);
					trace("playArmy: ", _playerArmyData.length);
					trace("npcArmy: ", _npcArmyData.length);
					resetState();
					return;
				}
				
				if (_initState == "BOSS")
				{
					_armyFightRole.visible = false;
				}
				else
				{
					_armyFightRole.visible = true;
				}
				
				this._nameTF.visible = true;
				this._hpCom.visible = true;
				showAction(IDLE);
				
				_hpCom.update(data[2] * 100 / data[3]);
				
				if (_playerArmyData.length > 0)
				{
					_playerArmyData[0].hp = data[2];
				}
				else
				{
					_npcArmyData[0].type = "2";
					_npcArmyData[0].restHp = data[2];
					_npcArmyData[0].hp = data[3];
				}
				
				var jsonStr:String = ResourceManager.instance.setResURL("imageFont/orangeMin.json");
				Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,doAction));
			}else{
				_armyFightRole.stop();
				showAction(IDLE)
				/*this._nameTF.visible = false;
				this._hpCom.visible = false;*/
			}
		}
		public function doAction():void{
			if(_data){
				showAction(ATTACK);
				var num:Number = _per*(1+Math.random()*0.1);//10%的浮动
				var sp:Sprite = ImageFont.createBitmapFont(Math.round(num)+"","orangeMin");
				var per:Number = _data[1]/_times;
				_curIndex ++;
				if (_curIndex >= TIMES)
				{
					_isInFighting = false;
				}
				
				_hpCom.update((_data[2] - per * _curIndex) * 100 / _data[3]);
				if (_playerArmyData.length > 0)
				{
					_playerArmyData[0].hp = _data[2] - per * _curIndex;
				}
				else
				{
					_npcArmyData[0].type = "2";
					_npcArmyData[0].restHp = _data[2] - per * _curIndex;
					_npcArmyData[0].hp = _data[3];
				}
				
				this.addChild(sp);
				sp.pos(BASE_X, BASE_Y);
				var targetY:Number = BASE_Y - 100;
				var targetX:Number = Math.round(BASE_X + Math.random() * 20 - 10);
				Tween.to(sp, { x:targetX, y:targetY }, 800, null, Handler.create(this, onHpFloatOver, [sp]));
			}
		}
		
		public function showAction(act:String):void{
			if(_curAct != act && _armyFightRole){
				_armyFightRole.clear();
				_armyFightRole.loadAtlas("appRes/heroModel/"+_key+"/"+act+".json");
				_armyFightRole.play(0,false);
			}
		}
		
		private function onHpFloatOver(sp:Sprite):void {
			sp.parent.removeChild(sp)
			Pool.recover(ImageFont.ImageFont_sign, sp);
			if (_curIndex >= TIMES)
			{
				out();
			}
			else
			{
				doAction();
			}
		}
		
		//退场动画
		public function out():void {
			
			if (_data) {				
				if(_data[0] == "0"){
					//trace("die----:", _data);
					showAction(DIE);
					Laya.timer.once(1000, this, checkArmy);
				}else {
					//trace("live-----:", _data);
					if (_playerArmyData.length > 0)
					{
						if (_hasMyArmy)
						{
							
							//_myArmyData.fight_times = parseInt(_myArmyData.fight_times) + 1;
							var len:int = _playerArmyData.length;
							for (var i:int = 0; i < len; i++) 
							{
								if (_playerArmyData[i].team_id == _myArmyData.tid)
								{
									_playerArmyData[i].fight_times = _myArmyData.fight_times;
									break;
								}
							}
						}
						else
						{
							//_playerArmyData[0].fight_times = parseInt(_playerArmyData[0].fight_times) + 1;
						}
						
					}
					showAction(IDLE)
					Laya.timer.once(1000, this, updateAnimation);
				}
			}
		}
		
		public function checkArmy():void
		{
			if (_playerArmyData.length > 0)
			{
				if (_playerArmyData[0].uid == User.getInstance().uid)
				{
					_hasMyArmy = false;
					_myArmyData = { };
				}
				_playerArmyData.shift();
			}
			else if (_npcArmyData.length > 0)
			{
				_npcArmyData.shift();
			}
			
			var len:int = _playerArmyData.length;
			for (var i:int = 0; i < len; i++) 
			{
				if (_playerArmyData[i].uid == User.getInstance().uid)
				{
					_myArmyData = _playerArmyData[i]
					_hasMyArmy = true;
					break;
				}
			}
			
			if (_playerArmyData.length == 0 && _npcArmyData.length == 0)
			{
				resetState();
			}
			
			updateAnimation();
		}
		
		public function resetState():void
		{
			_selectState = 0;
			
			_pieceBg.skin = "armGroupFight/grid_1.png";
			
			_hpCom.visible = false;
			_nameTF.visible = false;
			
			_flagImg.visible = false;
			_myFlag.visible = false;
			_totleImg.visible = false;
			_ftImg.visible = false;
			
			_lvTxt.text = "";
			_armyIndex.text = "";
			_armyNumTxt.text = "";
			_ftTxt.text = "";
			
			_isInFighting = false;
			
			_playerArmyData = [];
			_npcArmyData = [];
			_hasMyArmy = false;
			_myArmyData = { };
			
			this._data = null;
			
			if(_armyFightRole)
			{
				_aniContainer.removeChild(_armyFightRole);
				_armyFightRole.stop();
				_armyFightRole.clear();
				_armyFightRole = null;
			}
		}
		
		override public function createUI():void
		{
			_pieceBg = new Image("armGroupFight/grid_1.png");
			this.addChild(_pieceBg);
			_pieceBg.mouseEnabled = true;
			
			_aniContainer = new Box();
			_aniContainer.anchorX = _aniContainer.anchorY = 0.5;
			this.addChild(_aniContainer);
			
			_hpCom = new HpCom();
			this.addChild(_hpCom);
			_hpCom.scaleX = 0.8;
			_hpCom.pos(42, 50);
			_hpCom.visible = false;
			
			_nameTF = new Label();
			this.addChild(_nameTF);
			_nameTF.font = XFacade.FT_Futura;
			_nameTF.fontSize = 18;
			_nameTF.align = "center";
			_nameTF.color = "#ffffff";
			_nameTF.stroke = 2;
			_nameTF.pos(45, 34);
			
			_flagImg = new Image("armGroupFight/defFlag.png");
			this.addChild(_flagImg);
			_flagImg.scale(0.8, 0.8);
			_flagImg.x = _flagImg.y = 10;
			
			_lvTxt = new Text();
			this.addChild(_lvTxt);
			_lvTxt.font = XFacade.FT_Futura;
			_lvTxt.fontSize = 18;
			_lvTxt.align = "center";
			_lvTxt.color = "#ffffff";
			_lvTxt.pos(15, 50);
			_lvTxt.text = "99"
			
			_myFlag = new Image("armGroupFight/bg13.png");
			this.addChild(_myFlag);
			_myFlag.scale(0.8, 0.8);
			_myFlag.x = 10;
			_myFlag.y = 30;
			
			_armyIndex = new Text();
			this.addChild(_armyIndex);
			_armyIndex.font = XFacade.FT_Futura;
			_armyIndex.fontSize = 18;
			_armyIndex.align = "center";
			_armyIndex.color = "#ffffff";
			_armyIndex.pos(15, 32);
			
			_totleImg = new Image("armGroupFight/grid_num.png");
			this.addChild(_totleImg);
			_totleImg.scale(0.8, 0.8);
			_totleImg.x = 52;
			_totleImg.y = 105;
			
			_armyNumTxt = new Text();
			this.addChild(_armyNumTxt);
			_armyNumTxt.font = XFacade.FT_Futura;
			_armyNumTxt.fontSize = 18;
			_armyNumTxt.align = "center";
			_armyNumTxt.color = "#ffffff";
			_armyNumTxt.pos(62, 118);
			_armyNumTxt.text = "40";
			
			_ftImg = new Image("armGroupFight/icon_kill_1.png");
			this.addChild(_ftImg);
			_ftImg.scale(0.8, 0.8);
			_ftImg.x = 45;
			_ftImg.y = 10;
			_ftImg.visible = false;
			
			_ftTxt = new Text();
			this.addChild(_ftTxt);
			_ftTxt.font = XFacade.FT_Futura;
			_ftTxt.fontSize = 18;
			_ftTxt.align = "center";
			_ftTxt.color = "#fbfb00";
			_ftTxt.strokeColor = "#000000";
			_ftTxt.stroke = 2;
			_ftTxt.pos(73, 16);
			_ftTxt.text = "20"
			
			
			_flagImg.visible = false;
			_myFlag.visible = false;
			_totleImg.visible = false;
			
			_lvTxt.text = "";
			_armyIndex.text = "";
			_armyNumTxt.text = "";
			_ftTxt.text = "";
			addEvent();
		}
		
		override public function addEvent():void
		{
			_pieceBg.on(Event.CLICK, this, this.onClickHandler);
			super.addEvent();
		}

		override public function removeEvent():void
		{
			_pieceBg.on(Event.CLICK, this, this.onClickHandler);
			super.removeEvent();
		}
		
		protected function onClickHandler():void
		{
			if (_selectState == 4)
			{
				WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_FIGHT_START, [_moveTeamID, _pieceIndex]);
				//FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_GROUP,[_moveTeamID, _pieceIndex]);
				return;
			}
			
			if (_hasMyArmy && _selectState == 0)
			{
				//Signal.intance.event(ArmyGroupEvent.SELECT_MAP_PIECE, [_myArmyData, _pieceIndex]);
				return;
			}
			
			if (_initState != "ZA" && _moveTeamID)
			{
				WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_FIGHT_MAP_MOVE, [_moveTeamID, _pieceIndex]);
				return;
			}
			
			//Signal.intance.event(ArmyGroupEvent.CANCEL_SELECT_ARMY);
		}

	}

}