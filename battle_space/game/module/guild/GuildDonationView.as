package game.module.guild
{
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.base.BaseDialog;
	import game.common.ItemTips;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.guild.GuildContributeVo;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import laya.utils.Tween;
	import MornUI.guild.GuildActivityViewUI;
	import MornUI.guild.GuildDonationViewUI;
	
	import game.common.base.BaseView;
	
	import laya.events.Event;
	
	public class GuildDonationView extends BaseDialog
	{
		private var user:User = User.getInstance();
		
		private var donateType:int = 1;
		
		private var rewardItemImg0:Image;
		private var rewardNumTxt0:TextArea;
		
		private var rewardItemImg1:Image;
		private var rewardNumTxt1:TextArea;
		
		private var donateItemImg:Image;
		private var donateNumTxt:TextArea;
		
		private var rID_0:String;
		private var rID_1:String;
		
		public function GuildDonationView()
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			var cvo:GuildContributeVo;
			var id:String;
			var num:int;
			var str:String = "";
			
			switch(e.target)
			{
				case this.view.silverAdvBtn:
					this.view.silverAdvBtn.lable = "donate again";
					donateType = 1;
					cvo = GameConfigManager.intance.getContributeInfo(user.silverContribute, 1);
					id = cvo.consumption.split("=")[0];
					num = parseInt(cvo.consumption.split("=")[1]);
					
					if (User.getInstance().water < num)
					{
						XFacade.instance.openModule(ModuleName.ChargeView);
						return;
					}
					
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_DONATE, [1]);
					
					/*str = "本次捐献需要花费" + GameLanguage.getLangByKey(GameConfigManager.items_dic[id].name) + num + "个";
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str, 0, function(v:int){
						if (v == AlertType.YES)
						{
							//WebSocketNetService.instance.sendData(ServiceConst.GUILD_DONATE, [1]);
						}
					});*/
					
					break;
				case this.view.goldAdvBtn:
					/*donateType = 2;
					cvo = GameConfigManager.intance.getContributeInfo(user.goldContribute, 2);
					id = cvo.consumption.split("=")[0];
					num = parseInt(cvo.consumption.split("=")[1]);
					str = "本次捐献需要花费" + GameLanguage.getLangByKey(GameConfigManager.items_dic[id].name) + num + "个";
					AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW, str, 0, function(v:int){
						if (v == AlertType.YES)
						{
							WebSocketNetService.instance.sendData(ServiceConst.GUILD_DONATE, [2]);
						}
					});*/
					break;
				case this.view.cancelBtn:
					onClose();
					break;
				default:
					break;
				
			}
		}
		
		/**获取服务器消息*/
		private function onResult(cmd:int, ...args):void
		{
			//trace("donate: ",args);
			// TODO Auto Generated method stub
			var len:int = 0;
			var i:int=0;
			switch(cmd)
			{
				case ServiceConst.GUILD_DONATE:
					switch(parseInt(args[1][0]))
					{
						case 1:
							user.silverContribute++;
							refreshDonateInfo();
							Tween.clearTween(donateNumTxt);
							donateNumTxt.scaleX = donateNumTxt.scaleY = 1;
							Tween.from(donateNumTxt, {scaleX:1.5,scaleY:1.5},1000);
							break;
						case 2:
							user.goldContribute++;
							break;
						default:
							break;
					}
					WebSocketNetService.instance.sendData(ServiceConst.GUILD_BASE_INFO,[]);
					break;
				default:
					break;
			}
		}
		
		private function refreshDonateInfo():void
		{
			var cvo:GuildContributeVo = GameConfigManager.intance.getContributeInfo(user.silverContribute, 1);
			
			donateItemImg.skin = GameConfigManager.getItemImgPath(cvo.consumption.split("=")[0]);
			donateNumTxt.text = "x" + cvo.consumption.split("=")[1];
			
			/*rID_0 = cvo.reward.split(";")[0].split("=")[0];
			rewardItemImg0.skin = GameConfigManager.getItemImgPath(rID_0);
			rewardNumTxt0.text = cvo.reward.split(";")[0].split("=")[1];
			
			rID_1 = cvo.reward.split(";")[1].split("=")[0];
			rewardItemImg1.skin = GameConfigManager.getItemImgPath(rID_1);
			rewardNumTxt1.text = cvo.reward.split(";")[1].split("=")[1];*/
			
			this.view.gfNumTxt.text = User.getInstance().guildFundation;
			
			view.itemTF.text = user.contribution;
			view.add1TF.text = "+" + cvo.reward.split(";")[0].split("=")[1];
			
			view.gExpTF.text = user.guildExp + "/" + GameConfigManager.guild_info_vec[user.guildLv].re_qian;
			view.expBar.value = user.guildExp / GameConfigManager.guild_info_vec[user.guildLv].re_qian;
			view.add2TF.text = "EXP+" + cvo.reward.split(";")[1].split("=")[1];
		}
		
		override public function show(...args):void{
			super.show();
			this.view.silverAdvBtn.lable = "donate";
			
			this.view.gfNumTxt.text = User.getInstance().guildFundation;
			refreshDonateInfo();
		}
		
		override public function close():void{
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GuildDonationViewUI();
			this.addChild(_view);
			
			this.closeOnBlank = true;
			
			donateItemImg = new Image();
			donateItemImg.skin = GameConfigManager.getItemImgPath("1");
			donateItemImg.width = donateItemImg.height = 40;
			donateItemImg.x = this.view.silverAdvBtn.x + 20;
			donateItemImg.y = this.view.silverAdvBtn.y - 40;
			view.addChild(donateItemImg);
			
			donateNumTxt = new TextArea();
			donateNumTxt.font = "Futura";
			donateNumTxt.fontSize = 14;
			donateNumTxt.color = "#ffffff";
			donateNumTxt.height = 30;
			donateNumTxt.x = donateItemImg.x+30;
			donateNumTxt.y = donateItemImg.y+15;
			donateNumTxt.align= "left"
			donateNumTxt.text = "x1";
			donateNumTxt.mouseEnabled = false;
			view.addChild(donateNumTxt);
			
			view.gfImg.skin = GameConfigManager.getItemImgPath(93201);
			view.gfAddTxt.text ="+"+GameConfigManager.guild_params[28].value;
			
			
			UIRegisteredMgr.AddUI(view.silverAdvBtn,"GuildDonateBtn");
			UIRegisteredMgr.AddUI(view.cancelBtn,"GuildDonateClose");
			
		}
		
		private function showRewardTips(e:Event):void 
		{
			switch(e.target)
			{
				case rewardItemImg0:
					ItemTips.showTip(rID_0);
					break;
				case rewardItemImg1:
					ItemTips.showTip(rID_1);
					break;
				default:
					break;
			}
		}
		
		override public function dispose():void{
			super.destroy();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.GUILD_DONATE),this,onResult,[ServiceConst.GUILD_DONATE]);
			Signal.intance.on(User.PRO_CHANGED, this, this.refreshDonateInfo);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.GUILD_DONATE), this, onResult);
			Signal.intance.off(User.PRO_CHANGED, this, this.refreshDonateInfo);
			
			super.removeEvent();
		}
		
		private function get view():GuildDonationViewUI{
			return _view;
		}
	}
}