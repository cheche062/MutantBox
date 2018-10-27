package game.global.vo
{
	public class LangCigVo
	{
		
		public var id:Number = 0;
		public var name:String;
		public var des:String;
		public var langName:String;
		public var testWord:String;
		public var kaifu:String;
		public var muti_language:String;
		private var _fontList:Array;
		private var _sizeList:Array;
		private var maxFont:Number = 4;
		
		
		public function LangCigVo()
		{
			for (var i:int = 1; i <= maxFont; i++) 
			{
				this["font"+i] = "";
				this["size"+i] = 0;
			}
			
		}

		public function get sizeList():Array
		{
			if(!_sizeList)
			{
				_sizeList = [];
				for (var i:int = 1; i <= maxFont; i++) 
				{
					_sizeList.push(this["size"+i]);
				}
			}
			return _sizeList;
		}

		public function get fontList():Array
		{
			if(!_fontList)
			{
				_fontList = [];
				for (var i:int = 1; i <= maxFont; i++) 
				{
					_fontList.push(this["font"+i]);
				}
			}
			return _fontList;
		}

	}
}