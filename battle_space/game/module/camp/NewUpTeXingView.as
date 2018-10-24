package game.module.camp
{
	
	import MornUI.camp.NewUpTeXingViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ToolFunc;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.data.ConsumeHelp;
	import game.global.event.Signal;
	import game.global.vo.AwakenTypeVo;
	import game.global.vo.User;
	import game.module.bag.cell.needItemCell;
	import game.module.camp.data.JueXingMange;
	
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Handler;
	
	/**
	 * 紫水晶 技能升级弹层
	 * @author mutantbox
	 * 
	 */
	public class NewUpTeXingView extends BaseDialog
	{
		private var txCell:NewTeXingCell;
		private var needCell1:needItemCell;
		private var needCell2:needItemCell;
		// 玩家的cell
		private var myCell:needItemCell; 
		
		public function NewUpTeXingView()
		{
			super();
			_closeOnBlank = true;
		}
		
		private var upcount:Number = 0;
		private var voId:Number = 0;
		private var uId:Number = 0;
		/**状态state*/
		private var _state = null;
		
		override public function createUI():void
		{
			this.addChild(view);
			txCell = new NewTeXingCell();
			txCell.mouseEnabled = false;
			view.addChild(txCell);
			txCell.pos(view.posImg.x ,view.posImg.y);
			view.posImg.removeSelf();
			
			var colors:Array = ["#fff", "#fff"];
			var txtStyle = {fontSize: 24, font: XFacade.FT_Futura};
			var imgStyle = {y: -5};
			
			needCell1 = new needItemCell(colors);
			view.btnBox1.addChild(needCell1);
			needCell1.setElementStyle(imgStyle, txtStyle);
			
			needCell2 = new needItemCell(colors);
			view.btnBox2.addChild(needCell2);
			needCell2.setElementStyle(imgStyle, txtStyle);
			
			myCell = new needItemCell(colors);
			myCell.pos(-4, -3);
			// ide 里面的元素干掉
//			view.dom_title.destroyChildren();
			view.dom_title.addChild(myCell);
			txtStyle.fontSize = 18;
			txtStyle.y = 15;
			myCell.setElementStyle({}, txtStyle);
			
			Laya.loader.load('common/icons/jczy17.png');
		}
		
		/**/
		override public function show(...args):void
		{
			super.show();
			AnimationUtil.flowIn(this);
			
			// 深拷贝
			var data = ToolFunc.extendDeep(args[0]);
			
			// 当upcount为-1时需特别处理
			var isSpecially = (data[1] === -1);
			if (isSpecially) {
				data[1] = 10;
				data[0][2] = 1;
				
//				觉醒{0}级时解锁
				var text = GameLanguage.getLangByKey("L_A_73068");
				text = text.replace('{0}', data[0][1]);
				
				view.dom_unabled.text = text;
			}
			view.dom_bottom_box.visible = !isSpecially;
			view.dom_unabled.visible = isSpecially;
			
			_state = data;
			updateView(_state);
			
		}
		
		/**
		 * 更新视图
		 * 
		 */
		private function updateView(args):void {
			var cellData:Array = args[0];
						
			upcount = args[1]; //升级数
			voId = cellData[0];
			uId = cellData[3];
			txCell.dataSource = cellData;
			
			var vo:AwakenTypeVo = GameConfigManager.awakenTypeVoDic[cellData[0]];
			var lv:Number = cellData[2];
			// 当前等级
			view.lvDesLbl.text = "Lv." + lv + "   " + vo.getDes(lv);
			
			// 还可以继续升级
			if (upcount) {
				var nextLv:Number = lv + 1;
				needCell1.visible = true;
				needCell1.data = vo.upCountCost(lv,1)[0];
				// 升到下一级
				view.nextDesLbl.text = "Lv." + nextLv + "   " + vo.getDes(nextLv);
				view.btn1.disabled = false;
				
			} else {
				needCell1.visible = false;
				view.nextDesLbl.text = GameLanguage.getLangByKey("L_A_73125");
				view.btn1.disabled = true;
			}
			
			needCell1.x = view.btnBox1.width - needCell1.width >> 1;
			
			// 可升级数超过 1
			if (upcount > 1) {
				var s:String = GameLanguage.getLangByKey("L_A_73111");
				view.btn2.label = StringUtil.substitute(s, upcount);
				needCell2.data = vo.upCountCost(lv,upcount)[0];
				needCell2.x = view.btnBox2.width - needCell2.width >> 1;
				
				var jg:Number = 65;
				view.btnBox1.x = (view.width - jg - view.btnBox1.width * 2) / 2;
				view.btnBox2.x = view.btnBox1.x + view.btnBox1.width + jg;
				view.btnBox2.visible = true;
			} else {
				view.btnBox2.visible = false;
				view.btnBox1.x = (view.width - view.btnBox1.width) / 2;
			}
			
			// 写入用户当前能量结晶
			var txt = User.getInstance().purpleCrystal;
			// 还可以继续升级
			if (upcount) {
				myCell.data = vo.upCountCost(lv,1)[0];
				dealwithNeedCellStyle(true, needCell1, txt);
				dealwithNeedCellStyle(true, needCell2, txt);
			} else {
				myCell.data = {inum: txt, iid: 17};
			}
			
			// 最终写入
			renderTitleTxt(txt);
		}
		
		/**数据升级回调*/
		private function upgradeDataHandler(args):void{
			trace('数据升级回调:', args)
			// 重新赋值现在的等级
			_state[0][2] = args[3];
			
			// 剩下的可升的总等级数(配置表的总长度)
			var reset = GameConfigManager.awakenSpecialityVoArr.length - args[3];
			_state[1] = reset > 10 ? 10 : reset;
			
			updateView(_state);
		}
		
		/**
		 * 渲染用户能量（单位k） 
		 * 
		 */
		private function renderTitleTxt(str):void{
			var result:String;
			result = str;
			myCell.itemNumLal.text = result;
		}
		
		// 处理样式      	 bool是否需要重写需要的能量
		private function dealwithNeedCellStyle(bool:Boolean, needCell:needItemCell, text):void{
			var _label = needCell.itemNumLal;
			var _btn:Button = needCell.parent.getChildAt(0);
			var needNum:Number;
			
			if(bool){
				_label.text = "x" + _label.text;
				needCell.displayCenterInParent();
			}
			
			// 将类似'x2k'转换成数字 2000
			needNum = Number(_label.text.replace(/k/i, '000').slice(1));
			
			//不够
			if(needNum > Number(text)){
				_btn.disabled = true;
			}else{
				_btn.disabled = false;
			}
		}
		
		override public function close():void
		{
			AnimationUtil.flowOut(this, onClose);
		}
		
		private function onClose():void
		{
			super.close();
		}
		
		private function get view():NewUpTeXingViewUI{
			_view ||= new NewUpTeXingViewUI();
			return _view;
		}
		
		/**
		 * 更新用户能量结晶数 
		 * 
		 */
		private function refreshUserData(data):void{
			var txt = User.getInstance().purpleCrystal;
			renderTitleTxt(txt);
			dealwithNeedCellStyle(false, needCell1, txt);
			dealwithNeedCellStyle(false, needCell2, txt);
		}
		
		override public function addEvent():void
		{
			view.closeBtn.on(Event.CLICK, this, this.close);
			view.btn1.on(Event.CLICK,this,thisBtnClick);
			view.btn2.on(Event.CLICK,this,thisBtnClick);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.JUEXING_QIANGHUA),this,this.close);
			Signal.intance.on(User.PRO_CHANGED, this, refreshUserData);
			Signal.intance.on(JueXingMange.TEXING_CHANGE,this, upgradeDataHandler);
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.closeBtn.off(Event.CLICK, this, this.close);
			view.btn1.off(Event.CLICK,this,thisBtnClick);
			view.btn2.off(Event.CLICK,this,thisBtnClick);
//			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.JUEXING_QIANGHUA),this,this.close);
			Signal.intance.off(User.PRO_CHANGED, this, refreshUserData);
			Signal.intance.off(JueXingMange.TEXING_CHANGE,this, upgradeDataHandler);
			super.removeEvent();
		}
		
		private function thisBtnClick(e:Event):void{
			if(!voId) return ;
			var c:Number = e.target == view.btn1 ? 1 : upcount;
			var need:Array = e.target == view.btn1 ? [needCell1.data] : [needCell2.data];
			ConsumeHelp.Consume(need,Handler.create(this,qiangBtnSend,[c]));
		}
		
		private function qiangBtnSend(c:Number):void{
			JueXingMange.intance.qiangHuaFun(uId,voId,c);
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			txCell = null;
			needCell1 = null;
			needCell2 = null;
			myCell = null;
			super.destroy(destroyChild);
		}
		
	}
}