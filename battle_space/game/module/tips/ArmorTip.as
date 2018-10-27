package game.module.tips
{
	import MornUI.tips.PropertyTipUI;
	
	import game.common.LayerManager;
	import game.common.ModuleManager;
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.base.BaseView;
	
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.net.URL;

	/**
	 * ArmorTip
	 * author:huhaiming
	 * ArmorTip.as 2017-5-22 上午11:23:32
	 * version 1.0
	 *
	 */
	public class ArmorTip extends BaseView
	{
		private var reg:RegExp = /\+\d+\%/;
		private var reg2:RegExp = /\-\d+\%/;
		private var colors:Array = ["#9eff49","#ff8181"];
		private var colors2:Array = ["#ff8181","#9eff49"]
		protected const OFFSET_H:Number = 26;
		public function ArmorTip()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
		}
		
		/*数据结构{name:xx,des:xx, icon:xx}*/
		override public function show(...args):void{
			var data:Object = args[0];
			if(data){
				view.nameTF.innerHTML = data.name+"";
				var arr:Array = (data.des+"").split("<br>");
				//var reg:RegExp = /\+\d+\%/;
				var clo:Array = colors;
				if(data.defend){
					clo =colors2;
				}
				for(var i:int=0; i<arr.length; i++){
					if(!XUtils.isEmpty(arr[i].match(reg))){
						arr[i] = "<font color='"+clo[0]+"'>"+arr[i]+"</font><br>"
					}else if(!XUtils.isEmpty(arr[i].match(reg2))){
						arr[i] = "<font color='"+clo[1]+"'>"+arr[i]+"</font><br>"
					}else{
						arr[i] = "<font color='#ffffff'>"+arr[i]+"</font><br>"
					}
				}
				view.introTF.innerHTML = arr.join("");
				view.icon.skin = URL.formatURL("appRes/icon/property/"+data.icon+".png");
				this.view.bg.width = Math.max(view.nameTF.x + view.nameTF.contextWidth ,view.introTF.x + view.introTF.contextWidth) + OFFSET_H
				this.view.bg.height = view.introTF.y + view.introTF.contextHeight + OFFSET_H;
				
			}else{
				this.close();
			}
			super.show();
		}
		
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