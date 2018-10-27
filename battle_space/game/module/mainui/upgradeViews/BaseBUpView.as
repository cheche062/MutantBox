package game.module.mainui.upgradeViews
{
	import MornUI.homeScenceView.ProgressBarUI;
	
	import game.common.AnimationUtil;
	import game.common.DataLoading;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBBuilding;
	import game.global.data.DBBuildingCD;
	import game.global.data.DBBuildingUpgrade;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.BuildingLevelVo;
	import game.global.vo.User;
	import game.module.alert.XAlert;
	import game.module.mainScene.ArticleData;
	import game.module.mainScene.HomeScene;
	import game.module.mainui.SceneVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.maths.Rectangle;
	import laya.ui.ProgressBar;
	import laya.utils.Handler;
	
	/**
	 * BaseBUpView
	 * author:huhaiming
	 * BaseBUpView.as 2017-4-18 上午9:58:17
	 * version 1.0
	 *
	 */
	public class BaseBUpView extends BaseDialog
	{
		protected var _data:ArticleData;
		protected var _lvData:BuildingLevelVo;
		protected var _nextLvData:BuildingLevelVo;
		protected var _buildVo:Object;
		
		private var _mid0:String;
		private var _mNum0:String;
		private var _del0:Number;
		
		private var _mid1:String;
		private var _mNum1:String;
		private var _del1:Number;
		private var _canUp:Boolean;
		
		private var _divFormat:Boolean = false;
		private static const POS = 
			{
				3:[132,250,364],
				4:[72,190,304,416]
			};
		public function BaseBUpView()
		{
			super();
			_closeOnBlank = true;
		}
		
		protected function onClick(e:Event):void{
			switch(e.target){
				case ui.closeBtn:
					this.close();
					break;
				case ui.upBox.upgradeBtn:
					var sceneVo:SceneVo = User.getInstance().sceneInfo;
					var cost:Number = 0
					if(sceneVo.isQueueFull()){
						var minTime:Number = sceneVo.queue[0][1];//获取队列里建筑的最短时间
						var minArtId:String="-1";
						var minQId:String = 0;
//						trace("minTime0:"+minTime);
//						trace("minTime1"+sceneVo.queue[1][1]);
						for(var i:Number=1; i<sceneVo.queue.length; i++)
						{
							if(sceneVo.queue[i][1]<minTime)
							{
								minTime = sceneVo.queue[i][1];
								minArtId = sceneVo.queue[i][0];
								minQId = i;
							}
						}
						trace("最短时间的队列id:"+minQId);
						cost = DBBuildingCD.cost(sceneVo.getQueueTime(minArtId));
//						cost = DBBuildingCD.cost(sceneVo.getQueueTime("-1"));
						if(cost > 0){
							
							HomeScene.speedHandler = Handler.create(this,lvUp,null,false);
							
							var handler:Handler = Handler.create(WebSocketNetService.instance,WebSocketNetService.instance.sendData,[ServiceConst.B_ONCE,[minQId]])
							//XAlert.showAlert(XUtils.getDesBy("L_A_59", cost),handler);
							
							var data:ItemData = new ItemData;
							data.iid = DBItem.WATER;
							data.inum = cost;
							ConsumeHelp.Consume([data],handler, XUtils.getDesBy("L_A_59", cost));
							
							return;
						}else{
							WebSocketNetService.instance.sendData(ServiceConst.B_ONCE,[minQId]);
						}
					}
					lvUp();
					break;
				default:
					showTip();
					break;
			}
		}
		
		protected function showTip():void{
			if(XUtils.checkHit(ui.upBox.icon_0)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_400001"));
			}else if(XUtils.checkHit(ui.upBox.icon_1)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_400002"));
			}else if(XUtils.checkHit(ui.upBox.expIcon)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_44"));
			}else if(XUtils.checkHit(ui.upBox.icon_2)){
				XTipManager.showTip(GameLanguage.getLangByKey("L_A_46"));
			}
		}
		
		private function lvUp():void{
			var resList:Array = DBBuildingUpgrade.getUpStr(_lvData.building_id,_lvData.level+1);
			if(resList.length>0){
				var handler:Handler = Handler.create(this,doLvUp,[true])
				//XAlert.showAlert(str,handler)
				ConsumeHelp.Consume(resList,handler);
			}else{
				doLvUp();
			}
		}
		
		private function doLvUp(useWater:Boolean=true):void{
			var arr:Array = [this._data.id]
			if(useWater){
				arr.push(1);
			}
			DataLoading.instance.show();
			WebSocketNetService.instance.sendData(ServiceConst.B_LV_UP,arr);
			this.close();
		}
		
		//抽象建筑升级基础数据分析
		protected function format():void{
			var vo:Object = DBBuilding.getBuildingById(_data.buildId);
			_buildVo = vo;
			ui.nameTF.text = GameLanguage.getLangByKey(vo.name)+"\t"+GameLanguage.getLangByKey("L_A_73")+_data.level;
			_lvData = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level);
			_nextLvData = DBBuildingUpgrade.getBuildingLv(_data.buildId, _data.level+1);
			
			ui.icon.skin = "appRes/building/"+_data.buildId.replace("B","")+".png";
			_canUp = true;
			
			//升级面板
			
			if(ui.upBox && _nextLvData){
				var infoList:Array = [ui.upBox.expBox,ui.upBox.timeBox];
				ui.upBox.visible = true;
				if(_nextLvData && _nextLvData.cost1){
					var tmpArr:Array = _nextLvData.cost1.split("=")
					_del0 = parseInt(tmpArr[1])-User.getInstance().getResNumByItem(tmpArr[0])
					if(_del0 > 0){
						ui.upBox.valueTF_0.color="#ff0000";
						_canUp = false;
					}else{
						ui.upBox.valueTF_0.color="#ffffff";
					}
					ui.upBox.valueTF_0.text = XUtils.formatNumWithSign(tmpArr[1]);
					this._mid0 = tmpArr[0];
					this._mNum0 = tmpArr[1];
					infoList.unshift(ui.upBox.box_0);
				}else{
					ui.upBox.valueTF_0.text = ""
				}
				ItemUtil.formatIcon(ui.upBox.icon_0,_nextLvData.cost1);
				
				
				if(_nextLvData && _nextLvData.cost2){
					tmpArr = _nextLvData.cost2.split("=")
					_del1 = parseInt(tmpArr[1]) - User.getInstance().getResNumByItem(tmpArr[0])
					if(_del1 > 0){
						ui.upBox.valueTF_1.color="#ff0000";
						_canUp = false;
					}else{
						ui.upBox.valueTF_1.color="#ffffff";
					}
					ui.upBox.valueTF_1.text = XUtils.formatNumWithSign(tmpArr[1]);
					this._mid1 = tmpArr[0];
					this._mNum1 = tmpArr[1];
					infoList.unshift(ui.upBox.box_1);
				}else{
					ui.upBox.valueTF_1.text = ""
				}
				ItemUtil.formatIcon(ui.upBox.icon_1,_nextLvData.cost2);
				
				ui.upBox.valueTF_2.text = TimeUtil.getShortTimeStr(_nextLvData.CD*1000);
				ui.upBox.expTF.text = XUtils.formatNumWithSign(parseInt(_nextLvData.get_exp));
				var pos:Array = POS[3];
				if(infoList.length == 4){
					pos = POS[4];
				}
				for(var i:int=0; i<infoList.length; i++){
					infoList[i].x = pos[i];
				}
			}
			
			if(ui.tipBox){
//				trace("adlajd");
				var hqinQueue:Boolean = false;
				var sceneInfo:SceneVo = User.getInstance().sceneInfo;
				for(var i:int=0;i<sceneInfo.queue.length;i++)
				{
					if(sceneInfo.queue[i].length>0)
					{
						var hid:String = sceneInfo.queue[i][0];
						//trace("后端建筑id:"+id);
						var bid:String = sceneInfo.building[hid]["id"];
						
						if(bid=="1")
						{
							trace("大本营在建筑队列中");
							hqinQueue = true;
						}
					}
				}
				if(_nextLvData && _nextLvData.HQ_level > User.getInstance().sceneInfo.getBaseLv()){
					trace("大本营等级不满足不能升级");
					ui.upBox.visible = false;
					ui.tipBox.visible = true;
					var str:String = GameLanguage.getLangByKey("L_A_11");
					str = str.replace(/{(\d+)}/,_nextLvData.HQ_level)
					ui.tipTF.text = str;
				}else if(_nextLvData&&_nextLvData.HQ_level == User.getInstance().sceneInfo.getBaseLv()&&hqinQueue)
				{
					trace("大本营等级刚满足但是大本营在建筑队列里，不能升级");
					ui.upBox.visible = false;
					ui.tipBox.visible = true;
					var str:String = GameLanguage.getLangByKey("L_A_11");
					str = str.replace(/{(\d+)}/,_nextLvData.HQ_level)
					ui.tipTF.text = str;
				}
				else if(_nextLvData && _nextLvData.character_level > User.getInstance().level){
//					trace("adlajd2");
					ui.upBox.visible = false;
					ui.tipBox.visible = true;
					ui.tipTF.text = XUtils.getDesBy("L_A_58",_nextLvData.character_level);
				}else{
					ui.tipBox.visible = false;
				}
			}
		}
		
		override public function show(...args):void{
			super.show();
			this._data = args[0];
			format();
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			this._buildVo =null;
			this._lvData = null;
			this._data = null;
			if(HomeScene.speedHandler){
				HomeScene.speedHandler = null;
			}
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function get ui():*{
			if(!_divFormat){
				_divFormat = true;
				var tmp:* = _view
				for(var i:String in tmp){
					if(tmp[i] is HTMLDivElement){
						tmp[i].style.fontFamily = XFacade.FT_BigNoodleToo;
						tmp[i].style.fontSize = 24;
						tmp[i].style.color = "#ffffff";
						tmp[i].style.align = "right";
					}
				}
			}
			return this._view;
		}
		
		override public function addEvent():void{
			super.addEvent();
			_view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			_view.off(Event.CLICK, this, this.onClick);
		}
		
		/**格式化进度条-静态*/
		public static function formatPro(bar:ProgressBarUI, nowValue:*, nextValue:*, maxValue:*):void{
			var w:Number = bar.width;
			var h:Number = bar.height;
			var per:Number = nowValue/maxValue;
			bar.bar.scrollRect = new Rectangle(0,0,w*per, h);
			
			if(nextValue){
				bar.bar1.visible = true;
				per = nextValue/maxValue;
				bar.bar1.scrollRect = new Rectangle(0,0,w*per, h);
			}else{
				bar.bar1.visible = false;
			}
		}
	}
}