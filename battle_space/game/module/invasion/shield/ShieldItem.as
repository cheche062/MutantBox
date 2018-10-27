package game.module.invasion.shield
{
	import MornUI.military.ShieldItem1UI;
	
	import game.global.util.TimeUtil;

	/**
	 * ShieldItem
	 * author:huhaiming
	 * ShieldItem.as 2017-4-27 下午5:03:20
	 * version 1.0
	 *
	 */
	public class ShieldItem extends ShieldItem1UI
	{
		public var data:ShieldVo;
		public function ShieldItem()
		{
			super();
			this.cacheAsBitmap = true;
		}
		
		//格式化CD数据
		public function format(cdTime:Number=0):void{
			data.cdEndTime = cdTime;
			if(TimeUtil.now > data.cdEndTime*1000){
				this.buyBtn.disabled = false;
			}else{
				this.buyBtn.disabled = true;
			}
			
		}
		
		override public function set dataSource(value:*):void{
			data = value;
			this.buyBtn.disabled = false;
			if(data){
				this.priceTf.changeText(data.price.split("=")[1]);
				this.nameTF.changeText(data.name+"");
				this.rTimeTF.changeText(TimeUtil.getShortTimeStr(parseFloat(data.time)*1000));
				this.coolTF.changeText(TimeUtil.getShortTimeStr(parseFloat(data.cd)*1000));
				this.icon.skin = "military/icon_"+data.icon+".png"
				if(!data.cdEndTime || TimeUtil.now > data.cdEndTime*1000){
					this.buyBtn.disabled = false;
				}else{
					this.buyBtn.disabled = true;
				}
			}
		}
	}
}