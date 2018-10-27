package game.module.camp
{
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.data.DBUnit;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.FightUnitVo;
	import game.global.vo.User;
	import game.global.vo.teamCopy.TeamFightUnitVo;
	import game.module.tips.KpiUpView;
	import game.net.socket.WebSocketNetService;
	
	import laya.ani.bone.Bone;
	
	import org.hamcrest.mxml.collection.InArray;

	/**
	 * CampData 兵营数据
	 * author:huhaiming
	 * CampData.as 2017-5-17 上午11:12:02
	 * version 1.0
	 *
	 */
	public class CampData
	{
		/**单位数据池*/
		private static var _unitData:Object;
		private static var _callback:Function;
		private static var _target:Object;
		private static var _curId:*;
		/**事件-数据更新*/
		public static const UPDATE:String = "update"
		public function CampData()
		{
		}
		
		/**更新池数据*/
		public static function update(info:Object=null):void{
			if(!info){
				Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.C_INFO),null,onResult);
				WebSocketNetService.instance.sendData(ServiceConst.C_INFO, null);
				return;
			}
			if(!_unitData){
				_unitData = {};
			}
			for(var i:String in info.hero_list){
				_unitData[i] = info.hero_list[i];
			}
			for(i in info.solier_list){
				_unitData[i] = info.solier_list[i];
			}
			trace("后端兵营数据:"+JSON.stringify(info));
			trace("更新_unitData:"+JSON.stringify(_unitData));
			caculateKpi();
			Signal.intance.event(UPDATE);
			trace("更新!!!!!!!!");
		}
		
		/**计算kpi*/
		private static function caculateKpi():void{
			//计算KPI
			var originalKpi:int = User.getInstance().KPI;
			var kpi:int = 0;
			for(var i:String in _unitData){
				if(_unitData[i] && _unitData[i].power){
					kpi += _unitData[i].power
				}
			}
			User.getInstance().KPI = kpi;
			
			//显示KPI变化
			var delKpi:int = User.getInstance().KPI - originalKpi;
			if(originalKpi && delKpi != 0){
				XFacade.instance.showModule(KpiUpView, delKpi)
			}
		}
		
		/**更新单个数据*/
		public static function updateUnit(id:*,info:Object=null):void{
			if(_unitData){
				_unitData[id] = info;
				caculateKpi();
				Signal.intance.event(UPDATE);
			}
		}
		
		/**
		 * 获取单位数据，异步回调方式
		 * @param unitId 单位id
		 * @param callback 回调函数
		 * @param target 回调函数对象
		 */
		public static function getUnitInfo(unitId:*, target:Object, callback:Function):void{
			if(_unitData){
				callback.apply(target, [_unitData[unitId]]); 
			}else{
				callback = callback;
				_target = target;
				_curId = unitId;
				Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.C_INFO),null,onResult);
				WebSocketNetService.instance.sendData(ServiceConst.C_INFO, null);
			}
		}
		
		/**
		 * 同步获取数据,是否有数据不考虑
		 */
		public static function getUintById(unitId:*):Object{
//			trace("dadada0101:"+unitId);
//			trace("_unitData:"+JSON.stringify(_unitData));
//			trace("_unitData[unitId]"+JSON.stringify(_unitData[unitId]));
			var d:Object = _unitData ? _unitData[unitId] : null;
//			trace("d112121:"+JSON.stringify(d));
			return 	d;
		}
		
		/**
		 * 判断是否拥有某个单位,必须在获取数据源之后才有效.
		 * */
		public static function hasUnit(unitId:*):Boolean{
			return _unitData && _unitData[unitId]
		}
		
		/**
		 * 根据类型获取数据
		 * @param unitType 单位类型,1英雄，2兵
		 * @param armType 护甲类型，如果英雄或者小兵护甲类型为-1，则不考虑(护甲类型（1重甲，2中甲，3轻甲，4无甲）)
		 * */
		public static function getUnitList(unitType:int, armType:int = -1):Array{
			var vo:FightUnitVo
			var arr:Array = [];
			for(var i:String in _unitData){
				vo = GameConfigManager.unit_dic[i];
				if(vo.unit_type == unitType){
					if(unitType == 2){
						if(armType == -1){
							arr.push(_unitData[i]);
						}else{
							if(armType == vo.defense_type){
								arr.push(_unitData[i]);
							}
						}
					}else{
						arr.push(_unitData[i]);
					}
				}
			}
			return arr;
		}
		
		/**
		 * 根据攻击类型获取兵种列表（1爆炸，2穿透，3普通，4近战）
		 * @param	attType
		 * @return
		 */
		public static function getUnitListByAttType(attType:int):Array
		{
			var vo:FightUnitVo
			var arr:Array = [];
			for (var i:String in _unitData)
			{
				vo = GameConfigManager.unit_dic[i];
				if (vo.unit_type == 2 && attType == vo.attack_type)
				{
					arr.push(_unitData[i]);
				}
			}
			return arr;
		}
		
		/**
		 * 
		 */
		public static function getTeamFightUnitList(unitType:int,armType:int, p_str:String,p_arr:Array):Array
		{
			var l_strArr:Array=p_str.split(":");
			var vo:FightUnitVo
			var arr:Array = [];
			for(var i:String in _unitData){
				vo = GameConfigManager.unit_dic[i];
				var l_data:TeamFightUnitVo=new TeamFightUnitVo();
				l_data.id=vo.unit_id;
				l_data.sn=true;
				l_data.baseInfo=_unitData[i];
				var l_num:int=sortTeamfightUnit(vo,p_arr,_unitData[i].have_number)
				if(l_num>=0)
				{
					l_data.num=l_num;
					if(vo.unit_type == unitType||unitType==-1){
						if(unitType == 2||(unitType==-1&&vo.unit_type==2)){
							l_data.herouse=-1;
							if(parseInt(l_strArr[0])==7)
							{
								if(parseInt(l_strArr[1]) != vo.attack_type)
								{
									l_data.conform=true;
								}
							}
							else if(parseInt(l_strArr[0])==8)
							{
								if(parseInt(l_strArr[1]) != vo.defense_type)
								{
									l_data.conform=true;
								}
							}
							else if(parseInt(l_strArr[0])==9)
							{
								if(parseInt(l_strArr[1]) == vo.attack_type)
								{
									l_data.conform=true;
								}
							}
							else if(parseInt(l_strArr[0])==10)
							{
								if(parseInt(l_strArr[1]) == vo.defense_type)
								{
									l_data.conform=true;
								}
							}
							if(armType == -1){
								arr.push(l_data);
							}else{
								if(armType == vo.defense_type){
									arr.push(l_data);
								}
							}
						}else if(unitType ==1||(unitType==-1&&vo.unit_type==1)){
							var rebornTime:int = _unitData[i].cdTime*1000 - TimeUtil.now;
							if(_unitData[i].used==0)
							{
								l_data.conform=true;
							}
							arr.push(l_data);
						}
					}
				}
			}
			arr.sort(sortPowerHandler);
			
			
			arr.sort(sortTeamFightHandler);
			return arr;
		}
		
		private static function sortPowerHandler(p_a:TeamFightUnitVo,p_b:TeamFightUnitVo)
		{
			if(p_a.baseInfo.power>p_b.baseInfo.power)
			{
				return -1;
			}
			else
			{
				return 0;
			}
			return 0;
		}
		
		
		/**
		 * 
		 */
		private static function sortTeamFightHandler(p_a:TeamFightUnitVo,p_b:TeamFightUnitVo)
		{
			if(p_a.conform==false && p_b.conform==true)
			{
				return 1;
			}
			else if(p_a.conform==true && p_b.conform==false)
			{
				return -1;
			}
			else if(p_a.conform==true && p_b.conform==true)
			{
				if(p_a.baseInfo.power>p_b.baseInfo.power)
				{
					return -1;
				}
				else
				{
					return 1;
				}
			}
			else if(p_a.conform==false && p_b.conform==false)
			{
				if(p_a.baseInfo.power>p_b.baseInfo.power)
				{
					return -1;
				}
				else
				{
					return 1;
				}
			}
			return 0;
		}
		
		
		/**
		 * 
		 */
		public static function getTeamCopyUnitList(unitType:int, p_str:String,p_arr:Array,p_isAuto:Boolean=false):Array
		{
			var l_strArr:Array=p_str.split(":");
			var vo:FightUnitVo
			var arr:Array = [];
			for(var i:String in _unitData){
				vo = GameConfigManager.unit_dic[i];
					if(sortUseUnit(vo,p_arr,_unitData[i].have_number))
					{
						if(vo.unit_type == unitType){
							if(unitType == 2 && _unitData[i].have_number>0){
								if(parseInt(l_strArr[0])==7)
								{
									if(parseInt(l_strArr[1]) != vo.attack_type)
									{
										arr.push(_unitData[i]);
									}
								}
								else if(parseInt(l_strArr[0])==8)
								{
									if(parseInt(l_strArr[1]) != vo.defense_type)
									{
										arr.push(_unitData[i]);
									}
								}
								else if(parseInt(l_strArr[0])==9)
								{
									if(parseInt(l_strArr[1]) == vo.attack_type)
									{
										arr.push(_unitData[i]);
									}
								}
								else if(parseInt(l_strArr[0])==10)
								{
									if(parseInt(l_strArr[1]) == vo.defense_type)
									{
										arr.push(_unitData[i]);
									}
								}
							}else if(unitType ==1){
								if(p_isAuto==true)
								{
									var rebornTime:int = _unitData[i].cdTime*1000 - TimeUtil.now;
									if(_unitData[i].used==0 &&rebornTime<=0)
									{
										arr.push(_unitData[i]);
									}
								}
								else
								{
									arr.push(_unitData[i]);
								}
							}
						}
					}
			}
			arr.sort(sortHandler);
			return arr;
		}
		
		private static function sortHandler(p_objA:Object,p_objB:Object)
		{
			if(p_objA.power>p_objB.power)
			{
				return -1;
			}
			return 1;
			
		}
		
		private static function sortTeamfightUnit(p_vo:FightUnitVo,p_arr:Array,p_has_number:int):int
		{
			
			var useNum:int=0;
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				if(p_arr[i]!=null)
				{
					if(parseInt(p_vo.unit_id)==parseInt(p_arr[i].unitId))
					{
						useNum++;
					}
				}
			}
			if(p_vo.unit_type==1)
			{
				p_has_number=0;
			}
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				if(p_arr[i]!=null)
				{
					if(p_vo.unit_type==1)
					{
						if(parseInt(p_vo.unit_id)==parseInt(p_arr[i].unitId))
						{
							return -1;
						}
					}
					else
					{
						if(parseInt(p_vo.unit_id)==parseInt(p_arr[i].unitId))
						{
							if(p_has_number<=useNum)
							{
								return 0;
							}
						}
					}
				}
			}
			return p_has_number-useNum;
		}
		
		
		
		
		private static function sortUseUnit(p_vo:FightUnitVo,p_arr:Array,p_has_number:int):Boolean
		{
			var useNum:int=0;
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				if(p_arr[i]!=null)
				{
					if(parseInt(p_vo.unit_id)==parseInt(p_arr[i].unitId))
					{
						useNum++;
					}
				}
			}
			for (var i:int = 0; i < p_arr.length; i++) 
			{
				if(p_arr[i]!=null)
				{
					if(p_vo.unit_type==1)
					{
						if(parseInt(p_vo.unit_id)==parseInt(p_arr[i].unitId))
						{
							return false;
						}
					}
					else
					{
						if(parseInt(p_vo.unit_id)==parseInt(p_arr[i].unitId))
						{
							if(p_has_number<=useNum)
							{
								return false;
							}
						}
					}
				}
			}
			return true;
		}

		/**自动上阵逻辑*/
		public static function autoBattleHandler(p_index:int,p_str:String,p_arr:Array,p_isMaster:Boolean, index:InArray=0):Object
		{
			var arr:Array = [];
			if(p_index==1)
			{
				if(p_isMaster==true)
				{
					arr=getTeamCopyUnitList(1,p_str,p_arr,true);
					if(arr.length<=0)
					{
						arr=getTeamCopyUnitList(2,p_str,p_arr,true);
					}
					index = Math.min(index, arr.length-1);
					return arr[index];
				}
				else
				{
					arr=getTeamCopyUnitList(2,p_str,p_arr,true);
					index = Math.min(index, arr.length-1);
					return arr[index];
				}
			}
			else if(p_index==2)
			{
				arr=getTeamCopyUnitList(2,p_str,p_arr,true);
				index = Math.min(index, arr.length-1);
				return arr[index];
			}
			else
			{
				arr=getTeamCopyUnitList(2,p_str,p_arr,true);
				index = Math.min(index, arr.length-1);
				return arr[index];
			}
			return null;
		}
		
		private static function getRanKey(arr:Array):int{
			var len:int = arr.length;
			return Math.ceil(Math.random()*len-1)+1;
		}
		
		
		
		private static function onResult(...args):void{
			update(args[1]);
			if(_callback != null){
				_callback.apply(_target,[_unitData[_curId]]);
				_callback = null;
				_target = null;
			}
			
			//ton
			DBUnit.isAnyCanUp();
		}
	}
}