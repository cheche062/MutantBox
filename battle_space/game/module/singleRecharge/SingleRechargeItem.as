package game.module.singleRecharge
{
	import MornUI.singleRecharge.SigleRechargeItemUI;
	
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.global.GameLanguage;
	import game.module.bingBook.ItemContainer;
	
	import laya.utils.Handler;
	
	/**
	 * 单笔充值  渲染子项 
	 * @author hejianbo
	 * 
	 */
	public class SingleRechargeItem extends SigleRechargeItemUI
	{
		/**总的可兑换次数*/
		public static var _totalTimes:int = -1;
		public function SingleRechargeItem()
		{
			super();
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			if (!value) return;
			
			// 按钮是否禁用
			var _disabled = false;
			// 剩余次数
			var residueNum = value["time"] - Number(value["used_times"]);
			// 按钮是否显示
			var _visible = residueNum == 0 ? false : true;
			var status = value["residue_times"] > 0 ? 1 : 0;
			switch (Number(status)){
				case 0:
					_disabled = true;
					break;
				case 1:
					_disabled = false;
					break;
				case 2:
					_disabled = true;
					break;
			};
			
			var result = {
				dom_title: GameLanguage.getLangByKey("L_A_84006").replace('{0}', ToolFunc.thousandFormat(value["condition"])),
				btn_claim: {disabled: _disabled, visible: _visible},
				dom_claimed: { visible: !_visible },
				dom_remain: {
					text: residueNum + '/' + value["time"],
					color: residueNum == 0 ? "#999" : "#fff"
				}, 
				reward: value["reward"],
				residue_times: value["residue_times"]
			}
				
			super.dataSource = result;
			
			dom_HBox.destroyChildren();
			ToolFunc.rewardsDataHandler(result["reward"], function(id, num){
				// 添加小icon
				var child:ItemContainer = new ItemContainer();
				child.setData(id, num);
				child.scale(0.7, 0.7);
				dom_HBox.addChild(child);
			})
			var dom_btn = this.getChildByName("btn_claim");
			dom_btn.clickHandler = Handler.create(this, function(){
				value.callBack(value["id"]);
			}, null, false);
		}
		
		/**总的可兑换次数*/
		public static function get totalTimes():int{
			if (_totalTimes == -1) {
				var json = ResourceManager.instance.getResByURL("config/activity/activity_template.json");
				var targetData = ToolFunc.getTargetItemData(json, "tid", "2");
				_totalTimes = Number(targetData.times);
			}
			
			return _totalTimes;
		}
	}
}