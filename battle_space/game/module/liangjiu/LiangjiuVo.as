package game.module.liangjiu
{
	import game.global.data.bag.BagManager;

	/**
	 * 酿酒的数据
	 * @author hejianbo
	 * 
	 */
	public class LiangjiuVo
	{
		/**当前火候值*/
		public var fire:int = 0;
		/**当前祝福值*/
		public var wish:int = 0;
		/**当前合成次数*/
		public var num:int = 0;
		/**当前已获得科技点数*/
		public var tech_point:int = 0;
		/**暴击次数*/
		public var crits_num:int = 0;
		
		/**晶石数据*/
		public var jingshi_items:Array = [];
		/**晶石获得记录*/
		public var jingshi_log:Array = [];
		
		public function LiangjiuVo()
		{
		}
		
		private function extendData(data:Object):void {
			for (var key in data) {
				if (this.hasOwnProperty(key)) {
					this[key] = data[key];
				}
			}
		}
		
		/**初始化数据*/ 
		public function init(data:Object):void {
			extendData(data);
			updateJingshiItems();
		}
		
		/**获取晶石*/ 
		public function getJingshi(data:Object):void {
			extendData(data);
			jingshi_log = data["items"].concat(jingshi_log).slice(0, 30);
			updateJingshiItems();
		}
		
		/**更新当前晶石数量*/
		private function updateJingshiItems():void {
			var jingshi_data = BagManager.instance.getJingshiList();
			jingshi_items = jingshi_data;
		}
		
		/**合成更新*/
		private function hechengUpdate(data:Object):void {
			updateJingshiItems();
			extendData(data);
		}
		
		
		
		
		
		
		
		
		
	}
}