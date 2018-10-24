package game.module.camp
{
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.common.UIRegisteredMgr;
	
	import laya.events.Event;
	
	public class NewUnitInfoView extends BaseDialog
	{
		private var _nuiaView:NewUnitInfoAutoView;
		
		public function NewUnitInfoView()
		{
			super();
			m_iPositionType = LayerManager.LEFTUP;
		}
		
		override public function createUI():void
		{
			super.createUI();
			_nuiaView = new NewUnitInfoAutoView();
			addChild(_nuiaView);
			
			UIRegisteredMgr.AddUI(_nuiaView.closeBtn,"UnitInfoClose");
		}
		
		private var _selId:Number = 0;
		
		/**
		 *此界面两个参数  [兵种ID,功能页签] ,默认值均为0
		 */
		public override function show(...args):void{
			this.size(Laya.stage.width,Laya.stage.height);
			super.show(args);
			var ar:Array = args[0];
			//trace("ar:", ar);
			if(!ar) ar = [];
			if(ar.length > 0)
				_selId = Number(ar[0]);
			else
				_selId = 0;
			
			if(ar.length > 1)
			{
				_nuiaView.autoSelectIndex = Number(ar[1]);
			}
			
			_nuiaView.refreshList();
			
			_nuiaView.selectUnitById(_selId);
		}
		
		public override function addEvent():void{
			super.addEvent();
			_nuiaView.closeBtn.on(Event.CLICK,this,close);
			_nuiaView.addEvent();
		}
		
		public override function removeEvent():void{
			super.removeEvent();
			_nuiaView.closeBtn.off(Event.CLICK,this,close);
			_nuiaView.removeEvent();
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			_nuiaView  = null;
			super.destroy(destroyChild);
		}
	}
}