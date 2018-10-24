package game.module.arena 
{
	import game.common.base.BaseView;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.global.consts.ServiceConst;
	import game.global.event.ChallengeEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.arena.ArenaNPCVo;
	import game.global.vo.FightUnitVo;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import MornUI.arena.ChallengeItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ChallengeItem extends BaseView 
	{
		private var _headImg:Image;
		private var _mengImg:Image;
		
		private var _enemyID:String;
		private var _enemyRank:String;
		
		private var _tPower:int = 0;
		
		private var _data:Object;
		
		public function ChallengeItem() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.forceBg:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_737"));
					break;
				case view.heroBg:
					Signal.intance.event(ChallengeEvent.CHALLENGE_PLAYER, [_enemyID,_enemyRank]);
					break;
				default:
					break;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			_data = value;
			
			if (!_headImg)
			{
				_headImg = new Image();
				_headImg.x = 12;
				_headImg.y = 25;
				view.addChildAt(_headImg,2);
				
				_mengImg = new Image();
				_mengImg.skin = "appRes/icon/unitPic/mengban.png";
				_mengImg.x = 12;
				_mengImg.y = 26;
				view.addChildAt(_mengImg,3);
				
				/*view.setChildIndex(view.pNameTF, view.numChildren - 1);
				view.setChildIndex(view.changeImg, view.numChildren - 1);*/
				
			}
			//trace("data:", value);
			view.heroBg.skin = "common/bg6.png";
			view.playerForce.text = value.data.power;
			
			if (_data.type == "robot")
			{
				//var npcData:ArenaNPCVo = GameConfigManager.arena_npc_vec[value.data.arena_fight_level];
				//trace("npcData:", npcData);
				
				
				_headImg.skin = "appRes/icon/unitPic/" + value.data.model + "_c.png";
				view.heroBg.skin = "common/bg6_" + ((GameConfigManager.unit_dic[value.data.model] as FightUnitVo).rarity) + ".png";
				_enemyID = value.data.robot_id;
				view.heroLv.text = value.data.level;
			}
			else
			{
				if (_data.heros.length>0)
				{
					_headImg.skin = "appRes/icon/unitPic/" + _data.heros[0] + "_c.png";
					//trace("rarity:", ((GameConfigManager.unit_dic[_data.heros[0]] as FightUnitVo).rarity));
					//trace("skin:", "common/bg6_" + ((GameConfigManager.unit_dic[_data.heros[0]] as FightUnitVo).rarity) + ".png");
					view.heroBg.skin = "common/bg6_" + ((GameConfigManager.unit_dic[_data.heros[0]] as FightUnitVo).rarity) + ".png";
					
				}
				else
				{
					_headImg.skin = "appRes/icon/unitPic/0000_c.png";
				}
				view.heroLv.text = value.data.level;
				_enemyID = value.data.uid;
				view.playerForce.text = value.data.power;
			}
			
			switch(_data.will_advance)
			{
				case 1:
					/*view.stateTF.text = "晋级";
					view.stateTF.color = "#8fffa9"*/
					view.changeImg.skin = "arena/icon_up.png";
					view.frameImg.skin = "arena/frame_1.png";
					break
				case 0:
					/*view.stateTF.text = "保级";
					view.stateTF.color = "#add3ff"*/
					view.changeImg.skin = "arena/icon_ping.png";
					view.frameImg.skin = "arena/frame_2.png"
					break;
				case -1:
					/*view.stateTF.text = "降级";
					view.stateTF.color = "#ff9999"*/
					view.changeImg.skin = "arena/icon_down.png";
					view.frameImg.skin = "arena/frame_3.png"
					break;
			}
			
			_enemyRank = value.data.rank;
			
			
			
			view.pNameTF.text = value.data.name;
			
			view.pRankTF.text = "Rank " + value.data.rank;
			
			_tPower = parseInt(value.power);
		}
		
		override public function createUI():void
		{
			this._view = new ChallengeItemUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			view.heroBg.mouseEnabled = true;
			
			view.pNameTF.text = "";
			view.playerForce.text = "";
			view.pRankTF.text = "";
			
			view.forceBg.mouseEnabled = true;
			
			addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():ChallengeItemUI{
			return _view;
		}
	}

}