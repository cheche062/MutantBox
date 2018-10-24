package game.module.armyGroup.fight
{
	import game.global.GameConfigManager;
	import game.global.util.TimeUtil;
	import laya.debug.tools.TimeTool;
	import laya.events.Event;
	import MornUI.armyGroupFight.ArmyItemUI;
	
	import game.global.util.UnitPicUtil;
	
	/**
	 * ArmyDeployItem
	 * author:huhaiming
	 * ArmyDeployItem.as 2017-11-27 下午5:25:19
	 * version 1.0
	 *
	 */
	public class ArmyDeployItem extends ArmyItemUI
	{
		public var data:Object;
		public static var type:String = "";
		/**类型-进攻-对应皮肤*/
		public static const ATTACK:String = "armGroupFight/icon_atk2.png";
		/**类型-防守-对应皮肤*/
		public static const DEFEND:String = "armGroupFight/icon_def2.png";
		
		private var reTime:int = 0;
		
		public function ArmyDeployItem()
		{
			super();
			this.attackFlag.visible = false;
			this.on(Event.ADDED, this, addToStage);
			this.on(Event.REMOVED, this, removeFromStage);
		}
		
		private function addToStage(e:Event):void
		{
			Laya.timer.loop(1000, this, rebornCount);
		}
		
		private function removeFromStage(e:Event):void
		{
			Laya.timer.clear(this, rebornCount);
		}
		
		private function rebornCount():void
		{
			if (!data || data.status == 1)
			{
				return;
			}
			reTime--;
			
			if (reTime <= 0)
			{
				data.status = 1;
				this.rebornBtn.visible = false;
				this.rebornTime.visible = false;
			}
			
			this.rebornTime.text = TimeUtil.getTimeCountDownStr(reTime,false);
		}
		
		//[uid,站力,是否出战,teamId]
		override public function set dataSource(value:*):void{
			data = value;
			typePic.skin = type;
			this.y = 10;
			greenBg.visible = false;
			typePic.visible = true;
			this.attackFlag.visible = false;
			this.rebornBtn.visible = false;
			this.rebornTime.visible = false;
			
			if (data)
			{
				if (data.isSelect)
				{
					this.y = 0;
					greenBg.visible = true;
				}
				
				this.gray = false;
				
				//trace("dataSource:::",data)
				pic.skin = UnitPicUtil.getUintPic(data.hid, UnitPicUtil.ICON);
				
				pic.visible = true;
				addBtn.visible = false;
				typePic.visible = false;
				apBar.value = parseInt(data["muscle"]) / GameConfigManager.ArmyGroupBaseParam.APMax;
				apBar.visible = true;
				
				hpBar.visible = true;
				hpBar.value = parseInt(data["hp"]) / parseInt(data["hp_max"]);
				
				this.attackFlag.visible = false;// (data.attType == 1);
				
				if (data["status"] == 2)
				{
//					data["isAuto"] = 0;
					this.gray = true;
					hpBar.value = 0;
					this.rebornBtn.visible = true;
					this.rebornTime.visible = true;
					reTime = parseInt(data["rebornTime"]) - parseInt(TimeUtil.now / 1000);
				}
				
				if (data["isAuto"])
				{
					attackFlag.skin = "armGroupFight/icon_auto.png";
					attackFlag.visible = true;
				}
				
				if (data["isRetreat"])
				{
					attackFlag.skin = "armGroupFight/icon_down.png";
					attackFlag.visible = true;
				}
				
				
				
			}
			else
			{
				pic.skin = '';
				pic.visible = false;
				apBar.visible = false;
				hpBar.visible = false;
				addBtn.visible = true;
				this.attackFlag.visible = false;
			}
		}
	}
}