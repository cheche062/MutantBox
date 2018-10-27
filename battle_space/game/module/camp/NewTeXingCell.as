package game.module.camp
{
	import MornUI.camp.NewTeXingCellUI;
	
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.vo.AwakenTypeVo;
	
	import laya.events.Event;
	
	public class NewTeXingCell extends NewTeXingCellUI
	{
		public function NewTeXingCell()
		{
			super();
			this.on(Event.CLICK,this,thisclick);
		}
		
		private var _data:Array;
		public override function set dataSource(value:*):void{
			super.dataSource = value;
			_data = value;
			if(_data)
			{
				var vo:AwakenTypeVo = GameConfigManager.awakenTypeVoDic[_data[0]];
				var needLv:Number = _data[1];
				var lv:Number = _data[2];
				btn.disabled = !lv;
				var needStr:String = GameLanguage.getLangByKey("L_A_73106");
				needStr = StringUtil.substitute(needStr,needLv);	
					
				btn.label = lv ? vo.name : needStr;
				// 锁的图标永远不显示
				lockIcon.visible = false;
				
				lvBg.visible = lv;
				lvLbl.text = lv;
				iconImg.skin = vo.iconPath;
				
				//技能图标一直显示, 锁住则灰调
				iconImg.visible = true;
			}
		}
		
		private function thisclick(e:Event):void
		{
			if(!_data)return ;
			var needLv:Number = _data[1];
			var lv:Number = _data[2];
			
			// 等级为 0
			if (!lv) {
				var needStr:String = GameLanguage.getLangByKey("L_A_73123");
				needStr = StringUtil.substitute(needStr, needLv);	
//				XTip.showTip(needStr);
				
				// 特别情况
				var _upC = -1;
				XFacade.instance.openModule(ModuleName.NewUpTeXingView, [_data, _upC]);
			} else {
				var vo:AwakenTypeVo = GameConfigManager.awakenTypeVoDic[_data[0]];
				var upC:Number = vo.upCount(_data[2]);
				
				// 可以一次性升级的级数
				var _upC = upC > 10 ? 10 : upC;
				XFacade.instance.openModule(ModuleName.NewUpTeXingView, [_data, _upC]);
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			_data = null;
			this.btn.off(Event.CLICK,this,thisclick);
			super.destroy(destroyChild);
		}
	}
}