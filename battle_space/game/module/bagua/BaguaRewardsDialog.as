package game.module.bagua
{
	import MornUI.bagua.baguaRewardsDialogUI;
	import MornUI.bagua.buffViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XTipManager;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.data.DBFightEffect;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class BaguaRewardsDialog extends BaseDialog
	{
		public function BaguaRewardsDialog()
		{
			super();
			
		}
		
		override public function show(...args):void{
			super.show();
			
			AnimationUtil.flowIn(this);
			
			createBuffs(args[0]["buff_reward"]);
			createRewards(args[0]["item_reward"]);
			
			var _bool = args[0]["gray"];
			view.btn_close.label = _bool? "CONFIRM" : "CLAIM";
			closeOnBlank = _bool;
			
			trace("【领取弹窗】", args);
		}
		
		private function createRewards(str:String):void{
			view.dom_rewards_box.destroyChildren();
			
			var child:ItemContainer;
			ToolFunc.rewardsDataHandler(str, function(id, num){
				// 添加小icon
				child = new ItemContainer();
				child.setData(id, num);
				view.dom_rewards_box.addChild(child);
			})
				
			view.dom_rewards_box.x = this.width / 2 + (this.width / 2 - child.width * (view.dom_rewards_box.numChildren)) / 2;
		}
		
		private function createBuffs(str:String):void{
			view.dom_buff_box.destroyChildren();
			var result:Array = ToolFunc.concludeArray(str.split(";"));
			result.forEach(function(item, index){
				var data:Object = DBFightEffect.getEffectInfo(item[0]);
				var skin:String = "appRes/icon/mazeIcon/" + data.icon + ".png";
				var dom_num:String = Number(data["effect2"]) * 100 * item[1] + "%";
				var des:String = GameLanguage.getLangByKey(data.des);
				des = des.replace(/\d+%/, dom_num);
				Laya.loader.load(skin, Handler.create(this, function():void{
					var buff:buffViewUI = new buffViewUI();
					buff.dataSource = {
						"dom_icon": skin,
						"dom_num": dom_num
					}
					buff.on(Event.CLICK, this, function():void{
						XTipManager.showTip(des);
					});
					view.dom_buff_box.addChild(buff);
				}));
			})
				
			view.dom_buff_box.x = (this.width / 2 - (56 * result.length + (result.length - 1) * view.dom_buff_box.space)) / 2;
		}
		
		override public function createUI():void{
			this.addChild(view);
			
			view.dom_info.text = GameLanguage.getLangByKey("L_A_80513").replace(/##/g, '\n');
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_close:
					close();
					
					break;
			}
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
			
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
			
		}
		
		override public function close():void{
			AnimationUtil.flowOut(this, onClose);
			
		}
		
		private function onClose():void{
			super.close();
		}
		
		public function get view():baguaRewardsDialogUI{
			_view = _view || new baguaRewardsDialogUI();
			return _view;
			
		}
	}
}