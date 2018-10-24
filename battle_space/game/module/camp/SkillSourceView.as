package game.module.camp
{
	import MornUI.camp.SkillSourceViewUI;
	
	import game.common.AnimationUtil;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.data.bag.ItemData;
	import game.global.vo.itemSourceVo;
	import game.module.bag.cell.BaseItemSourceCell;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * 技能所需材料的资源来源 
	 * 
	 */
	public class SkillSourceView extends BaseDialog
	{
		public function SkillSourceView()
		{
			super();
		}
		
		override public function show(...args):void{
			super.show();
			AnimationUtil.flowIn(this); 
			
			var data = args[0];
			var itemData:ItemData = new ItemData();
			itemData.iid = data[0];
			
			view.srcList.array = itemData.vo.sourceAr;
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
					
					break;
			}
		}
		
		private function listMouseHandler(e:Event,index:int):void {
			if(e.type != Event.CLICK)return ;
			var cell:BaseItemSourceCell = view.srcList.getCell(index);
			if(!cell || !cell.dataSource) return ;
			
			var vo:itemSourceVo = cell.dataSource;
			if(!vo.state)return ;
			
			BaseItemSourceCell.sourceClick(cell.dataSource, Handler.create(this, function() {
				XFacade.instance.closeModule(SkillInfoView);
				XFacade.instance.closeModule(NewUnitInfoView);
				XFacade.instance.closeModule(CampView);
				close();
			}));
			
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			view.srcList.mouseHandler = Handler.create(this,listMouseHandler, null, false);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			view.srcList.mouseHandler.clear();
		}
		
		override public function createUI():void{
			this._view = new SkillSourceViewUI();
			this.addChild(this._view);
			
			this.view.srcList.itemRender = NewItemSourceCell;
			this.view.srcList.vScrollBarSkin = "";
			this.closeOnBlank = true;
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function get view():SkillSourceViewUI{
			return this._view as SkillSourceViewUI;
		}
	}
}