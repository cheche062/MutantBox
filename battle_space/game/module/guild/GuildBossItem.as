package game.module.guild
{
	import game.common.XTipManager;
	import MornUI.guild.GuildActivityItmeUI;
	import MornUI.guild.GuildBossItemUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.ItemTips;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.GuildEvent;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.global.vo.guild.GuildBossVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.TextArea;
	
	public class GuildBossItem extends Box
	{
		private var _bossVo:GuildBossVo;
		private var itemMC:GuildBossItemUI;
		private var _data:Object;
		
		private var _reward0:Image;	
		private var _it1:String;
		
		private var _openItemPic:Image;
		
		private var _reTime:int = 0;
		private var _remTF:TextArea;
		
		private var _stateImg:Image;
		private var _stateTxt:Text;
		
		private var _stateIcon:Image;
		
		private var _isRefresh:Boolean = false;
		
		
		
		public function GuildBossItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			this.itemMC = new GuildBossItemUI();
			this.addChild(itemMC);
			
			_openItemPic = new Image();
			_openItemPic.skin = GameConfigManager.getItemImgPath('1');
			_openItemPic.width = _openItemPic.height = 50;
			_openItemPic.x = 90;
			_openItemPic.y = 295;
			itemMC.addChild(_openItemPic);
			_openItemPic.on(Event.CLICK, this, showTips);
			
			_reward0 = new Image();
			_reward0.skin = GameConfigManager.getItemImgPath('70000');
			_reward0.width = _reward0.height = 50;
			_reward0.x = 170;
			_reward0.y = 265;
			itemMC.addChild(_reward0);
			_reward0.on(Event.CLICK, this, showTips);
			
			this.itemMC.remTF.text = "";
			
			_stateImg = new Image();
			_stateImg.skin = "appRes/icon/guildIcon/bossSt_b.png";
			_stateImg.x = 40;
			_stateImg.y = 66;
			itemMC.addChild(_stateImg);
			
			_stateTxt = new Text();
			_stateTxt.font = "BigNoodleToo";
			_stateTxt.fontSize = 32;
			_stateTxt.color = "#ffffff";
			_stateTxt.strokeColor = "#000000";
			_stateTxt.stroke = 1;
			_stateTxt.x = 24;
			_stateTxt.y = 270;
			_stateTxt.align = "center";
			_stateTxt.width = 218;
			_stateTxt.height = 50;
			_stateTxt.text = "FIGHTING";
			itemMC.addChild(_stateTxt);
			
			_stateIcon = new Image();
			_stateIcon.skin = "appRes/icon/guildIcon/state_icon0.png";
			_stateIcon.x = 20;
			_stateIcon.y = -5;
			itemMC.addChild(_stateIcon);
			
			itemMC.setChildIndex(itemMC.lvBox, itemMC.numChildren - 1);
			itemMC.setChildIndex(itemMC.bossName, itemMC.numChildren - 1);
			
			view.selectBtn['clickSound'] = ResourceManager.getSoundUrl("ui_guild_select_boss",'uiSound')
			
			itemMC.noticeBtn.on(Event.CLICK, this, showTips);
			itemMC.selectBtn.on(Event.CLICK, this, selectBoss);
			Laya.timer.loop(1000, this, countReTime);
		}
		
		private function countReTime():void
		{			
			if (!_bossVo || !this.itemMC.remTF.visible)
			{
				return;
			}
			
			_reTime--;
			itemMC.freeTF.visible = false;
			if (_isRefresh)
			{
				this.itemMC.remTF.text = GameLanguage.getLangByKey("L_A_2601")+" "+TimeUtil.getTimeCountDownStr(_reTime,false);
			}
			else
			{
				this.itemMC.remTF.text = GameLanguage.getLangByKey("L_A_2600")+" "+TimeUtil.getTimeCountDownStr(_reTime,false);
			}
			
			if (_reTime<=0)
			{
				this.itemMC.remTF.text = "";
				
				if (_bossVo.state == 0 || _bossVo == 1)
				{
					return;
				}
				
				Signal.intance.event(GuildEvent.REFRESH_GUILD_BOSS);
				
				//WebSocketNetService.instance.sendData(ServiceConst.GUILD_BOSS_INIT);
				/*if (_isRefresh)
				{
					_isRefresh = false;
					_bossVo.state = 0;
					_stateImg.visible = false;
					_stateTxt.visible = false;
					_openItemPic.visible = view.openNumTF.visible = true;
					view.selectBtn.label = "open";
				}
				else
				{
					_bossVo.state = 3;
					_stateImg.visible = true;
					_stateTxt.visible = true;
					_stateImg.skin = "appRes/icon/guildIcon/bossSt_gray.png";
					_stateTxt.text = "outtime";
					view.selectBtn.label = "check";
				}
				return;*/
			}
			
			
		}
		
		private function showTips(e:Event):void
		{
			switch(e.target)
			{
				case itemMC.noticeBtn:
					XTipManager.showTip(GameLanguage.getLangByKey("L_A_2621"));
					break;
				case _openItemPic:
					ItemTips.showTip(_bossVo.cost.split("=")[0]);
					break;
				case _reward0:
					ItemTips.showTip(_it1);
					break;
				default:
					break;
			}
		}
		
		private function openBossOK():void 
		{
			if (!_bossVo)
			{
				return;
			}
			_bossVo.state = 1;
			view.selectBtn.label = "enter";
		}
		
		private function selectBoss(e:Event):void
		{
			var str:String = "";
			var cid:String = "";
			var cnum:int = 0;
			
			//state标识 0 未开启 1 已开启 2 打死了 3 超时
			switch(_bossVo.state)
			{
				case 0:
					if (_bossVo.lx == 0 && _bossVo.openTime == 0 && (User.getInstance().guildJob == 1 || User.getInstance().guildJob == 2))
					{
						WebSocketNetService.instance.sendData(ServiceConst.OPEN_GUILD_BOSS, [_bossVo.type]);
					}
					else
					{
						cid = _bossVo.cost.split("=")[0];
						cnum = _bossVo.cost.split("=")[1];
						
						if (User.getInstance().water < cnum)
						{
							XFacade.instance.openModule(ModuleName.ChargeView);
							return;
						}
						//str = "开启次BOSS需要支付"+ GameLanguage.getLangByKey(GameConfigManager.items_dic[cid].name)+ cnum +"";
						str = GameLanguage.getLangByKey("L_A_57002");
						str = str.replace("{0}", GameLanguage.getLangByKey(GameConfigManager.items_dic[cid].name));
						str = str.replace("{1}", cnum);
						
						XFacade.instance.openModule(ModuleName.ItemAlertView, [ GameLanguage.getLangByKey("L_A_57002"),
																			1,
																			cnum,
																			function(){									
																				WebSocketNetService.instance.sendData(ServiceConst.OPEN_GUILD_BOSS, [_bossVo.type]);
																			}]);
						
						/*AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str,0,function(v:int){
										if (v == AlertType.RETURN_YES)
										{
											WebSocketNetService.instance.sendData(ServiceConst.OPEN_GUILD_BOSS, [_bossVo.type]);
										}
									});*/
					}
					break;
				case 1:
				case 2:
				case 3:
					XFacade.instance.closeModule(GuildBossView);
					XFacade.instance.openModule(ModuleName.GuildBossDetail,_bossVo);
					break;
				
				default:
					break;
			}
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			
			this._data = value;
			
			if(!data||!data.id)
			{
				return;
			}
			
			
			_bossVo = GameConfigManager.intance.getGuildBossInfo(data.id);
			_bossVo.state = parseInt(data.status);
			_bossVo.type = data.type;
			_bossVo.fightTimes = data.ft;
			_bossVo.openTime = data.open_times;
			//trace("data:", data);
			//trace("bbbbbbb:", _bossVo);
			//trace("status:", _bossVo.state);
			
			
			itemMC.bImg.skin = "appRes/icon/guildIcon/"+_bossVo.icon+".png";
			itemMC.blueBg.visible = true;
			
			itemMC.bossName.text = GameLanguage.getLangByKey(_bossVo.name);
			for (var i:int = 0; i < 5; i++) 
			{
				if (i < _bossVo.level)
				{
					view["star" + i].visible = true;
				}
				else
				{
					view["star" + i].visible = false;
				}
			}
			view.selectBtn.label = "open";
			view.selectBtn.disabled = false;
			
			_openItemPic.skin = GameConfigManager.getItemImgPath(_bossVo.cost.split("=")[0]);
			view.openNumTF.text = _bossVo.cost.split("=")[1];
			
			_openItemPic.visible = view.openNumTF.visible = false;
			
			this.itemMC.remTF.visible = false;
			
			_stateImg.skin = "appRes/icon/guildIcon/bossSt_b.png";
			_stateIcon.skin = "appRes/icon/guildIcon/state_icon0.png";
			_isRefresh = false;
			//state标识 0 未开启 1 已开启 2 打死了 3 超时
			switch(_bossVo.state)
			{
				case 0:
					_stateImg.visible = false;
					_stateTxt.visible = false;
					_openItemPic.visible = view.openNumTF.visible = true;
					_stateIcon.skin = "appRes/icon/guildIcon/state_icon1.png";
					view.selectBtn.label = "open";
					_stateIcon.skin = "appRes/icon/guildIcon/state_icon0.png";
					itemMC.bImg.skin = "appRes/icon/guildIcon/" + _bossVo.icon + "_c.png";
					
					_reward0.visible = true;
					_reward0.mouseEnabled = true;
					itemMC.rewardLabel.visible = true;
					itemMC.noticeBtn.visible = true;
					break;
				case 1:
					_stateTxt.visible = true;
					_stateTxt.color = "#ff7f7f";
					_stateTxt.text = GameLanguage.getLangByKey("L_A_2602");// "FIGHTING";
					view.selectBtn.label = "enter";
					_reTime = data.end - TimeUtil.now / 1000;
					this.itemMC.remTF.visible = true;
					_stateIcon.skin = "appRes/icon/guildIcon/state_icon1.png";
					
					_reward0.visible = false;
					_reward0.mouseEnabled = false;
					itemMC.noticeBtn.visible = false;
					itemMC.rewardLabel.visible = false;
					itemMC.openRewardNum.text = "";
					break;
				case 2:
					_isRefresh = true;
					_stateTxt.visible = true;
					_stateTxt.color = "#ffef65";
					_stateTxt.text = GameLanguage.getLangByKey("L_A_2603");//"VICTORY";
					view.selectBtn.label = "check";
					_reTime = data.end - TimeUtil.now / 1000;
					this.itemMC.remTF.visible = true;
					_stateIcon.skin = "appRes/icon/guildIcon/state_icon2.png";
					
					_reward0.visible = false;
					_reward0.mouseEnabled = false;
					itemMC.rewardLabel.visible = false;
					itemMC.noticeBtn.visible = false;
					itemMC.rewardLabel.visible = false;
					itemMC.openRewardNum.text = "";
					break;
				case 3:
					_isRefresh = true;
					_reTime = data.end - TimeUtil.now / 1000;
					_stateImg.visible = true;
					_stateTxt.visible = true;
					_stateImg.skin = "appRes/icon/guildIcon/bossSt_gray.png";
					_stateTxt.text = GameLanguage.getLangByKey("L_A_2604");//"outtime";
					_openItemPic.visible = view.openNumTF.visible = true;
					view.selectBtn.label = "check";
					this.itemMC.remTF.visible = true;
					
					break;
				default:
					break;
			}
			
			if (_bossVo.open_r && _bossVo.state == 0)
			{
				_it1 = _bossVo.open_r.split("=")[0];
				_reward0.skin = GameConfigManager.getItemImgPath(_it1);
				_reward0.visible = true;
				_reward0.mouseEnabled = true;
				itemMC.openRewardNum.text = _bossVo.open_r.split("=")[1];
				itemMC.rewardLabel.visible = true;
				itemMC.noticeBtn.visible = true;
			}
			else
			{
				_reward0.skin = GameConfigManager.getItemImgPath(6);
				_reward0.visible = false;
				_reward0.mouseEnabled = false;
				itemMC.rewardLabel.visible = false;
				itemMC.openRewardNum.text = "";
				itemMC.noticeBtn.visible = false;
			}
			
			itemMC.freeTF.visible = false;
			if (parseInt(_bossVo.cost.split("=")[1]) == 0 || _bossVo.lx == 0)
			{
				if (_bossVo.openTime == 0 && (User.getInstance().guildJob == 1 || User.getInstance().guildJob == 2))
				{
					_openItemPic.visible = view.openNumTF.visible = false;
					itemMC.freeTF.visible = true;
				}
			}
			
			//itemMC.freeTF.visible = !this.itemMC.remTF.visible;
			
			countReTime();
		}
		
		public function get data():Object{
			return this._data;
		}
		
		private function get view():GuildBossItemUI{
			return itemMC;
		}
	}
}