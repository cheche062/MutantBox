package game.module.guide
{
	import game.common.LayerManager;
	import game.common.base.BaseView;
	import game.global.vo.HitAreaData;
	import game.net.pack.MsgBodyAnaly;
	
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.utils.HitArea;
	
	public class GuidePanel extends BaseView
	{
		public function GuidePanel()
		{
			super();
			m_iLayerType	= LayerManager.M_GUIDE;
			m_iPositionType = LayerManager.LEFTUP;
		}
		
		private var sp:Sprite;
		private var imgHitArea:HitArea;
		private var maSp:Sprite;
		public override function show(...args):void{
			super.show(args);
			
			sp = args[0][0];
			
			if(sp && sp.displayedInStage)
			{
				var pi:Point = new Point(sp.x,sp.y);
				var pp:Sprite = sp.parent as Sprite;
				if(pp && pp is Sprite)
				{
					pp.localToGlobal(pi);
				}
				this.size(Laya.stage.width , Laya.stage.height);
				
				if(!maSp)
				{
					maSp = new Sprite();
					addChild(maSp);
				}
				maSp.graphics.clear();
				maSp.graphics.alpha(.5);
				maSp.graphics.drawPoly(pi.x,pi.y,[
					sp.width >> 1, 0,
					sp.width >> 1, 0 - pi.y,
					0 - pi.x , 0 - pi.y,
					0 - pi.x , height - pi.y,
					width - pi.x , height - pi.y,
					width - pi.x , 0 - pi.y,
					sp.width >> 1 , 0 - pi.y,
					sp.width >> 1, 0,
					sp.width , 0 ,
					sp.width , sp.height,
					0, sp.height,
					0, 0
				
				],"#000000");
				
				
//				imgHitArea ||= new HitArea();
//				imgHitArea.hit.clear();
//				imgHitArea.hit.d
//				this.hitArea = imgHitArea;
				
			}
		}
	}
}