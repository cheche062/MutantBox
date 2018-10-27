package game.module.camp
{
	import MornUI.camp.CampSoldierItemUI;
	
	import game.common.starBar;
	import game.global.data.DBUintUpgradeExp;
	import game.global.data.DBUnitStar;
	import game.global.util.UnitPicUtil;
	
	import laya.ui.Component;
	import laya.ui.UIUtils;
	
	/**
	 * SoldierItem
	 * author:huhaiming
	 * SoldierItem.as 2017-3-20 下午2:48:01
	 * version 1.0
	 *
	 */
	public class SoldierItem extends CampSoldierItemUI
	{
		private var _starLv:starBar;
		private var _data:Object;
		public function SoldierItem()
		{
			super();
			this.minusBtn.visible = false;
			size(90,120);
		}
		
		override protected function createChildren():void{
			super.createChildren();
			this._starLv = new starBar("common/sectorBar/star_2.png","common/sectorBar/star_1.png",23,21,-9,10,5);
			this.addChild(this._starLv);
			this._starLv.x = 20;
			this._starLv.y = 106;
		}
		
		/**@inheritDoc */
		override public function set dataSource(value:*):void {
			super.dataSource = value;
			_data = value;
			UIUtils.gray(this.icon, false);
			if(_data){
				this.icon.graphics.clear();
				this.icon.loadImage(UnitPicUtil.getUintPic(_data.unitId || _data.unit_id,UnitPicUtil.ICON_SKEW));
				
				if(_data.hasOwnProperty("edit") && _data.edit == 1 && _data.have_number > 0){
					this.minusBtn.visible = true;
				}else{
					this.minusBtn.visible = false;
				}
				if(_data.have_number > 0){
					this.numTF.text = _data.have_number +"";
				}else{
					this.numTF.text = "";
				}
				
				//星级
				if(_data.hasOwnProperty("starId")){//服务端传过来的数据
					var vo:Object = DBUnitStar.getStarData(_data.starId);
					if(vo){
						_starLv.barValue = vo.star_level;
						var tmp:Array = (vo.star_cost+"").split("=");
						_data.actNum = tmp[1]
					}
				}else if(_data.hasOwnProperty("initial_star")){
					_starLv.barValue = _data.initial_star
				}

				//数量
				if(_data.curNum < _data.actNum){
					this.numTF2.color = "#ffffff";
					if(!_data.acted){
						UIUtils.gray(this.icon);
					}
				}else{
					this.numTF2.color = "#abff47";
				}
				this.numTF2.text = _data.curNum+"/"+_data.actNum;
				if(!_data.actNum){
					this.numTF2.color = "#abff47";
					this.numTF2.text = "MAX"
				}
			}else{
				this.minusBtn.visible = false;
				this.numTF.text = "";
			}
		}
		
		public function get data():Object{
			return this._data;
		}
	}
}