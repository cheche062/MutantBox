package game.module.grassShip
{
	import MornUI.grassShip.rankViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	
	import laya.events.Event;
	
	/**
	 * 草船借箭排行榜 
	 * @author hejianbo
	 * 2018-01-29
	 */
	
	public class GrassShipRankView extends BaseDialog
	{
		/**每页5条数据*/
		private const BASE_PAGE:int = 5;
		/**列表总数据*/
		private var list_total_data:Array = [];
		/**当前页*/
		private var current_page:int = 0;
		/**总页数*/
		private var total_page:int = 0;
		public function GrassShipRankView()
		{
			super();
			closeOnBlank = true;
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			updateListData(current_page);
			
			// 进入排行榜
			sendData(ServiceConst.CAOCHUAN_OPEN_RANK);
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			
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
			
//			trace("【草船借箭】当前数据：", result);
		}
		
		/**
		 * 请求回来的数据处理 
		 * @param args 数据
		 * 
		 */
		private function onResult(...args):void{
			trace("【草船借箭排行】", args);
			
			switch(args[0]){
				//打开排行
				case ServiceConst.CAOCHUAN_OPEN_RANK:
					//重置
					list_total_data.length = 0;
					
					var uid = User.getInstance().uid;
					var myRank:Number = 0;
					// 根据后台给出的玩家数据列表填具体玩家信息
					args[1].forEach(function(item, index){
						var color:String = "";
						// 玩家自己的uid
						if (item["uid"] == uid) {
							color = "#afffa7";
							myRank = index + 1;
						} else {
							color = "#aadbeb";
						}
						list_total_data.push({
							"dom_rank": {text: index + 1 , color: color},
							"dom_name": {text: item["name"] , color: color},
							"dom_level": {text: item["level"] , color: color},
							"dom_score": {text: item["point"] , color: color}
						})
					})
					
					// 有名次
					if(myRank){
						view.dom_myRank.text = GameLanguage.getLangByKey("L_A_79016") + myRank;
					}else{
						view.dom_myRank.text = GameLanguage.getLangByKey("L_A_79017");
					}
					
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
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_OPEN_RANK), this, onResult);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CAOCHUAN_OPEN_RANK), this, onResult);
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