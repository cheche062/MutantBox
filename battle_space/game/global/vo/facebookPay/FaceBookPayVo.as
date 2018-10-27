package game.global.vo.facebookPay
{
	import game.global.GameSetting;

	public class FaceBookPayVo
	{
		public var selectId:int;
		public var region_name:String;
		public var country_code:String;
		public var currencyList:Array;
		public var payWayList:Array;
		public var countriesList:Array;
		public var packList:Array;
		public var payInfoList:Array;

		public function FaceBookPayVo()
		{

		}

		public function setCurrencyList(p_data:Object):void
		{
			currencyList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:CurrencyVo=new CurrencyVo();
				vo.id=parseInt(i.id);
				vo.name=i.name;
				vo.symbol=i.symbol;
				currencyList.push(vo);
			}

		}

		public function setPayWay(p_data:Object):void
		{
			payWayList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:PayWayVo=new PayWayVo();
				vo.id=parseInt(i.id);
				vo.pay_way=i.pay_way;
				vo.img=i.img;
				vo.img_url=i.img_url;
				payWayList.push(vo);
			}

		}

		public function setCountries(p_data:Object):void
		{
			countriesList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:CountriesVo=new CountriesVo();
				vo.id=parseInt(i.id);
				vo.region_name=i.region_name;
				vo.country_code=i.country_code;
				countriesList.push(vo);
			}
		}

		public function setPack(p_data:Object):void
		{
			packList=new Array();
			for each (var i:Object in p_data)
			{
				for each (var l_obj:Object in i)
				{
					var vo:PackVo=new PackVo();
					vo.id=parseInt(l_obj.id);
					vo.img_fb=l_obj.img_fb;
					vo.img_gw=l_obj.img_gw;
					vo.name=l_obj.name;
					vo.type=l_obj.type;
					vo.setcurrencyList(l_obj.currency);
					vo.setProductsData(l_obj.products[0]);
					packList.push(vo);
				}
			}
		}

		public function setPayInfo(p_data:Object):void
		{
			payInfoList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:PayInfoVo=new PayInfoVo();
				vo.id=parseInt(i.id);
				vo.country_id=parseInt(i.country_id);
				vo.channel_way_id=parseInt(i.channel_way_id);
				vo.currency_id=parseInt(i.currency_id);
				vo.setGwList(i.channel_way_id.gw);
				vo.setFbList(i.channel_way_id.fb);
				payInfoList.push(vo);
			}
		}

		public function getCountriesList():String
		{
			var l_str:String="";

			for (var i:int=0; i < countriesList.length; i++)
			{
				var l_vo:CountriesVo=countriesList[i];
				if (l_str == "")
				{
					l_str+=l_vo.region_name;
				}
				else
				{
					l_str+="," + l_vo.region_name;
				}
			}


			return l_str;
		}

		public function getCurrencyData(p_str:String):CountriesVo
		{
			for (var i:int=0; i < countriesList.length; i++)
			{
				var vo:CountriesVo=countriesList[i];
				if (vo.region_name == p_str)
				{
					return vo;
				}
			}
			return null;
		}


		public function getPackListByPayId(p_id:int, p_chanelId:int):Array
		{
			trace("getPackListByPayId", p_id, p_chanelId)
			var l_vo:FaceBookGwVo;
			var l_arr:Array=new Array();


			for (var i:int=0; i < payInfoList.length; i++)
			{
				var vo:PayInfoVo=payInfoList[i];

				if (vo.country_id == p_id)
				{
					l_vo=vo.getGwInfo(p_chanelId);
				}
			}
			trace("l_vo====>>",l_vo)
			trace("xx",packList)
			for (var i:int=0; i < packList.length; i++)
			{
				var l_packVo:PackVo=packList[i];
				for (var j:int=0; j < l_vo.pack_id.length; j++)
				{
					if (l_packVo.id == l_vo.pack_id[j])
					{
						l_arr.push(l_packVo);
					}
				}
			}
			return l_arr;
		}

		public function getCountyIndex(p_name:String):int
		{
			if (p_name == undefined || p_name == "" || p_name == null)
			{
				p_name="United States";
			}


			for (var i:int=0; i < countriesList.length; i++)
			{
				var l_vo:CountriesVo=countriesList[i];
				if (p_name == l_vo.region_name)
				{
					return l_vo.id + 1;
				}
			}
		}

		public function getPayWayListByCountry(p_id:int):Array
		{
			var l_vo:PayInfoVo;
			var l_arr:Array=new Array();
			var l_payidList:Array=new Array();
			for (var i:int=0; i < payInfoList.length; i++)
			{
				var vo:PayInfoVo=payInfoList[i];

				if (vo.country_id == p_id)
				{
					l_vo=vo
				}
			}
			if (l_vo == undefined)
			{
				return l_arr;
			}

			if (GameSetting.Platform == GameSetting.P_FB)
			{
				if (l_vo.fbList != null && l_vo.fbList != undefined)
				{
					l_payidList=l_vo.fbList;
				}
			}
			else
			{
				if (l_vo.gwList != null && l_vo.gwList != undefined)
				{
					l_payidList=l_vo.gwList;
				}
			}
			for (var i:int=0; i < l_payidList.length; i++)
			{
				var vo:FaceBookGwVo=l_payidList[i];
				for (var j:int=0; j < payWayList.length; j++)
				{
					var l_payWayVo:PayWayVo=payWayList[j];
					if (vo.channel_way_id == l_payWayVo.id)
					{
						l_arr.push(l_payWayVo);
					}
				}
			}
			return l_arr;
		}


	}
}