package game.module.fighting
{
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Handler;

	/**
	 * FightUtil 战斗辅助类
	 * author:huhaiming
	 * FightUtil.as 2017-12-7 下午2:52:41
	 * version 1.0
	 *
	 */
	public class FightUtil
	{
		private static const HERO_CD_COST:int = 1;   //复活英雄的CD，每分钟的价格  （对应的表：unit_parameter  多余数据太多啦，不读了，就留这个值写入客户端常量）
		private static var _outACDOverH:Handler;
		public function FightUtil()
		{
		}
		
		/**
		 *复活英雄
		 *uuid  英雄ID
		 *t    剩余复活时间（毫秒） 
		 *overH 复活成功后处理函数
		 */
		public static function outArmyCd(uuid:Number,t:Number,overH:Handler = null):void{
			_outACDOverH = overH;
			t = Math.ceil(t / 1000 / 60)*2;
			var alertStr:String = GameLanguage.getLangByKey("L_A_914");
			var mitem:ItemData = new ItemData();
			mitem.iid = DBItem.WATER;
			mitem.inum = t * HERO_CD_COST;
			
			ConsumeHelp.Consume([mitem],Handler.create(null,outArmyCdAlertBack,[uuid]),alertStr);
		}
		
		private static function outArmyCdAlertBack(uuid:Number):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_ARMY_CD_CONST,[uuid]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.FIGHTING_ARMY_CD_CONST),null,outArmyCdBack);
		}
		
		
		private static function outArmyCdBack(... args):void{
			Signal.intance.off(ServiceConst.getServerEventKey(args[0]),null,outArmyCdBack);
			
			var uuid:Number = args[1];
			
			if(_outACDOverH){
				_outACDOverH.runWith(uuid);
				_outACDOverH.recover();
				_outACDOverH = null;
			}
		}
	}
}