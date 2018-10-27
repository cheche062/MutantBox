package game.module.mineFight 
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.AnimationUtil;
	import game.common.base.BaseDialog;
	import game.common.baseScene.SceneType;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.mine.MineFightVo;
	import game.global.vo.User;
	import game.module.fighting.mgr.FightingManager;
	import game.net.socket.WebSocketNetService;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.utils.Handler;
	import MornUI.mineFight.MineInfoViewUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MineInfoView extends BaseDialog 
	{
		
		private var _sMineInfo:Object = { };
		
		private var _roleImg:Image;
		
		public function MineInfoView() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			var str:String = "";
			switch(e.target)
			{
				case view.alBtn:
					
					if (view.alBtn.label == GameLanguage.getLangByKey("L_A_2524"))
					{
						if (User.getInstance().mineIsProtect)
						{
							str = GameLanguage.getLangByKey("L_A_54022");
							
							str = str.replace(/##/g, "\n");
							
							AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,0,function(v:int){
										if (v == AlertType.RETURN_YES)
										{
											WebSocketNetService.instance.sendData(ServiceConst.LEAVE_MINE, [_sMineInfo.mine_point_id]);
										}
									});
							return;
						}
						WebSocketNetService.instance.sendData(ServiceConst.LEAVE_MINE, [_sMineInfo.mine_point_id]);
						return;
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.CHECK_MINE_FIGHT, [_sMineInfo.mine_point_id]);
					
					break;
				case view.closeBtn:
					close();
					break;
				default:
					break;
			}
		}
		
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			_sMineInfo = args[0];
			//trace("矿场详情", _sMineInfo);
			view.outPutTF.text = _sMineInfo.output[0][1] + "/M";
			_roleImg.skin = "appRes/icon/unitPic/0000_c.png";
			
			if (_sMineInfo.uid == 0)
			{
				var npcVo:MineFightVo = new MineFightVo();
				npcVo = GameConfigManager.mine_npc_vec[_sMineInfo.mine_fight_level]
				
				_roleImg.skin = "appRes/icon/unitPic/" + npcVo.model + "_c.png";
				
				view.nameTF.text = GameLanguage.getLangByKey(npcVo.name);
				view.LvTF.text = npcVo.level;
				view.PowerTF.text = npcVo.br
				view.guildTF.text = "";
				
			}
			else
			{
				if (_sMineInfo.user.heros.length > 0)
				{
					_roleImg.skin = "appRes/icon/unitPic/" + _sMineInfo.user.heros[0] + "_c.png";
				}
				else
				{
					_roleImg.skin = "appRes/icon/unitPic/0000_c.png";
				}
				
				view.nameTF.text = _sMineInfo.user.name;
				view.LvTF.text = _sMineInfo.user.level;
				view.PowerTF.text = _sMineInfo.user.power;
				view.guildTF.text = _sMineInfo.user.guide_name;
				
			}
			
			
			
			if (User.getInstance().uid == _sMineInfo.user.uid)
			{
				view.alBtn.label = GameLanguage.getLangByKey("L_A_2524");
			}
			else
			{
				view.alBtn.label = "L_A_54015";
			}
			
		}
		
		/**获取服务器消息*/
		private function serviceResultHandler(cmd:int, ...args):void
		{
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.LEAVE_MINE:
					WebSocketNetService.instance.sendData(ServiceConst.MINE_INIT, []);
					close();
					
					break;
				case ServiceConst.CHECK_MINE_FIGHT:
					
					if (args[1].isFight)
					{
						FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_KUANGCHANG, _sMineInfo.mine_point_id,new Handler(this,openMineView));
						return;
					}
					if (parseInt(args[1].win) == 1)
					{
						XTip.showTip(GameLanguage.getLangByKey("L_A_54019"));
						WebSocketNetService.instance.sendData(ServiceConst.MINE_INIT, []);
						close();
					}
					
					break;
				default:
					break;
			}
		}
		
		private function openMineView():void
		{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_HOME);
			
			Laya.timer.once(500, this, function() {
				XFacade.instance.openModule(ModuleName.MineFightView);
				} );
			
		}
		
		/**服务器报错*/
		private function onError(...args):void
		{
			var cmd:Number = args[1];
			var errStr:String = args[2]
			XTip.showTip( GameLanguage.getLangByKey(errStr));
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
		
		override public function createUI():void
		{
			this._view = new MineInfoViewUI();
			this.addChild(_view);
			
			_roleImg = new Image();
			_roleImg.x = 110;
			_roleImg.y = 120;
			_roleImg.skin = "appRes/icon/unitPic/1009_c.png";
			view.addChild(_roleImg);
			
		}
		
		override public function addEvent():void
		{
			view.on(Event.CLICK, this, this.onClick);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.LEAVE_MINE),this,serviceResultHandler,[ServiceConst.LEAVE_MINE]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.CHECK_MINE_FIGHT), this, serviceResultHandler, [ServiceConst.CHECK_MINE_FIGHT]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, this.onError);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.LEAVE_MINE),this,serviceResultHandler);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.CHECK_MINE_FIGHT), this, serviceResultHandler);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ERROR),this,this.onError);
			
			super.removeEvent();
		}
		
		
		
		private function get view():MineInfoViewUI{
			return _view;
		}
		
	}

}