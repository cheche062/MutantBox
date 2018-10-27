package game.common
{
	import MornUI.fightingView.BossHpBarUI;
	
	import game.global.util.UnitPicUtil;
	import game.global.vo.FightUnitVo;
	
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Tween;

	public class BossHpProgressBar extends BossHpBarUI implements IHpProgressBar
	{
		private var barArr:Array = []; 

		public function BossHpProgressBar()
		{
			super();
			
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			this.hpPi.removeSelf();
			
			var barImg:Image = new Image();
			barImg.skin = "fightingUI/progress_boss$bar.png";
			addChild(barImg);
			barImg.pos(hpPi.x,hpPi.y);
			for (var i:int = 0; i < 3; i++) 
			{
				barImg = new Image();
				barImg.skin = "fightingUI/progress_boss_"+(i+1)+".png";
				addChild(barImg);
				barImg.pos(hpPi.x,hpPi.y);
				barArr.push(barImg);
			}
			addChild(this.gaiBg);
			addChild(this.bossFace);
			addChild(this.hpLbl);
		}
		
		private var _maxBarNum:Number = 3;
		public function bindUnitVo(vo:FightUnitVo):void
		{
			_maxBarNum = vo.num ? vo.num : 1;
			bossFace.graphics.clear();
			bossFace.loadImage(UnitPicUtil.getUintPic(vo.model,UnitPicUtil.PIC_BOSS));
//			vo.f
//			this.bossFace.l
		}
		
		public function setHpValue(v:Number,mv:Number, hd:Boolean):void
		{
			maxHp = mv;
			if(hd)
			{
				Tween.to(this,{hp:v},200);
			}else
			{
				hp = v;
			}
		}
		
		private var _hp:Number = 0;
		public var maxHp:Number = 0;
		public function get hp():Number
		{
			return _hp;
		}
		
		public function set hp(value:Number):void
		{
			value = Math.ceil(value);
			if(_hp != value)
			{
				_hp = value;
				hpLbl.text = _hp+"/"+maxHp;
				var vvv:Number = _hp/maxHp;
				this.bossFace.disabled = !value;
				
				var bN:Number = 1 / _maxBarNum;
				var endN:Number = 1 - ((_maxBarNum - 1) * bN);
				
				for (var i:int = 0; i < barArr.length; i++) 
				{
					var bar:Image = barArr[i];
					if(i >= _maxBarNum)
					{
						bar.visible = false;
					}else
					{
						var nn:Number = i == 0 ? endN : bN;
						var xxx:Number = 1;
						if(vvv > nn)
						{
							xxx = 1;
						}else if(vvv <= 0)
						{
							xxx = 0;
						}else
						{
							xxx = vvv / nn;
						}
						bar.width = 254 * xxx;
						bar.x =  hpPi.x + 254 - bar.width;
						vvv -= nn;
					}
				}
			}
		}
	}
}