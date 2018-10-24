package game.module.camp.avatar
{
	import MornUI.camp.avatar.HeroAvatarUI;
	
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.camp.CampData;
	import game.module.camp.CampView;
	import game.module.camp.NewUnitInfoView;
	import game.module.camp.UnitInfoView;
	import game.module.camp.UnitSrcView;
	import game.module.fighting.view.BaseChapetrView;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	
	/**
	 * HeroAvatarCom
	 * author:huhaiming
	 * HeroAvatarCom.as 2018-3-30 下午3:07:09
	 * version 1.0
	 *
	 */
	public class HeroAvatarCom extends BaseChapetrView
	{
		private var ui:HeroAvatarUI;
		/**换装*/
		public static const DRESS_UP:String = "dressUp";
		public function HeroAvatarCom()
		{
			super();
			init();
		}
		
		private function init():void{
			ui = new HeroAvatarUI(); 
			addChild(ui); 
			this.mouseThrough = ui.mouseThrough = true;
			
			ui.list.itemRender = AvatarItem;
			ui.list.vScrollBarSkin = "";
			ui.list.selectEnable = true;
		}
		
		public function format(uid:int):void{
			var arr:Array = DBSkin.getSkinData(uid);
			ui.list.array = arr;
			trace("arr---------------"+arr);
			
			if(this.ui.list.selectedIndex < 0){
				this.ui.list.selectedIndex = 0;
			}
			ui.btnEnchance.disabled = (this.ui.list.selectedIndex == 0);
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case ui.btnEquip:
					//合成
					var cur:SkinVo= this.ui.list.selectedItem
					WebSocketNetService.instance.sendData(ServiceConst.SKIN_EQUIP,[cur.unit, cur.ID]);
					Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.SKIN_EQUIP),this,onEquip);
					break;
				case ui.btnEnchance:
					XFacade.instance.showModule(AvatarLvUpView, ui.list.selectedItem);
					break; 
			} 
		}
		
		private function onEquip(...args):void{
			trace("onEquip::",args)
			var heroVo:Object = CampData.getUintById(args[1]);
			if(heroVo){
				heroVo.skin = args[2];
			}
			ui.list.refresh();
			Signal.intance.event(DRESS_UP)
		}
		
		private function onRender(cell:Box,index:int):void{
			if(index == ui.list.selectedIndex){
				cell.selected = true;
			}else{
				cell.selected = false;
			}
		}
		
		private function onCompose(...args):void{
//			trace("1111");
			var vo:Object = CampData.getUintById(args[1]);
			if(!vo.skins){
				vo.skins = {};
			}
			vo.skins[args[2]] = [0,0];
			
			ui.list.refresh();
			setBtnState();
		}
		
		private function onSelect(e:Event,index:int):void{
			if(e.type == Event.CLICK){
				trace("onSelect", index,ui.list.selectedIndex)
				ui.list.refresh();
				var cur:SkinVo= this.ui.list.selectedItem
				var item:AvatarItem = ui.list.getCell(ui.list.selectedIndex);
				if(item.canCompose){
					//合成
					WebSocketNetService.instance.sendData(ServiceConst.SKIN_COMPOSE,[cur.unit, cur.ID]);
					Signal.intance.once(ServiceConst.getServerEventKey(ServiceConst.SKIN_COMPOSE),this,onCompose);
				}else{
					if(XUtils.checkHit(item.btnInfo)){
						if(cur.garde>0){
							XFacade.instance.showModule(AvatarTip, cur);
							//XTipManager.showTip(cur,AvatarTip, false);
						}else{
							XTipManager.showTip(GameLanguage.getLangByKey("L_A_84569"));
						}
					}else{
						if(item.HeroImage.gray && cur.garde>0){
							XFacade.instance.showModule(SkinSrcView, cur, function() {
								XFacade.instance.closeModule(CampView);
								XFacade.instance.closeModule(UnitInfoView);
								XFacade.instance.closeModule(NewUnitInfoView);
								XFacade.instance.closeModule(AvatarLvUpView);
							});
						}
					}
				}
				
			}
//			trace("222222");
			setBtnState();
		}
		
		private function update():void{
//			trace("11111111111");
			ui.list.refresh();
			setBtnState();
		}
		
		private function setBtnState():void{
			var cur:SkinVo= this.ui.list.selectedItem
//			trace("cur:"+cur);
			if(cur){
				var heroVo:Object = CampData.getUintById(cur.unit);
				if(heroVo && heroVo.skins[cur.ID]){
					ui.btnEquip.disabled = (heroVo.skin == cur.ID);
					if(this.ui.list.selectedIndex == 0){
						ui.btnEnchance.disabled = true;
					}else{
						this.ui.btnEnchance.disabled = false;
					}
				}else{
					ui.btnEquip.disabled = true;
					this.ui.btnEnchance.disabled = true;
				}
			}
		}
		
		override public function addEvent():void
		{
			super.addEvent();
			ui.on(Event.CLICK, this, onClick);
			ui.list.renderHandler = Handler.create(this, this.onRender, null, false)
			ui.list.mouseHandler = Handler.create(this,onSelect, null, false);
			Signal.intance.on(Event.CLOSE, this, update);
		}
		override public function removeEvent():void
		{
			super.removeEvent();
			ui.off(Event.CLICK, this, onClick);
			ui.list.renderHandler = null
			ui.list.mouseHandler = null
			Signal.intance.off(Event.CLOSE, this, update);
		}
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			ui.size(width,ui.height);
			ui.pos(width >> 1 , (Laya.stage.height - ui.height)/2);
		}
	}
}