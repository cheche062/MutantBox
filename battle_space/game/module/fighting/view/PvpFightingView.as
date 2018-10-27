package game.module.fighting.view
{
	
	import game.global.GameConfigManager;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.quickMsgVo;
	import game.module.pvp.PvpManager;
	import game.module.tips.itemTip.ItemTipManager;
	
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;

	public class PvpFightingView extends FightingView
	{
		
		public var pvpTopView:pvpTopViewControl;
		public var msgSelectView:msgSelectViewControl;
		public var leftShowMsg:showMsgControl;
		public var rightShowMsg:showMsgControl;
		public var enemyInfoView:enemyInfoViewControl;
		
		public function PvpFightingView()
		{
			super();
		}
		
		public override function setType(type:uint , isMove:Boolean = false):void
		{
			if(_showType != type)
			{
				super.setType(type,isMove);
				pvpTopView.visible = enemyInfoView.visible =  _showType == SHOWTYPE_7;
//				pvpTopView.visible = enemyInfoView.visible =  true;
				
				stageSizeChange();
			}
			
			if(enemyInfoView.visible)
			{
				enemyInfoView.bindEnemyInfo();
			}
			
		}
		
		
		public override function close():void{
			pvpTopView.stop();
			super.close();
		}
		
		
		override public function createUI():void
		{
			super.createUI();
			pvpTopView = new pvpTopViewControl();
			this.addChild(pvpTopView);
			
			msgSelectView = new msgSelectViewControl();
			this.addChild(msgSelectView);
			
			leftShowMsg = new showMsgControl();
			this.addChild(leftShowMsg);
			
			rightShowMsg = new showMsgControl(false);
			this.addChild(rightShowMsg);
			
			enemyInfoView = new enemyInfoViewControl();
			this.addChild(enemyInfoView);
			
			(rightTopView1.escapeBtn.getChildByName("iconImg") as Image).skin = "fighting_pvpUI/icon_surrend.png";	
			(rightTopView1.backBtn.getChildByName("iconImg") as Image).skin = "fighting_pvpUI/icon_surrend.png";	
			rightTopView1.escapeBtn.label = "L_A_70068";
			rightTopView1.backBtn.label = "L_A_70068";
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			pvpTopView = null;
			super.destroy(destroyChild);
		}
		
		
		protected function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			pvpTopView.x = Laya.stage.width - pvpTopView.width >> 1;
			
			if(_showType == SHOWTYPE_3 || _showType == SHOWTYPE_5 || _showType == SHOWTYPE_7 )
			{
				msgSelectView.y = 0;
			}else
			{
				msgSelectView.y = Laya.stage.height - msgSelectView.height >> 1;
			}
			
			
			
			leftShowMsg.x = 130;
			leftShowMsg.y = msgSelectView.y + (msgSelectView.height - leftShowMsg.height) / 2;
			
			rightShowMsg.x = Laya.stage.width - rightShowMsg.width - 20;
			rightShowMsg.y = Laya.stage.height - rightShowMsg.height >> 1;
			rightShowMsg.y = msgSelectView.y + (msgSelectView.height - rightShowMsg.height) / 2;
			
			if(enemyInfoView.visible)
			{
				enemyInfoView.x = Laya.stage.width - enemyInfoView.width - 20;
				enemyInfoView.y = msgSelectView.y + (msgSelectView.height - enemyInfoView.height) / 2;
				rightShowMsg.x = enemyInfoView.x - rightShowMsg.width - 20;
			}
			
		}
		
		
		public override function addEvent():void
		{
			super.addEvent();
			pvpTopView.addEvent();
			msgSelectView.addEvent();
			enemyInfoView.addEvent();
			Signal.intance.on(PvpManager.SETQUICKMSG_EVENT,this,setquickMsg);
			
		}
		
		public override function removeEvent():void
		{
			super.removeEvent();
			pvpTopView.removeEvent();
			msgSelectView.removeEvent();
			enemyInfoView.removeEvent();
			Signal.intance.off(PvpManager.SETQUICKMSG_EVENT,this,setquickMsg);
		}
		
		private function setquickMsg(... args):void{
			var vo:quickMsgVo;
			for (var i:int = 0; i < GameConfigManager.quickMsgList.length; i++) 
			{
				var vo2:quickMsgVo = GameConfigManager.quickMsgList[i];
				if(vo2.id == args[0])
				{
					vo = vo2;
					break;
				}
			}
			if(!vo)return ;
			
			if(args[1] == true)
			{
				leftShowMsg.show(vo.content);
			}else
			{
				rightShowMsg.show(vo.content);
			}
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			//trace(1,"destroy PvpFightingView");
			pvpTopView = null;
			msgSelectView = null;
			leftShowMsg = null;
			rightShowMsg = null;
			enemyInfoView = null;
			super.destroy(destroyChild);
		}
	}
}