package game.module.equip
{
	import MornUI.equip.EquipHeroCellUI;
	import MornUI.equip.EquipTipsViewUI;
	import MornUI.tips.ItemTipsUI;
	
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.data.bag.ItemData;
	import game.global.vo.ItemVo;
	import game.global.vo.equip.AttVo;
	import game.global.vo.equip.EquipInfoVo;
	import game.global.vo.equip.EquipmentBaptizeVo;
	import game.global.vo.equip.EquipmentIntensifyVo;
	import game.global.vo.equip.EquipmentListVo;
	import game.global.vo.equip.HeroEquipVo;
	import game.module.tips.itemTip.ItemTipManager;
	import game.module.tips.itemTip.base.BaseItemTip;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.View;
	
	public class EquipTipsView extends BaseView
	{
		private var m_EquipTips:BaseItemTip;
		private var m_data:ItemData;
		public function EquipTipsView()
		{
			super();
			this._m_iLayerType = LayerManager.M_POP;
		}
		
		/**
		 * 显示一个道具Tips
		 * @param	tipStr
		 */
		public static function showTip(p_data:ItemData):void{
			XFacade.instance.openModule(ModuleName.EquipTips, p_data);
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClickHander(e:Event):void
		{
			switch(e.target.parent.name)
			{
				case "equipTips":
				
					break;
				default:
				{
					close();
					break;
				}
			}
		}
		
		
		
		
		override public function show(...args):void{
			super.show(args);
			m_data=args[0];
			this.mouseThrough=true;
			m_EquipTips = ItemTipManager.getTips(m_data,null,null);
			m_EquipTips.visible=true;
			addChild(m_EquipTips);
			if(this.m_EquipTips.stage.mouseX>=425)
			{
				this.x = this.m_EquipTips.stage.mouseX-570;
			}
			else
			{
				this.x = this.m_EquipTips.stage.mouseX-260;
			}
			
			
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		override public function addEvent():void{
			super.addEvent();
			this.on(Event.CLICK,this,this.onClickHander);
			Laya.stage.on(Event.MOUSE_DOWN, this, onClickHander);
			Laya.stage.on(Event.MOUSE_WHEEL, this, onClickHander);
		}
		
		override public function removeEvent():void{
			//view && view.off(Event.CLICK, this, this.onClick);
			this.off(Event.CLICK,this,this.onClickHander);
			super.removeEvent();
			Laya.stage.off(Event.MOUSE_DOWN, this);
			Laya.stage.off(Event.MOUSE_WHEEL, this);
		}
		
		
		
	}
}