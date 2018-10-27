package game.module.replay
{
	import MornUI.replay.ReplayItemUI;
	
	import game.common.DataLoading;
	import game.common.XTip;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.data.DBItem;
	import game.global.vo.User;
	import game.module.fighting.adata.frSoldierData;
	import game.module.fighting.cell.FightResultsSoldierCell;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.panel.BaseFightResultsView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	/**
	 * ReplayItem
	 * author:huhaiming
	 * ReplayItem.as 2017-5-3 下午5:22:50
	 * version 1.0
	 *
	 */
	public class ReplayItem extends ReplayItemUI
	{
		public var data:Object;
		public var getFightReportFun:Function;
		private var _h:Number = 90;
		public function ReplayItem()
		{
			super();
			this.infoBox.visible = false;
			sList.itemRender = FightResultsSoldierCell;
			this.on(Event.CLICK, this, this.onClick);
			sList.scale(0.78, 0.78);
		}
		
		override public function set selected(value:Boolean):void{
			super.selected = value;
			if(value){
				this.infoBox.visible = true;
				this.bg.selected = true;
				_h = 160;
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
				if(data.attacker_uid == User.getInstance().uid){//进攻方
					this.revengeBtn.visible = false;
					this.nameTF.text = data.name+"";
					this.lvTF.text = data.level+"";
					var dbNum:Number = getDBNum();
					if(dbNum > 0){
						this.dbTF.text = "+"+getDBNum();
						this.dbIcon.visible = this.dbTF.visible = true;
					}else{
						this.dbIcon.visible = this.dbTF.visible = false;
					}
					
					if(data.attacker_change_cup > 0){//胜利
						this.cupTF.text = "+"+data.attacker_change_cup;
						this.cupTF.color = "#81ff84";
						this.icon.skin = "replay/icon_win.png";
					}else{//失败
						this.cupTF.text = ""+data.attacker_change_cup;
						this.cupTF.color = "#ff9f9f";
						this.icon.skin = "replay/icon_lose.png";
					}
					
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
					sList.refresh();
				}else{//防守方
					this.revengeBtn.visible = true;
					
					this.nameTF.text = data.name+"";
					this.lvTF.text = data.level+"";
					this.dbIcon.visible = this.dbTF.visible = false;
					
					if(data.defender_change_cup > 0){//胜利
						this.cupTF.text = "+"+data.defender_change_cup;
						this.cupTF.color = "#81ff84";
						this.icon.skin = "replay/icon_win.png";
					}else{//失败
						this.cupTF.text = ""+data.defender_change_cup;
						this.cupTF.color = "#ff9f9f";
						this.icon.skin = "replay/icon_lose.png";
					}
					
					arr = [];
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
					sList.refresh();
				}
			}
			trace("data----------------------",data);
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case replayBtn:
//					DataLoading.instance.show();
//					WebSocketNetService.instance.sendData(ServiceConst.getFightReport,[data.reportId]);
					if(getFightReportFun)
						getFightReportFun(data.reportId);
					break;
				case revengeBtn:
					DataLoading.instance.show();
					var id = data.defender_uid;
					if(id == User.getInstance().uid){
						id = data.attacker_uid
					}
					WebSocketNetService.instance.sendData(ServiceConst.IN_REVENGE,[id]);
					break;
				case shareBtn:
					XTip.showTip("Comming soon~");
					break;
			}
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