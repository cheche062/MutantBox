package game.module.camp
{
	import MornUI.camp.UnitInfoViewUI;
	import MornUI.camp.UnitSrcViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.event.Signal;
	import game.global.vo.ItemVo;
	import game.global.vo.itemSourceVo;
	import game.module.bag.cell.BaseItemSourceCell;
	import game.module.fighting.mgr.FightingStageManger;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * UnitSrcView
	 * author:huhaiming
	 * UnitSrcView.as 2017-7-12 下午1:57:31
	 * version 1.0
	 *
	 */
	public class UnitSrcView extends BaseDialog
	{
		private var callback:Function
		public function UnitSrcView()
		{
			super();
		}
		
		// 传进来兵种的id
		override public function show(...args):void{
			super.show();
			/**产出*/
//			var db:Object = GameConfigManager.unit_json[args[0]];
//			var arr:Array = []
//			for(var i:int=1; i<6; i++){
//				var tmp:Object;
//				if(db["s_dec"+i]){
//					tmp = {};
//					tmp.source = db["source"+i];
//					tmp.des = db["s_dec"+i];
//					arr.push(tmp);
//				}else{
//					break;
//				}
//			}
//			trace("产出路径db：", db);
//			trace("产出路径：", arr);
			AnimationUtil.flowIn(this);
			
			// 跳转后的回调（关闭当前打开的那些弹层）
			
			var data = args[0];
			callback = data[1];
			
			var result:Array;
			var db:Object = GameConfigManager.unit_json[data[0]];
			if (db["condition"]) {
				//碎片id
				var suipianId:String = db["condition"].split("=")[0];
				
				var vo:ItemVo = GameConfigManager.items_dic[suipianId];
				result = vo.sourceAr;
			}
			
			var itemData:itemSourceVo = ToolFunc.find(result, function(item:itemSourceVo) {
				return item.type == 100;
			})
			
			view.dom_nojump.text = itemData ? itemData.des : "";
			result = result.filter(function(item:itemSourceVo) {
				return item.type != 100;
			})
			
//			trace("列表", result);
			
			view.srcList.array = result;
			view.srcList.refresh();
			
			if(!FightingStageManger.intance.isInit)
			{
				FightingStageManger.intance.initData();
				Signal.intance.on(FightingStageManger.FIGHTINGMAP_INIT,this,initMapDataBack);
			}else
			{
				initMapDataBack();
			}
			
		}
		
		protected function initMapDataBack():void{
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_INIT,this,initMapDataBack);
			var ar:Array = view.srcList.array;
			if(ar && ar.length)
			{
				for (var i:int = 0; i < ar.length; i++) 
				{
					var vo:itemSourceVo = ar[i];
					if(vo) vo.changeState();
				}
				
				ar.sort(sortfun);
				view.srcList.refresh();
			}
		}
		
		private function sortfun(a:itemSourceVo, b:itemSourceVo):Number {
			if(a.state > b.state)
				return 1;
			else if(a.state < b.state)
				return -1;
			
			if(a.id < b.id)
				return -1;
			else if(a.id > b.id)
				return 1;
			return 0;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				default:
//					if(e.target is UnitRenderItem){
					if(e.target is NewItemSourceCell){
//						var item:UnitRenderItem = e.target as UnitRenderItem;
						var item:NewItemSourceCell = e.target as NewItemSourceCell;
//						(XFacade.instance.getView(MainView) as MainView).linkTo(item.data.source);
						
						var vo:itemSourceVo = item.dataSource;
						if(!vo.state)return ;
						
						BaseItemSourceCell.sourceClick(item.dataSource, Handler.create(this, function() {
							callback && callback();
							this.close();
						}));
					}
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			this._view = new UnitSrcViewUI();
			this.addChild(this._view);
			
//			this.view.srcList.itemRender = UnitRenderItem;
			// 换成可以跳到具体的章节
			this.view.srcList.itemRender = NewItemSourceCell;
			this.view.srcList.vScrollBarSkin = "";
			this.closeOnBlank = true;
		}
		
		private function get view():UnitSrcViewUI{
			return this._view as UnitSrcViewUI;
		}
	}
}