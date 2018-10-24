package game.module.armyGroup.fight
{
	import game.common.XFacade;
	import game.global.GameLanguage;
	
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.maths.Rectangle;
	import laya.ui.Label;
	import laya.utils.Pool;

	/**
	 * ArmyMsgCom 跑马灯控制逻辑
	 * author:huhaiming
	 * ArmyMsgCom.as 2017-12-1 下午3:35:58
	 * version 1.0
	 *
	 */
	public class ArmyMsgCom
	{
		private var _ui:Sprite;
		private var _msgList:Array = [];
		private var _curLabels:Array = [];
		/***/
		private var _inAction:Boolean = false;
		private static const SIGN:String = "Arm_Label"
		private static const WIDTH:int = 618;
		//
		private static const SPEED:int = -3;
		//间隔
		private static const SPACE:int = 50;
		public function ArmyMsgCom(ui:Sprite)
		{
			_ui = ui;
			_ui.visible = false;
			_ui.scrollRect = new Rectangle(0,0,_ui.width, _ui.height);
		}
		
		//[35884,"1","saygoodbye"]
		public function show(data:Object):void{
			_ui.visible = true;
			var msg:String = GameLanguage.getLangByKey(data[1]);
			msg = msg.replace(/{(\d+)}/, GameLanguage.getLangByKey(data[2]));
			_msgList.push(msg);
			doAction();
		}
		
		public function reset():void{
			_msgList.length = 0;
			_msgList = [];
			
			_curLabels = [];
		}
		
		private function showMsg():void{
			var msg:String = _msgList.shift();
			if(msg){
				var tf:Label = Pool.getItem(SIGN);
				if(!tf){
					tf = new Label();
					tf.color = '#ffffff';
					tf.fontSize = 20;
					tf.font = XFacade.FT_Futura;
				}
				tf.text = msg;
				_ui.addChild(tf);
				tf.x = WIDTH;
				tf.y = 6;
				_curLabels.push(tf);
			}
		}
		
		private function doAction():void{
			if(!_inAction){
				_inAction = true;
				Laya.timer.loop(25, this, this.update);
			}
		}
		
		private function update():void{
			var last:Label;
			for(var i:int=0; i<_curLabels.length; i++){
				_curLabels[i].x += SPEED;
				if(_curLabels[i].x < -_curLabels[i].width){
					_curLabels[i].removeSelf()
					Pool.recover(SIGN, _curLabels[i]);
					_curLabels.splice(i, 1);
					i--;
				}
				
			}
			if(_curLabels.length> 0){
				last = _curLabels[_curLabels.length -1];
				if(last.x < WIDTH - last.width - SPACE){
					showMsg();
				}
			}else{
				showMsg();
			}
			
			if(_curLabels.length == 0){
				_inAction = false;
				Laya.timer.clear(this, this.update);
				this.close();
			}
		}
		
		public function close():void{
			_ui.visible = false;
		}
	}
}