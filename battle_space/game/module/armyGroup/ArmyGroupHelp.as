package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupHelpUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * ArmyGroupHelp
	 * 军团帮助指南
	 * @author hejianbo 2017-12-12
	 * 
	 */
	public class ArmyGroupHelp extends BaseDialog
	{
		// 当前tab索引
		private var current_tab_index:int = 0;
		// 表数据
		private static var IMAGE_TXT_DATA:Object;
		public function ArmyGroupHelp()
		{
			super();
			
			closeOnBlank = true;
		}
		
		override public function close():void{
			IMAGE_TXT_DATA = null;
			current_tab_index = 0;
			
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new ArmyGroupHelpUI();
			
			this.addChild(view);
			
			view.dom_list.vScrollBarSkin = "";
		}
		
		override public function show(...args):void{
			super.show();
			
			readTableData();
			
			createTabDom();
			
			var index:int = 0;
			if(args[0] === 'fight'){
				index = 1;
			}
			
			tabSelecteHandler(index);

			AnimationUtil.flowIn(this);
		}
		
		/**
		 * 读表数据 
		 */
		private function readTableData():void{
			IMAGE_TXT_DATA = ResourceManager.instance.getResByURL("config/juntuan/juntuan_image_txt.json");
//			trace("【ArmyGroupHelp】表数据: ", IMAGE_TXT_DATA);
		}
		
		/**
		 * 创建tab元素 
		 * 
		 */
		private function createTabDom():void{
			var labelArr:Array = [];
			for(var key:String in IMAGE_TXT_DATA){
				labelArr.push({
					label: GameLanguage.getLangByKey(IMAGE_TXT_DATA[key].type),
					selected: false
				});
			}
			// 暂时屏蔽其它的
			labelArr.length = 3;
			view.dom_list.array = labelArr;
			view.dom_list.selectedIndex = 0;
			view.dom_list.scrollBar.value = 0;
			
		}
		
		/**
		 * 创建list主题内容 
		 * 
		 */
		private function createListContentDom(index:int):void{
			// 首先销毁所有字元素
			view.dom_panel.destroyChildren();
			view.dom_panel.vScrollBar.value = 0;
				
			var content:String = "";
			if(IMAGE_TXT_DATA[index]){
				content = GameLanguage.getLangByKey(IMAGE_TXT_DATA[index].LR)
			}
//			trace("【ArmyGroupHelp】内容: ", content);
			if(!content) return;
			
			content = content.replace(/##/g, '\n');
//			if(index === 1){
//				content = "加入公会后开启公会战，通过公会建筑进入国战地图,加入公会后开启公会战，通过公会建筑进入国战地图。加入公会后开启公会战，" +
//					"通过公会建筑进入国战地图{{10001}}国战地图里散落了大大小小的51个星球，快来占领吧。" +
//					"{{10002}}点击星球后，有进入按钮，点击后可进入星球。"
//			}else if(index === 2){
//				content = "Wang Yi said that China has no intention to change or displace the United States, " +
//					"but stressed that the US cannot dictate or impede its development.。{{10005}}" +
//					"国战地图里散落了大大小小的51个星球，快来占领吧。（以上废话仅为测试用）。{{10004}}" +
//					"点击星球后，有进入按钮，点击后可进入星球。{{10003}}"
//			}
			
			// 拆分具体信息
			content.split("}}").forEach(function(item:String, index:int):void{
				if(item){
					var arr:Array = item.split("{{");
					var url:String = arr[1]? "armyGroup/help/" + arr[1] + ".jpg" : "";
					var newChild:ArmyGroupHelpItem = new ArmyGroupHelpItem(arr[0], url);
					var lastChild:ArmyGroupHelpItem = view.dom_panel.getChildAt(view.dom_panel.numChildren - 1);
					if(lastChild){
						newChild.y = lastChild.y + lastChild.height + 20;
					}
					view.dom_panel.addChild(newChild);
				}
			})
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					this.close();
					
					break;
				
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.dom_list.selectHandler = Handler.create(this, tabSelecteHandler, null, false);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.dom_list.selectHandler = null;
			
		}
		
		/**
		 * tab切换 
		 * @param index
		 * 
		 */
		private function tabSelecteHandler(index):void{
			trace("【ArmyGroupHelp】tab: ", index);
			var lastItem:Object = view.dom_list.getItem(current_tab_index);
			lastItem.selected = false;
			view.dom_list.changeItem(current_tab_index, lastItem);
			
			var newItem:Object = view.dom_list.getItem(index);
			newItem.selected = true;
			view.dom_list.changeItem(index, newItem);
			current_tab_index = index;
			
			createListContentDom(index + 1);
		}
		
		public function get view():ArmyGroupHelpUI{
			return this._view as ArmyGroupHelpUI;
		}
	}
}