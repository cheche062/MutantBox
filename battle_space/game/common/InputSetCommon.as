/***
 *作者：罗维
 */
package game.common
{
	import laya.events.Event;
	import laya.ui.Button;
	import laya.ui.TextInput;
	import laya.utils.Handler;
	import laya.utils.Timer;

	/**
	 *这是一个包含输入数量、选择数量组件控制器 
	 */
	public class InputSetCommon
	{
		public var inputText:TextInput;
		public var leftBtn:Button;
		public var rightBtn:Button;
		public var leftBtn2:Button;
		public var rightBtn2:Button;
		protected var _timer:Timer;
		protected var _maxNum:Number = 0;
		protected var _minNum:Number = 0;
		
		public function InputSetCommon()
		{
			
		}
		
		
		public function set text(value:Number):void
		{
			inputText.text = value.toString();
			isMaxOfMinValue();
		}
		
		public function get text():Number{
			return Number(inputText.text);
		}
		
		public function get minNum():Number
		{
			return _minNum;
		}

		public function set minNum(value:Number):void
		{
			if(_minNum != value)
			{
				_minNum = value;
			}
		}

		public function get maxNum():Number
		{
			return _maxNum;
		}

		public function set maxNum(value:Number):void
		{
			if(_maxNum != value)
			{
				_maxNum = value;
			}
		}

		public function get timer():Timer
		{
			if(!_timer)
				_timer = new Timer();
			return _timer;
		}

		public static function create(_inputText:TextInput,_leftBtn:Button , _rightBtn:Button , _leftBtn2:Button = null , _rightBtn2:Button = null):InputSetCommon{
			var rt:InputSetCommon = new InputSetCommon();
			rt.inputText = _inputText;
			rt.leftBtn = _leftBtn;
			rt.rightBtn = _rightBtn;
			rt.leftBtn2 = _leftBtn2;
			rt.rightBtn2 = _rightBtn2;
			rt.inputText.restrict = "0123456789";
			return rt;
		}
		
		
		public function addEvent():void{
			if(inputText)
				inputText.on(Event.INPUT,this,inputChange);
			if(leftBtn)
			{
				leftBtn.on(Event.MOUSE_DOWN,this,btnDown);
				leftBtn.on(Event.MOUSE_UP,this,btnUp);
			}
			if(rightBtn)
			{
				rightBtn.on(Event.MOUSE_DOWN,this,btnDown);
				rightBtn.on(Event.MOUSE_UP,this,btnUp);
			}
			if(leftBtn2)
			{
				leftBtn2.on(Event.MOUSE_DOWN,this,btnDown);
				leftBtn2.on(Event.MOUSE_UP,this,btnUp);
			}
			if(rightBtn2)
			{
				rightBtn2.on(Event.MOUSE_DOWN,this,btnDown);
				rightBtn2.on(Event.MOUSE_UP,this,btnUp);
			}
		}
		
		public function removeEvent():void{
			if(inputText)
				inputText.off(Event.INPUT,this,inputChange);
			if(leftBtn)
			{
				leftBtn.off(Event.MOUSE_DOWN,this,btnDown);
				leftBtn.off(Event.MOUSE_UP,this,btnUp);
			}
			if(rightBtn)
			{
				rightBtn.off(Event.MOUSE_DOWN,this,btnDown);
				rightBtn.off(Event.MOUSE_UP,this,btnUp);
			}
			if(leftBtn2)
			{
				leftBtn2.off(Event.MOUSE_DOWN,this,btnDown);
				leftBtn2.off(Event.MOUSE_UP,this,btnUp);
			}
			if(rightBtn2)
			{
				rightBtn2.off(Event.MOUSE_DOWN,this,btnDown);
				rightBtn2.off(Event.MOUSE_UP,this,btnUp);
			}
		}
		
		
		public function inputChange(e:Event):void{
			isMaxOfMinValue();
		}
		
		public function isMaxOfMinValue():Boolean{
			var rt:Boolean;
			var n:Number = Number(inputText.text);
			if(n < minNum)
				inputText.text = minNum.toString();
			else if(n > maxNum)
				inputText.text = maxNum.toString();
			n = Number(inputText.text);	
			
			leftBtn.disabled = n == minNum;
			if(leftBtn2)
			{
				leftBtn2.disabled = n == minNum;
			}
			rightBtn.disabled = n == maxNum;
			if(rightBtn2)
			{
				rightBtn2.disabled = n == maxNum;
			}
			rt = n == minNum || n == maxNum;
			return rt;
		}
		
		
		public function btnDown(e:Event):void{
			switch(e.target)
			{
				case leftBtn:
				{
					timerChange(-1);
					break;
				}
				case rightBtn:
				{
					timerChange(1);
					break;
				}
				case leftBtn2:
				{
					inputText.text = minNum.toString();
					break;
				}
				case rightBtn2:
				{
					inputText.text = maxNum.toString();
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		public function btnUp(e:Event):void{
			timer.clear(this,timerChange);
		}
		/**
		 *v 值
		 *v2 本轮执行次数
		 *v3 本轮执行上限
		 *v4 值增指数
		 */
		public function timerChange(v:Number , nextTime:Number = 200, v2:Number = 1 , v3:Number = 10 , v4:Number = .5):void{
			var n:Number = Number(inputText.text);
			n+= v;
			inputText.text = n.toString();
			if(isMaxOfMinValue())
			{
				return ;
			}
			if(v2 == v3)
			{
				v2 = 1;
				var addV:Number = v * v4;
				if(addV > 0)
					addV = Math.ceil(addV);
				else
					addV = Math.floor(addV);
				v += addV;
				trace("vvvv"+v);
			}else
			{
				v2 ++;
			}
				
			timer.once(nextTime,this,timerChange,[v,50,v2,v3,v4]);
		}
		
		public function dispose():void{
			removeEvent();
			_timer = null;
			inputText = null;
			leftBtn = null;
			rightBtn = null;
			leftBtn2 = null;
			rightBtn2 = null;
		}
		
	}
}