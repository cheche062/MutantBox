package game.module.mainScene
{
	import MornUI.homeScenceView.TrainInfoViewUI;
	
	import game.common.AnimationUtil;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.net.socket.WebSocketNetService;
	
	import laya.ui.Box;
	import laya.ui.Image;
	
	/**
	 * TrainInfoCom
	 * author:huhaiming
	 * TrainInfoCom.as 2018-3-28 下午1:58:38
	 * version 1.0
	 *
	 */
	public class TrainInfoCom extends TrainInfoViewUI
	{
		private var _timeBar:TimeBarCom;
		private static var _build:BaseArticle;
		private var _time:int;
		public function TrainInfoCom()
		{
			super();
			init();
		}
		
		public function show(time:int):void{
			_time = time;
			updateTime();
			Laya.timer.loop(1000,this, updateTime);
		}
		
		private function updateTime():void{
			_time -= 1;
			tfTime.text = TimeUtil.getShortTimeStr(_time * 1000);
			if(_time <= 0){
				Laya.timer.clear(this, updateTime);
				//AnimationUtil.removeFlow(this)
				this.removeSelf();
			}
		}
		
		private function init():void{
			/*_timeBar = new TimeBarCom();
			this.spTime.addChild(_timeBar);*/
		}
		
		private static var _hasInit:Boolean = false;
		private static var _data:Object;
		//获取训练状态
		public static function initTranInfo(build:BaseArticle):void{
			_build = build;
			if(!_hasInit){
				_hasInit = true;
				Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.T_INFO),null,onGetInfo);
				WebSocketNetService.instance.sendData(ServiceConst.T_INFO,null);
			}else{
				updateData(_data);
			}
		}
		
		private static function onGetInfo(cmd:int,...args):void{
			updateData(args[0]);
		}
		
		public static function update():void{
			if(_data){
				updateData(_data);
			}
		}
		
		public static function updateData(info:Object):void{
			_data = info;
			var arr:Array = [];
			var trainInfo:Object
			if(info.train_list){
				trainInfo = info.train_list.queue;
				for(var j:String in trainInfo){
					arr.push(trainInfo[j]);
				}
				arr.sort(sortFun)
			}
			var _trainList:Array = arr;
			
			var _currentVo:Object;
			var _giveTime:Number;
			if(arr.length){//格式化第一个时间
				var first:Object = arr.shift();
				_giveTime = info.train_list.last_give_time;
				_currentVo = GameConfigManager.unit_dic[first.unitId];
			}
			
			
			var time:Number = 0;
			var delTime:Number = 0;
			if(_currentVo){
				var totalTime:Number = parseFloat(_currentVo.unit_training_time)*1000;
				delTime = TimeUtil.now - _giveTime*1000;
			}else{
				_build && _build.showTrainInfo(parseInt(time))
				return;
			}
			time += (totalTime - delTime)/1000;
			
			var vo:Object;
			var data:Object = first;
			vo = GameConfigManager.unit_json[data.unitId];
			time += vo.unit_training_time * Math.round(data.make_number-1);
			
			for(var i:int=0; i<_trainList.length; i++){
				vo = GameConfigManager.unit_json[_trainList[i].unitId];
				time += vo.unit_training_time * _trainList[i].make_number;
			}
			
			_build && _build.showTrainInfo(parseInt(time))
		}
		
		private static function sortFun(a:*, b:*):Number{
			return a.start_make_time > b.start_make_time ? 1 : -1
		}
	}
}