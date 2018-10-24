package game.module.tips
{
	import MornUI.tips.PropertyTipUI;
	
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.base.BaseView;
	
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.net.URL;
	
	/**
	 * PropertyTip 属性tip
	 * author:huhaiming
	 * PropertyTip.as 2017-5-19 上午11:05:29
	 * version 1.0
	 *
	 */
	public class PropertyTip extends BaseView
	{
		protected const OFFSET_H:Number = 26;
		public function PropertyTip()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
		}
		
		/*数据结构{name:xx,des:xx, icon:xx}*/
		override public function show(...args):void{
			super.show();
			var data:Object = args[0];
			if(data){
				view.nameTF.innerHTML = data.name+"";
				//生成
				view.introTF.innerHTML = data.des+"";
				view.icon.skin = URL.formatURL("appRes/icon/property/"+data.icon+".png");
				this.view.bg.height = view.introTF.y + view.introTF.contextHeight + OFFSET_H;
			}else{
				this.close();
			}
		}
		
		/*override public function get height():Number{
			return 454
		}*/
		
		/**
		 * 获取本对象在父容器坐标系的矩形显示区域。
		 * <p><b>注意：</b>计算量较大，尽量少用。</p>
		 * @return 矩形区域。
		 */
		override public function getBounds():Rectangle {
			return new Rectangle(0, 0, this.view.bg.width, this.view.bg.height);
		}
		
		override public function createUI():void{
			this._view = new PropertyTipUI();
			this.addChild(this._view);
			
			view.nameTF.style.fontFamily = XFacade.FT_Futura;
			view.nameTF.style.fontSize = 18;
			view.nameTF.style.color = "#b1d9fe";
			
			view.introTF.style.fontFamily = XFacade.FT_Futura;
			view.introTF.style.fontSize = 14;
			view.introTF.style.color = "#b1d9fe";
		}
		
		override public function addEvent():void{
			super.addEvent();
			Laya.stage.on(Event.MOUSE_DOWN, this, close);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			Laya.stage.off(Event.MOUSE_DOWN, this, close);
		}
		
		protected function get view():PropertyTipUI{
			return this._view as PropertyTipUI;
		}
	}
}