package game.module.worldBoss
{
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	
	import laya.ui.Box;
	import laya.ui.Image;

	public class WorldBossShareTask
	{
		
		/**切图宽度*/
		public static const SizeX:int=4;
		public static const SizeY:int=4;
		public static const CellW:int=575;
		public static const CellH:int=310;
		
		public function WorldBossShareTask()
		{
		}
		/**创建格子对象容器并初始化*/
		public static function createM_pieceContainer():Object {
			var result = ResourceManager.instance.getResByURL("config/p_boss/p_boss_map.json");
			//挑出有效数据
			var pieceData = {};
			ToolFunc.values(result).forEach(function(item, index){
				var newObj = ToolFunc.filterObj(item, function(value, key) {
					return !!value;
				})
				var h_id = newObj["H_id"];
				for (var key in newObj) {
					if (key !== "H_id") {
						pieceData[h_id + '_' + key.slice(1)] = newObj[key];
					}
				}
			})
			
			//总行数
			var totalLineNum = ToolFunc.keys(result).length;
			//总的键
			var totalKeys = ToolFunc.keys(pieceData);
			//奇数行的格子数	
			var oddLineNum = totalKeys.filter(function(item, index) {
				return item.indexOf('1_') > -1
			}).length
			//偶数行的格子数	
			var evenLineNum = totalKeys.filter(function(item, index) {
				return item.indexOf('2_') > -1
			}).length
			
			// 容器
			var m_pieceContainer:Box = new Box();
			var m_pieceObj = { };
			
			for (var j = 1; j <= totalLineNum; j++) {
				var l = j%2==0 ? evenLineNum : oddLineNum;
				for (var k = 1; k <= l; k++) {
					var ix = j;
					var iy = (j%2==0) ? k * 2 + 1 : k * 2;
					var index:String = ix + "_" + iy;
					var chess:WorldBossChess = m_pieceObj[index] = new WorldBossChess(index);
					chess.x = (iy - 2) * WorldBossFightView.DISSX;
					chess.y = (ix - 1) * WorldBossFightView.DISSY;
					chess.init(pieceData[index]);
					m_pieceContainer.addChild(chess);
				}
			}
			
			return {box: m_pieceContainer, obj: m_pieceObj};
		}
		
		/**创建背景地图*/
		public static function createMapImages():Box {
			var box:Box = new Box();
			var i:int = 0;
			for (i = 0; i < SizeX * SizeY; i++)
			{
				var _url = i < 9 ? ("0" + (i + 1)) : (i + 1);
				var image:Image = new Image(ResourceManager.instance.setResURL("worldBossMap/WB_MAP_" + _url + ".jpg"));
				image.width=CellW;
				image.height=CellH;
				image.name="image" + i;
				var yNum = Math.floor(i / SizeY);
				var xNum = Math.floor(i % SizeX);
				box.addChild(image);
				image.x=CellW * xNum;
				image.y=CellH * yNum;
			}
			
			return box;
		}
			
		
	}
}