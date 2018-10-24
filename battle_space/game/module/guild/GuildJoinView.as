package game.module.guild
{
	import MornUI.guild.GuildJoinViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * 首次加入公会奖励 
	 * @author hejianbo
	 * 2018-03-14
	 */
	public class GuildJoinView extends BaseDialog
	{
		/**状态   0尚未加入公会    1可领取 */
		private var state:int = -1;
		
		public function GuildJoinView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			trace("【首次加入公会奖励】:   init~~~~");
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			var jsonData = ResourceManager.instance.getResByURL("config/global_param.json");
			var targetData = ToolFunc.getTargetItemData(jsonData, "id", "24");
			view.dom_num.text = "x" + targetData["value"].split("=")[1];
			
			state = Number(args[0]);
			updateState(state);
		}
		
		/**渲染状态*/
		private function updateState(state):void{
			// 尚未加入公会
			if (state == 0) {
				view.btn_join.label = GameLanguage.getLangByKey("L_A_2651");
				view.btn_join.disabled = false;
			} else if(state == 1){
				view.btn_join.label = GameLanguage.getLangByKey("L_A_2652");
				view.btn_join.disabled = false;
			} else {
				view.btn_join.disabled = true;
			}
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					
					close();
					
					break;
				
				// 领取 || 加入公会
				case view.btn_join:
					if (state == 0) {
						XFacade.instance.openModule(ModuleName.CreateGuildView);
						close();
						
					// 领取奖励
					} else if (state == 1){
						sendData(ServiceConst.GET_GUILD_REWARD);
					}
					
					break;
			}
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【首次加入公会奖励】", args);
			switch(args[0]){
				// 领取奖励
				case ServiceConst.GET_GUILD_REWARD:
					// 领取成功的提示弹框
					var childList = args[1]["reward"].map(function(item, index){
						var child:ItemData = new ItemData();
						child.iid = item[0];
						child.inum = item[1];
						return child;
					})
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					
					User.getInstance().has_add_guild_reward = 2;
					User.getInstance().event();
					
					close();
					break;

				
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_REWARD), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GET_GUILD_REWARD), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():GuildJoinViewUI{
			_view = _view || new GuildJoinViewUI();
			return _view;
		}
		
	}
}