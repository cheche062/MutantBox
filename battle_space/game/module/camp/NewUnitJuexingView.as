package game.module.camp
{
	import MornUI.camp.NewUnitJuexingViewUI;
	
	import game.common.RewardList;
	import game.common.UIHelp;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.data.ConsumeHelp;
	import game.global.data.bag.BagManager;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.module.bag.cell.needItemCell;
	import game.module.camp.data.JueXingData;
	import game.module.camp.data.JueXingMange;
	import game.module.fighting.adata.ArmyData;
	import game.module.fighting.view.BaseChapetrView;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	
	/**
	 * 觉醒升级 
	 * @author mutantbox
	 * 
	 */
	public class NewUnitJuexingView extends BaseChapetrView
	{
		public var muUi:NewUnitJuexingViewUI;
		private var _selectAmData:ArmyData;
		private var _jxd:JueXingData;
		
		private var _rList:RewardList;
		private var _needCell:needItemCell;
		private var L_A_73066 = "L_A_73066"; // 一键自动更新
		private var isEnoughPay:Boolean = false; // 是否足够
		
		/**
		 * 是否可升星 
		 */
		public var isUpdateAble:Boolean; 
		
		public function NewUnitJuexingView()
		{
			super();
			muUi = new NewUnitJuexingViewUI();
			addChild(muUi);
			
			this.mouseThrough = muUi.mouseThrough = true;
			
			_rList = new RewardList();
			_rList.selectEnable = true;
			_rList.itemRender = NewUnitJXItemCell;
			_rList.itemWidth = NewUnitJXItemCell.itemWidth;
			_rList.itemHeight = NewUnitJXItemCell.itemHeight;
			muUi.xqCellBox.addChild(_rList);
			
			_needCell = new needItemCell(); 
			muUi.tupoNeedBox.addChild(_needCell);
			_needCell.setElementStyle({y: -5}, {font: XFacade.FT_Futura, fontSize: 24})
			
			muUi.txList.selectEnable = true;
			muUi.txList.repeatX = 2;
			muUi.txList.repeatY = 2;
			muUi.txList.itemRender = NewTeXingCell;
			muUi.txList.spaceX = 66;
			muUi.txList.spaceY = 16;
			muUi.txList.array = [];
			muUi.txList.scrollBar.sizeGrid = "6,0,6,0";
			muUi.txList.scrollBar.visible = false;
			muUi.txList.scrollBar.elasticBackTime = 200;//设置橡皮筋回弹时间。单位为毫秒。
			muUi.txList.scrollBar.elasticDistance = 50;//设置橡皮筋极限距离。
			
			muUi.btn_updateall.label = GameLanguage.getLangByKey(L_A_73066);
			
			UIRegisteredMgr.AddUI(muUi.fArea,"JueXingCaiLiao");
			UIRegisteredMgr.AddUI(muUi.lArea,"JueXingXiaoGuo");
			
		}
		
		
		public function set selectAmData(v:ArmyData):void
		{
			if(_selectAmData != v)
			{
				_selectAmData = v;
				bindAmData();
			}
		} 
		
		public function get selectAmData():ArmyData
		{
			return _selectAmData;
		}
		
		private function bindAmData():void
		{
			if(!selectAmData)
			{
			
				return ;
			}else
			{
//				trace("adaf");
				_jxd = JueXingMange.intance.getJueXingDataByUid(selectAmData.unitId);
				_rList.array = _jxd.eqList;
				_rList.pos( muUi.xqCellBox.width - _rList.width >> 1,  muUi.xqCellBox.height - _rList.height >> 1);
				
				var to:Boolean = !_jxd.isMax && _jxd.isFull;
				muUi.xiangqiqnBox.visible = !to;
				muUi.tupoBox.visible = to;
				var s:String = GameLanguage.getLangByKey("L_A_73106");
				// 当前等级
				muUi.juexingLvlLbl.text = StringUtil.substitute(s, _jxd.level);
				
				if(to){
					//是否存在下一级
					var isExitNext = _jxd.awakenVo.costList;
					if (isExitNext) {
						var costData = _jxd.awakenVo.costList[0];
						_needCell.data = costData;
						dealwithNeedCellStyle(costData.iid);
						
					}
					muUi.tupoNeedBox.visible = isExitNext;
					muUi.dom_maxLevel.visible = !isExitNext;
					muUi.tupoBtn.disabled = !isExitNext;
					
					UIHelp.crossLayout(muUi.tupoNeedBox);
				}
				
				muUi.txList.array = _jxd.featuresList;
				
				var able = isUpdateAbleHandler(_jxd.eqList);
				// 一键升星按钮是否开启
				muUi.btn_updateall.disabled = !able;
				
				// 可升星
				isUpdateAble = to || able;
			}
		}
		
		/**
		 * 处理可升星状态时的文案样式
		 * 
		 */
		private function dealwithNeedCellStyle(iid):void{
			var _label = _needCell.itemNumLal;
			var needNum:String = _label.text;
			var myNum:String = BagManager.instance.getItemNumByID(iid);
			var text:String = myNum + "/" + needNum;
			
			// 不够
			if(Number(needNum) > Number(myNum)){
				_label.color = "#ff9f9f";
				muUi.tupoBtn.label = GameLanguage.getLangByKey("L_A_73067");
				isEnoughPay = false;
			}else{
				_label.color = "#fff";
				muUi.tupoBtn.label = GameLanguage.getLangByKey("L_A_73105");
				isEnoughPay = true;
			}
			_label.text = text;
			
			_needCell.displayCenterInParent();
		}
		
		/**
		 * 处理数据 (返回是否可升星)
		 * 
		 */
		public function dealWithSelectAmData(selectAmData:Object):Boolean{
			var _jxd = JueXingMange.intance.getJueXingDataByUid(selectAmData.unitId);
			var to:Boolean = !_jxd.isMax && _jxd.isFull;
			var result:Boolean = to || isUpdateAbleHandler(_jxd.eqList);
			return result;
		}
		
		/**
		 * 处理是否可以升星
		 * 一旦有一项是可升星即可
		 */
		private function isUpdateAbleHandler(arr:Array):void{
			// item:[1015, AwakenEqVo, 0]
			var result:Boolean = false;
			arr.map(function(item, index):void{
				if(Number(item[2]) === 0){
					var states:Array  = item[1].getStates(item[0]);
					if(states.length <= 0){
						result = true;
					}
				}
			})
//			trace("【NewUnitJXItemCell】读取+号可升星完毕", result);
			return result;
		}
		
		/**
		 * 更新用户的突破道具
		 * 
		 */
		private function refreshUserData():void{
			bindAmData();
		}
		
		
		public override function addEvent():void{
			super.addEvent();
			Signal.intance.on(JueXingMange.JUEXING_CHANGE,this,juexingChangeFun);
			Signal.intance.on(JueXingMange.TEXING_CHANGE,this,texingChangeFun);
			Signal.intance.on(BagEvent.BAG_EVENT_CHANGE, this, refreshUserData);
			_rList.mouseHandler = Handler.create(this,listMouseHandler,null,false);
			muUi.tupoBtn.on(Event.CLICK,this,tupoBtnClick);
			muUi.btn_updateall.on(Event.CLICK,this, updateAll);
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			Signal.intance.off(JueXingMange.JUEXING_CHANGE,this,juexingChangeFun);
			Signal.intance.off(JueXingMange.TEXING_CHANGE,this,texingChangeFun);
			Signal.intance.off(BagEvent.BAG_EVENT_CHANGE, this, refreshUserData);
			_rList.mouseHandler = null;
			muUi.tupoBtn.off(Event.CLICK,this,tupoBtnClick);
			muUi.btn_updateall.off(Event.CLICK,this, updateAll);
		}
		
		/**
		 * 一键全部更新 
		 * 
		 */
		private function updateAll():void{
			if(_rList.array && _rList.array[0]){
				var uid:int = _rList.array[0][0];
				
				JueXingMange.intance.autoAllOpenLockFun(uid);
			}
		}
		
		private function tupoBtnClick(e:Event):void
		{
			// 不够的情况则直接去获取更多
			if (!isEnoughPay) {
				XFacade.instance.openModule(ModuleName.StarTrekMainView);
				XFacade.instance.closeModule(NewUnitInfoView);
				XFacade.instance.closeModule(CampView);
				
				return;
			}
			if(!selectAmData)return;
			ConsumeHelp.Consume(_jxd.awakenVo.costList,Handler.create(this,tupoBtnSend));
		}
		
		private function texingChangeFun(e:Event):void
		{
			if(!muUi)return ;
			muUi.txList.refresh();
		}
		
		private function tupoBtnSend():void
		{
			JueXingMange.intance.tupoFun(_jxd.unitId);
		}
		
		private function listMouseHandler(e:Event,index:int):void
		{
			if(e.type != Event.CLICK)return ;
			if(!selectAmData)return null;
			if(!selectAmData.serverData) {
				XTip.showTip("L_A_73120");
				return ;
			}
			var ar:Array = _rList.array;
			if(_rList.length <= index) return ;
			var cAr:Array = ar[index];
			if (Number(cAr[2])) return ;
			
			XFacade.instance.openModule(ModuleName.NewJuXingXQView,cAr);
		}
		
		
		private function juexingChangeFun(e:Event):void
		{
			bindAmData();
		}
		
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			muUi.size(width,height);
			muUi.showBox.pos(width >> 1 , height - muUi.showBox.height >> 1);
			
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			
			super.destroy(destroyChild);
			muUi  = null;
			_selectAmData = null;
			_jxd = null;
			_rList = null;
			_needCell = null;
			
			UIRegisteredMgr.DelUi("JueXingCaiLiao");
			UIRegisteredMgr.DelUi("JueXingXiaoGuo");
		}
	}
}