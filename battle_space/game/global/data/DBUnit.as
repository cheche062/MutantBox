package game.global.data
{
	import game.global.GameConfigManager;
	import game.global.consts.ItemConst;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.BagManager;
	import game.global.data.bag.ItemData;
	import game.global.event.BagEvent;
	import game.global.event.Signal;
	import game.global.vo.AwakenEqVo;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	import game.global.vo.relic.TransportBookVo;
	import game.module.camp.CampData;
	import game.module.camp.data.JueXingData;
	import game.module.camp.data.JueXingMange;
	import game.net.socket.WebSocketNetService;
	
	import laya.utils.Browser;
	import laya.utils.Handler;

	/**
	 * DBUnit
	 * author:huhaiming
	 * DBUnit.as 2017-7-8 下午1:52:26
	 * version 1.0
	 *
	 */
	public class DBUnit
	{
		/**类型-英雄*/
		public static const TYPE_HERO:int = 1;
		/**类型-士兵*/
		public static const TYPE_SOLDIER:int = 2;
		/**事件-可操作状态变化->兵种可以觉醒或者升星*/
		public static const CHANGE:String = "dbuint_change_starup";
		/**事件-可操作状态变化->兵种可升级*/
		public static const CHANGE1:String = "dbuint_change_levelup";
		public function DBUnit()
		{
		}
		
		/**获取单位数据源*/
		public static function getUnitInfo(uid:*):Object{
			return GameConfigManager.unit_json[uid]
		}
		
		/**
		 *初始化觉醒数据 
		 * 
		 */
		public static function initAwake():int
		{
			if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) < 2)
			{
				return 0;
			}

			var tmp:Object;
			var uid:*;
			for(var i:String in GameConfigManager.unit_json){
				tmp = GameConfigManager.unit_json[i];
				uid = tmp.unit_id;
				var _jxd:JueXingData;
				_jxd= JueXingMange.intance.getJueXingDataByUid(uid);	
			}
			//等待兵种觉醒信息完全初始化
			for(var i:String in GameConfigManager.unit_json){
				tmp = GameConfigManager.unit_json[i];
				uid = tmp.unit_id;
				var _jxd:JueXingData;
				_jxd= JueXingMange.intance.getJueXingDataByUid(uid);
				if(CampData.getUintById(uid) && _jxd.initData)
				{
					trace("uid:"+uid+"未能初始化");
					return 1;
				}
			}
			return 2;
		}
		/**
		 *检测是否兵种是否觉醒 
		 * @return 
		 * 
		 */
		public static function checkAwake():Boolean
		{
			//兵营等级小于2级，觉醒没有开放
			if(User.getInstance().sceneInfo.getBuildingLv(DBBuilding.B_CAMP) < 2)
			{
				trace("兵营等级小于2级");
				return false;
			}
			var tmp:Object;
			var uid:*;
			var num:int = 0;
//			//等待兵种觉醒信息完全初始化
//			for(var i:String in GameConfigManager.unit_json){
//				tmp = GameConfigManager.unit_json[i];
//				uid = tmp.unit_id;
//				var _jxd:JueXingData;
//				_jxd= JueXingMange.intance.getJueXingDataByUid(uid);
//				if(CampData.getUintById(uid) && _jxd.initData)
//				{
//					if(num<20)//最多执行20次
//					{
//						//延时执行
//						trace("延时执行:uid="+uid);
//						Laya.timer.once(50,null,checkAwake);
//						num++;
//						return ;
//					}
//				}
//			}
			//确认兵种完全初始化后
			var propOkUidArr:Array = [];
			for(var i:String in GameConfigManager.unit_json){
				tmp = GameConfigManager.unit_json[i];
				uid = tmp.unit_id;
				var _jxd:JueXingData;
				if(CampData.getUintById(uid))
				{
					_jxd= JueXingMange.intance.getJueXingDataByUid(uid);	
					var max:Boolean = _jxd.isMax;
					var ifFull:Boolean = _jxd.isFull;
					var ar:Array =  _jxd.eqList;
					var vo:AwakenEqVo;
					trace("ar:"+JSON.stringify(ar));
					var curUitOk:Boolean = true;
//					trace("uid:"+uid+"max:"+max);
					var isExitNext = _jxd.awakenVo.costList;
					if (isExitNext) {
						var costData = _jxd.awakenVo.costList[0];
						var itemNum:Number = User.getInstance().getResNumByItem(costData.iid);
						if(itemNum < costData.inum)
						{
//							trace("uid"+uid+"觉醒道具数量不足");
							continue;
						}
					}else 
					{
//						trace("uid:"+uid+"达到最大觉醒等级");
						continue;
					}
					if(!ifFull)
					{
						for each(var data:Array in ar)
						{
							vo = data[1];
							var states:Array = vo.getStates(uid);
							if(states.length>0)//必须都满足条件，才可能存在兵种觉醒
							{//不满足
//								trace("uid:"+uid+"不满足");
								curUitOk = false;
								
								break;
							}
						}
						if(curUitOk)
						{
							propOkUidArr.push(uid);
						}
					}else
					{
						propOkUidArr.push(uid);
					}
				
				}
			}
//			trace("propOkUidArr"+propOkUidArr);
			if(propOkUidArr.length>0)
			{
				return true;
			}else
			{
//				trace("uid:"+uid+"没有满足觉醒条件的兵种");
				return false;
			}
		}
		/**
		 * 检测是否任意兵种升星
		 * @param uid
		 * 
		 */
		public static function checkStarUp():Boolean
		{
			var tmp:Object;
			const typeList:Array = ["1","2"];
			for(var i:String in GameConfigManager.unit_json){
				tmp = GameConfigManager.unit_json[i];
				if(typeList.indexOf(tmp.unit_type) != -1  && DBUnit.check(tmp.unit_id) > 1){
					trace("可以升星");
					Signal.intance.event(CHANGE, true);
					return true;
				}
			}
			Signal.intance.event(CHANGE, false);
			return false
		}
		/**
		 * 检测兵种是否升星
		 * @param uid
		 * @return 
		 * 
		 */
		public static function check(uid:*):int{
			var data:Object = CampData.getUintById(uid);
			var order:int = 1;
			if(!data){
//				trace("data不存在");
				order = 0;
				data = GameConfigManager.unit_json[uid];
				if(data.visible == 0){
//					trace("zzzzzzzzzzzzzz");
					return 0
				}
			}
//			trace("data存在");
			var starid:* = (data.star_id || data.starId);
			var starInfo:Object = DBUnitStar.getStarData(starid);
			//trace("uid:", uid);
			var arr:Array = BagManager.instance.getItemListByIid((starInfo.star_cost+"").split("=")[0]);
			if(!arr){
				arr = [];
			}
			var num:Number = 0;
			for(var i:int=0; i<arr.length; i++){
				num += parseInt(ItemData(arr[i]).inum+"")
			}
			
			var actNum:Number = (starInfo.star_cost+"").split("=")[1];
			if(data.condition){//是需要激活
				var tmp:Array = (data.condition+"").split("|");
				for(var j:String in tmp){
					if((tmp[j]+"").indexOf("B") == -1){
						tmp = (tmp[j]+"").split("=");
						actNum = tmp[1]
						break;
					}
				}
			}
			if(actNum){
				if(num < actNum){
					return order;
				}else{
					return 2;
				}
			}
			return order;
		}
		
		/**检测是否有能觉醒或升星的单位，用于兵营上方提示*/
		public static function isAnyCanUp():void{
			//背包数据
		

			num=0;
			var list:Array = BagManager.instance.getItemListByType([ItemConst.ITEM_TYPE_SOLDIER]);
			if(!list){
				Signal.intance.once(BagEvent.BAG_EVENT_INIT, null, doCheck);
			}else{
				doCheck();
			}
		}
		/**检测是否有兵种是否有升级的单位，用于雷达上方提示*/
		public static function isRadioCanUp():void{
			//背包数据
			var list:Array = BagManager.instance.getItemListByType([ItemConst.ITEM_TYPE_SOLDIER]);
			if(!list){
				Signal.intance.once(BagEvent.BAG_EVENT_INIT, null, docheckLevel);
			}else{
				docheckLevel();
			}

		}
		
		private static function docheckLevel():void
		{
			var a:Boolean = checkLevel()
//			trace("aaaaaa:"+a);
			
			if(checkLevel())
			{
				//				trace("弹出提示");
				Signal.intance.event(CHANGE1, true);
				return;
			}
			Signal.intance.event(CHANGE1, false);
		}
		
		/**
		 * 检测兵种是否升级
		 */
		private static function checkLevel():Boolean 
		{
			// TODO Auto Generated method stub
			var tmp:Object;
			var uid:*;
			for(var i:String in GameConfigManager.unit_json){
				tmp = GameConfigManager.unit_json[i];
				uid = tmp.unit_id;
				var data:Object = CampData.getUintById(uid);
//				trace("data111:"+JSON.stringify(data));
				if(data)
				{
					if(data.level&&data.level<	User.getInstance().level)
					{
						GameConfigManager.intance.getTransport();
						var l_arr:Array=BagManager.instance.getItemListByType([18]);
						var l_vo:ItemData
//						trace("l_arr:"+l_arr);
//						trace("data111:"+JSON.stringify(data));
						var l_fightUnit:FightUnitVo=GameConfigManager.unit_dic[uid];
						var l_heroType:int=0;
						if(l_fightUnit.unit_type==1)
						{
							l_heroType=5;
						}
						else
						{
							l_heroType=l_fightUnit.defense_type;
					
						}
						if(l_arr!=null)
						{
							for (var m:int = 0; m < GameConfigManager.TransportBookList.length; m++) 
							{
								var l_bookVo:TransportBookVo=GameConfigManager.TransportBookList[m];
								var num:Number;
								for (var j:int = 0; j < l_arr.length; j++) 
								{
									l_vo=l_arr[j];
									if(l_bookVo.id==l_vo.iid&&l_bookVo.type == l_heroType)
									{
										num=BagManager.instance.getItemNumByID(l_vo.iid);
										if(num>0)
										{
											return true;
										}
									}
								}
							}
						}
					}
				}
			}
			return false;//所有兵种都达到等级上限，或者材料都用
		}
		/**
		 *检测兵种是否升星或者觉醒 
		 * 
		 */
		public static var num:int=0;
		public static function doCheck():void{
//			if(initAwake()==1&&num<20)
//			{
//				num++;
//				trace("延时调用");
//				Laya.timer.once(50,null,doCheck);
//				return;
//			}

			if(checkStarUp())
			{
				Signal.intance.event(CHANGE, true);  
				return;
			}
			Signal.intance.event(CHANGE, false);
		}
	}
}