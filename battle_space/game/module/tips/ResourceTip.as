package game.module.tips
{	
	import MornUI.tips.ResourceTipUI;
	
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameLanguage;
	
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	
	/**
	 * RescourceTip
	 * author:huhaiming
	 * RescourceTip.as 2017-6-30 下午2:15:29
	 * version 1.0
	 *
	 */
	public class ResourceTip extends BaseView
	{
		public function ResourceTip()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			var data:Object = args[0];
			view.nameTF.text = data.name+"";
			view.infoTF.text = data.des+"";
			view.maxTF.text = data.max+"";
			view.icon.skin = "common/icons/"+data.icon+".png";
			if(data.output != undefined){
				view.lineIMG.visible = true;
				view.outHDE.visible = true;
				view.outHDE.innerHTML = "<font color='#98e8f4'>"+GameLanguage.getLangByKey("L_A_54024")+"</font>"+XUtils.formatNumWithSign(data.output)+"/M";
			}else{
				view.lineIMG.visible = false;
				view.outHDE.visible = false;
			}
		}
		
		override public function createUI():void{
			this._view = new ResourceTipUI();
			this.addChild(_view);
			
			view.outHDE.style.fontFamily = XFacade.FT_Futura;
			view.outHDE.style.fontSize = 18;
			view.outHDE.style.color = "#ffffff";
			view.outHDE.style.align = "right";
		}
		
		override public function addEvent():void{
			super.addEvent();
			Laya.stage.on(Event.MOUSE_DOWN, this, close);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			Laya.stage.off(Event.MOUSE_DOWN, this, close);
		}
		
		private function get view():ResourceTipUI{
			return this._view as ResourceTipUI
		}
	}
}