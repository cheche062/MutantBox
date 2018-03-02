package game.module.fortress
{
	import MornUI.fortress.rankViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	
	import laya.events.Event;
	
	/**
	 * 堡垒活动排行榜 
	 * @author hejianbo
	 * 2018-01-22
	 */
	public class FortressRankView extends BaseDialog
	{
		/**堡垒排行榜的奖励数据*/
		private const BAOLEI_RANK_URL = "config/baolei/baolei_rank.json";
		/**堡垒参数url*/
		private var BAOLEI_PARAM_URL = "config/baolei/baolei_param.json";
		/**每页5条数据*/
		private const BASE_PAGE:int = 5;
		/**列表总数据*/
		private var list_total_data:Array = [];
		/**当前页*/
		private var current_page:int = 0;
		/**总页数*/
		private var total_page:int = 0;
		
		public function FortressRankView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			updateListData(current_page);
			
			// 进入堡垒
			sendData(ServiceConst.FORTRESS_ENTER_RANK);
		}
		
		override public function createUI():void{
			this.addChild(view);
		
			view.dom_list.itemRender = RankItemView;
			
			var baolei_param_data = ResourceManager.instance.getResByURL(BAOLEI_PARAM_URL);
			if(baolei_param_data){
				for(var key in baolei_param_data){
					if(baolei_param_data[key]["id"] == "9"){
						view.dom_tips.text = GameLanguage.getLangByKey("L_A_79018").replace("{0}", baolei_param_data[key]["value"]);
						
						break;
					}
				}
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
				
				case view.btn_left:
					changePageHandler(-1);
					break;
				
				case view.btn_right:
					changePageHandler(1);
					
					break;
			}
		}
		
		/**换页函数*/
		private function changePageHandler(num:int):void{
			current_page = current_page + num;
			
			if(current_page < 1){
				current_page = 1;
				return;
			}
			if(current_page > total_page){
				current_page = total_page;
				return;
			}
			
			updateListData(current_page);
		}
		
		/**更新数据列表视图*/
		private function updateListData(current_page:int):void{
			// 截取数据
			var startPage = (current_page - 1) * BASE_PAGE;
			var result = list_total_data.slice(startPage, startPage + BASE_PAGE);
			
			view.dom_page.text = current_page + '/' + total_page;
			view.dom_list.array = result;
			
			trace("【堡垒排行】当前数据：", result);
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【堡垒排行】", args);
			
			switch(args[0]){
				//打开排行
				case ServiceConst.FORTRESS_ENTER_RANK:
					// 读取排行的奖励数据
					var rank_data = ResourceManager.instance.getResByURL(BAOLEI_RANK_URL);
					//重置
					list_total_data.length = 0;
					
					var myRank:String = args[2]["rank"];
					// 有名次
					if(myRank){
						view.dom_myRank.text = GameLanguage.getLangByKey("L_A_79016") + myRank;
					}else{
						view.dom_myRank.text = GameLanguage.getLangByKey("L_A_79017");
					}
					
					//把数据表可能会有的排行奖励全部列出来
					for (var key in rank_data) {
						// 遍历每项的最小值到最大值
						for (var i:int = Number(rank_data[key]["down"]), len:int = Number(rank_data[key]["up"]); i <= len; i++) {
							var color:String = "#aadbeb";
							list_total_data.push({
								"dom_rank": {text: String(i), color: color},
								"dom_name": {text: "", color: color},
								"dom_number": {text: "", color: color},
								"dom_HBox_data": rank_data[key]["reward"]
							})
						}
					}
					
					// 根据后台给出的玩家数据列表填具体玩家信息
					args[1].forEach(function(item, index){
						var rank:int = index + 1;
						var color:String = rank == myRank ? "#afffa7" : "#aadbeb";
						
						var item_data = list_total_data[index];
						item_data["dom_rank"].color = color;
						item_data["dom_name"] = {text: item[0], color: color},
						item_data["dom_number"] = {text: item[1], color: color}
					})
					
					// 初始总页数和当前页
					total_page = Math.ceil(list_total_data.length / BASE_PAGE) || 1;
					current_page = 1;
					updateListData(current_page);
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_ENTER_RANK), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.FORTRESS_ENTER_RANK), this, onResult);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
			
			//重置
			list_total_data.length = 0;
			current_page = 0;
			total_page = 0;
			updateListData(current_page);
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():rankViewUI{
			_view = _view || new rankViewUI();
			return _view;
			
		}
	}
}