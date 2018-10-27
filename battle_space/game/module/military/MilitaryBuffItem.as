package game.module.military
{
	import MornUI.military.MolitaryBuffItemUI;
	
	import game.global.GameLanguage;
	import game.global.data.DBFightEffect;
	import game.global.data.DBMilitary;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.util.TimeUtil;
	import game.global.vo.User;
	
	import laya.debug.tools.SingleTool;
	import laya.events.Event;
	import laya.ui.UIUtils;
	
	/**
	 * MilitaryBuffItem
	 * author:huhaiming
	 * MilitaryBuffItem.as 2017-4-28 上午11:48:31
	 * version 1.0
	 *
	 */
	public class MilitaryBuffItem extends MolitaryBuffItemUI
	{
		public var data:MilitaryVo;
		/**事件-买*/
		public static const BUY:String = "buy"
		public function MilitaryBuffItem()
		{
			super();
		}
		
		private function onClick(e:Event):void{
			Signal.intance.event(BUY, this.data);
		}
		
		override public function set dataSource(value:*):void{
			data = value;
			var curVo:MilitaryVo = DBMilitary.getInfoByCup(User.getInstance().cup || 0);
			UIUtils.gray(this, false);
			if(data){
				this.nameTF.text = GameLanguage.getLangByKey(data.name);
				this.priceTF_0.text = data.down+"";
				this.buyBtn.visible = true;
				this.timeTF.visible = false;
				
				var effectInfo:Object = DBFightEffect.getEffectInfo(data.buff);
				this.introTF.text = effectInfo.des;
				this.priceTf.text = data.price.split("=")[1];
				this.icon.skin = "appRes\\icon\\military\\"+data.icon+".png";
				ItemUtil.formatIcon(currencyIcon, data.price);
				
				if(parseInt(curVo.ID) < parseInt(data.ID)){
					UIUtils.gray(this);
					this.buyBtn.disabled = true;
				}else{
					var timeRemian:Number = MilitaryView.buy_buff_time*1000 - TimeUtil.now;
					if( timeRemian > 0 ){
						if(MilitaryView.data.base_rob_info.buy_buff == data.buff){
							this.buyBtn.visible = false;
							this.timeTF.visible = true;
							this.timeTF.text = "Remain:"+TimeUtil.getShortTimeStr(timeRemian);
						}else{
							this.buyBtn.disabled = true;
						}
					}else{
						this.buyBtn.disabled = false;
					}
				}
				this.buyBtn.on(Event.CLICK, this, this.onClick);
			}
		}
		
		/**@inheritDoc */
		override public function destroy(destroyChild:Boolean = true):void {
			this.buyBtn.on(Event.CLICK, this, this.onClick);
			super.destroy(destroyChild);
		}
	}
}