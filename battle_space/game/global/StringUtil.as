/***
 *作者：罗维
 */
package game.global
{
	public class StringUtil
	{
		public function StringUtil()
		{
			
		}
		
		public static function removeBlank(char:String):String
		{
			if (char == null)
			{
				return null;
			}
			var pattern:RegExp = /(^\s*)|(\s*$)/g;
			return char.replace(pattern, "");
		}        
		
		public static function substitute(str:String , ... args):String{
			if(!args.length)
				return str;
			
			var pattern:RegExp = /{(\d+)}/g;
			
			if (args.length > 0) {
				str = (str+"").replace(pattern, function ():String {
					return args[arguments[1]];
				});
			}
			return str;
		}
	}
}