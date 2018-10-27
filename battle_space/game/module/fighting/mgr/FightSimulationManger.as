package game.module.fighting.mgr
{
	import game.common.ResourceManager;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.module.fighting.scene.FightingScene;
	
	import laya.net.Loader;
	import laya.utils.Handler;
	import laya.utils.Timer;

	public class FightSimulationManger
	{
		private static var _instance:FightSimulationManger;
		
		public static const HERO_CD_COST:int = 1;   //复活英雄的CD，每分钟的价格  （对应的表：unit_parameter  多余数据太多啦，不读了，就留这个值写入客户端常量）
		private var timer:Timer = new Timer();
		
		public function FightSimulationManger()
		{
			if(_instance){				
				throw new Error("FightSimulationManger是单例,不可new.");
			}
			
			Signal.intance.on(
				NewerGuildeEvent.GUIDE_ATTACK_FIRST_ACT,
				this,pushBu);
			_instance = this;
		}
		
		
		public static function get intance():FightSimulationManger
		{
			if(_instance)
				return _instance;
			_instance = new FightSimulationManger;
			
			
			return _instance;
		}
		
		public function sendData():void
		{
			if(lod)return ;
			lod = true;
			var jsonStr:String = "appRes/staticConfig/Simulation/chushi.json";
//			Laya.loader.load([{url:jsonStr,type:Loader.JSON}],Handler.create(this,loaderOver,[jsonStr]));
			Laya.loader.load([{url:jsonStr,type:Loader.JSON}],Handler.create(this,loaderOver,[jsonStr,false]));
		}
		
		public function loaderOver(jsonStr:String,isOpen:Boolean = false):void
		{
			lod = false;
			var obj:* = Loader.getRes(jsonStr);
			if(!obj)return ;
			var str:String = JSON.stringify(obj);
			str = StringUtil.substitute(str,User.getInstance().uid);
			obj = JSON.parse(str);
			Signal.intance.event(ServiceConst.getServerEventKey(obj[0]),obj);
			
			if(isOpen)
			{
				trace("加载第一步 虚拟");
				pushBu();
			}
		}
		
		public function disEvent():void
		{
//			return ;
			var buNum:Number = num - 1;
			if(buNum)
			{
				buNum -- ;
				
				if(buDataArr.length > buNum){
					var erData:* = buDataArr[buNum];
					trace("事件派发",NewerGuildeEvent.GUIDE_ATTACK_FINISH , erData);
					Signal.intance.event(NewerGuildeEvent.GUIDE_ATTACK_FINISH,erData);
				}
			}	
		}
		
		public function startData():void
		{
			if(lod)return ;
			lod = true;
			var jsonStr:String = "appRes/staticConfig/Simulation/start.json";
			Laya.loader.load([{url:jsonStr,type:Loader.JSON}],Handler.create(this,loaderOver,[jsonStr,true]));
//			timer.once(300,this,pushBu);
		}
		
		/**
		 *第一步数据 
		 */
		private var lod:Boolean;
		public function pushBu():void
		{
			if(lod)return ;
			lod = true;
			if(num == 4)
			{
				 var a="第四步";
			}
			var jsonStr:String = "appRes/staticConfig/Simulation/bu"+num+".json";
			Laya.loader.load([{url:jsonStr,type:Loader.JSON}],Handler.create(this,loaderOver,[jsonStr,false]));
			num ++ ;
		}
		
		private var num:uint = 1;
		
		private var buDataArr:Array = [
			[1,120,212,1],   //引导  1攻击 , 攻击者 ,目标  , 附加  1 首次攻击  2 普通  3 援军到来
			[6],      //敌人前排死绝，要BB
			[1,110,210,3],   //引导  1攻击 , 攻击者 ,目标  , 附加  1 首次攻击  2 普通  3 援军到来
		];
		
	}
}