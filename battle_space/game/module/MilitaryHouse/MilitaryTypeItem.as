package game.module.MilitaryHouse 
{
	import game.common.base.BaseView;
	import game.common.XUtils;
	import game.global.data.DBUnitStar;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.FightUnitVo;
	import game.global.vo.militaryHouse.MilitaryBlockVo;
	import game.global.vo.militaryHouse.MilitaryHeroScore;
	import game.global.vo.militaryHouse.MilitaryUnitScore;
	import game.module.camp.CampData;
	import laya.display.Text;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.View;
	import MornUI.militaryHouse.MilitaryTypeItemUI;
	/**
	 * ...
	 * @author ...
	 */
	public class MilitaryTypeItem extends BaseView
	{
		private var data:Object;
		
		private var _itemMc:MilitaryTypeItemUI;
		private var _id:int = 0;
		private var _setNum:int = 0;
		private var _openNum:int = 0;
		private var _blockData:MilitaryBlockVo;
		
		private var _typeImg:Image;
		
		private var _alertTF:Text;
		
		public function MilitaryTypeItem() 
		{
			super();
		}
		
		private function onClick(e:Event):void
		{
			
			switch(e.target)
			{
				
				default:
					break;
			}
		}
		
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void
		{
			data = value;
			
			_blockData = GameConfigManager.military_block_info[_id];
			var ta:Array = _blockData.req.split("|");
			
			if (ta[0] == 256)
			{
				_typeImg.skin = "militaryHouse/icon_256.png";
			}
			else if (parseInt(ta[1])!=0)
			{
				_typeImg.skin = "militaryHouse/icon_"+ ta[1] +".png";
			}
			else
			{
				_typeImg.skin = "militaryHouse/icon_"+ ta[2] +".png";
			}
			
			if (!data)
			{
				_typeImg.gray = true;
				_itemMc.blockNumTF.text = "-";
				_itemMc.scoreTF.text =  "-";
				_itemMc.disabled = true;
				_itemMc.typeTF.text = GameLanguage.getLangByKey("L_A_15013").replace("{0}", _blockData.level);
				_itemMc.lvTF.text = "";
				return;
			}
			
			
			_itemMc.disabled = false;
			_setNum = _openNum = 0;
			var allScore:int = 0;
			for (var c in data.slots)
			{
				if (data.slots[c] != "")
				{
					var cData:Object = CampData.getUintById(data.slots[c]);
					/*trace("data.slots[c]:", data.slots[c]);
					trace("cData:", cData);*/
					allScore += MilitartHouseView.countScore(cData.level, (DBUnitStar.getStarData(cData.starId).star_level), cData.advLv, (GameConfigManager.unit_dic[cData.unitId] as FightUnitVo).rarity);
					_setNum++;
				}
				_openNum++;
			}
			
			
			
			if (data.level > 0)
			{
				/*trace("data.level:", data.level);
				trace("data:", data);
				trace("GameConfigManager.military_score[data.level]:", GameConfigManager.military_score[data.level]);*/
				allScore = Math.ceil(allScore * (1 + data.level * GameConfigManager.military_score[data.level].inc / 100));
			}
			
			var ef:Number = 0;
			if (allScore > 0)
			{
				if (ta[0] == 256)
				{
					var hs:MilitaryHeroScore = GameConfigManager.intance.getHeroScoreVo(allScore);
					trace("hs:", hs);
					if (!hs.lj)
					{
						hs.lj = 0;
					}
					ef = parseFloat((allScore-hs.CD_down) * hs.stage_price)+parseFloat(hs.lj);
				}
				else
				{
					var us:MilitaryUnitScore = GameConfigManager.intance.getUnitScoreVo(allScore);
					if (!us.lj)
					{
						us.lj = 0;
					}
					ef = parseFloat((allScore-us.CD_down) * us.stage_price)+parseFloat(us.lj);
				}
			}
			
			/*trace("allScore:", allScore);
			trace("ef:", ef);
			trace("=========================================");*/
			
			_itemMc.blockNumTF.text = _setNum + "/" + _openNum;
			_itemMc.scoreTF.text =  XUtils.toFixed(ef,2)+"%";;
			//_itemMc.scoreTF.text = allScore;
			_itemMc.lvTF.text = GameLanguage.getLangByKey("L_A_15012").replace("{0}", data.level);
			
			_itemMc.typeTF.text = GameLanguage.getLangByKey(_blockData.name);
			
			
		}
		
		public function setMC(view:MilitaryTypeItemUI):void
		{
			if (_itemMc)
			{
				_itemMc = null;
			}
			
			_itemMc = view;
			
			_typeImg = new Image();
			_typeImg.skin = "militaryHouse/icon_1.png";
			_typeImg.x = _typeImg.y = -10;
			_itemMc.addChild(_typeImg);
			
			_id = _itemMc.name.split("_")[1];
		}
		
		override public function createUI():void
		{
			
		}
		
		override public function addEvent():void{
			//view.on(Event.CLICK, this, this.onClick);
			
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			//view.off(Event.CLICK, this, this.onClick);
			
			super.removeEvent();
		}
		
		public function get view():MilitaryTypeItemUI{
			return _itemMc;
		}
		
	}

}