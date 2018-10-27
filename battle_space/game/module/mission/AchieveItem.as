package game.module.mission 
{
	import game.global.consts.ServiceConst;
	import game.global.data.DBBuilding;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.mission.DailyScoreVo;
	import game.global.vo.mission.MissionStateVo;
	import game.global.vo.mission.MissionVo;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Box;
	import MornUI.mission.AchieveItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class AchieveItem extends Box 
	{
		private var itemMC:AchieveItemUI;
		private var _data:DailyScoreVo;
		
		private var _itemVec:Vector.<ItemContainer> = new Vector.<ItemContainer>();
		
		private var _startPos:Array = [0, 540, 490];
		
		public function AchieveItem() 
		{
			super();
			init();
		}
		private function init():void
		{
			this.itemMC = new AchieveItemUI();
			this.addChild(itemMC);
			
			this.view.getBtn.on(Event.CLICK, this, this.clickBtnHandler);
			
		}
		
		private function clickBtnHandler():void 
		{
			WebSocketNetService.instance.sendData(ServiceConst.GET_DAILY_SCORE_REWARD,[data.id]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value as DailyScoreVo;
			
			
			if(!data)
			{
				return;
			}
			
			//_missionData = GameConfigManager.missionInfo[data.id];
			
			switch(data.state)
			{
				case 0:
					view.getBtn.visible = true;
					view.finishTF.visible = false;
					if (User.getInstance().dailyScore >= data.point)
					{
						view.getBtn.label = GameLanguage.getLangByKey("L_A_2652");
						view.getBtn.disabled = false;
					}
					else
					{
						view.getBtn.label = GameLanguage.getLangByKey("L_A_2652");
						
						view.getBtn.disabled = true;
					}
					
					break;
				case 1:
					view.getBtn.visible = false;
					view.finishTF.visible = true;
					break;
				default:
					view.getBtn.label = "L_A_2652";
					view.getBtn.visible = true;
					view.getBtn.disabled = true;
					break;
			}
			
			if (User.getInstance().dailyScore >= data.point)
			{
				view.progessTF.text = "(" + data.point + "/" + data.point + ")";
			}
			else
			{
				view.progessTF.text = "(" + User.getInstance().dailyScore + "/" + data.point + ")";
			}
			
			view.achieveNameTF.text = GameLanguage.getLangByKey(data.name);
			
			var rewardArr:Array = data.reward.split(";");
			var len:int = rewardArr.length;
			var i:int = 0;
			
			for (i = 0; i < 3; i++ )
			{
				if (_itemVec[i])
				{
					_itemVec[i].visible = false;
				}
			}
			len = Math.max(rewardArr.length,_itemVec.length)
			for (i = 0; i < len; i++) 
			{
				if (!_itemVec[i])
				{
					_itemVec[i] = new ItemContainer();
					_itemVec[i].x = _startPos[len] + 100 * i;
					_itemVec[i].y = 4;
					_itemVec[i].needOtherNum = false;
					_itemVec[i].numTF.width = 70;
					this.view.addChild(_itemVec[i]);
				}
				
				if (rewardArr[i])
				{
					_itemVec[i].setData(rewardArr[i].split("=")[0], rewardArr[i].split("=")[1]);
					_itemVec[i].x = _startPos[rewardArr.length] + 100 * i;
					_itemVec[i].visible = true;
				}				
				
			}
			
		}
		
		public function translateMissionDes():String
		{
			/*var orignDes:String = GameLanguage.getLangByKey(_missionData.describe);
			var params:Array = [_missionData.canshu1, _missionData.canshu2, _missionData.canshu3, _missionData.canshu4, _missionData.canshu5];
			var paramsType:Array = _missionData.canshu_type.split("|");
			
			for (var i:int = 0; i < paramsType.length; i++) 
			{
				var replaceStr:String = "";
				switch(parseInt(paramsType[i]))
				{
					case 1:
						replaceStr = params[i];
						break;
					case 2:
						replaceStr = GameLanguage.getLangByKey(DBBuilding.getBuildingById(params[i]).name);
						break;
					case 3:
						replaceStr = GameLanguage.getLangByKey(GameConfigManager.unit_dic[params[i]].name);
						break;
					case 4:
						replaceStr = GameLanguage.getLangByKey(GameConfigManager.items_dic[params[i]].name);
						break;
					case 5:
						break;
					default:
						break;
				}
				orignDes = orignDes.replace("{" + i + "}", replaceStr);
			}
			return orignDes;*/
		}
		
		
		public function get data():DailyScoreVo{
			return this._data;
		}
		
		private function get view():AchieveItemUI{
			return itemMC;
		}
	}

}