package game.module.armyGroup 
{
	import game.common.base.BaseView;
	import game.global.event.ArmyGroupEvent;
	import game.global.event.Signal;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.armyGroup.ArmyGroupCityVo;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextArea;
	import MornUI.armyGroup.ArmyGroupOutputItemUI;
	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupOutputItem extends BaseView 
	{
		private var cityData:ArmyGroupCityVo;
		
		private var _goodArr:Vector.<Image> = new Vector.<Image>(3);
		private var _textArr:Vector.<TextArea> = new Vector.<TextArea>(3);
		
		public function ArmyGroupOutputItem() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				case view.goBtn:
					Signal.intance.event(ArmyGroupEvent.JUMP_PLANT, [cityData]);
					break;
				
				default:
					break;
			}
		}
		
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			if (!value)
			{
				return;
			}
			
			cityData = GameConfigManager.ArmyGroupCityList[parseInt(value.city_id) - 1]
			
			view.cNameTxt.text = GameLanguage.getLangByKey(cityData.name);
			//view.cArmyNumTxt.text = value.defNum;
			
			switch(value.status)
			{
				case "peace":
					view.cStateTxt.color = "#fff9a1";
					view.cStateTxt.text = GameLanguage.getLangByKey("peace");
					break;
				case "protecting":
					view.cStateTxt.color = "#49d1fe";
					view.cStateTxt.text = GameLanguage.getLangByKey("protecting");
					break;
				case "fighting":
					view.cStateTxt.color = "#fe6464";
					view.cStateTxt.text = GameLanguage.getLangByKey("fighting");
					break;
				default:
					break;
			}
			
			_goodArr[0].skin = "armyGroup/icon_score.png";
			_textArr[0].text = "x"+cityData.points;
			
			var reArr:Array = cityData.award.split(";");
			var len:int = reArr.length;
			switch(len)
			{
				case 1:
					_goodArr[1].skin = (GameConfigManager.getItemImgPath(reArr[0].split("=")[0]));
					_textArr[1].text = "x" + reArr[0].split("=")[1];
					_goodArr[1].visible = _textArr[1].visible = true;
					break;
				case 2:
					_goodArr[1].skin = (GameConfigManager.getItemImgPath(reArr[0].split("=")[0]));
					_textArr[1].text = "x" + reArr[0].split("=")[1];
					_goodArr[1].visible = _textArr[1].visible = true;
					
					_goodArr[2].skin = (GameConfigManager.getItemImgPath(reArr[1].split("=")[0]));
					_textArr[2].text = "x" + reArr[1].split("=")[1];
					_goodArr[2].visible = _textArr[2].visible = true;
					break;
				default:
					_goodArr[1].visible = _textArr[1].visible = false;
					_goodArr[2].visible = _textArr[2].visible = false;
					break;
			}
			
			
			
		}
		
		override public function createUI():void
		{
			this._view = new ArmyGroupOutputItemUI();
			view.cacheAsBitmap = true;
			this.addChild(_view);
			
			for (var i:int = 0; i < 3; i++) 
			{
				_goodArr[i] = new Image();
				_goodArr[i].name = i;
				_goodArr[i].scaleX = _goodArr[i].scaleY = 0.5;
				_goodArr[i].y = 3;
				_goodArr[i].x = 300 + 90 * i;						
				view.addChild(_goodArr[i]);
				
				_textArr[i] = new TextArea();
				_textArr[i].font = "Futura";
				_textArr[i].fontSize = 18;
				_textArr[i].color = "#ffffff";					
				_textArr[i].mouseEnabled = false;
				_textArr[i].y = 16;
				_textArr[i].x = 340 + 90 * i;
				view.addChild(_textArr[i]);
			}
			
			_goodArr[0].scaleX = _goodArr[0].scaleY = 1;
			_goodArr[0].y = 5;
			
			addEvent();
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		private function get view():ArmyGroupOutputItemUI{
			return _view;
		}
		
	}

}