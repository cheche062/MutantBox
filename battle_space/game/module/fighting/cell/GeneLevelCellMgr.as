package game.module.fighting.cell
{
	import game.common.RewardList;
	import game.global.GameConfigManager;
	import game.global.data.bag.ItemCell3;
	import game.global.vo.GeneLevelVo;
	
	import laya.display.Node;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.ui.List;
	import laya.ui.ProgressBar;

	public class GeneLevelCellMgr
	{
		
		public var typeIcon:Image;
		public var nameLbl:Label;
		public var tiaojianLbl:Label;
		public var rBox:Box;
		public var fBtn:Button;
		public var wIcon:Image;
		public var wNulLbl:Label;
		public var hpBar:ProgressBar;
		public var hpLbl:Label;
		
		private var _data:Object;
		private var _rList:RewardList;
		private var _iconList:List;
		
		public function GeneLevelCellMgr(ui:Node)
		{
			typeIcon = ui.getChildByName("typeIcon");
			nameLbl = ui.getChildByName("nameLbl");
			tiaojianLbl = ui.getChildByName("tiaojianLbl");
			rBox = ui.getChildByName("rBox");
			fBtn = ui.getChildByName("fBtn");
			hpBar = ui.getChildByName("hpBar");
			hpLbl = ui.getChildByName("hpLbl");
			
			
			wIcon = fBtn.getChildByName("wIcon");
			wNulLbl = fBtn.getChildByName("wNulLbl");
			
			_rList = new RewardList();
			_rList.itemRender = ItemCell3;
			_rList.itemWidth = ItemCell3.itemWidth;
			_rList.itemHeight = ItemCell3.itemHeight;
			rBox.addChild(_rList);
			
			_iconList = new List();
			_iconList.repeatX = 4;
			_iconList.repeatY = 1;
			_iconList.itemRender = TypeIconCell;
			_iconList.size(120,36);
			ui.addChild(_iconList);
			_iconList.pos(typeIcon.x, typeIcon.y);
			typeIcon.removeSelf();
		}
		
		public function set data(v:Object):void
		{
			_data = v;
			var vo:GeneLevelVo = GameConfigManager.convict_level_dic[v.genen_level_id];
			if(vo)
			{
				nameLbl.text = vo.name;
				tiaojianLbl.text = vo.rq_text1;
				_rList.array = vo.showReward;
				_rList.x = rBox.width - _rList.width >> 1;
				if(v.price_number && v.buy_state)
				{
					fBtn.label = "";
					wIcon.visible = wNulLbl.visible = true;
					wNulLbl.text = v.price_number;
				}else
				{
					fBtn.label = !v.buy_state ? "L_A_30":"L_A_27";
					wIcon.visible = wNulLbl.visible = false;
				}
				_iconList.array = vo.rqIcons;
				hpBar.value = _data.progress / 100;
				hpLbl.text = _data.progress + "%";
			}
		}
		
		public function destroy():void{
			typeIcon = null;
			nameLbl = null;
			tiaojianLbl = null;
			rBox = null;
			fBtn = null;
			wIcon = null;
			wNulLbl = null;
			hpBar = null;
			hpLbl = null;
			_data = null;
			_rList = null;
			_iconList = null;
			
		}
	}
}