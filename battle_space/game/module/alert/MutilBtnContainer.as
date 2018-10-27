package game.module.alert 
{
	import MornUI.baseAlert.MutilBtnContainerUI;
	
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.module.guild.GuildMainView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MutilBtnContainer extends BaseDialog 
	{
		
		private var _btnArray:Vector.<Button> = new Vector.<Button>(6);
		
		private var _btnData:Object;
		
		private var _serviceInterface:String;
		
		public function MutilBtnContainer() 
		{
			super();
			
			
		}
		private function onClick(e:Event):void
		{
			var id:String = e.target.name.split("_")[1];
			
			switch(_serviceInterface)
			{
				case "changeInterType":
					GuildMainView.setting_config = {"join_type": parseInt(id) + 1};
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_CHANGE_SETTING, ["join_type", parseInt(id) + 1]);
					Signal.intance.event(GuildEvent.CHANGE_JOIN_TYPE, [parseInt(id) + 1]);
					close();
					
					break;
				
				case "adjustMemberJob":
					Signal.intance.event(GuildEvent.ADJUSE_MEMBER_JOB, [e.target.label, _btnData.uid]);
					close();
					
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void{
			super.show();
			
			this.x = this.view.stage.mouseX+20;
			this.y = this.view.stage.mouseY;
			
			if (this.x + this.view.width > this.view.stage.width)
			{
				this.x = this.view.stage.width - this.view.width;
			}
			
			if (this.y + this.view.height >= this.view.stage.height)
			{
				this.y = this.view.stage.height - this.view.height;
			}
			
			view.bg.width = 308;
			_btnData = args[0];
			m_iPositionType = LayerManager.M_FIX;
			if (parseInt(_btnData.btnNum)<=3)
			{
				view.bg.width = 160;
			}
			
			for (var i:int = 0; i < 6; i++) 
			{
				if (i < parseInt(_btnData.btnNum))
				{
					_btnArray[i].disabled = false;
					if (_btnData["place"] == GameLanguage.getLangByKey("L_A_2540") && 
						_btnData.lableArray[i] == GameLanguage.getLangByKey("L_A_2542"))
					{
						_btnArray[i].disabled = true;
					}
					_btnArray[i].label = _btnData.lableArray[i];
					_btnArray[i].visible = true;
				}
				else
				{
					_btnArray[i].visible = false;
				}
			}
			
			_serviceInterface = _btnData.service;
		}
		
		override public function close():void{
			
			super.close();
			
		}
		
		override public function createUI():void{
			this._view = new MutilBtnContainerUI();
			this.addChild(_view);
			this.bg.alpha = 0.01;
			this.mouseThrough = this.view.mouseThrough = true;
			this.closeOnBlank = true;
			
			for (var i:int = 0; i < 6; i++) 
			{
				this._btnArray[i] = this.view.getChildByName("btn_" + i);
				this._btnArray[i].mouseEnabled = true;
				this._btnArray[i].mouseThrough = true;
			}
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():MutilBtnContainerUI{
			return _view;
		}
		
	}

}