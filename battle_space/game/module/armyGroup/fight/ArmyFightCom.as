package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyGroupFightViewUI;
	
	import game.common.ResourceManager;
	
	import laya.net.Loader;
	import laya.utils.Handler;

	/**
	 * ArmyFightCom 军团战逻辑处理
	 * author:huhaiming
	 * ArmyFightCom.as 2017-11-28 下午4:16:21
	 * version 1.0
	 *
	 */
	public class ArmyFightCom
	{
		//
		private var _ui:ArmyGroupFightViewUI;
		//动画表现-攻方
		private var _attackers:Array = [];
		//动画表现-守方
		private var _defenders:Array = [];
		/**动画索引*/
		private var _index:int = 0;
		//表现动画个数
		private static const ACT_SIZE:int = 3;
		/**表现时长*/
		public static const SHOW_TIME:Number = 3600;
		/**切分次数*/
		private static const TIMES:int = 3;
		public function ArmyFightCom(ui:ArmyGroupFightViewUI)
		{
			_ui = ui;
			for(var i:int=0; i<ACT_SIZE; i++){
				_attackers.push(new ArmyFightRole(_ui["att_"+i], "gf_attacker"));
				_defenders.push(new ArmyFightRole(_ui["den_"+i], "gf_defender"));
			}
		}
		
		/**
		 * 格式化战斗数据
		 * @param data [[[1,336],[0,11208]],[[1,406],[0,10674]],[[1,118],[0,10977]]];
		 * */
		public function format(data:Array):void{
			trace("format:::",data);
			var info:Array;
			for(var i:int=0; i<ACT_SIZE; i++){
				info = data[i];
				if(info){
					_attackers[i].format(info[0], TIMES);
					_defenders[i].format(info[1], TIMES);
				}else{
					_attackers[i].format(null);
					_defenders[i].format(null);
				}
			}
			//启动计算时间
			//
			var jsonStr:String = ResourceManager.instance.setResURL("imageFont/redMax.json");
			Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,doAction));
		}
		
		public function reset():void{
			for(var i:int=0; i<ACT_SIZE; i++){
				_attackers[i].reset();
				_defenders[i].reset();
			}
		}
		
		private function doAction():void{
			//todo，上次的数据处理
			_index = 0;
			Laya.timer.clear(this, this.onDoAct);
			Laya.timer.loop(SHOW_TIME/TIMES/2, this, this.onDoAct);
		}
		
		private function onDoAct():void{
			var arr:Array = _attackers;
			if(_index %2 == 0){
				for(var i:int=0; i<ACT_SIZE; i++){
					_defenders[i].doAction();
					_attackers[i].showAction(ArmyFightRole.ATTACK)
				}
			}else{
				for(i=0; i<ACT_SIZE; i++){
					_attackers[i].doAction();
					_defenders[i].showAction(ArmyFightRole.ATTACK)
				}
			}
			
			_index ++;
			if(_index >= TIMES*2){
				for(i=0; i<ACT_SIZE; i++){
					_attackers[i].out();
					_defenders[i].out();
				}
				Laya.timer.clear(this, this.onDoAct);
			}
		}
	}
}