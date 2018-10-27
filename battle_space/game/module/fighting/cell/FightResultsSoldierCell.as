/***
 *作者：罗维
 */
package game.module.fighting.cell
{
	import MornUI.fightResults.FightResultsSoldierCellUIUI;
	
	import game.common.ResourceManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.data.DBUintUpgradeExp;
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	import game.module.fighting.adata.frSoldierData;
	
	import laya.filters.ColorFilter;
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.ProgressBar;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class FightResultsSoldierCell extends Box
	{
		
		public static const itemWidth:Number = 79;
		public static const itemHeight:Number = 110;
		
		protected var bgImg:Image;
		protected var faceImg:Image;
		protected var numLbl:Label;
		protected var flag:Image;
//		protected var expBar:ProgressBar;
		
		public function FightResultsSoldierCell()
		{
			super();
			init();
			
//			size(60,84);
		}

		protected function init():void{
			
			
			var mV:FightResultsSoldierCellUIUI = new FightResultsSoldierCellUIUI();
			addChild(mV);
			faceImg = mV.faceImg;
			numLbl = mV.numLbl;
			flag = mV.flag;
//			expBar = new ProgressBar();
//			expBar.bg.skin = "common/progressBar/progress1bg.png";
//			expBar.bar.skin = "common/progressBar/progress1.png";
//			expBar.sizeGrid = "0,11,2,11";
//			expBar.size(50,15);
//			
//			addChild(expBar);
//			expBar.y = mV.piImg.y;
			mV.piImg.removeSelf();
			
			faceImg.visible = numLbl.visible = flag.visible = false;
//			faceImg.visible = numLbl.visible = expBar.visible = false;
			
		}
		
		private var _data:frSoldierData;
		public function get data():frSoldierData
		{
			return _data;
		}
		
		public function set data(value:frSoldierData):void
		{
			if(_data != value)
			{
				_data = value;
				bindData();
			}
		}
		
		private function bindData():void
		{
			if(_data)
			{
				flag.visible = false;
				faceImg.visible = numLbl.visible = true;
				
				faceImg.loadImage(UnitPicUtil.getUintPic(data.uid,UnitPicUtil.ICON_SKEW));
				
//				numLbl.text = data.uNum + "/" +data.uMaxNum;
				numLbl.text = data.death ;
//				numLbl.filters = faceImg.filters = data.uNum ? null: [ColorFilter.GRAY];
				numLbl.filters = faceImg.filters = [ColorFilter.GRAY];
//				//设置当前经验
				var uvo:FightUnitVo = GameConfigManager.unit_dic[data.uid]; 
				flag.skin = "common/item_bar"+(uvo.rarity-1)+".png";
//				var lvMaxExp:Number = DBUintUpgradeExp.getLvExp(data.uLev , 1,uvo.rarity);
//				expBar.value = data.uExp / lvMaxExp;
//				
//				if(data.addExp)  //设置升级
//				{
//					var maxExp:Number = DBUintUpgradeExp.getAllExpByLevelAndExp(data.uLev,data.uExp,1,uvo.rarity);
//					maxExp += data.addExp;
//					var obj:Object = DBUintUpgradeExp.getLevelAndExpByAllExp(maxExp,1,uvo.rarity);
//					moveLevel(obj);
//				}
				
			}else
			{
				faceImg.visible = numLbl.visible = flag.visible = false;
			}
		}
		
//		private function moveLevel(obj:Object):void
//		{
////			level 当前级别  exp 当前经验 lexp 当前级别需要经验
//			var addLv:Number = obj.level - data.uLev;
//			if(!addLv)
//			{
//				Tween.to(this.expBar,{value: obj.exp / obj.lexp},500,null,
//						Handler.create(this,moverOver,[obj,false])
//				);
//				return ;
//			}
//			
//			data.uLev ++ ;
//			Tween.to(this.expBar,{value: 1},500,null,
//				Handler.create(this,this.moverOver,[obj,true])
//			);
//		}
//		
//		
//		private function moverOver(obj:Object, mmax:Boolean):void{
//			if(mmax)
//			{
//				expBar.value = 0;
//				moveLevel(obj);
//			}
//		}
//		
		public override function set dataSource(value:*):void{
			super.dataSource = data = value;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy FightResultsSoldierCell");
			bgImg = null;
			faceImg = null;
			numLbl = null;
			flag = null;
			super.destroy(destroyChild);
			
		}
		
	}
}