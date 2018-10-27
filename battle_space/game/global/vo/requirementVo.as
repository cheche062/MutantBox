package game.global.vo
{
	import game.global.GameLanguage;
	import game.module.bag.mgr.ItemManager;

	public class requirementVo
	{
		
		public var rq:String ;  // 通关条件
		public var rq_text:String; //通关条件
		public var text_canshu:String;  //通关条件参数
		public var points:Number;  //通关条件积分
		public var reward:String; // 通关条件奖励
		public var show_reward:String;  //展示扫荡奖励
		
		
		private var _reward:Array;  
		private var _canshu:Array;
		private var _showReward:Array; 
		
		
		public function requirementVo()
		{
			
		}
		
		public function get showReward():Array
		{
			if(!_showReward)
			{
				_showReward = ItemManager.StringToReward(show_reward);
			}
			return _showReward;
		}

		public function get stageReward():Array
		{
			if(!_reward)
			{
				_reward = ItemManager.StringToReward(reward);
			}
			return _reward;
		}
		
		public function get canshu():Array
		{
			if(!_canshu)
			{
				_canshu = [];
				if(text_canshu && text_canshu.length)
				{
					var ar:Array = text_canshu.split("|");
					for (var i:int = 0; i < ar.length; i++) 
					{
						_canshu.push( GameLanguage.getLangByKey(ar[i]));
					}
				}
			}
			return _canshu;
		}
	}
}