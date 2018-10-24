package game.module.camp.data
{
	import game.global.GameConfigManager;
	import game.global.vo.AwakenVo;
	import game.global.vo.FightUnitVo;

	public class JueXingData
	{
		public var initData:Boolean = true;
		
		public var unitId:Number;
		private var _level:Number = 0;  //觉醒等级
		public var jihuoAr:Array = [0,0,0,0];  //激活状态
		public var uintId:Number = 0;
		public var features:Object = {};
		
		public function JueXingData(uid:Number)
		{
			unitId = uid;
		}
		
		public function get level():Number
		{
			return _level;
		}

		public function set level(value:Number):void
		{
			if(_level != value)
			{
				removerEqList();
				_level = value;
			}
		}

		public function setData(d:Object):void{
			this.level = Number(d.level);
			this.jihuoAr = d.slots;
			if(d.features)
				this.features = d.features;
		}
		
		public function get unitVo():FightUnitVo{
			return GameConfigManager.unit_dic[unitId];
		}
		
		public function get awakenVo():AwakenVo{
			var id:String = "";
			id = id + ( unitVo.isHero ? 1 : 2 );
			id = id + unitVo.defense_type;
			id = id + level;
			
			return GameConfigManager.awakenVoDic[id];
		}
		
		public function get isFull():Boolean{
			for (var i:int = 0; i < jihuoAr.length; i++) 
			{
				var num:Number = Number(jihuoAr[i]);
				if(!num)return false;
			}
			return true;
		}
		
		public function get isMax():Boolean{
			var nextVo:AwakenVo = GameConfigManager.awakenVoDic[ awakenVo.nextId ];
			return !nextVo;
		}
		
		private var _eqList:Array;
		public function get eqList():Array{
			
			if(!_eqList)
			{
				_eqList = [];
				for (var i:int = 0; i < awakenVo.awakenEqList.length; i++) 
				{
					var cAr:Array = [unitId , awakenVo.awakenEqList[i] , 0];
					_eqList.push(cAr);
				}
			}
			
			for (var j:int = 0; j < jihuoAr.length; j++) 
			{
				_eqList[j][2] = jihuoAr[j];
			}
			
			
			return _eqList;
		}
		
		public function removerEqList():void
		{
			_eqList = null;
		}
		
		
		private var _featuresList:Array ;
		
		public function get featuresList():Array{
			if(!_featuresList)
			{
				_featuresList = [];
				for (var i:int = 0; i < unitVo.featureAr.length; i++) 
				{
					var obj:Object = unitVo.featureAr[i];
					var ar:Array = [obj.id,obj.lv,0,unitId];
					_featuresList.push(ar);
				}
			}
			
			for (var j:int = 0; j < _featuresList.length; j++) 
			{
				var fid:Number = _featuresList[j][0];
				if(features[fid])
				{
					_featuresList[j][2] = Number(features[fid]);
				}
			}
			
			return _featuresList;
		}
		
	}
}