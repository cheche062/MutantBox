package game.global.vo
{
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.baseScene.SceneType;
	import game.global.ModuleName;
	import game.module.fighting.mgr.FightingStageManger;

	public class itemSourceVo
	{
		public var id:Number = 0;
		public var type:Number = 0;
		public var icon:String;
		public var des:String;
		public var state:Number = 1;
		private var _params:Array;
		
		public static var maxParam:Number = 10;
		
		
		
		public function itemSourceVo()
		{
			for (var i:int = 1; i <= maxParam; i++) 
			{
				this["param"+i] = null;
			}
		}
		
		public function get params():Array{
			if(!_params)
			{
				_params = [];
				for (var i:int = 1; i <= maxParam; i++) 
				{
					_params.push(this["param"+i]);
				}
			}
			return _params;
		}
		
		public function changeState():void
		{
			switch(type)
			{
				case 1:  //主线 ：章节ID ， 关卡ID
				case 2: //精英：章节ID ， 关卡ID
				{
					
//					params[1] = 42;
					var b:Boolean = FightingStageManger.intance.levelIsF(Number(params[1]), type == 2);
					state = b ? 1 : 0;	
					break;
				}

		}
		
		
	}
}