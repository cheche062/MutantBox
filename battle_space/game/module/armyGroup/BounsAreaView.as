package game.module.armyGroup
{
	import MornUI.armyGroup.bounsAreaBoxUI;
	import MornUI.armyGroup.bounsAreaUI;
	
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Node;
	import laya.events.Event;
	
	/**
	 * 每日杀敌领取小界面
	 * @author hejianbo
	 * 2018/01/10
	 */
	public class BounsAreaView extends bounsAreaUI
	{
		/**更新小红点*/ 
		private var refreshBounsTips:Function;
		/**每日杀敌领取小界面*/
		public function BounsAreaView(fn:Function)
		{
			//TODO: implement function
			super();
			init();
			
			refreshBounsTips = fn;
		}
		
		private function init():void{
			initDom();
			addEvent();
		}
		
		/** 打开视图 更新数据*/
		public function show():void{
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_ROLLKILL);
			
		}
		
		/** 隐藏视图*/
		public function hide():void{
			removeEvent();
			this.destroy(true);
		}
		
		/**
		 * 初始化dom 
		 * 
		 */
		private function initDom():void{
			var data = GameConfigManager.ArmyGroupKillReList;
			var i:int = 0;
			for (var key in data) {
				i++;
				var item:bounsAreaBoxUI = new bounsAreaBoxUI();
				item.dataSource = {
					dom_light: {visible: true},
					dom_clip: {skin: 'armyGroup/clip_reward_' + i + '.png', index: 0},
					dom_text: {text: 'skill: ' + key}
				}
				item["myType"] = Number(key);
				bounsHBox.addChild(item);
			}
		}
		
		/**
		 * 更新
		 * @param num 总杀敌数
		 * @param arr 领取记录
		 * 
		 */
		private function update(num:int, arr:Array):void{
			var total:int = Number(num);
			// 是否含有可点的箱子
			var hasAbled:Boolean = false;
			killedNum.text = String(num);
			
			forEachChildren(bounsHBox, function(dom:bounsAreaBoxUI){
				var myType = Number(dom["myType"]);
				// 是否足够
				var isEnough:Boolean = total >= myType;
				// 是否未领取过
				var isReward:Boolean = (arr.indexOf(myType) === -1);
				dom.offAll(Event.CLICK);
				if(isEnough && isReward){
					dom.gray = false;
					dom.on(Event.CLICK, this, rewardHandler.bind(this, dom["myType"]));
					dom.dataSource = {
						dom_light: {visible: true}
					}
					
					hasAbled = true;
				}else{
					dom.gray = true;
					dom.offAll(Event.CLICK);
					dom.dataSource = {
						dom_light: {visible: false}
					}
				}
				
				dom.dataSource = {
					dom_clip: {index: isReward? 0 : 1}
				}
			})
			
			refreshBounsTips(hasAbled);
		}
		
		/**
		 * 帮助页
		 * 
		 */
		private function helpHandler():void{
			XFacade.instance.openModule(ModuleName.ArmyGroupBounsInfoView);
		}
		
		/**
		 * 领取 
		 * 
		 */
		private function rewardHandler(type):void{
			
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD, [type]);
			trace('点击领取', type);
			
		}
		
		private function addEvent():void{
			bHelpBtn.on(Event.CLICK, this, helpHandler);
			
			// 打开每日杀敌阶段奖励面板
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL), this, serviceResultHandler);
			// 领取
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD), this, serviceResultHandler);
		}
		
		private function removeEvent():void{
			bHelpBtn.off(Event.CLICK, this, helpHandler);
			forEachChildren(bounsHBox, function(dom:Node){
				dom.offAll(Event.CLICK);
			});
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL), this, serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD), this, serviceResultHandler);
			
			refreshBounsTips = null;
		}
		
		/**
		 * 遍历子元素
		 * @param dom
		 * @param callBack
		 * 
		 */
		private function forEachChildren(dom:Node, callBack:Function):void{
			for (var i:int = 0; i < dom.numChildren; i++) {
				callBack(dom.getChildAt(i));
			}
		}
		
		/**
		 * 服务端接受数据 
		 * 
		 */
		private function serviceResultHandler(...args):void{
			switch (args[0]){
				case ServiceConst.ARMY_GROUP_GET_ROLLKILL:
					update(args[1].kill_number, args[1].get_log);
				
//					trace('ARMY_GROUP_GET_ROLLKILL打开', args);
					break;
				case ServiceConst.ARMY_GROUP_GET_ROLLKILL_REWARD:
					update(args[1], args[3]);
					
					var arr:Array=[];
					var list:Array=args[2];
					for (var i=0; i < list.length; i++)
					{
						var item:ItemData=new ItemData();
						item.iid=list[i].id;
						item.inum=list[i].num;
						arr.push(item);
					}
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [arr]);
					
//					trace('ARMY_GROUP_GET_ROLLKILL_REWARD领取', args);
					break;
			}
		}
	}
}