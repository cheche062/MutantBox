package game.common
{
	import laya.media.SoundChannel;
	import laya.media.SoundManager;
	import laya.net.LocalStorage;
	import laya.utils.Handler;

	public class SoundMgr
	{
		private static var _instance:SoundMgr;
		public static function get instance():SoundMgr{
			if(_instance)return _instance;
			_instance = new SoundMgr;
			
			return _instance;
		}
		
		private var _m_bPlayMusic:Boolean = true;// true;
		private var _m_bPlayeSound:Boolean = true;//true;
		/**背景音乐地址*/
		public var m_strMusicURL:String;
		
		
//		public static const soundType:String = "mp3";
//		public static const soundType:String = "wav";
		public static const soundType:String = "ogg";
		
		//////////////////////////////////////////////////////////////////////////////////
		//-----------------------------------------------------------------------------
		/**是否关闭 背景音乐*/
		public function get m_bPlayMusic():Boolean
		{
			var v:String = LocalStorage.getItem("m_bPlayMusic");
			return v != "0"
		}
		
		/**
		 * @private
		 */
		public function set m_bPlayMusic(value:Boolean):void
		{
			_m_bPlayMusic = value;
			
			LocalStorage.setItem("m_bPlayMusic",value ? "1" : "0");
//			
			if(value){
				playMusicByURL(m_strMusicURL);
			}else{
				SoundManager.stopMusic()
			}
		}
		//////////////////////////////////////////////////////////////////////////////////
		//-----------------------------------------------------------------------------
		/**是否关闭音效*/
		public function get m_bPlayeSound():Boolean
		{
			var v:String = LocalStorage.getItem("m_bPlayeSound");
			return v != "0"
		}
		
		/**
		 * @private
		 */
		public function set m_bPlayeSound(value:Boolean):void
		{
			_m_bPlayeSound = value;
			LocalStorage.setItem("m_bPlayeSound",value ? "1" : "0");
		}
		
		//////////////////////////////////////////////////////////////////////////////////
		//-----------------------------------------------------------------------------
		/**
		 * 播放背景音乐 
		 * @param url
		 * 
		 */		
		private var left_strMusicURL:String;
		public function playMusicByURL(url:String):void 
		{
			left_strMusicURL = m_strMusicURL;
			m_strMusicURL = url;
			if( !m_bPlayMusic )return;
			SoundManager.playMusic(url, 0, new Handler(this, onComplete));
		}
		
		/**
		 * 播放上次的背景音乐 
		 * @param url
		 * 
		 */
		public function restoreMusic():void
		{
			if(left_strMusicURL)playMusicByURL(left_strMusicURL);
		}
		
		public function playMusicByName(name:String):void 
		{
//			var url:String = ResourceManager.instance.getSoundURL(name);
//			playMusicByURL(url);
		}
		/**
		 *  播放音效 
		 * @param url
		 * 
		 */		
		public function playSound(url:String,loops:int = 1):SoundChannel 
		{
			
			if( !m_bPlayeSound )return null;
			return SoundManager.playSound(url, loops, new Handler(this, onComplete));
		}
		
		private function onComplete():void 
		{
		}
	}
}