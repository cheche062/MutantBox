package game.common
{
	import game.global.GameInterface.IGameDispose;
	
	import laya.display.Sprite;
	import laya.net.Loader;
	import laya.resource.Texture;
	import laya.utils.Handler;
	
	/**
	 * 场景加载控制器 
	 * @author zhangmeng
	 * 
	 */	
	public class SceneLoadMgr implements IGameDispose
	{
		public function SceneLoadMgr()
		{
		}
		
		private static var _instance:SceneLoadMgr;
		public static function get instance():SceneLoadMgr{
			if(!_instance){
				_instance=new SceneLoadMgr();
			}
			return _instance;
		}
		//背景图地址
		private var _mapUrl:String="";
		//背景图的宽度
		private var _mapWidth:Number=0;
		// 背景图的高度
		private var _mapHeight:Number=0;
		//分块的宽度
		private var _gridWidth:Number=0;
		//分块的高度
		private var _gridHeight:Number=0;
		//横向的图片数量
		private var _xPics:uint=0;
		//纵向的图片数量
		private var _yPics:uint=0;
		//当前的地图容器
		private var _fuzzySprite:Sprite;
		//地图名称
		private var _fuzzyName:String="";
		//回调函数
		private var _fuzzyCallBack:Handler;
		/**
		 * 加载场景 
		 * @param mapWidth 地图宽度
		 * @param mapHeight 地图高度
		 * @param gridWidth 小图宽度
		 * @param gridHeight 小图高度
		 * @param _mapImg 背景图容器
		 * @param _mapName 背景地图名称
		 * @param _callBack 回调函数
		 * 
		 */		
		public function loadScene(mapWidth:Number,mapHeight:Number,gridWidth:Number,gridHeight:Number,_mapImg:Sprite,_mapName:String,_callBack:Handler):void{
			if(_fuzzyName!="" && _fuzzyName!=_mapName){
				this.dispose();
			}
			this._mapWidth=mapWidth;
			this._mapHeight=mapHeight;
			this._gridWidth=gridWidth;
			this._gridHeight=gridHeight;
			this._fuzzySprite=_mapImg;
			_xPics=Math.floor(this._mapWidth/gridWidth);
			_yPics=Math.floor(this._mapHeight/gridHeight);
			_fuzzyName=_mapName;
			this._fuzzyCallBack=_callBack;
			
//			var _altlasXmlUrl:String=ResourceManager.instance.setResURL(_mapName+".json");
			var _altlasXmlUrl:String = _mapName + ".json";
			//var _altlasXmlUrl:String=ResourceManager.instance.setResURL("scene/subScene/"+_mapName+".xml");
			//var _altlasTexture:String=ResourceManager.instance.setResURL("scene/subScene/"+_mapName+".png");
			
			Laya.loader.load([{url:_altlasXmlUrl,type:Loader.ATLAS}],Handler.create(this,loadSceneComplete),Handler.create(this,loadProcess, null, false),null,0,true,null,true);
			
			//Laya.loader.load([{url:_altlasXmlUrl,type:Loader.XML},{url:_altlasTexture,type:Loader.IMAGE}],Handler.create(this,loadSceneComplete),Handler.create(this,loadProcess));
		}
		private function loadProcess():void{
			
		}
		private function loadSceneComplete():void{
			/*var _texture:Texture=Laya.loader.getRes(ResourceManager.instance.setResURL("scene/subScene/"+_fuzzyName+".png"));
			var _xml:XmlDom=Laya.loader.getRes(ResourceManager.instance.setResURL("scene/subScene/"+_fuzzyName+".xml"));
			var _data:*=_xml.getElementsByTagName("SubTexture");
			var _xmlDic:Dictionary=new Dictionary();*/
			var _altlasXmlUrl:String= _fuzzyName+".json";
			var _nima:*=Loader.getAtlas(_altlasXmlUrl);
			/*for(var _n:* in _data){
				var _item:* =_data[_n];
				if(_item["attributes"]){
					var _atribu:*=_item.attributes;
					var _obj:Object=new Object();
					_obj.x=parseFloat(_atribu["1"]["nodeValue"]);
					_obj.y=parseFloat(_atribu["2"]["nodeValue"]);
					_obj.width=parseFloat(_atribu["3"]["nodeValue"]);
					_obj.heigth=parseFloat(_atribu["4"]["nodeValue"]);
					_xmlDic.set(_atribu["0"]["nodeValue"],_obj);
				}
			}*/
			if(this._fuzzySprite){
				_fuzzySprite.graphics.clear();
				var _index:uint=0;
				for(var a:uint=0;a<this._yPics;a++){
					for(var b:uint=0;b<this._xPics;b++){
						var _textures:Texture=Laya.loader.getRes(_nima[_index]);
						_fuzzySprite.graphics.drawTexture(_textures,b*this._gridWidth,a*this._gridHeight,_textures.width,_textures.height);
						_index++;
					}
				}
			}
			if(_fuzzyCallBack!=null){
				_fuzzyCallBack.run();
			}
		}
		
		public function dispose():void
		{
			if(this._fuzzySprite){
				_fuzzySprite.graphics.clear();
			}
			Laya.loader.clearRes(_fuzzyName+".json");
		}
	}
}