package game.module.equipFight.cell
{
	import game.common.FilterTool;
	import game.common.GameLanguageMgr;
	import game.common.XFacade;
	import game.global.GameLanguage;
	import game.global.StringUtil;
	import game.global.vo.User;
	import game.module.equipFight.data.equipFightChapterData;
	
	import laya.display.Stage;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Component;
	import laya.ui.Image;
	import laya.ui.Label;
	
	public class equipFightBtnCell extends Component
	{
		public var grayBox:Box;
		public var btn:Image;
		public var cNameLbl:Label;
		public var clevelLbl:Label;
		private var _data:equipFightChapterData;
		
		public function equipFightBtnCell()
		{
			super();
			size(400,400);
			
			grayBox = new Box();
			addChild(grayBox);
			
			btn = new Image();
			btn.pos(108,108);
			grayBox.addChild(btn);
			
			cNameLbl = new Label();
			cNameLbl.autoSize = false;
			cNameLbl.align = Stage.ALIGN_CENTER;
			cNameLbl.size(width,35);
			cNameLbl.pos(0,356 - 45);
			cNameLbl.font = XFacade.FT_BigNoodleToo;
			cNameLbl.fontSize = 30;
			cNameLbl.color = "#ffffff";
			
			
			clevelLbl = new Label();
			clevelLbl.autoSize = false;
			clevelLbl.align = Stage.ALIGN_CENTER;
			clevelLbl.size(width,22);
			clevelLbl.pos(0,388 - 45);
			clevelLbl.font = XFacade.FT_Futura;
			clevelLbl.fontSize = 18;
			
			grayBox.addChild(cNameLbl);
			addChild(clevelLbl);
			
			this.anchorX = .5;
			this.anchorY = 1;
		}
		
		public function get data():equipFightChapterData
		{
			return _data;
		}

		public function set data(value:equipFightChapterData):void
		{
			_data = value;
			if(!_data)return ;
			btn.skin = "appRes/equipFight/icon1/"+_data.vo.icon+".png";
			cNameLbl.text = String(_data.vo.chapter_name);
//			clevelLbl.text =  (value.vo.open_level);
			var lvStr:String = GameLanguage.getLangByKey("L_A_44002");
			lvStr = StringUtil.substitute(lvStr,_data.vo.open_level);
			clevelLbl.text = lvStr;
			
			
//			User.getInstance().level
			clevelLbl.color = User.getInstance().level < _data.vo.open_level ? "#ce4a4a" : "#4acea7";
			
			grayBox.gray = !_data.isOpen;
		}
		
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy equipFightBtnCell");
			grayBox = null;
			btn = null;
			cNameLbl = null;
			clevelLbl = null;
			_data = null;
			
			
			super.destroy(destroyChild);
		}
		

	}
}