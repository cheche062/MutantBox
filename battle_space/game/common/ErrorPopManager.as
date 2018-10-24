package game.common
{
	import game.global.GameInterface.IGameDispose;
	
	import laya.ani.swf.MovieClip;
	import laya.ui.Label;
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	import laya.utils.Tween;

	/**
	 * 错误信息控制类 
	 * @author zhangmeng
	 * 
	 */	
	public class ErrorPopManager implements IGameDispose
	{
		
		private static var _instance:ErrorPopManager;
		
		public static function get instance():ErrorPopManager{
			if(!_instance){
				_instance=new ErrorPopManager();
			}
			return _instance;
		}
		/**
		 * 错误信息存储 
		 */		
		public var errData:Dictionary;
		
		private var _curErrTxt:String="";
		
		public function ErrorPopManager()
		{
		}
		//初始化错误信息数据
		public function initErrData():void{
			var _data:Object=ResourceManager.instance.getResByURL("config/error.json");
			errData=new Dictionary();
			for(var a:* in _data){
				errData.set(_data[a]["ID"],_data[a]["words"]);
				//errData[_data[a]["ID"]]=_data[a]["words"];
			}
			this.errData=errData;
		}
		/**
		 * 显示错误信息 (暂用)
		 * @param id
		 * 
		 */		
		public function showErrorWord(id:int):void{
			if(this.errData.get(id)){
				_curErrTxt=this.errData.get(id+"");
			}else{
				_curErrTxt=""+id;
			}
//			this.showErrByString(_curErrTxt);
		}
		/**
		 *通过字符显示错误信息 
		 * @param value
		 * 
		 */		
		public function showErrByString(value:String):void{
			_curErrTxt=value;
			var _txt:Label=new Label(_curErrTxt);
			_txt.width=300;
			_txt.align="center";
			_txt.height=40;
			_txt.fontSize=26;
			_txt.color="#ff0000";
			_txt.mouseEnabled=false;
			_txt.cacheAsBitmap=true;
			_txt.strokeColor="#000000";
			_txt.stroke=0.5;
			
			Laya.stage.addChild(_txt);
			_txt.x=(Laya.stage.width-_txt.width)/2;
			_txt.y=(Laya.stage.height-_txt.height)/2;
			Tween.to(_txt,{y:_txt.y-100,alpha:0},500,null,Handler.create(this,completeHandler,[_txt]),1000);
		}
		
		//缓动完成后删除文字
		private function completeHandler(value:Label):void{
			if(value && value.parent){
				value.parent.removeChild(value);
			}
		}
		//错误信息清理
		public function dispose():void
		{
			if(errData){
				errData.clear();
			}
		}
	}
}