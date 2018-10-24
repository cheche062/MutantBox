/***
 *作者：罗维
 */
package game.module.bag.cell
{
	import mx.utils.StringUtil;
	
	import game.common.ItemTips;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemData;
	import game.global.vo.equip.EquipmentListVo;
	import game.module.equip.EquipTipsView;
	import game.module.tips.itemTip.ItemTipManager;
	import game.module.tips.itemTip.base.BaseItemTip;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	public class BaseItemCell extends Box
	{
		protected var _itemIcon:Image;
		protected var _itemNumLal:Label;
		protected var _data:ItemData;
		private var _showTip:Boolean;
		public static const itemWidth:Number = 100;
		public static const itemHeight:Number = 40;
		
		public function BaseItemCell()
		{
			super();
			
		}
		
		
		public function get showTip():Boolean
		{
			return _showTip;
		}

		public function set showTip(value:Boolean):void
		{
			if(_showTip != value)
			{
				_showTip = value;
				
				if(_showTip)
					this.on(Event.CLICK,this,showTipFun);
				else
					this.off(Event.CLICK,this,showTipFun);
			}
		}
		
		protected function showTipFun(e:Event):void
		{
			if(!_data)return ;
			
			var l_equipVo:EquipmentListVo=GameConfigManager.EquipmentList[_data.iid];
			if(l_equipVo==null||l_equipVo==undefined)
			{
				ItemTips.showTip(_data.iid);	
			}
			else
			{
				EquipTipsView.showTip(_data);
			}
		}
		

		public function get data():ItemData
		{
			return _data;
		}

		public function set data(value:ItemData):void
		{
			if(_data != value){
				_data = value;
				bindData();
			}
			if(_data)
				bindNum();
		}
		
		public function bindData():void{
			if(_data){
				bindIcon();
				
				_itemIcon.visible =  _itemNumLal.visible = true;
			}else
			{
				_itemIcon.visible =  _itemNumLal.visible = false;
			}
		}
		
		public function bindIcon():void{
			
//			var url:String = "appRes/icon/itemIcon/"+this.data.vo.icon+".png"
			var url:String = GameConfigManager.getItemImgPath(this.data.iid);
			_itemIcon.loadImage(url,0,0,22,22);
			trace(url); 
		}
		
		public function bindNum():void{
//			_itemNumLal.text = XUtils.formatResWith(data.inum);
			_itemNumLal.text = data.inum;
			
		}

		override protected function createChildren():void
		{
			super.createChildren();
			init();
		}
		
		protected function init():void
		{
			
			_itemIcon = new Image();
			this.addChild(_itemIcon);
			
			_itemNumLal = new Label();
			this.addChild(_itemNumLal);
			_itemNumLal.font = "BigNoodleToo";
			_itemNumLal.color = "#56f49f";
			_itemNumLal.fontSize = 14;
			_itemNumLal.x = 25;
			_itemNumLal.stroke = 1;
			size(itemWidth,itemHeight);
		}
		
		public function get itemNumLal():Label{
			return _itemNumLal;
		}
		
		public function get itemIcon():Image{
			return _itemIcon;
			
		}
		
		
		/**
		 * 设置图片与文字的样式
		 * @param imgOption 图片样式
		 * @param labelOption 文字样式
		 * 
		 */
		public function setElementStyle(imgOption:Object, labelOption:Object ):void{
			_setElementStyle(itemIcon, imgOption);
			_setElementStyle(itemNumLal, labelOption);
			
		}
		
		/**
		 * 设置元素样式 
		 * @param sp
		 * @param option
		 * 
		 */
		private function _setElementStyle(sp:Sprite, option:Object):void{
			for(var key in option){
				sp[key] = option[key];
			}
		}
		
		public override function set dataSource(value:*):void{
			super.dataSource = value;
			this.data = value;
//			trace(value);
		} 
		
		public override function destroy(destroyChild:Boolean=true):void{
			
			_itemIcon = null;
			_itemNumLal = null;
			_data = null;
			
			this.off(Event.CLICK,this,showTipFun);
			super.destroy(destroyChild);
		}
	}
}