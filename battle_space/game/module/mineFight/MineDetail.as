package game.module.mineFight 
{
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.global.consts.ServiceConst;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.mine.MineFightVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.View;
	/**
	 * ...
	 * @author ...
	 */
	public class MineDetail extends BaseView
	{
		private var _detailInfo:Object = { };
		
		private var _mineItem:View;
		
		private var _headIcon:Image;
		private var _circleMask:Sprite;
		
		public function MineDetail() 
		{
			super();
		}
		
		private function clickMine(e:Event):void
		{
			XFacade.instance.openModule(ModuleName.MineInfoView,_detailInfo);
		}
		
		public function setMC(view:View):void
		{
			if (_mineItem)
			{
				_mineItem = null;
			}
			
			
			_mineItem = view;
			_mineItem.mineBtn.on(Event.CLICK, this, this.clickMine);
			_mineItem.nameTF.text = "";
			_mineItem.LvTF.text = "";
			
			
			if (_headIcon)
			{
				_headIcon.skin = "";
				_headIcon.parent.removeChild(_headIcon);
				_headIcon = null;
			}
			
			_headIcon = new Image();
			_headIcon.x = -15;
			_headIcon.y = -15;
			_headIcon.mouseEnabled = false;
			_mineItem.headContainer.addChild(_headIcon);
			
			_circleMask = new Sprite();
			_circleMask.x = 15;
			_circleMask.y = 15;
			_circleMask.graphics.drawCircle(35, 35, 26, '#ffffff');
			
			_headIcon.mask = _circleMask;
			_headIcon.skin = "appRes/icon/unitPic/0000_b.png";
			
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			//trace("矿场数据", value);
			_detailInfo = value;
			
			_mineItem.outputTF.text = _detailInfo.output[0][1] + "/M";
			//_mineItem.outputTF.text = _detailInfo.output.split("=")[1] + "/M";
			_headIcon.skin = "appRes/icon/unitPic/0000_b.png";
			_mineItem.nameTF.color = _mineItem.LvTF.color = "#ffffff";
			
			if (_detailInfo.uid == 0)
			{
				_mineItem.barImg.skin = "common/mineBar_gray.png";
				
				var npcVo:MineFightVo = new MineFightVo();
				npcVo = GameConfigManager.mine_npc_vec[_detailInfo.mine_fight_level];
				
				
				_headIcon.skin = "appRes/icon/unitPic/" + npcVo.model + "_b.png";
				
				_mineItem.nameTF.text = GameLanguage.getLangByKey(npcVo.name);
				_mineItem.LvTF.text = npcVo.level;
				_mineItem.nameTF.color = _mineItem.LvTF.color = "#ffffff";
			}
			else
			{
				if (_detailInfo.user.heros.length > 0)
				{
					_headIcon.skin = "appRes/icon/unitPic/" + _detailInfo.user.heros[0] + "_b.png";
				}
				else
				{
					_headIcon.skin = "appRes/icon/unitPic/0000_b.png";
				}
				
				if (_detailInfo.user.is_enemy)
				{
					_mineItem.barImg.skin = "common/mineBar_red.png";
					_mineItem.nameTF.color = _mineItem.LvTF.color = "#fdada9";
				}
				else if (_detailInfo.uid == User.getInstance().uid)
				{
					_mineItem.barImg.skin = "common/mineBar_green.png";
					_mineItem.nameTF.color = _mineItem.LvTF.color = "#83ffa1";
				}
				else 
				{
					_mineItem.barImg.skin = "common/mineBar_gray.png";
				}
				_mineItem.nameTF.text = _detailInfo.user.name;
				_mineItem.LvTF.text = _detailInfo.user.level;
			}
			
		}
		
		override public function createUI():void
		{
			
		}
		
		override public function addEvent():void{
			//view.on(Event.CLICK, this, this.onClick);
			
			//Signal.intance.on(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler,[GuildEvent.CHANGE_GUILD_DESC]);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			//view.off(Event.CLICK, this, this.onClick);
			
			//Signal.intance.off(GuildEvent.CHANGE_GUILD_DESC, this, this.guildEventHandler);
			
			super.removeEvent();
		}
	}

}