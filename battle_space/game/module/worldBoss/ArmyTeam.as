package game.module.worldBoss
{
	import MornUI.worldBoss.armyTeamUI;
	
	import game.global.util.TimeUtil;
	import game.global.util.UnitPicUtil;
	
	/**
	 * 队伍tab
	 * @author hejianbo
	 * 2018-04-17 14:05:26
	 */
	public class ArmyTeam extends armyTeamUI
	{
		public function ArmyTeam()
		{
			super();
		}
		
		override public function set dataSource(value:*):void {
			if (!value) return;
			var _result:ArmyTeamDataVo = value;
			
			this.dom_viewStack.selectedIndex = _result.hasData ? 1 : 0;
			this.dom_bg.index = _result.isSelected ? 1 : 0;
			this.y = _result.isSelected ? 5 : 15;
			//有数据内容
			if (_result.hasData) {
				this.dom_head.skin = UnitPicUtil.getUintPic(_result.head, UnitPicUtil.ICON);
				this.dom_blood.value = _result.hp / _result.hp_max;
				this.dom_action.value = _result.muscle / WorldBossFightView.MUSCLE_INIT;
				
				if (_result.isDied) {
					var detailTime = TimeUtil.toDetailTime(_result.time);
					this.dom_time.text = TimeUtil.timeToText(detailTime);
				}
				
				this.dom_diebox.visible = _result.isDied;
				this.dom_blood.visible = !_result.isDied;
				this.dom_action.visible = !_result.isDied;
				
				this.dom_auto.visible = (_result.auto == 1);
			}
			//是否显示删除按钮(选中 && 在起点)
			this.btn_close.visible = (_result.isSelected && _result.isStartPoint && !_result.isDied);
			
			super.dataSource = _result;
		}
		
	}
}