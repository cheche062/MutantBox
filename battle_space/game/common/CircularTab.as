package game.common
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.ui.Button;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class CircularTab extends Sprite
	{
		private var bg:Sprite = new Sprite();
		private var _leftBtn:Button = new Button();
		private var _rightBtn:Button = new Button();		
		private var _tabList:Array;
		private var _radius:Number;
		private var _scaleList:Array;
		private var _stateIndex:Number = 0;
		
		
		public static var CBChange:String = "CBChange";
		
		public function CircularTab()
		{
			super();
			
			addChild(bg);
			
		}
		
		/**
		 *参数： radius半径   tabList[ [角度,显示对象], ] stateIdx 默认选中 sY 纵向压缩比
		 */
		public function init(radius:Number,tabList:Array, scaleList:Array , sY:Number = 0.5):void
		{
//			sY= 1;
			this.size(radius * 2 , radius * 2 * sY);
//			this.graphics.drawRect(0,0,width,height,"#ffff00");
//			
//			bg.graphics.drawCircle(-radius,-radius,radius,"#ff0000");
//			bg.pos( 0 , 0 );
			bg.scaleY = sY;
			_tabList = tabList;
			_radius = radius;
			_scaleList = scaleList;
			for (var i:int = 0; i < _tabList.length; i++) 
			{
				var ar:Array = _tabList[i];
				var sp:Sprite = ar[1];
				addChild(sp as Sprite);
				
				sp.scale(scaleList[i],scaleList[i]);
				sp.on(Event.CLICK,this,btnClick);
				sp.mouseEnabled = true;
			}
//			_stateIndex = 
			BgEotation = 0;
			
			
		}
		
		private function btnClick(e:Event):void
		{
			var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
			SoundMgr.instance.playSound(mp3Url);
			if(lock)
				return ;
			var clickBtn:Sprite = e.currentTarget;
			if(clickBtn == selectBtn)return;
			var idx1:Number;
			var cpAR:Array = [];
			for (var i:int = 0; i < _tabList.length; i++) 
			{
				var ar:Array = _tabList[i];
				var sp:Sprite = ar[1];
				cpAR.push(sp);
//				if(sp == clickBtn)
//					idx1 = i;
//				if(sp == selectBtn)
//					idx2 = i;
			}
			
			idx1 = cpAR.indexOf(selectBtn);
			idx1 += 3;
			while(idx1){
				var toSp:* = cpAR.shift();
				cpAR.push(toSp);
				idx1 --;
			}
			
			idx1 = cpAR.indexOf(clickBtn);
			
			
			
//			if(idx1 > 2)
//			{
//				trace(1,">2",idx1 - 2);
//				stateIndex -= (idx1 - 2);
//			}
//			else
//			{
//				trace(1,"<2",2 - idx1);
//				stateIndex += (2 - idx1);
//			}
			
			m_isAdd = !(idx1 > 2);
			m_changeNum = m_isAdd ? 2 - idx1 : idx1 - 2;
			if(m_changeNum) m_changeNum = 1;
			trace(1,m_isAdd,m_changeNum);
			openChange();
		}
		
		private var m_changeNum:Number = 0;
		private var m_isAdd:Boolean;
		public function openChange():void{
			if(!m_changeNum)return ;
			m_changeNum -- ;
			if(m_isAdd){
				stateIndex ++ 
			}else
			{
				stateIndex --;
			}
		}
		
		
		
		public function get selectBtn():*{
			var tabListCp:Array = _tabList.concat();
			var isAd:Boolean = _stateIndex > 0;
			var xx:Number = Math.abs(_stateIndex);
			for (var i:int = 0; i < xx; i++) 
			{
				if(!isAd)
				{
					var v:Number = tabListCp.shift();
					tabListCp.push(v);
				}else
				{
					var v:Number = tabListCp.pop();
					tabListCp.unshift(v);
				}
			}
			return tabListCp[0][1];
		}
		
		private function thisMoveOver():void{
			lock = false;
			openChange();
		}
		
		private var lock:Boolean ;
		public function set stateIndex(value:Number):void
		{
			if(lock)
				return ;
			lock = true;
			
			_stateIndex = value;
			Tween.to(this,{BgEotation:0 - _stateIndex * 72 },500,null,Handler.create(this,thisMoveOver)); 
			var scaleListCp:Array = _scaleList.concat();
			
			var isAd:Boolean = _stateIndex > 0;
			var xx:Number = Math.abs(_stateIndex);
			for (var i:int = 0; i < xx; i++) 
			{
				if(isAd)
				{
					var v:Number = scaleListCp.shift();
					scaleListCp.push(v);
				}else
				{
					var v:Number = scaleListCp.pop();
					scaleListCp.unshift(v);
				}
			}
			
			for (var i:int = 0; i < _tabList.length; i++) 
			{
				var ar:Array = _tabList[i];
				var sp:Sprite = ar[1];
				Tween.to(sp,{scaleX:scaleListCp[i] , scaleY:scaleListCp[i] },500); 
			}
			
			this.event(CBChange);
			
		}
		public function get stateIndex():Number
		{
			return _stateIndex;
		}
		
		private var _BgEotation:Number;
		public function set BgEotation(v:Number):void
		{
//			bg.rotation = v;
			_BgEotation = v;
			for (var i:int = 0; i < _tabList.length; i++) 
			{
				var ar:Array = _tabList[i];
				var pi:Point = new Point();
				var sp:Sprite = ar[1];
				pi.x   =   _radius   *   Math.cos((ar[0] + _BgEotation)  *   3.14   /180   ) + _radius; 
				pi.y   =   _radius   *   Math.sin((ar[0] + _BgEotation)   *   3.14   /180  ) + _radius;
				pi = bg.localToGlobal(pi);
				pi = this.globalToLocal(pi);
//				pi.x -= sp.width / 2;
//				pi.y -= sp.height;
				sp.pos(pi.x , pi.y);
			}
			
		}
		
		public function get BgEotation():Number{
			return _BgEotation;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy CircularTab");
			bg = null;
			_leftBtn = null;
			_rightBtn = null;
			_scaleList = null;
			super.destroy(destroyChild);
		}
	}
}