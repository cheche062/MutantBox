package game.module.equipFight
{
	import MornUI.equipFight.EquipHXMuneUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.SceneManager;
	import game.common.XFacade;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.module.equipFight.cell.equipFigthBtn;
	import game.module.equipFight.vo.equipFightChapterVo;
	import game.module.fighting.mgr.FightingManager;
	import game.module.fighting.view.BaseChapetrView;
	import game.module.gm.helpButton;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.utils.Handler;
	
	public class EquipFightHangXingView extends BaseChapetrView
	{
		private var _muneView:EquipHXMuneUI;
		private var _helpB:helpButton;
		private var btnList:Array = [];
		private var _cid:Number;
		private var infoData:Object;
		
		public function EquipFightHangXingView()
		{
			super();
			
			
			_muneView = new EquipHXMuneUI();
			contentBox.addChild(_muneView);
			
			contentBox.addChild(_muneView.endBtn);
			
			
			var st:String = GameLanguage.getLangByKey("L_A_44004").replace(/##/g, "\n");
			
			_helpB = new helpButton("common/btn_info2.png","",st);
			contentBox.addChild(_helpB);
			_helpB.pos(1050,12);
		}
		
		
		/** @private */
//		public override function _setDisplay(value:Boolean):void {
//			if(_displayedInStage != value)
//			{
//				if(value)sendInfoData();
//			}
//			super._setDisplay(value);
//			
//			
//		}
		
		private function endClickFun(e:Event):void
		{
			AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,
				GameLanguage.getLangByKey("L_A_44019")	
				,0,function(v:uint):void{
				if(v == AlertType.RETURN_YES)
				{
					fun();
				}
			});
			
			var fun:Function = function():void{
				WebSocketNetService.instance.sendData(ServiceConst.EQUIP_FIGHT_END,[]);
				Signal.intance.on(
					ServiceConst.getServerEventKey(ServiceConst.EQUIP_FIGHT_END),
					this,endHXBack);
			}
		}
		
		private function endHXBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,endHXBack);
			
			XFacade.instance.closeModule(EquipFightInfoView);
		}
		
		private function sendInfoData():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.EQUIP_FIGHT_HANGXING,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.EQUIP_FIGHT_HANGXING),
				this,sendInfoBack);
		}
		
		
		public function sendInfo(cid:Number):void{
			
			_cid = cid;
			sendInfoData();
			
			var i:int = 0;
			var btn:equipFigthBtn ;
			for (i = 0; i < btnList.length; i++) 
			{
				btn = btnList[i];
				btn.removeSelf();
			}
			var ar:Array = GameConfigManager.equipFightChapters;
			var ecv:equipFightChapterVo;
			for (var j:int = 0; j < ar.length; j++) 
			{
				if( (ar[j] as equipFightChapterVo).id == cid)
				{
					ecv = ar[j];
					break
				}
			}
			
			
			if(ecv == null)return ;
			
//			bgImg.loadImage("appRes/fightingMapImg/"+ecv.icon1+".jpg");
			bgImg.skin = ("appRes/fightingMapImg/"+ecv.icon1+".jpg");
			
			for (i = 0; i < ecv.levelList.length; i++) 
			{
				if(i < btnList.length)
				{
					btn = btnList[i];
				}else
				{
					btn = new equipFigthBtn();
					btnList.push(btn);
				}
				btn.off(Event.CLICK,this,btnClick);
				btn.on(Event.CLICK,this,btnClick);
				btn.data = ecv.levelList[i];
//				btn.skin = "common/buttons/btn_+.png";
				btn.x = btn.data.cPoint.x;
				btn.y = btn.data.cPoint.y;
				bgBox.addChild(btn);
			}
		}
		
		private function btnClick(e:Event):void{
			var btn:equipFigthBtn = e.currentTarget as equipFigthBtn;
			if(btn && btn.selected)
			{
//				trace("搞起");
				XFacade.instance.showModule(EquipLevelShowPanel,[btn.data,_cid]);
			}
		}
		
		private function sendInfoBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendInfoBack);
			infoData = args[1];
			infoData.level = Number(infoData.level);
			for (var i:int = 0; i < btnList.length; i++) 
			{
				var btn:equipFigthBtn = btnList[i];
				if(btn.data.id == infoData.level)
				{
					btn.selected = true;
					_muneView.cNameLbl.text = btn.data.name;
				}
				else
					btn.selected = false;
				
				btn.showstate = btn.data.id <= infoData.level ? 1 : 0;
			}
			
		}
		
		
		override public function addEvent():void
		{
			super.addEvent();
			_muneView.endBtn.on(Event.CLICK,this,endClickFun);
			_muneView.storeBtn.on(Event.CLICK,this,storeBtnFun);
			_muneView.bagBtn.on(Event.CLICK,this,bagBtnClick);
		}
		override public function removeEvent():void
		{
			super.removeEvent();
			_muneView.endBtn.off(Event.CLICK,this,endClickFun);
			_muneView.storeBtn.off(Event.CLICK,this,storeBtnFun);
			_muneView.bagBtn.off(Event.CLICK,this,bagBtnClick);
			for (var i:int = 0; i < btnList.length; i++) 
			{
				var btn:equipFigthBtn = btnList[i];
				btn.off(Event.CLICK,this,btnClick);
			}
			
		}
		
		private function bagBtnClick(e:Event):void{
			XFacade.instance.openModule(ModuleName.BagPanel);
		}
		
		private function storeBtnFun(e:Event):void
		{
			XFacade.instance.openModule(ModuleName.EquipSuppliesPanel);
		}
		
		override protected function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			_muneView.pos(Laya.stage.width - _muneView.width >> 1, Laya.stage.height - _muneView.height);
			_helpB.pos(Laya.stage.width - 90 , 20);
			_muneView.endBtn.pos(10,Laya.stage.height - 20 - _muneView.endBtn.height);
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			if(_helpB)
			{
				_helpB.removeSelf();
				_helpB.destroy();
				_helpB = null;
			}
			
			super.destroy(destroyChild);
			_muneView = null;
			btnList = null;
			infoData = null;
		}

	}
}