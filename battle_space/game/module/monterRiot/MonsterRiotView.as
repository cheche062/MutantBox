package game.module.monterRiot
{
	import MornUI.monsterRush.MonsterRushUI;
	
	import game.common.AnimationUtil;
	import game.common.SceneManager;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameLanguage;
	import game.global.util.ItemUtil;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.module.mainScene.ArticleData;
	import game.module.mainScene.MonsterLogic;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * MosterRiotView 怪物入侵
	 * author:huhaiming
	 * MosterRiotView.as 2017-3-31 下午2:49:10
	 * version 1.0
	 *
	 */
	public class MonsterRiotView extends BaseDialog
	{
		private var _data:ArticleData;
		/**最大杀怪次数*/
		private const KILL_NUM:int = 10;
		public function MonsterRiotView()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				case view.attackBtn:
					fight(this._data.id)
					//FightingManager.intance.getSquad(4, this._data.id,Handler.create(this, this.onFightOver));
					break;
			}
		}
		/**改成静态*/
		public static function fight(id:String):void{
			FightingManager.intance.getSquad(4, id,Handler.create(null, onFightOver));
		}
		
		private static function onFightOver():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
		}
		
		override public function show(...args):void{
			super.show();
			this._data = args[0][1];
			//4=41=1;3=41=1
			var exData:Array = (this._data.ex+"").split(";");
			var rewardNum:Number;
			
			var tmpArr:Array = exData[0].split("=");
			//todo奖励类型分析,tmpArr[0]为奖励道具ID
			rewardNum = Math.round(parseInt(tmpArr[1])*parseInt(tmpArr[2]));
			this.view.rewardTF_0.text = rewardNum+"";
			ItemUtil.formatIcon(this.view.icon_0, exData[0]);
			if(exData[1]){
				tmpArr = exData[1].split("=");
				//todo奖励类型分析,tmpArr[0]为奖励道具ID
				rewardNum = Math.round(parseInt(tmpArr[1])*parseInt(tmpArr[2]));
				this.view.rewardTF_1.text = rewardNum+"";
			}else{
				this.view.rewardTF_1.text = "";
			}
			ItemUtil.formatIcon(this.view.icon_1, exData[1]);
			var n:Number = (MonsterLogic.monsterData.skill_number || 0)
			view.timesTF.text = n +"/"+KILL_NUM
			
			//影响建筑列表
			var list:Array = MonsterLogic.getEffList(_data.id);
			view.list.array = list;
			if(list.length > 0){
				view.tipTF.text = "";
			}else{
				view.tipTF.text = GameLanguage.getLangByKey("L_A_47004");
			}
			
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			this._data = null;
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new MonsterRushUI();
			this.addChild(this._view);
			
			this.view.list.itemRender = MonsterRiotItem;
			this.view.list.vScrollBarSkin = "";
			this._closeOnBlank = true;
		}
		
		override public function addEvent():void{
			this.view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			this.view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
		private function get view():MonsterRushUI{
			return this._view as MonsterRushUI;
		}
	}
}