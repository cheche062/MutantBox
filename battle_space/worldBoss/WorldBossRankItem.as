package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossRankItem2UI;
	import MornUI.worldBoss.WorldBossRankItemUI;
	
	import game.global.GameConfigManager;
	
	/**
	 * WorldBossRankItem
	 * author:huhaiming
	 * WorldBossRankItem.as 2018-4-24 下午5:25:06
	 * version 1.0
	 *
	 */
	public class WorldBossRankItem
	{
		private var _ui:WorldBossRankItemUI
		public function WorldBossRankItem(ui:WorldBossRankItemUI)
		{
			super();
			this._ui = ui;
		}
		
		//
		public function format(data:Object, type:*):void{
			if(data){
				this._ui.visible = true;
				this._ui.tfName.text = data.name+"";
				this._ui.tfKill.text = data.kill+"";
				this._ui.tfRank.text = data.rank+"";
				var typeData:Object = WorldBossRankView.getRankData(type, data.uid);
				if(typeData){
					var arr:Array = (typeData.reward1+"").split(";");
					for(var i:int=0; i<4; i++){
						formatItem(_ui["rItem_"+i], arr[i])
					}
					
					arr = (typeData.reward2+"").split(";");
					for(i=0; i<4; i++){
						formatItem(_ui["dItem_"+i], arr[i])
					}
				}else{
					for(i=0; i<4; i++){
						_ui["rItem_"+i].visible = false;
						_ui["dItem_"+i].visible = false;
					}
				}
			}else{
				this._ui.visible = false;
			}
		}
		
		//格式化一个道具
		private function formatItem(item:WorldBossRankItem2UI, itemStr:String):void{
			if(itemStr){
				item.visible = true;
				var arr:Array = itemStr.split("=");
				item.icon.skin = GameConfigManager.getItemImgPath(arr[0]);
				item.tfNum.text = "x"+arr[1];
				item.name = "WB_"+arr[0]
			}else{
				item.visible = false;
			}
		}
	}
}