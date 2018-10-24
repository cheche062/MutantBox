package game.module.chests
{
	import MornUI.chests.ChestMainCardItemUI;
	
	import game.common.ToolFunc;
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.consts.ServiceConst;
	import game.global.util.TimeUtil;
	import game.global.vo.DrawCardVo;
	import game.global.vo.ItemVo;
	import game.net.socket.WebSocketNetService;
	
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Tween;
	
	public class ChestMainCardItem extends Box
	{
		private var m_ui:ChestMainCardItemUI;
		private var m_type:int;
		private var m_drawCardSRMaxTime:int;
		private var m_data:DrawCardVo;
		private var m_select:Boolean;
		/**倒计时的清理函数*/
		private var clearTimerHandler:Function;
		
		public function ChestMainCardItem(p_ui:ChestMainCardItemUI,p_type:int,p_data:DrawCardVo)
		{
			super();
			this.m_ui=p_ui;
			this.m_type=p_type;
			m_data=p_data;
			doClearTimerHandler();
			initUI();
		}
		
		private function doClearTimerHandler():void {
			clearTimerHandler && clearTimerHandler();
			clearTimerHandler = null;
		}
		
		/**
		 * 
		 */
		private function initUI():void
		{
			m_select=false;
			m_drawCardSRMaxTime=10;
			var _cardCostLevel:int = m_data.cardCost.level;
			var level:int = _cardCostLevel - 1;
			m_ui.CostImage1.y=249;
			m_ui.CostText1.y=276;
			if(m_type==1)
			{
				m_ui.CardText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45040"),m_data.cardCost.level);
				m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45041");
				//第二层
				if(_cardCostLevel === 2 ){
					m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45041");
					//第三层
				}else if(_cardCostLevel === 3){
					m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45041");
				}
				m_ui.OnceBtn.visible = true;
				m_ui.OrText.visible = true;
				m_ui.CostImage.visible = true;
				m_ui.CostText.visible = true; 
				
			}
			else if(m_type==2)
			{
				m_ui.CardText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45042"),m_data.cardCost.level);
				m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45043");
				//第二层
				if(_cardCostLevel === 2 ){
					m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45043");
					//第三层
				}else if(_cardCostLevel === 3){
					m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45043");
				}
				m_ui.OnceBtn.visible = true;
				m_ui.OrText.visible = true;
				m_ui.CostImage.visible = true;
				m_ui.CostText.visible = true;
			}else
			{
				m_ui.CardText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45044"),m_data.cardCost.level);
				m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45045");
				//第二层
				if(_cardCostLevel === 2 ){
					m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45045");
					//第三层
				}else if(_cardCostLevel === 3){
					m_ui.TipsText.text=GameLanguage.getLangByKey("L_A_45045");
				}
				m_ui.OnceBtn.visible = true;
				m_ui.OnceImage.visible = true;
				m_ui.OnceCostTxt.visible = true;
				m_ui.LineOneImage.visible = false;
				m_ui.OrText.visible = false;
				m_ui.CostImage.visible = false;
				m_ui.CostText.visible = false;
				//				m_ui.LineTenImage.visible = false;
				m_ui.CostImage1.y+=35;
				m_ui.CostText1.y+=35;
			}
			m_ui.OnceBtn.text.text=GameLanguage.getLangByKey("L_A_45007");
			m_ui.TenTimeBtn.text.text=GameLanguage.getLangByKey("L_A_45008");
			m_ui.CardImage.skin="chests/ka_"+m_type.toString()+".png";
			
			m_ui.CardScheduleBox.visible=false;
			m_ui.DrawCardBox.visible=false;
			m_ui.CostImage1.visible=true;
			m_ui.CostText1.visible=true;
			setCardCost();
			if(m_type==1)
			{
				for(var i:int=0;i<10;i++)
				{
					var l_image:Image=this.m_ui.CardScheduleBox.getChildByName("scheduleImage0"+i.toString()) as Image;
					l_image.visible=false;
				}
				m_ui.NextNumText.visible=false;
				setDownCard(m_data.prop_1_card);
			}
			else if(m_type==2)
			{
				setDownCard(m_data.water_1_card);
			}else
			{
				setDownCard(m_data.water_1_card);
			}
			var l_imageMask:Image=new Image("chests/ka_1.png");
			l_imageMask.height=416;
			l_imageMask.pos(0,-20);
			this.m_ui.mask=l_imageMask;
			//this.m_ui.DrawCardBox.mask=l_imageMask;
			this.m_ui.DrawCardBox.x=-56;
			this.m_ui.DrawCardBox.y=376;
			this.m_ui.CardScheduleBox.x=-126;
			this.m_ui.CardScheduleBox.y=386;
		}
		
		/**
		 * 
		 */
		private function setCardCost()
		{
			var l_arr:Array=m_data.cardCost.getCost(m_type,1);
			var l_arr1:Array=m_data.cardCost.getNoCost(m_type,1,1);
			var l_arr2:Array=m_data.cardCost.getNoCost(m_type,1,2);
			var l_itemVo:ItemVo=GameConfigManager.items_dic[l_arr[0]];
			var l_itemVo1:ItemVo=GameConfigManager.items_dic[l_arr1[0]];
			var l_itemVo2:ItemVo=GameConfigManager.items_dic[l_arr2[0]];
			m_ui.OriginalOneImage.skin=m_ui.OnceImage.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			m_ui.OnceCostTxt.text=XUtils.formatResWith(l_arr[1]);
			m_ui.CostImage.skin="appRes/icon/itemIcon/"+l_itemVo2.icon+".png";
			m_ui.CostText.text="x"+XUtils.formatResWith(l_arr2[1]);
			m_ui.CostImage1.skin="appRes/icon/itemIcon/"+l_itemVo1.icon+".png";
			m_ui.CostText1.text="x"+XUtils.formatResWith(l_arr1[1]);
			l_arr=m_data.cardCost.getCost(m_type,2);
			l_itemVo=GameConfigManager.items_dic[l_arr[0]];
			
			m_ui.OriginalTenImage.skin=m_ui.TenTimeImage.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
			m_ui.TenTimesCostTxt.text=XUtils.formatResWith(l_arr[1]);
			
			if(m_data.cardCost.isDis(m_type*1)==true)
			{
				l_arr=m_data.cardCost.getCost(m_type,1);
				m_ui.OffIOnemage.visible=true;
				m_ui.LineOneImage.visible=true;
				m_ui.OriginalOneCostText.visible=true;
				m_ui.OriginalOneImage.visible=true;
				m_ui.OnceCostTxt.text=XUtils.formatResWith(l_arr[1]);
				m_ui.OriginalOneCostText.text=XUtils.formatResWith(m_data.cardCost.getOffCost(m_type*1,l_arr[1]));
				m_ui.OffOneText.text=m_data.cardCost.getDis(m_type*1);
				m_ui.OnceCostTxt.x=213;
				m_ui.OnceImage.x=169;
			}
			else
			{
				m_ui.OffIOnemage.visible=false;
				m_ui.LineOneImage.visible=false;
				m_ui.OriginalOneCostText.visible=false;
				m_ui.OriginalOneImage.visible=false;
				m_ui.OnceCostTxt.x=154;
				m_ui.OnceImage.x=105;
			}
			//			// 打折 (且不是紫色抽卡道具)
			//			if(m_data.cardCost.isDis(m_type*2)==true && l_itemVo.icon !== "20003")
			//			{
			//				l_arr=m_data.cardCost.getCost(m_type,2);
			//				m_ui.OffITenmage.visible=true;
			//				m_ui.LineTenImage.visible=true;
			//				m_ui.OriginalTenCostText.visible=true;
			//				m_ui.OriginalTenImage.visible=true;
			//				m_ui.TenTimesCostTxt.text=XUtils.formatResWith(l_arr[1]);
			//				m_ui.OriginalTenCostText.text=XUtils.formatResWith(m_data.cardCost.getOffCost(m_type*2,l_arr[1]));
			//				m_ui.OffTenText.text=m_data.cardCost.getDis(m_type*2);
			//				m_ui.TenTimesCostTxt.x=158;
			//				m_ui.TenTimeImage.x=323;
			//				
			//			}
			if(m_type==1)
			{
				GameConfigManager.card_param.freeId=l_arr[0];
				m_ui.TenTimeImage.x=106;
				m_ui.TenTimesCostTxt.x=158;
			}
			if(m_type==3)
			{
				
				l_arr=m_data.cardCost.getCost(m_type,2);
				trace("l_arr："+l_arr);
				l_itemVo=GameConfigManager.items_dic[l_arr[0]];
				m_ui.TenTimeImage.skin="appRes/icon/itemIcon/"+l_itemVo.icon+".png";
				m_ui.TenTimesCostTxt.text=XUtils.formatResWith(l_arr[1]);
				m_ui.TenTimeImage.visible = true;
				m_ui.TenTimesCostTxt.visible=true;
				m_ui.TenTimeImage.x=106;
				m_ui.TenTimesCostTxt.x=158;
				
				var l_arr3:Array=m_data.cardCost.getNoCost(m_type,1,1);
				var l_itemVo1:ItemVo=GameConfigManager.items_dic[l_arr3[0]];
				m_ui.CostImage1.skin="appRes/icon/itemIcon/"+l_itemVo1.icon+".png";
				m_ui.CostText1.text="x"+XUtils.formatResWith(l_arr3[1]);
			}
			// 打折 (且不是紫色抽卡道具)
			if(m_data.exploration_sale.length !=0 &&Number(m_data.exploration_sale[this.m_type].discount)!=100 && m_data.template_info.end_date_time>TimeUtil.nowServerTime)
			{
				var discount = Number(m_data.exploration_sale[this.m_type].discount);
				l_arr=m_data.cardCost.getCost(m_type,2);
				m_ui.OffITenmage.visible=true;
				m_ui.LineTenImage.visible=true;
				m_ui.OriginalTenCostText.visible=true;
				m_ui.OriginalTenImage.visible=true;
				//				m_ui.TenTimesCostTxt.text=XUtils.formatResWith(l_arr[1]);
				//				//原价格
				//				m_ui.OriginalTenCostText.text=XUtils.formatResWith(m_data.cardCost.getOffCost(m_type*2,l_arr[1]));
				//				//打折的
				//				m_ui.TenTimesCostTxt.text=XUtils.formatResWith(m_data.cardCost.getOffCost(m_type*2,l_arr[1])*discount/100);
				//				//不知道为什么以前第三个东东特殊处理，那就这样吧，加一个
				//				if(m_type==3)
				//				{
				//原价格
				m_ui.OriginalTenCostText.text=XUtils.formatResWith(l_arr[1]);
				//打折的
				m_ui.TenTimesCostTxt.text=XUtils.formatResWith(l_arr[1]*discount/100)
				//				}
				m_ui.OffTenText.text= discount + '% OFF';
				m_ui.TenTimesCostTxt.x=158;
				m_ui.TenTimeImage.x=323;
				clearTimerHandler = ToolFunc.limitHandler(Math.abs(m_data.template_info.end_date_time - TimeUtil.nowServerTime), function(time) {
					var detailTime = TimeUtil.toDetailTime(time);
					m_ui.OffTenTimeText.text = TimeUtil.timeToText(detailTime);
				}, function() {
					m_ui.OffTenTimeText.text = "";
					//					setTitle_bg("2");
					clearTimerHandler = null;
					trace('倒计时结束：：：');
					//刷新抽卡
					setCardCost();
				}, false);
			}
				// 不打折
			else
			{
				m_ui.OffITenmage.visible=false;
				m_ui.LineTenImage.visible=false;
				m_ui.OriginalTenCostText.visible=false;
				m_ui.OriginalTenImage.visible=false;
				m_ui.CardScheduleBox.visible = false;
				m_ui.TenTimesCostTxt.x=373;
				m_ui.TenTimeImage.x=323;
			}
			
			
		}
		
		/**抽卡进度*/
		private function setDownCard(p_index:int):void 
		{
			m_ui.NextNumText.text=StringUtil.substitute(GameLanguage.getLangByKey("L_A_45009"),(p_index+1));
			var l_index:int=m_drawCardSRMaxTime-p_index;
			for(var i:int=0;i<10;i++)
			{
				var l_image:Image=this.m_ui.CardScheduleBox.getChildByName("scheduleImage0"+i.toString()) as Image;
				if((l_index-1)>i)
				{
					l_image.skin="chests/progress11.png";
				}
				else
				{
					l_image.skin="chests/progressbg.png";
				}
			}
		}
		
		/**
		 * 
		 */
		public function selectCard():void
		{
			m_select=!m_select;
			//			m_ui.CardScheduleBox.visible=m_select;
			m_ui.DrawCardBox.visible=m_select;
			m_ui.CostImage.visible=!m_select;
			m_ui.CostImage1.visible=!m_select;
			
			m_ui.CostText.visible=!m_select;
			m_ui.CostText1.visible=!m_select;
			m_ui.OrText.visible=!m_select;
			if(m_type == 3)
			{
				m_ui.OrText.visible = false;
				m_ui.CostImage.visible = false;
				m_ui.CostText.visible = false;
				m_ui.CardScheduleBox.visible = false;
				//				m_ui.LineTenImage.visible = false;
				m_ui.TenTimeImage.visible = true;
				m_ui.TenTimesCostTxt.visible=true;
			}
			if(m_select==true)
			{
				Tween.to(this.m_ui.CardScheduleBox,{x:-70,y:12},200);
				Tween.to(this.m_ui.DrawCardBox,{x:0,y:0},200);
			}
			else
			{
				Tween.to(this.m_ui.CardScheduleBox,{x:0,y:376},200);
				Tween.to(this.m_ui.DrawCardBox,{x:-126,y:386},200);
			}
		}
		
		override public function destroy(destroyChild:Boolean=true):void {
			super.destroy();
			doClearTimerHandler();
		}
	}
}