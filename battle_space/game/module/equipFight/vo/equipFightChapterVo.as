package game.module.equipFight.vo
{
	import game.global.GameConfigManager;
	import game.global.vo.FightUnitVo;
	import game.module.bag.mgr.ItemManager;

	public class equipFightChapterVo
	{
		public var id:Number;
		public var hero:Number;
		public var pre_chapter:Number;
		public var chapter_name:String;
		public var icon:String;
		public var icon1:String;
		public var icon2:String;
		public var population:Number;
		public var hero_num:Number;
		public var open_level:Number;
		public var preview:String;
		
		private var _levelList:Array;
		
		
		private var _showReward:Array;
		
		public function equipFightChapterVo()
		{
		}
		
		
		
		public function get unitVo():FightUnitVo{
			return GameConfigManager.unit_dic[hero];
		}

		public function get levelList():Array
		{
			if(!_levelList)
			{
				_levelList = [];
				var ar:Array = GameConfigManager.equipFightLevelVos;
				for (var i:int = 0; i < ar.length; i++) 
				{
					var vo:equipFightLevelVo = ar[i];
					if(vo.chapter_id == this.id)
						_levelList.push(vo);
				}
				
			}
			
			return _levelList;
		}
		
		
		public function get showReward():Array
		{
			if(!_showReward)
			{
				_showReward = ItemManager.StringToReward(preview);
			}
			return _showReward;
		}

	}
}