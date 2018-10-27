package game.module.worldBoss
{
	import MornUI.worldBoss.WorldBossRankItem2UI;
	import MornUI.worldBoss.WorldBossRankItemUI;
	
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	
	import laya.display.Node;
	import laya.events.Event;
	
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
			_ui.mouseEnabled = true;
		}
		
		//
		public function format(data:Object, type:*):void{
			if(data){
				this._ui.visible = true;
				
				this._ui.tfName.text = "-";
				this._ui.tfKill.text = "-";
				
				if( data.hasOwnProperty("name") )
				{
					this._ui.tfName.text = data.name+"";
					addShowUserInfo(this._ui.tfName, data.uid);
				}
				
				if( data.hasOwnProperty("kill") )
				{
					this._ui.tfKill.text = data.kill+"";
				}
				
				var typeData:Object;
				if( data.hasOwnProperty("rank") )
				{
					this._ui.tfRank.text = data.rank+"";
					typeData = WorldBossRankView.getRankData(type, data.rank);
				}
				else
				{
					typeData = data;
					this._ui.tfRank.text = typeData.up+"";
				}
				
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
		
		/**添加玩家的信息展示弹框事件*/
		private function addShowUserInfo(node:Node, uid:int):void {
			node.on(Event.CLICK, this, function() {
				XFacade.instance.openModule(ModuleName.OthersInfoView, [uid]);
			});
		}
		
		//格式化一个道具
		private function formatItem(item:WorldBossRankItem2UI, itemStr:String):void{
			if(itemStr){
				item.visible = true;
				var arr:Array = itemStr.split("=");
				item.icon.skin = GameConfigManager.getItemImgPath(arr[0]);
				item.tfNum.text = "x"+arr[1];
				item.icon.name = "WB_"+arr[0]
			}else{
				item.icon.name = "";
				item.visible = false;
			}
		}
	}
}