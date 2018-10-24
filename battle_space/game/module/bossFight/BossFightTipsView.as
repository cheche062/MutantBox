package game.module.bossFight
{
	import MornUI.bossFight.BossFightTipsViewUI;
	
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GlobalRoleDataManger;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.ItemVo;
	import game.global.vo.User;
	import game.global.vo.worldBoss.BossBuyVo;
	import game.global.vo.worldBoss.BossSellItemVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	
	public class BossFightTipsView extends Box
	{
		private var m_ui:BossFightTipsViewUI;
		private var m_num:int;
		private var m_data:BossBuyVo;
		private var m_type:int;
		private var m_buyItem:BossSellItemVo;
		
		public function BossFightTipsView(p_ui:BossFightTipsViewUI,p_type:int,p_data:*)
		{
			super();
			m_ui=p_ui;
			m_type=p_type;
			if(m_type==0)
			{
				m_num=p_data;
				onInitUI();
			}
			else
			{
				m_buyItem=p_data;
				buyItemHandler();
			}
		}
		
		/**初始化ui*/
		private function onInitUI():void
		{
			// TODO Auto Generated method stub
			this.m_ui.LabelText.text="Buy "+m_num+" challenge?";
			this.m_ui.ItemList.visible=false;
			for (var i:int = 0; i < GameConfigManager.boss_buy_arr.length; i++) 
			{
				var l_bossBuyVo:BossBuyVo= GameConfigManager.boss_buy_arr[i];
				if(l_bossBuyVo.up>=m_num && l_bossBuyVo.down<=m_num)
				{
					m_data=l_bossBuyVo;
					break;
				}
			}
			var user:User = GlobalRoleDataManger.instance.user;
			var l_arr:Array=BossBuyVo(m_data).price.split("=");
			var l_itemVo:ItemVo=GameConfigManager.items_dic[l_arr[0]];
			var m_number:Number=BossBuyVo(m_data).getPrice()
			this.m_ui.CostImage.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			this.m_ui.BuyBtn.text.text=m_number.toString();
			if(user.water<m_data.getPrice())
			{
				this.m_ui.BuyBtn.text.color="#2d3c4d,#2d3c4d,#2d3c4d";
			}
			else
			{
				this.m_ui.BuyBtn.text.color="#ff0000,#ff0000,#ff0000";
			}
		}
		
		
		/**
		 *  
		 */				
		private function buyItemHandler():void
		{
			var l_itemVO:ItemVo=GameConfigManager.items_dic[m_buyItem.getItemId()];
			var l_itemdata:ItemData=new ItemData();
			l_itemdata.iid=l_itemVO.id;
			l_itemdata.inum=1;
			var l_name=l_itemVO.name;
			var l_arr:Array=new Array();
			this.m_ui.LabelText.text=GameLanguage.getLangByKey("L_A_46108");
			this.m_ui.ItemList.itemRender=ItemCell;
			l_arr.push(l_itemdata);
			this.m_ui.ItemList.array=l_arr;
			this.m_ui.ItemList.visible=true;
			var user:User = GlobalRoleDataManger.instance.user;
			var l_costItemVo:ItemVo=GameConfigManager.items_dic[m_buyItem.getCostItemId()];
			this.m_ui.CostImage.skin="appRes/icon/itemIcon/"+l_costItemVo.icon+".png";
			this.m_ui.BuyBtn.text.text=m_buyItem.sellPrice().toString();
			if(user.water<m_buyItem.sellPrice())
			{
				this.m_ui.BuyBtn.text.color="#2d3c4d,#2d3c4d,#2d3c4d";
			}
			else
			{
				this.m_ui.BuyBtn.text.color="#ff0000,#ff0000,#ff0000";
			}	
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy BossFightTipsView");
			m_ui = null;
			m_data = null;
			m_buyItem = null;
			super.destroy(destroyChild);
		} 
		
	}
}