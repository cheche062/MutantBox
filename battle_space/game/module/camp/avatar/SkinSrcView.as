package game.module.camp.avatar
{
	import MornUI.camp.UnitSrcViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.module.camp.CampView;
	import game.module.camp.NewUnitInfoView;
	import game.module.camp.UnitInfoView;
	import game.module.camp.UnitRenderItem;
	import game.module.mainui.MainView;
	
	import laya.events.Event;
	
	/**
	 * SkinSrcView
	 * author:huhaiming
	 * SkinSrcView.as 2018-4-2 下午7:27:10
	 * version 1.0
	 *
	 */
	public class SkinSrcView extends BaseDialog
	{
		public function SkinSrcView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			var skinInfo:Object = args[0];
			var arr:Array = [];
			for(var i:int=1; i<6; i++){
				var tmp:Object;
				if(skinInfo["s_dec"+i]){
					tmp = {};
					tmp.source = skinInfo["source"+i];
					tmp.des = skinInfo["s_dec"+i];
					arr.push(tmp);
				}else{
					break;
				}
			}
			view.srcList.array = arr;
			view.srcList.refresh();
			AnimationUtil.flowIn(this);
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					break;
				default:
					if(e.target is UnitRenderItem){
						var item:UnitRenderItem = e.target as UnitRenderItem;
						(XFacade.instance.getView(MainView) as MainView).linkTo(item.data.source);
						
						XFacade.instance.closeModule(CampView);
						XFacade.instance.closeModule(UnitInfoView);
						XFacade.instance.closeModule(NewUnitInfoView);
						XFacade.instance.closeModule(AvatarLvUpView);
						this.close();
					}
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
		}
		
		override public function createUI():void{
			this._view = new UnitSrcViewUI();
			this.addChild(this._view);
			
			this.view.srcList.itemRender = UnitRenderItem;
			this.view.srcList.vScrollBarSkin = "";
			this.closeOnBlank = true;
			
			view.tfTitle.text = "L_A_84567";
		}
		
		private function get view():UnitSrcViewUI{
			return this._view as UnitSrcViewUI;
		}
	}
}