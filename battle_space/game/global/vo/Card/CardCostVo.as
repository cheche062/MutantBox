package game.global.vo.Card
{
	import game.global.data.bag.BagManager;
	
	public class CardCostVo
	{
		public var level:int;
		public var free1:String;
		public var free2:String;
		public var pay1:String;
		public var pay2:String;
		public var high1:String;
		public var high2:String;
		public var dis1:Number;
		public var dis2:Number;
		public var dis3:Number;
		public var dis4:Number;
		public var dis5:Number;
		public var dis6:Number;
		public function CardCostVo()
		{
		}
		
		public function getCostId():int
		{
			var l_arr:Array=new Array();
			var l_costArr:Array=new Array();
			l_costArr=pay1.split("*");
			l_arr=l_costArr[0].split("=");
			return l_arr[0];
		}
		
		public function getFreeCostId():int
		{
			var l_arr:Array=new Array();
			var l_costArr:Array=new Array();
			l_costArr=free1.split("*");
			l_arr=l_costArr[0].split("=");
			return l_arr[0];
		}
		
		public function getNoCost(p_type:int,p_payType:int,p_textType:int):Array
		{
			var l_arr:Array=new Array();
			var l_num:int=0;
			var l_str:String="";
			var l_str1:String="";
			if(p_type==1)
			{
				if(p_payType==1)
				{
					l_str=free1;
				}
				else
				{
					l_str1=free2;
				}
			}
			else if(p_type==2)
			{
				if(p_payType==1)
				{
					l_str=pay1;
				}
				else
				{
					l_str1=pay2;
				}
			}else if(p_type==3)
			{
				if(p_payType==1)
				{
					l_str=high1;
				}
				else{
					l_str=high2;
				}
			}
			
			var l_costArr:Array=new Array();
			if(p_payType==1)
			{
				l_costArr=l_str.split("*");
				l_arr=l_costArr[0].split("=");
				l_num=BagManager.instance.getItemNumByID(l_arr[0]);
				if(p_textType==1)
				{
					return l_arr;
				}
				else
				{
					l_arr=l_costArr[1].split("=");
					return l_arr;
				}
			}
			else if(p_payType==2)
			{
				l_costArr=l_str1.split("*");
				l_arr=l_costArr[0].split("=");
				l_num=BagManager.instance.getItemNumByID(l_arr[0]);
				if(p_textType==1)
				{
					return l_arr;
				}
				else
				{
					l_arr=l_costArr[1].split("=");
					return l_arr;
				}
			}
			return l_arr;
		}
		
		public function isDis(p_type:int):Boolean
		{
			var l_dis:Number=0;
			switch(p_type)
			{
				case 1:
				{
					l_dis=dis1;
					break;
				}
				case 2:
				{
					l_dis=dis2;
					break;
				}
				case 3:
				{
					l_dis=dis3;
					break;
				}
				case 4:
				{
					l_dis=dis4;
					break;
				}
				case 5:
				{
					l_dis=dis5;
					break;
				}
				case 6:
				{
					l_dis=dis6;
					break;
				}
			}
			
			if(l_dis<1)
			{
				return true;
				
			}
			return false;
		}
		
		
		
		public function getDis(p_type:int):String
		{
			var l_str:String="";
			switch(p_type)
			{
				case 1:
				{
					l_str=(dis1*100)+"% OFF";
					break;
				}
				case 2:
				{
					l_str=(dis2*100)+"% OFF";
					break;
				}
				case 3:
				{
					l_str=(dis3*100)+"% OFF";
					break;
				}
				case 4:
				{
					l_str=(dis4*100)+"% OFF";
					break;
				}
				default:
				{
					break;
				}
			}
			
			return l_str;
		}
		
		public function getOffCost(p_type:int,p_cost:int):int
		{
			var l_dis:Number=0;
			switch(p_type)
			{
				case 1:
				{
					l_dis=1-dis1;
					break;
				}
				case 2:
				{
					l_dis=1-dis2;
					break;
				}
				case 3:
				{
					l_dis=1-dis3;
					break;
				}
				case 4:
				{
					l_dis=1-dis4;
					break;
				}
			}
			
			return parseInt(p_cost)/l_dis;
		}
		
		
		
		public function getCost(p_type:int,p_payType:int):Array
		{
			var l_arr:Array=new Array();
			var l_num:int=0;
			var l_str:String="";
			var l_str1:String="";
			var l_str2:String="";
			if(p_type==1)
			{
				if(p_payType==1)
				{
					l_str=free1;
				}
				else
				{
					l_str1=free2;
				}
			}
			else if(p_type==2)
			{
				if(p_payType==1)
				{
					l_str=pay1;
				}
				else
				{
					l_str1=pay2;
				}
			}
			else
			{
				if(p_payType==1)
				{
					l_str=high1;
				}
				else
				{
					l_str1=high2;
				}
			}
			var l_costArr:Array=new Array();
			if(p_payType==1)
			{
				trace("p_type:"+p_type+"p_payType:"+p_payType+"l_str:"+l_str);
				l_costArr=l_str.split("*");
				l_arr=l_costArr[0].split("=");
				l_num=BagManager.instance.getItemNumByID(l_arr[0]);
				if(l_num>=l_arr[1])
				{
					return l_arr;
				}
				else
				{
					l_arr=l_costArr[1].split("=");
					return l_arr;
				}
			}
			else if(p_payType==2)
			{
				l_costArr=l_str1.split("*");
				l_arr=l_costArr[0].split("=");
				l_num=BagManager.instance.getItemNumByID(l_arr[0]);
				if(l_num>=l_arr[1])
				{
					return l_arr;
				}
				else
				{
					l_arr=l_costArr[1].split("=");
					return l_arr;
				}
			}
			return l_arr;
		}
	}
}