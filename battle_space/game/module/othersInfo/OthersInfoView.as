package game.module.othersInfo
{
	import MornUI.othersInfoView.HeroItemUI;
	import MornUI.othersInfoView.OthersInfoViewUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.UnitPicUtil;
	
	import laya.events.Event;
	import laya.ui.HBox;
	import laya.utils.Handler;
	
	/**
	 * 玩家信息弹出框
	 * @author hejianbo
	 * 
	 */
	public class OthersInfoView extends BaseView
	{
		public function OthersInfoView()
		{
			super();
			_m_iLayerType = LayerManager.M_POP;
		}
		
		// 玩家的id
		override public function show(param:Array):void{
			super.show();
			onStageResize();
			
			var posX = view.stage.mouseX + 20;
			var posY = view.stage.mouseY;
			if (posX + view.dom_box.width > Laya.stage.width) {
				posX = Laya.stage.width - view.dom_box.width; 
			}
			if (posY + view.dom_box.height > Laya.stage.height) {
				posY = Laya.stage.height - view.dom_box.height; 
			}
			view.dom_box.pos(posX, posY);
			
			// 玩家id
			sendData(ServiceConst.PLAYER_INFO, [param[0]]);
		}
		
		/**改变舞台尺寸*/
		override public function onStageResize():void {
			var stageHeight = Laya.stage.height;
			view.dom_bg.height = view.height = stageHeight;
		}
		
		private function onClick(e:Event):void {
			switch (e.target) {
				case view.dom_bg:
					close();
					
					break;
			}
		}
		
		/**请求回来的数据处理*/
		private function onServerResult(...args):void {
			var cmd = Number(args[0]);
			trace('%c 【玩家信息】：', 'color: green', cmd, args);
			var result = args[1];
			switch(cmd) {
				case ServiceConst.PLAYER_INFO:
					view.dom_name.text = result["name"];
					view.dom_level.text = GameLanguage.getLangByKey("L_A_14015") + result["level"];
					view.dom_power.text = GameLanguage.getLangByKey("L_A_1201") + result["power"];
					view.dom_guild.text = GameLanguage.getLangByKey("L_A_1202") + result["guild_name"];
					
					createHeroHeaders(result["heros"], view.dom_heros);
					createHeroHeaders(result["soldiers"], view.dom_soldiers);
					
					break;
			}
		}
		
		/**创建英雄的头像*/
		private function createHeroHeaders(idList:Array, parentBox:HBox):void {
			var skinList:Array = idList.map(function(id) {
				var skin = UnitPicUtil.getUintPic(id, UnitPicUtil.ICON);
				return skin;
			});
			parentBox.removeChildren();
			// 资源加载完成
			Laya.loader.load(skinList, Handler.create(this, function():void{
				skinList.forEach(function(item){
					var child:HeroItemUI = new HeroItemUI();
					child.dataSource = {"dom_header": item};
					parentBox.addChild(child);
				});
			}));
		}
		
		override public function createUI():void{
			this.addChild(view);
			view.mouseEnabled = true;
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PLAYER_INFO), this, onServerResult);
		}
		
		override public function removeEvent():void {
			super.removeEvent();
			
			view.off(Event.CLICK, this, onClick);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PLAYER_INFO), this, onServerResult);
		}
		
		override public function close():void{
			super.close();
		}
		
		public function get view():OthersInfoViewUI{
			_view = _view || new OthersInfoViewUI();
			return _view;
		}
	}
}