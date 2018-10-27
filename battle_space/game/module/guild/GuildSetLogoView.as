package game.module.guild
{
	import MornUI.guild.GuildSetLogoViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 公会设置logo
	 * @author hejianbo
	 * 
	 */
	public class GuildSetLogoView extends BaseDialog
	{
		/**颜色编号对照表*/ 
		private const COLOR_NAME_MAP:Object = {
			"purple": 0,
			"blue": 1,
			"green": 2,
			"red": 3,
			"yellow": 4,
			"white": 5
		}
		private var colorsList:Array = [];
		/**当前设置的类型， 0:底框, 1:图片*/
		private var currentSetType:int = 0;
		
		/**当前设置的类型， 0紫色  1蓝色 2绿色 3红色 4黄色*/
		private var currentBgColor:int = 1;
		private var currentLogoColor:int = 1;
		
		/**当前设置的底框类型， 1菱形  2盾牌  3桶  4箭头 5圆形 */
		private var currentBg:int = 1;
		
		/**当前设置的logo形状*/
		private var currentLogo:int = 1;
		
		
		public function GuildSetLogoView()
		{
			super();
			this.closeOnBlank = true;
		}
		
		override public function createUI():void {
			this.addChild(view);
			
			for (var i = 0; i < view.dom_colors.numChildren; i++) {
				var child:Node = view.dom_colors.getChildAt(i);
				colorsList.push(child.name.split("_")[1]);
			}
			
			trace("colorsList", colorsList);
		}
		
		override public function show(... args):void {
			super.show();
			AnimationUtil.flowIn(this);
			
			view.dom_tab.selectedIndex = 0;
			
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				case view.btn_close:
				case view.btn_cancel:
					close();
					break;
				
				case view.btn_confirm:
					// logo背景图 然后是logo
					var param = currentBg + "_" + currentBgColor + "|" + currentLogo + "_" + currentLogoColor;
					GuildMainView.setting_config = {"icon": param};
					Signal.intance.event(GuildEvent.CHANGE_GUILD_ICON, [param])
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_CHANGE_SETTING, ["icon", param]);
					break;
			}
		}
		
		private function onServerResult(... args):void {
			var cmd = args[0];
			var result = args[1];
			switch (cmd) {
				//打开界面
				case ServiceConst.GUILD_CHANGE_SETTING:
					close();
					
					break;
			}
		}
		
		private function selectColorHandler(e:Event):void {
			var color = ToolFunc.find(colorsList, function(item) {
				return e.target.name.indexOf(item) > -1;	
			});
			
			view.dom_selected_color.pos(e.target.x - 7, e.target.y - 7 );
			trace(color);
			
			setColor(COLOR_NAME_MAP[color]);
		}
		
		private function setColor(color):void {
			if (currentSetType == 0) {
				currentBgColor = color;
			} else {
				currentLogoColor = color;
			}
			
			updateList();
		}
		
		private function tabHandler(index):void {
			if (index == -1) return;
			currentSetType = index;
			
			trace(currentSetType);
			
			view.dom_list.selectedIndex = -1;
			updateList();
			
		}
		
		private function updateList():void {
			var array = [];
			if (currentSetType == 0) {
				array = [1,2,3,4,5].map(function (item, index){
					return {
						"dom_select": {visible: (currentBg - 1) == index},
						"dom_icon": getBgSkin(item, currentBgColor)
					}
				});
			} else if (currentSetType == 1) {
				array = [1,2,3,4,5,6,7].map(function (item, index){
					return {
						"dom_select": {visible: (currentLogo - 1) == index},
						"dom_icon": getLogoSkin(item, currentLogoColor)
					}
				});
			}
			
			view.dom_list.array = array;
			
			renderLogo();
		}
		
		private function listHandler(index):void {
			if (index == -1) return;
			
			if (currentSetType == 0) {
				currentBg = index + 1;
			} else {
				currentLogo = index + 1;
			}
			
			view.dom_list.array.forEach(function(item, i){
				item["dom_select"] = {visible: index == i};
			});
			
			view.dom_list.refresh();
			
			renderLogo();
			
			trace(index);
		}
		
		private function renderLogo():void {
			var str = currentBg + "_" +currentBgColor + "|" + currentLogo + "_" + currentLogoColor;
			GameConfigManager.setGuildLogoSkin(view.dom_logo, str);
		}
		
		private function getBgSkin(a, b):String {
			return "appRes/icon/guildIcon/new/d" + a + "_" + b + ".png";
		}
		
		private function getLogoSkin(a, b):String {
			return "appRes/icon/guildIcon/new/0" + a + "_" + b + ".png";
		}
		
		override public function addEvent():void {
			view.on(Event.CLICK, this, onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_CHANGE_SETTING), this, onServerResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			view.dom_tab.selectHandler = new Handler(this, tabHandler);
			view.dom_list.selectHandler = new Handler(this, listHandler);
			super.addEvent();
			
			for (var i = 0; i < view.dom_colors.numChildren; i++) {
				var child:Node = view.dom_colors.getChildAt(i);
				child.on(Event.CLICK, this, selectColorHandler);
			}
		}
		
		
		override public function removeEvent():void {
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_CHANGE_SETTING), this, onServerResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			view.dom_tab.selectHandler.clear();
			
			super.removeEvent();
			for (var i = 0; i < view.dom_colors.numChildren; i++) {
				var child:Node = view.dom_colors.getChildAt(i);
				child.off(Event.CLICK, this, selectColorHandler);
			}
		}
		
		/**服务器报错*/
		private function onError(... args):void {
			var cmd:Number=args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void {
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void {
			super.close();
		}
		
		private function get view():GuildSetLogoViewUI {
			_view = _view || new GuildSetLogoViewUI();
			return _view;
		}
	}
}