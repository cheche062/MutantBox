package game.module.TeamCopy
{
	import MornUI.teamcopy.TeamCopyRoomViewUI;
	import MornUI.teamcopy.TeamCopyTipsViewUI;
	
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class TeamCopyTipsView extends BaseDialog
	{
		private var m_num:int;
		private var m_id:String;
		
		
		public function TeamCopyTipsView()
		{
			super();
		}
		
		/**初始化UI*/
		override public function createUI():void
		{
			this._view = new TeamCopyTipsViewUI();
			this.addChild(_view);
		}
		
		override public function show(...args):void
		{
			m_id="";
			m_num=args[0][0];
			m_id=args[0][1];
			super.show();
			
			initUI();
		}
		
		private function initUI():void
		{
			
			if(m_num<parseInt(GameConfigManager.teamFightParamVo.guildRewardTime))
			{
				view.LabelText.text=GameLanguage.getLangByKey("L_A_14021");
				view.TipsText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_14022"),(GameConfigManager.teamFightParamVo.getRewardMax()-m_num));
			}
			else
			{
				view.LabelText.text=GameLanguage.getLangByKey("L_A_14044");
				view.TipsText.text="";
			}
		}
		
		override public function addEvent():void
		{
			this.on(Event.CLICK, this, this.onClickHandler);
		}
		
		private function onClickHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			switch(e.target)
			{
				case view.CloseBtn:
				{
					this.close();
					break;
				}
				
				case view.OkBtn:
				{
					if(m_id!="")
					{
						WebSocketNetService.instance.sendData(ServiceConst.TEAMCORY_JOINROOM,[m_id]);
					}
					else
					{
						WebSocketNetService.instance.sendData(ServiceConst.TEAMCORY_SEARCHROOM,[]);
					}
					this.close();
					break;
				}	
				case view.ChanelBtn:
				{
					this.close();
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		override public function removeEvent():void
		{
			this.off(Event.CLICK, this, this.onClickHandler);
		}
		
		private function get view():TeamCopyTipsViewUI
		{
			return this._view as TeamCopyTipsViewUI;		
		}
		
	}
}