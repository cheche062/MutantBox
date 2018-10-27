package game.module.playerHelp
{
	import MornUI.playerHelp.PlayerHelpViewUI;
	import MornUI.playerHelp.bigIdItemUI;
	import MornUI.playerHelp.smallIdItemUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemData;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.Label;
	import laya.ui.Panel;
	import laya.ui.VBox;
	import laya.ui.View;
	import laya.utils.Handler;
	
	/**
	 * 玩家帮助弹层 
	 * @author hejianbo
	 * 2018-02-24
	 * 
	 */
	public class PlayerHelpView extends BaseDialog
	{
		/**help*/
		private const HELP_URL = "config/help.json";
		/**数据表归纳*/
		private var conclude_data = {};
		/**最大的id*/
		private var max_id = "0";
		/**选中项小id*/
		private var selected_smallid = "0";
		/**选中项大id*/
		private var selected_bigid = "0";
		/**已领取小id*/
		private var gettedId_list:Object = {};
		/**按钮作用*/
		private var button_effect:String = "";
		
		public function PlayerHelpView()
		{
			super();
//			closeOnBlank = true;
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			view.dom_nav.vScrollBarSkin = "";
			
			//console.clear();
			//trace("【新手帮助】:   init~~~~");
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this);
			
			selected_smallid = args[0] || "20";
			
			// 进入界面
			sendData(ServiceConst.PLAYER_HELP_OPEN);
			
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.OPEN_HELP_NOTE)
			}
			
		}
		
		/**id状态  0 没资格， 1未领取， 2 已领取*/
		private function getIdState(id, gettedId_list):void{
			var isGetted = 0;
			if (id in gettedId_list) {
				isGetted = gettedId_list[id]["reward"] == 0 ? 1 : 2;
			}
			
			return isGetted;
		}
		
		private function initData(max_id, gettedId_list):void{
			var data = ResourceManager.instance.getResByURL(HELP_URL);
			var result = {};
			for (var key in data) {
				if (Number(max_id) < Number(data[key]["small_id"])) continue;
				if (!result[data[key]["big_id"]]) {
					result[data[key]["big_id"]] = {id_list: [], tab_title: data[key]["big_title"]};
				}
				
				result[data[key]["big_id"]]["id_list"].push({
					id: data[key]["small_id"],
					type: data[key]["small_type"],
					tab_title: data[key]["small_title"],
					isGetted: getIdState(data[key]["small_id"], gettedId_list)
				});
			}
			
			for (var key2 in result) {
				var isConcludeType2 = result[key2]["id_list"].some(function(item, index){
					// 有子项包含类型2 && 没有领取过
					return (item["type"] == "2") && (item["isGetted"] != 2);
				})
				result[key2]["isShow"] = isConcludeType2;
			}
			
			conclude_data = result;
			//trace("conclude_data", conclude_data);
		}
		
		/**
		 * 更新所有视图
		 * @param selected_smallid 当前选中的小id
		 * @param data 整个大小id数据的归纳数组
		 * 
		 */
		private function updateView(selected_smallid, data):void{
			//选中的small_id对应的大id是多少
			var targetData = ToolFunc.getTargetItemData(ResourceManager.instance.getResByURL(HELP_URL), "small_id", selected_smallid);
			// 选中的big_id
			selected_bigid = targetData["big_id"];
			
			var dom_nav:Panel = view.dom_nav;
			var dom_vbox:VBox = view.dom_vbox;
			// 销毁所有小id元素
			dom_vbox.destroyChildren();
			
			// 累计高度
			var _height:Number = 0;
			// 销毁 除了dom_vbox的子元素
			dom_nav.removeChild(dom_vbox);
			dom_nav.destroyChildren();
			
			// 添加元素
			for (var key in data) {
				var big_dom:bigIdItemUI = new bigIdItemUI();
				big_dom.dataSource = {
					"dom_btn":{label: data[key]["tab_title"], selected: selected_bigid == key},
					"dom_icon": {visible: data[key]["isShow"]}
				}
				big_dom.y = _height;
				_height += big_dom.height;
				
				// 大id点击事件
				big_dom.on(Event.CLICK, this, bigIdHandler, [key]);
				dom_nav.addChild(big_dom);
				// 添加下拉小id
				if (selected_bigid == key) {
					var small_dom:smallIdItemUI;
					for (var j = 0; j < data[key]["id_list"].length; j++) {
						var _item = data[key]["id_list"][j];
						small_dom = new smallIdItemUI();
						small_dom.dataSource = {
							"dom_btn": {label: _item["tab_title"], selected: _item["id"] == selected_smallid},
							"dom_icon": {visible: (_item["type"] == "2") && (_item["isGetted"] != 2)},
							"myid": _item["id"]
						}
						// 小id点击事件
						small_dom.on(Event.CLICK, this, smallIdHandler, [_item["id"]]);
						dom_vbox.addChild(small_dom);
					}
					dom_vbox.y = _height;
					_height += dom_vbox.numChildren * small_dom.height + (dom_vbox.numChildren - 1) * dom_vbox.space;
					dom_nav.addChild(dom_vbox);
				}
			}
			
			renderRightPanel(selected_smallid);
		}
		
		/**小id点击事件*/
		private function smallIdHandler(id):void{
			if (selected_smallid == id) return;
			for (var i = 0; i < view.dom_vbox.numChildren; i++) {
				var child:View = view.dom_vbox.getChildAt(i); 
				child.dataSource["dom_btn"]["selected"] = (id == child.dataSource["myid"]);
				
				child.dataSource = child.dataSource;
			}
			selected_smallid = id;
			renderRightPanel(selected_smallid);
		}
		
		/**大id点击事件*/
		private function bigIdHandler(id):void{
			if (selected_bigid == id) return;
			// 通过大id来确定当前选中的小id
			var targetData = ToolFunc.getTargetItemData(ResourceManager.instance.getResByURL(HELP_URL), "big_id", id);
			selected_smallid = targetData["small_id"];
			updateView(selected_smallid, conclude_data);
			
		}
		
		/**渲染右侧的帮助panel*/
		private function renderRightPanel(id):void{
			trace('渲染', id);
			// 通过小id来判断显示哪一版
			var targetData = ToolFunc.getTargetItemData(ResourceManager.instance.getResByURL(HELP_URL), "small_id", id);
			var _index = targetData["small_type"] == "1"? 0 : 1;
			
			view.dom_viewstack.selectedIndex = _index;
			var dom_content:Panel = view.dom_viewstack.getChildAt(_index).getChildByName("content");
			// 首先销毁所有子元素
			dom_content.destroyChildren();
			dom_content.scrollTo(0, 0);
			
			var content:String = GameLanguage.getLangByKey(targetData["dec"]) || id;
			
			// 拆分具体信息
			var splitContent:Array = content.split("{{").filter(function(item:String){
				return !!item;
			})
			trace("【帮助内容】", splitContent);
			
			// 图片地址列表
			var urlList:Array = splitContent.map(function(item:String){
				var arr:Array = item.split("}}");
				var url:String = arr[0]? "playerHelp/" + arr[0] + ".jpg" : "";
				if (/icon/.test(url)) {
					url = url.replace('jpg', 'png');
				}
				return url;
			})
				
			// 内容信息列表
			var txtList:Array = splitContent.map(function(item:String){
				var arr:Array = item.split("}}");
				return arr[1];
			})
			
			// 异步加载图片完成后
			Laya.loader.load(urlList, Handler.create(this, function(){
				createContentItem(dom_content, urlList, txtList);
			}), null, Loader.IMAGE, 1, true, ModuleName.PlayerHelpView);
			
			//是类型2是否已领取
			if (_index == 1) {
				renderBattleOrReward(id, targetData);
			}
		}
		
		/**给右侧内容添加子项*/ 
		private function createContentItem(parentNode:Node, urlList:Array, txtList:Array):void{
			for (var i = 0; i < urlList.length; i++) {
				var newChild:ContentItem = new ContentItem(txtList[i], urlList[i]);
				var lastChild:ContentItem = parentNode.getChildAt(parentNode.numChildren - 1);
				if(lastChild){
					newChild.y = lastChild.y + lastChild.height + 15;
				}
				parentNode.addChild(newChild);
			}
		}
		
		/**战斗或领取的渲染*/
		private function renderBattleOrReward(id, targetData):void{
			var state = getIdState(id, gettedId_list);
			var label:Label = view.dom_water.getChildAt(0);
			var L_A:String;
			
			switch (state){
				case 0:
					L_A = "L_A_80820";
					button_effect = "battle";
					view.dom_water.visible = true;
					// 渲染reward列表
					createRewardIcons(targetData["reward"], targetData["reward_dec"]);
					break;
				
				case 1:
					L_A = "L_A_80821";
					button_effect = "reward";
					view.dom_water.visible = true;
					// 渲染reward列表
					createRewardIcons(targetData["reward"], targetData["reward_dec"]);
					break;
				
				case 2:
					L_A = "L_A_80820";
					button_effect = "battle";
					view.dom_water.visible = false;
					break;
			}
			
			view.btn_get.label = GameLanguage.getLangByKey(L_A);
		}
		
		/**创建奖励图标*/
		private function createRewardIcons(data, info):void{
			view.dom_water.destroyChildren();
			var _totalWidth = 0;
			var scale = 0.5;
			var infoArr:Array = info.split(";");
			ToolFunc.rewardsDataHandler(data, function(id, num, index){
				var child:RewardItem = new RewardItem();
				child.dataSource = {
					"dom_info": '(' + GameLanguage.getLangByKey(infoArr[index]),
					"dom_icon": GameConfigManager.getItemImgPath(id),
					"dom_num": num + ')'
				}
				_totalWidth += child.width;
				view.dom_water.addChild(child);
			})
			
			// 居中显示
			view.dom_water.x = (view.dom_viewstack.width - _totalWidth) / 2;
		}
		
		private function onError(...args):void{
			var cmd:Number = args[1];
			var errStr:String = args[2];
			XTip.showTip(GameLanguage.getLangByKey(errStr));
			
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					if (!User.getInstance().hasFinishGuide)
					{
						Signal.intance.event(NewerGuildeEvent.CLOSE_HELP_NOTE)
					}
					close();
					
					break;
				
				// 领取||战斗
				case view.btn_get:
					if (button_effect === "reward") {
						sendData(ServiceConst.PLAYER_HELP_GET, [selected_smallid]);
						trace("领取...", selected_smallid);
						
					} else {
						// 战斗结束后的回调
						FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_PLAYER_HELP, selected_smallid, Handler.create(this, function(){
							SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
							XFacade.instance.openModule(ModuleName.PlayerHelpView, selected_smallid);
						}));
						
						trace("进入战斗...", selected_smallid);
						close();
					}
					
					break;
				
				default:
					
					
					break;
			}
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【新手帮助】", args);
			switch(args[0]){
				//打开
				case ServiceConst.PLAYER_HELP_OPEN:
					max_id = args[1]["small_id"];
					if (args[1]["extra"].length == 0) {
						args[1]["extra"] = {};
					}
					gettedId_list = args[1]["extra"];
					
					initData(max_id, gettedId_list);
					updateView(selected_smallid, conclude_data);
					
					break;
				
				//领取
				case ServiceConst.PLAYER_HELP_GET:
					// 领取成功的提示弹框
					var childList = args[1]["reward"].map(function(item, index){
						var child:ItemData = new ItemData();
						child.iid = item[0];
						child.inum = item[1];
						return child;
					})
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [childList]);
					
					gettedId_list[args[1]["small_id"]] = {reward: 1};
					initData(max_id, gettedId_list);
					updateView(selected_smallid, conclude_data);
					
					break;
					
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PLAYER_HELP_OPEN), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.PLAYER_HELP_GET), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PLAYER_HELP_OPEN), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.PLAYER_HELP_GET), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
			
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void{
			super.close();
			
			// 清除资源图
			Loader.clearResByGroup(ModuleName.PlayerHelpView);
		}
		
		public function get view():PlayerHelpViewUI{
			_view = _view || new PlayerHelpViewUI();
			return _view;
		}
		
	}
}