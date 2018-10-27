package game.global.vo.facebookPay
{
	public class PackVo
	{
		public var id:int;
		public var name:String;
		public var type:int;
		public var img_fb:String;
		public var img_gw:String;
		public var currencyList:Array;
		public var productsVo:ProductsVo;
		public var selectId:int;
		
		public var pack_currency_id:int;
		
		public function PackVo()
		{
		}
		
		public function setcurrencyList(p_data:Object):void
		{
			currencyList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:CurrencyInfoVo=new CurrencyInfoVo();
				vo.pack_id=parseInt(i.pack_id);
				vo.pack_amount=i.pack_amount;
				vo.pack_currency_id=i.pack_currency_id;
				pack_currency_id=i.pack_currency_id;;
				currencyList.push(vo);
			}
		}
		
		public function setProductsData(p_data:Object):void
		{
			productsVo=new ProductsVo();
			productsVo.coin_id=p_data.coin_id;
			productsVo.platform_id=p_data.platform_id;
			productsVo.number=p_data.number;
			productsVo.presented=p_data.presented;
			productsVo.img=p_data.img;
			productsVo.name=p_data.name;
			
		}
		
		
		
		
	}
}