/***
 *作者：罗维
 */
package game.module.fighting.adata
{
	import game.global.fighting.BaseUnit;
	import game.module.fighting.scene.FightingScene;
	
	import laya.utils.Pool;

	public class ActionData
	{
		public static const ACTION_PLAY:uint = 1;  //常规动画
		public static const ACTION_HPCHANGE_ADD:uint = 201;  //血量变化 增
		public static const ACTION_HPCHANGE_DEL:uint = 202;  //血量变化 减
		public static const ACTION_NEWHP:uint = 203;  //血量变化 设置
		public static const ACTION_DODGED:uint = 3; //闪躲
		public static const ACTION_ADDBUFF:uint = 4; //新增buff特效
		public static const ACTION_CHANGEBUFF:uint = 401; //改变BUFF
		public static const ACTION_UNITCHANGE:uint = 5; //变身
		public static const ACTION_SHOWSKILLEFFECT:uint = 6; //添加技能特效
		public static const ACTION_PLAY_MUSIC:uint = 7; //音效
		public static const ACTION_POS_CHANGE:uint = 8; //击退
		public static const ACTION_INVINCIBLE:uint = 9; //无敌
		public static const ACTION_ABSORBED:uint = 10; //吸收
		public static const ACTION_DELUNIT:uint = 11;  //移除单位
		public static const ACTION_VIBRATION:uint = 12; //抖屏
		public static const ACTION_SPOTLIGHT:uint = 13; //角色特写
		public static const ACTION_UNIT_ADD:uint = 14; //添加角色
		public static const ACTION_UNIT_ALPHA:uint = 15; //透明度变化
		
		public static const ACTIONDATA_SIGN:String = "ACTIONDATA_SIGN";
		
		public var waitTimer:uint = 0;
		public var endTimer:uint = 1;
		public var actionType:int = ACTION_PLAY;
		public var data:*;
		
		public var nextActionData:ActionData;
		
		public function ActionData()
		{
			
		}
		
		public static function create(_waitTimer:uint = 0 ,_endTimer:uint = 1, _actionType:uint = 1 ,_data:* = null):ActionData
		{
//			var v:ActionData = Pool.getItemByClass(ACTIONDATA_SIGN,ActionData);
			var v:ActionData = new ActionData();
			v.waitTimer = _waitTimer;
			v.endTimer = _endTimer;
			v.actionType = _actionType;
			v.data = _data;
			return v;
		}
		
		public function clear():void
		{
			Laya.timer.once(30000,this,destroy);
		}
		
		public function destroy():void{
			//trace(1,"destroy ActionData");
			this.data = null;
//			Pool.recover(ACTIONDATA_SIGN,this);
		}
		
		public function copy():void
		{
			var rv:ActionData = create(waitTimer,endTimer,actionType,data);
			rv.nextActionData = this.nextActionData;
			return rv;
		}
		
		public function stopAction(_scene:FightingScene):void
		{
			if(actionType == ACTION_PLAY)
			{
				if(data)
				{
					var uitem:BaseUnit = _scene.getUnitByPoint(data[0]);
					if(uitem){
						uitem.stopFrame();
						//trace(1,"清理动作后续",uitem.Action,uitem.data.showPointID);
					}
				}
				
			}
			if(nextActionData)nextActionData.stopAction(_scene);
		}
		
		
	}
}