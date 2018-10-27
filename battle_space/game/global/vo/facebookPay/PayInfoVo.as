package game.global.vo.facebookPay
{
	import game.global.GameSetting;

	public class PayInfoVo
	{
		public var country_id:int;
		public var currency_id:int;
		public var channel_way_id:int;
		public var gwList:Array=new Array();
		public var fbList:Array=new Array();
		public var id:int;
		public function PayInfoVo()
		{
			gwList=new Array();
			fbList=new Array();
		}
		
		public function setGwList(p_data:Object):void
		{
			gwList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:FaceBookGwVo=new FaceBookGwVo();
				vo.channel_way_id=parseInt(i.channel_way_id);
				vo.pack_id=i.pack_id;
				vo.id=parseInt(i.id);
				gwList.push(vo);
			}
			
		}
		
		public function setFbList(p_data:Object):void
		{
			fbList=new Array();
			for each (var i:Object in p_data)
			{
				var vo:FaceBookGwVo=new FaceBookGwVo();
				vo.channel_way_id=parseInt(i.channel_way_id);
				vo.pack_id=i.pack_id;
				vo.id=parseInt(i.id);
				fbList.push(vo);
			}
		}
		
		public function getGwInfo(p_id:int):FaceBookGwVo
		{
			var l_arr:Array=new Array();
			if(GameSetting.Platform==GameSetting.P_FB)
			{
				l_arr=fbList;
			}
			else
			{
				l_arr=gwList;
			}
			
			for (var i:int = 0; i < l_arr.length; i++) 
			{
				var vo:FaceBookGwVo=l_arr[i];
				if(vo.channel_way_id==p_id)
				{
					return vo;
				}
			}
			
			return null;
		}
		
		
	}
}