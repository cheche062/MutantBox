package game.module.gameRankView 
{
	import game.common.base.BaseView;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.vo.FightUnitVo;
	import game.module.bingBook.ItemContainer;
	import laya.events.Event;
	import laya.ui.Image;
	import MornUI.gameRank.GameRankItemUI;
	
	/**
	 * ...
	 * @author ...
	 */
	public class GameRankItem extends BaseView 
	{
		
		private var _rankImg:Image;
		private var _unitBg:Image;
		private var _unitImg:Image;
		private var _data:Object;
		
		public function GameRankItem() 
		{
			super();
			
		}
		
		private function onClick(e:Event):void
		{
			XFacade.instance.openModule(ModuleName.OthersInfoView, [_data.uid]);
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			_data = value;
			if (value.rank < 4)
			{
				_rankImg.visible = true;
				_rankImg.skin = "gameRank/icon_" + value.rank + ".png";
				view.itemBg.skin = "gameRank/bg2.png";
				
				view.rankTxt.visible = false;
				view.nameTxt.color = "#ffffff";
				
				view.detailTxt.color = "#ffffff";
				view.bpTxt.color = "#ffffff";
				
				_unitBg.x = 580;
				_unitBg.y = 2;
				_unitBg.scaleX = _unitBg.scaleY = 0.7;
				
				_unitImg.x = 574;
				_unitImg.y = -4;
				_unitImg.scaleX = _unitImg.scaleY = 0.7;
			}
			else
			{
				_rankImg.visible = false;
				view.itemBg.skin = "gameRank/bg5.png";
				
				view.rankTxt.visible = true;
				view.nameTxt.color = "#81bbd0";
				
				view.detailTxt.color = "#81bbd0";
				view.bpTxt.color = "#81bbd0";
				
				_unitBg.x = 586;
				_unitBg.y = 9;
				_unitBg.scaleX = _unitBg.scaleY = 0.5;
				
				_unitImg.x = 580;
				_unitImg.y = 3;
				_unitImg.scaleX = _unitImg.scaleY = 0.5;
			}
			
			view.starImg.visible = false;
			view.bpTxt.visible = false;
			view.detailTxt.visible = false;
			_unitBg.visible = false;
			_unitImg.visible = false;
			
			switch(value.rType)
			{
				case "level":
					view.detailTxt.visible = true;
					view.nameTxt.text = GameLanguage.getLangByKey("L_A_34071").replace("{0}",value.level);
					view.detailTxt.text = value.name;
					break;
				case "stage_level":
					view.starImg.visible = true;
					view.bpTxt.visible = true;
					view.nameTxt.text = value.name;
					view.bpTxt.text = value.totalStars;
					break;
				case "power":
					view.bpTxt.visible = true;
					view.nameTxt.text = value.name;
					view.bpTxt.text = GameLanguage.getLangByKey("L_A_49046") + " " + value.power;
					break;
				case "soldier":
					
					_unitBg.skin = "common/item_bar3.png";
					_unitBg.visible = true;
					
					_unitImg.skin = "appRes/icon/unitPic/"+value.unitId+"_b.png";
					_unitImg.visible = true;
					view.bpTxt.visible = true;
					view.nameTxt.text = value.name;
					view.bpTxt.text = GameLanguage.getLangByKey("L_A_49046") + " " + value.power;
					break;
				case "hero":
					
					_unitBg.skin = "common/item_bar"+((GameConfigManager.unit_dic[value.unitId] as FightUnitVo).rarity-1)+".png";
					_unitBg.visible = true;
					
					_unitImg.skin = "appRes/icon/unitPic/"+value.unitId+"_b.png";
					_unitImg.visible = true;
					view.bpTxt.visible = true;
					view.nameTxt.text = value.name;
					view.bpTxt.text = GameLanguage.getLangByKey("L_A_49046") + " " + value.power;
					break;
				default:
					break;
			}
			
			view.rankTxt.text = value.rank;
			
			
		}
		
		override public function createUI():void
		{
			this._view = new GameRankItemUI();
			view.cacheAsBitmap = true;
			addEvent();
			this.addChild(_view);
			
			_rankImg = new Image();
			_rankImg.x = 92;
			_rankImg.y = -9;
			view.addChild(_rankImg);
			
			_unitBg = new Image();
			_unitBg.x = 580;
			_unitBg.y = 2;
			_unitBg.scaleX = _unitBg.scaleY = 0.7;
			view.addChild(_unitBg);
			
			_unitImg = new Image();
			_unitImg.x = 574;
			_unitImg.y = -4;
			_unitImg.scaleX = _unitImg.scaleY = 0.7;
			view.addChild(_unitImg);
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			super.removeEvent();
		}
		
		override public function dispose():void{
			removeEvent();
			super.dispose();
		}
		
		private function get view():GameRankItemUI{
			return _view;
		}
	}

}