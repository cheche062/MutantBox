package game.module.waterLottery 
{
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	/**
	 * ...
	 * @author ...
	 */
	public class LotteryRollItem extends Box
	{
		
		private var imgVec:Vector.<Image> = new Vector.<Image>(5);
		
		private var nIndex:int = 0;
		private var tIndex:int = 0;
		
		public function LotteryRollItem() 
		{
			for (var i:int = 0; i < 4; i++) 
			{
				imgVec[i] = new Image();
				imgVec[i].skin = "waterLottery/i_"+i%2+".png";
				imgVec[i].x = 0;
				imgVec[i].y = -85 + 80 * i;
				imgVec[i].name = imgVec[i].y;
				this.addChild(imgVec[i]);
			}
		}
		
		public function startRoll(times:int = 0):void
		{
			var i:int = 0;
			if (times > 0)
			{
				nIndex = 0;
				tIndex = times;
				for (i = 0; i < 4; i++) 
				{
					imgVec[i].skin = "waterLottery/i_" + i % 2 + ".png";
					imgVec[i].y = -85 + 80 * i;
				}
			}
			else
			{
				nIndex++;
				for (i = 0; i < 4; i++) 
				{
					if (imgVec[i].y > 155)
					{
						imgVec[i].y = -85;
					}
					imgVec[i].name = imgVec[i].y;
				}
				//trace("imgVec:", imgVec);
			}
			
			for (i = 0; i < 4; i++) 
			{
				if (nIndex >= tIndex)
				{
					if (i == 3)
					{
						Tween.to(imgVec[i], { y:imgVec[i].y+80 }, 200, Ease.linearInOut, new Handler(this, showResult));
					}
					else
					{
						Tween.to(imgVec[i], { y:imgVec[i].y+80 }, 200, Ease.linearInOut);
					}
					
				}
				else
				{
					if (i == 3)
					{
						Tween.to(imgVec[i], { y:imgVec[i].y+80 }, 100, Ease.linearNone, new Handler(this, startRoll));
					}
					else
					{
						Tween.to(imgVec[i], { y:imgVec[i].y+80 }, 100, Ease.linearNone);
					}
					
				}
			}
		}
		
		private function showResult():void
		{
			nIndex = 0;
			if (tIndex % 2 == 0)
			{
				for (var i:int = 0; i < 4; i++) 
				{
					if (imgVec[i].name == -5)
					{
						imgVec[i].skin = "waterLottery/i_2.png";
					}
				}
			}
			
		}
		
	}

}