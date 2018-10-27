package game.module.camp
{
	import MornUI.camp.NewJuexingTupoViewUI;
	import MornUI.camp.NewTuPoAddTexingCellUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.vo.AwakenTypeVo;
	
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.Label;
	
	public class NewJuexingTupoView extends BaseDialog
	{
		private var txList:Array = [];
		
		public function NewJuexingTupoView()
		{
			super();
			_closeOnBlank = true;
		}
		
		override public function show(...args):void
		{
			
			var ar:Array = args[0];
			var uid:Number = ar[0];
			var lv:Number = ar[1];
			var ps:Array = ar[2];
			
//			trace("打个断点123");
			bindPs(view.leftBox,ps,lv);
			ProTipUtil.addTip(view.leftBox,uid,true);
			var _rightA:Array = [0,0,0,0];
			var cData:Object = CampData.getUintById(uid);
			if(cData)
			{
				_rightA[0] = Number(cData.hp);  //血量
				_rightA[1] = Number(cData.attack);  //攻击
				_rightA[2] = Number(cData.defense);  //防御
				_rightA[3] = Number(cData.speed);  //速度
			}
			bindPs(view.rightBox,_rightA,lv+1);
			ProTipUtil.addTip(view.rightBox,uid,true);
			view.size(578,308);
			size(view.width,view.height);
			
			var tx:Array = ar[3];
			if(tx && tx.length)
			{
				for (var i:int = 0; i < tx.length; i++) 
				{
					var txView:NewTuPoAddTexingCellUI = new NewTuPoAddTexingCellUI();
					addChild(txView);
					txView.x = 0;
					txView.y = height;
					txList.push(txView);
					bindTx(txView,tx[i]);
					width = txView.width;
					height += txView.height;
				}
				
			}
			
			view.closeBtn.x = width - 54;
			view.bgImg.size(width,height);
			view.size(view.bgImg.width,view.bgImg.height);
			view.tileLbl.x = width - view.tileLbl.width >> 1;
			view.topBox.x = width - view.topBox.width >> 1;
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			AnimationUtil.flowIn(this);
		}
		
		public function bindTx(txView:NewTuPoAddTexingCellUI,txId:Number):void
		{
			var vo:AwakenTypeVo = GameConfigManager.awakenTypeVoDic[txId];
			if(vo)
			{
				txView.voCell.lockIcon.visible = false;
				txView.voCell.btn.label = vo.name;
				txView.voCell.lvBg.visible = false;
				txView.desLbl.text = vo.getDes(1);
				txView.voCell.iconImg.skin = vo.iconPath;
			}
		}
		
		
		public static function bindPs(_box:Node,_ps:Array,_lv:Number):void
		{
			var levelLbl:Label = _box.getChildByName("levelLbl");
			var numLbl0:Label = _box.getChildByName("numLbl0");
			var numLbl1:Label = _box.getChildByName("numLbl1");
			var numLbl2:Label = _box.getChildByName("numLbl2");
			var numLbl3:Label = _box.getChildByName("numLbl3");
			
			var s:String = GameLanguage.getLangByKey("L_A_73106");
			s = StringUtil.substitute(s,_lv);
			if(levelLbl) levelLbl.text = s;
			if(numLbl0) numLbl0.text = _ps[0];
			if(numLbl1) numLbl1.text = _ps[1];
			if(numLbl2) numLbl2.text = _ps[2];
			if(numLbl3) numLbl3.text = _ps[3];
		}
		
		override public function createUI():void
		{
			this.addChild(view);
			
			for each (var c:* in view.rightBox._childs) 
			{
				if(c is Label)(c as Label).color = "#6cf088";
			}
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			 while(txList.length){
				 var txView:NewTuPoAddTexingCellUI = txList.shift();
				 txView.removeSelf();
			 }
			
			super.close();
		}
		
		private function get view():NewJuexingTupoViewUI{
			_view ||= new NewJuexingTupoViewUI();
			return _view;
		}
		
		override public function addEvent():void
		{
			view.closeBtn.on(Event.CLICK, this, this.close);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.closeBtn.off(Event.CLICK, this, this.close);
			
			super.removeEvent();
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			txList  = null;
			super.destroy(destroyChild);
		}
		
	}
}