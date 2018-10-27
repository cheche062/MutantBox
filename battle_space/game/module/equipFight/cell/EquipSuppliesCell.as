package game.module.equipFight.cell
{
	import MornUI.equipFight.EquipSuppliesCellUI;
	
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.data.ItemCell2;
	import game.module.equipFight.data.EquipBuyData;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	
	public class EquipSuppliesCell extends EquipSuppliesCellUI
	{
		
		private var itemCell:ItemCell2;
		private var _data:EquipBuyData;
		
		public function EquipSuppliesCell()
		{
			super();
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			itemCell = new ItemCell2();
			this.addChild(itemCell);
			itemCell.pos(20,49);
			
			buyBtn.on(Event.CLICK,this,clickFun);
		}
		
		private function clickFun(e:Event):void
		{
			WebSocketNetService.instance.sendData(ServiceConst.EQUIO_SUPPLIES_BUY,[data.sell_id]);
		}
		
		public function get data():EquipBuyData
		{
			return _data;
		}

		public function set data(value:EquipBuyData):void
		{
//			if( _data != value)
//			{
				_data = value;
				if(_data)
				{
					itemCell.data = _data.itemD;
					this.buyBtn.label = String(_data.priceNum);
					this.nameLbl.text = _data.itemD.vo.name;
					var sStr:String = GameLanguage.getLangByKey("L_A_44028");
					sStr = StringUtil.substitute( sStr , _data.num + "/" +_data.maxNum);
					this.xgNumLbl.text = sStr;
					this.buyBtn.disabled = !_data.num || !_data.state;
//					this.buyBtn.disabled = true;
				}
//			}
		}
		
	
		override public function set dataSource(value:*):void{
			super.dataSource = data = value;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			itemCell = null;
			_data = null;
			buyBtn.off(Event.CLICK,this,clickFun); 
		}
	}
}