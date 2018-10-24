package game.module.armyGroup.fight
{
	import MornUI.armyGroupFight.ArmyFightResultUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.event.Signal;
	import game.global.util.TimeUtil;
	import game.module.bingBook.ItemContainer;
	
	import laya.events.Event;
	
	/**
	 * ArmyFightResultCom
	 * author:huhaiming
	 * ArmyFightResultCom.as 2017-11-29 上午10:15:52
	 * version 1.0
	 *
	 */
	public class ArmyFightResultCom extends BaseDialog
	{
		private var _data;
		private var _item:ItemContainer;
		public function ArmyFightResultCom()
		{
			super();
		}
		
		override public function show(...args):void{
			LayerManager.instence.addToLayer(this,this.m_iLayerType);
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			AnimationUtil.flowIn(this);
			this._data = args[0];
			
			view.hNameTF.text = _data.attack_guild_info.name;
			view.aNameTF.text = _data.defend_guild_info.name?_data.defend_guild_info.name:GameLanguage.getLangByKey("L_A_20903");
			GameConfigManager.setGuildLogoSkin(view.homeIcon, _data.attack_guild_info.icon, 0.5);
			GameConfigManager.setGuildLogoSkin(view.awayIcon, _data.defend_guild_info.icon, 0.5);

			this.view.timeTF.text = TimeUtil.getTimeStr(_data.fight_time*1000)
				
			if(_data.winner == 1){//进攻方胜利
				view.hResult.text = "L_A_20875";
				view.aResult.text = "L_A_20876";
				view.hResultIcon.gray = false;
				view.aResultIcon.gray = true;
				
			}else{
				view.hResult.text = "L_A_20874";
				view.aResult.text = "L_A_20877";
				view.hResultIcon.gray = true;
				view.aResultIcon.gray = false;
			}
			
			//胜利失败判定
			if(_data.winner == _data.role){
				view.rewardLb.visible = true;
				view.itemSp.visible = true;
				view.titlePic.skin = ResourceManager.instance.getLangImageUrl("victory.png")
				view.bg.gray = false;
			}else{
				view.rewardLb.visible = false;
				view.itemSp.visible = false;
				view.bg.gray = true;
				view.titlePic.skin = ResourceManager.instance.getLangImageUrl("lose.png")
			}
						
			
			var info:Object;
			for(var i:int=0; i<3; i++){
				info =  _data.rank_list[1][i];
				if(info){
					view["groupTF_"+i].text = info.guildname+"";
					view["nameTF_"+i].text = info.nickname+"";
					view["killTF_"+i].text = info.killnum+"";
				}else{
					view["groupTF_"+i].text = "";
					view["nameTF_"+i].text = "";
					view["killTF_"+i].text = "";
				}
			}
		}
		
		override public function close():void{
			if(displayedInStage){
				Signal.intance.event(ArmyGroupFightView.CLOSE);
				AnimationUtil.flowOut(this, this.onClose);
			}
		}
		
		private function onClose():void{
			super.close();
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.closeBtn:
					this.close();
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
		
		override public function createUI():void{
			this._view  = new ArmyFightResultUI();
			this.addChild(_view);
			for(var i:int=0; i<3; i++){
				view["groupTF_"+i].text = "";
				view["nameTF_"+i].text = "";
				view["killTF_"+i].text = "";
			}
			
			_item = new ItemContainer();
			view.itemSp.addChild(_item);
			
			var juntuan_canshu_json:*=ResourceManager.instance.getResByURL("config/juntuan/juntuan_canshu.json");
			if(juntuan_canshu_json){
				var data:Object = juntuan_canshu_json[42];
				if(data){
					var tmp:Array = (data.value+"").split("=");
					_item.setData(tmp[0], tmp[1]);
				}
			}
		}
		
		private function get view():ArmyFightResultUI{
			return this._view;
		}
	}
}