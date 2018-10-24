package game.module.military
{
	import MornUI.military.RewardItemUI;
	
	import game.common.DataLoading;
	import game.common.ItemTips;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.DBMilitary;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.bingBook.ItemContainer;
	import game.module.invasion.ItemIcon;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * MilitaryRewardItem
	 * author:huhaiming
	 * MilitaryRewardItem.as 2017-9-13 上午11:42:08
	 * version 1.0
	 *
	 */
	public class MilitaryRewardItem extends RewardItemUI
	{
		private var data:Object;
		private var _items:Array = [];
		private var _reward:Array;
		public function MilitaryRewardItem()
		{
			super();
			claimBtn.on(Event.CLICK, this, this.onClaim);
		}
		
		override public function set dataSource(value:*):void{
			data = value;
			var item:ItemContainer
			for(var i:int=0; i<_items.length; i++){
				item = _items[i];
				if(item){
					item.off(Event.CLICK, this, this.onClick);
					item.visible = false;
				}
			}
			if(data){
				var vo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 1);
				this.cupNumTF.text = User.getInstance().cup+"/"+data.down;
				this.icon.skin = "appRes\\icon\\military\\"+data.ID+".png"
				if(data.reward){
					if(record.indexOf(data.ID) != -1){
						this.claimBtn.visible = false;
						this.receivedLabel.visible = true;
						this.cupNumTF.color = '#83ff9d';
						this.gray = true;
					}else{
						this.receivedLabel.visible = false;
						this.claimBtn.visible = true;
						if(User.getInstance().cup >= data.down){
							claimBtn.disabled = false;
						}else{
							claimBtn.disabled = true;
						}
						this.cupNumTF.color = '#a0e5ff';
						this.gray = false;
					}
					
					if(data.ID == vo.ID){
						this.bg.skin = "military/bg19_1.png"
						this.cupNumTF.color = '#83ff9d';
						this.gray = false;
					}else{
						this.bg.skin = "military/bg19.png"
					}
					
					var arr:Array = (data.reward+"").split(";")
					var tmp:Array;
					_reward =  [];
					var itemD:ItemContainer = new ItemContainer();
					for(var i:int=0; i<arr.length; i++){
						tmp = arr[i].split("=");
						item = _items[i]
						if(!item){
							item = new ItemContainer();
							_items[i] = item;
						}
						item.visible = true;
						item.setData(tmp[0], tmp[1]);
							
						itemD.iid = tmp[0];
						itemD.inum = tmp[1];
						_reward.push(itemD);
						
						this.itemContainer.addChild(item);
						item.x = i* (item.width+5);
					}
					
					
					
				}else{
					this.claimBtn.visible = false;
					this.receivedLabel.visible = false;
					this.gray = true;
				}
			}
			//trace(data);
		}
		
		private function onClick(event:Event):void{
			/*var item:ItemIcon = event.currentTarget as ItemIcon;
			if(item.data){
				ItemTips.showTip(item.data.id);
			}*/
		}
		
		private function onResult(...args):void{
			var info:Object = args[1].get_mil_log
			MilitaryView.data.base_rob_info.get_mil_log = info
			this.claimBtn.visible = false;
			this.receivedLabel.visible = true;
			Signal.intance.event(MilitaryView.UPDATE);
			
//			XFacade.instance.openModule(ModuleName.ShowRewardPanel,[_reward]);
			
			ToolFunc.showRewardsHandler(data.reward);
			
		}
		
		private function onClaim():void{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.IN_getReward),this,onResult);
			WebSocketNetService.instance.sendData(ServiceConst.IN_getReward,[data.ID]);
		}
		
		private function get record():Array{
			return MilitaryView.data.base_rob_info.get_mil_log || [];
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			super.destroy()
			
			_items = null;
			claimBtn.off(Event.CLICK, this, this.onClaim);
		}
	}
}