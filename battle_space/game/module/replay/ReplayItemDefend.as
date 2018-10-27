package game.module.replay
{	
	import MornUI.replay.ReplayItem1UI;
	
	import game.common.DataLoading;
	import game.common.XTip;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBInvasion;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	import game.module.alert.XAlert;
	import game.module.fighting.adata.frSoldierData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.panel.BaseFightResultsView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	/**
	 * ReplayItemDefend
	 * author:huhaiming
	 * ReplayItem.as 2017-5-3 下午5:22:50
	 * version 1.0
	 *
	 */
	public class ReplayItemDefend extends ReplayItem1UI
	{
		public var data:Object;
		public var getFightReportFun:Function;
		private var _h:Number = 90;
		public static var curModel:int = 1;
		public function ReplayItemDefend()
		{
			super();
			this.infoBox.visible = false;
			sList.itemRender = FightResultsSoldierCell;
			sList.hScrollBarSkin = "";
			this.on(Event.CLICK, this, this.onClick);
			sList.scale(0.78, 0.78);
		}
		
		override public function set selected(value:Boolean):void{
			super.selected = value;
			if(value){
				this.infoBox.visible = true;
				this.bg.selected = true;
				if(curModel == ReplayView.T_ATTACK){
					_h = 221;
				}else{
					_h = 161;
				}
				//trace("oxxoo", curModel, _h)
			}else{
				this.bg.selected = false;
				this.infoBox.visible = false;
				_h = 90;
			}
		}
		
		override public function set dataSource(value:*):void{
			if(value){
				if(value is String){
					this.data = JSON.parse(value);
				}else{
					this.data = value;
				}
				//trace("基地互动战报数据:", data);
				if(data.attacker_uid == User.getInstance().uid){//进攻方
					this.dbTF.color = '#81ff84';
					this.resBox.visible = true;
					this.revengeBtn.visible = false;
					this.resLabel.text = "L_A_49627";
					this.nameTF.text = data.name+"";
					this.lvTF.text = data.level+"";
					var dbNum:Number = getDBNum();
					if(dbNum > 0){
						this.dbTF.text = "+"+dbNum;
						//this.dbIcon.visible = this.dbTF.visible = true;
					}else if(dbNum < 0){
						this.dbTF.text = "-"+dbNum;
						//this.dbIcon.visible = this.dbTF.visible = false;
					}else{
						this.dbTF.text = "0";
					}
					
					this.cupIcon.visible = this.cupTF.visible = true;
					this.tfWin.visible = this.tfLose.visible = false;
					if(data.attacker_change_cup > 0){//胜利
						this.cupTF.text = "+"+data.attacker_change_cup;
						this.cupTF.color = "#81ff84";
						this.tfWin.visible = true;
					}else{//失败
						this.cupTF.text = ""+data.attacker_change_cup;
						this.cupTF.color = "#ff9f9f";
						this.tfLose.visible = true;
						if(data.attacker_change_cup+"" == "0"){
							this.cupIcon.visible = this.cupTF.visible = false;
						}
					}
					
					//资源抢夺
					this.breadTF.text = this.goldTF.text = this.steelTF.text = this.foodTF.text = this.stoneTF.text = "-";
					this.goldTF.text = getRes(DBItem.GOLD,true);
					this.steelTF.text = getRes(DBItem.STEEL,true);
					this.foodTF.text = getRes(DBItem.FOOD,true);
					this.stoneTF.text = getRes(DBItem.STONE, true);
					this.breadTF.text = getRes(DBItem.BREAD,true);
					
					var arr:Array = [];
					if(data.army.length == 0){
						attLabel.visible = false;
						tipLabel.visible = true;
						tipLabel.text = GameLanguage.getLangByKey("L_A_49615");
					}else{
						attLabel.visible = true;
						tipLabel.visible = false;
						for (var i:int = 0; i < data.army.length; i++) 
						{
							var sdata:Object = data.army[i];
							var sod:frSoldierData = new frSoldierData();
							sod.addExp = Number(sdata.addExp);
							sod.uid = Number(sdata.id);
							sod.uExp = Number(sdata.exp);
							sod.uLev = Number(sdata.level);
							sod.uNum = Number(sdata.surplus);
							sod.uMaxNum = Number(sdata.total);	
							arr.push(sod);
						}
					}
					sList.array = BaseFightResultsView.filterSoldierData(arr);
					if(sList.array.length == 0){
						attLabel.text = GameLanguage.getLangByKey("L_A_4403")
					}else{
						attLabel.text = GameLanguage.getLangByKey("L_A_49628");
					}
					sList.refresh();
					bg.skin = "replay/btn_7.png";
					bg.height = 221;
					this.replayBtn.y = shareBtn.y = 30;
				}else{//防守方
					this.dbTF.color = '#ffffff';
					bg.skin = "replay/btn_6.png";
					bg.height = 161;
					this.replayBtn.y = shareBtn.y = 4;
					this.sList.visible = this.tipLabel.visible = attLabel.visible = false;
					
					if((TimeUtil.now - data.time*1000)/1000 < 3*TimeUtil.OneDaySceond){
						this.revengeBtn.visible = true;
					}else{
						this.revengeBtn.visible = false;
					}
					
					this.nameTF.text = data.name+"";
					this.lvTF.text = data.level+"";
					this.resLabel.text = "L_A_49628";
					
					var dbNum:* = getRes(DBItem.DB);
					if(dbNum > 0){
						this.dbTF.text = "-"+dbNum;
						//this.dbIcon.visible = this.dbTF.visible = true;
					}else{
						this.dbTF.text = "0";
						//this.dbIcon.visible = this.dbTF.visible = false;
					}
					
					this.cupIcon.visible = this.cupTF.visible = false;
					this.tfWin.visible = this.tfLose.visible = false;
					if(data.defender_change_cup > 0){//胜利
						this.cupTF.text = "+"+data.defender_change_cup;
						this.cupTF.color = "#81ff84";
						this.tfWin.visible = true;
						this.tipLabel.visible = true;
						this.tipLabel.text = "L_A_49532";
						this.resBox.visible = false;
					}else{//失败
						this.cupTF.text = ""+data.defender_change_cup;
						this.cupTF.color = "#ff9f9f";
						this.tfLose.visible = true
						this.resBox.visible = true;
					}
					
					//资源损失
					this.breadTF.text=this.goldTF.text = this.steelTF.text = this.foodTF.text = this.stoneTF.text = "-";
					this.goldTF.text = getRes(DBItem.GOLD);
					this.steelTF.text = getRes(DBItem.STEEL);
					this.foodTF.text = getRes(DBItem.FOOD);
					this.stoneTF.text = getRes(DBItem.STONE);
					this.breadTF.text = getRes(DBItem.BREAD);
					
					
					/*arr = [];
					if(data.army.length == 0){
						attLabel.visible = false;
						tipLabel.visible = true;
						tipLabel.text = GameLanguage.getLangByKey("L_A_49616");
					}else{
						tipLabel.visible = false;
						attLabel.visible = true;
						for (i = 0; i < data.army.length; i++) 
						{
							sdata = data.army[i];
							sod = new frSoldierData();
							sod.addExp = Number(sdata.addExp);
							sod.uid = Number(sdata.id);
							sod.uExp = Number(sdata.exp);
							sod.uLev = Number(sdata.level);
							sod.uNum = Number(sdata.surplus);
							sod.uMaxNum = Number(sdata.total);	
							arr.push(sod);
						}
					}
					sList.array = arr;
					sList.refresh();*/
				}
			}
			//trace("data----------------------",data,TimeUtil.now - data.time*1000);
		}
		
		private function getRes(type:int, isRob:Boolean = false):String{
			var info:Object = data.itemsLost;
			if(isRob){
				info = data.itemsGet;
			}
			//trace("getRes::",type,info);
			for(var i:String in info){
				if(info[i].id == type){
					return info[i].num;
				}
			}
			return "-";
		}
		
		private function onClick(e:Event):void{
			//trace(data);
			switch(e.target){
				case replayBtn:
//					DataLoading.instance.show();
//					WebSocketNetService.instance.sendData(ServiceConst.getFightReport,[data.reportId]);
					if(getFightReportFun)
						getFightReportFun(data.reportId);
					break;
				case revengeBtn:
					var price:String = DBInvasion.getBuyPrice(User.getInstance().sceneInfo.base_rob_info.search_number);
					if(price){
						var tmp:Array = price.split("=");
						
						
						var handler:Handler = Handler.create(this,callback)
						var str:String = GameLanguage.getLangByKey("L_A_23");
						str = str.replace(/{(\d+)}/,tmp[1]);
						var item:ItemData = new ItemData;
						item.iid = tmp[0];
						item.inum = tmp[1];
						ConsumeHelp.Consume([item],handler);
					}else{
						callback();
					}
					break;
				case shareBtn:
					XTip.showTip("Comming soon~");
					break;
			}
		}
		
		private function callback():void{
			DataLoading.instance.show();
			var id = data.defender_uid;
			if(id == User.getInstance().uid){
				id = data.attacker_uid
			}
			WebSocketNetService.instance.sendData(ServiceConst.IN_REVENGE,[id]);
		}
		
		private function getDBNum():Number{
			for(var i:String in data.itemsGet){
				if(data.itemsGet[i].id == DBItem.DB){
					return data.itemsGet[i].num
				}
			}
			return 0;
		}
		
		override public function get height():Number{
			return _h;
		}
	}
}