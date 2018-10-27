/***
 *作者：罗维
 */
package game.module.fighting.view
{
	import MornUI.fightingChapter.GeneInfoViewUI;
	import MornUI.fightingChapter.fightingChapetrMenuUI;
	
	import game.common.AlertManager;
	import game.common.AlertType;
	import game.common.ResourceManager;
	import game.common.SceneManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.baseScene.SceneType;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.RegistClass;
	import game.global.StringUtil;
	import game.global.cond.ConditionsManger;
	import game.global.consts.ServiceConst;
	import game.global.data.ConsumeHelp;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.GeneLevelVo;
	import game.global.vo.StageChapterVo;
	import game.global.vo.User;
	import game.module.bag.mgr.ItemManager;
	import game.module.fighting.cell.GeneLevelCellMgr;
	import game.module.fighting.mgr.FightingManager;
	import game.module.gm.helpButton;
	import game.net.socket.WebSocketNetService;
	
	import laya.display.Node;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	
	public class GeneChapetrView extends BaseChapetrView
	{
		private var rBtn:Button;
		private var rNumBox:Image;
		private var rNumLbl:Label;
		private var cellList:Array = [];
		private var dataList:Array = [];
		private var _helpB:helpButton;
		private var _listBox:Box;
		private var rwitem:ItemData;
		private var mV:GeneInfoViewUI; 
		
		public function GeneChapetrView()
		{
			super();
//			addChild(bgImg);
			
			size(Laya.stage.width,Laya.stage.height);
			
			
			mV = new GeneInfoViewUI();
			_listBox = mV.listBox;
			contentBox.addChild(mV);
			rBtn = mV.rBtn;
			rNumBox = mV.rNumBox;
			rNumLbl = mV.rNumLbl;
			for (var i:int = 0; i < 3; i++) 
			{
				cellList.push(new GeneLevelCellMgr(mV.listBox.getChildByName("gCell"+i)));
				dataList.push({
					combat_number:0,
					genen_level_id:1,
					free_number:0,
					price_number:0,
					buy_state:0
				});
			}
			
			var st:String = GameLanguage.getLangByKey("L_A_44004");
			st = st.replace(/##/g,"<br>");
			_helpB = new helpButton("common/btn_info2.png","",st);
//			contentBox.addChild(_helpB);
//			_helpB.pos(1050,12);

			UIRegisteredMgr.AddUI(mV.genReq, "FightLimit");
			UIRegisteredMgr.AddUI(mV.genReward, "FightReward");
			UIRegisteredMgr.AddUI(mV.FreeBtn, "FreeFight");
			

			bindData();
		}
		
		public function bindData():void{
			bgImg.skin = "appRes/fightingMapImg/bg.jpg";
		}
		
		
		public function sendChapetrInfo():void{
			WebSocketNetService.instance.sendData(ServiceConst.GENENSTAGE_INFO_DATA,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.GENENSTAGE_INFO_DATA),
				this,sendChapetrInfoBack);
		}
		
		
		private function sendChapetrInfoBack(... args):void{
			Signal.intance.off(
				ServiceConst.getServerEventKey(args[0]),
				this,sendChapetrInfoBack);
			var stageInfo:Object = args[1].stage_info;
			var refreshN:Number = Number(args[1].refresh_number);
			var frN:Number = 0;
			var json:Object = ResourceManager.instance.getResByURL("config/convict_param.json");
			var fn:Number = 0;
			if(json)
			{
				fn = Number(json[1].value);
				frN = Number(json[7].value);
				var obj:Object = dataList[0];
				obj.free_number = fn;
			}
			var nn:Number = frN - refreshN;
			if(nn > 0)
			{
				rNumBox.visible = true;
				rNumLbl.text = nn;
				rwitem = null;
			}else
			{
				rNumBox.visible = false;
				rwitem = getReNum(refreshN - frN + 1);
			}
			
			for (var i:int = 0; i < 3; i++) 
			{
				var obj:Object = dataList[i];
				obj.combat_number = stageInfo[i+1].combat_number;
				obj.genen_level_id = stageInfo[i+1].genen_level_id;
				obj.buy_state = stageInfo[i+1].buy_state;
				if(stageInfo[i+1].hasOwnProperty("progress"))
					obj.progress = Number(stageInfo[i+1].progress);
				else
					obj.progress = 100;
				var pNum:Number = obj.combat_number - obj.free_number + 1;
				if(pNum > 0)
				{
					obj.price_number = getBuyNum(pNum,i+1).inum;
				}else
				{
					obj.price_number = 0;
				}
				
			}
			
			
			for (var j:int = 0; j < 3; j++) 
			{
				(cellList[j] as GeneLevelCellMgr).data = dataList[j];
			}
			
		}
		
		private function btnClick(i:Number):void{
			
			if(!dataList)
			{
				XTip.showTip("基础数据未获得");
				return ;
			}
			
			if(!dataList[i].price_number || !dataList[i].buy_state)
			{
				ackFun(i);
				return ;
			}
			
			var fP:Number = dataList[i].price_number;  //购买价格
			var item:ItemData = new ItemData();
			item.iid = DBItem.WATER;
			item.inum = fP;
			
			ConsumeHelp.Consume([item],Handler.create(this,ackFun,[i]),GameLanguage.getLangByKey("L_A_38048"));
		}
		
		private  function ackFun(i:Number):void
		{
			FightingManager.intance.getSquad(FightingManager.FIGHTINGTYPE_GENE ,i+1,Handler.create(this,fBackFunction));
		}

		private function fBackFunction():void{
			SceneManager.intance.setCurrentScene(SceneType.M_SCENE_FIGHT_MAP ,true,1, [1,1]);
		}
		
		public override function addEvent():void
		{
			super.addEvent();
			rBtn.on(Event.CLICK,this,refreshFun);
			if(cellList)
			{
				for (var i:int = 0; i < cellList.length; i++) 
				{
					(cellList[i] as GeneLevelCellMgr).fBtn.on(Event.CLICK,this,btnClick,[i]);
				}
			}
			sendChapetrInfo();
		}
		public override function removeEvent():void
		{
			super.removeEvent();
			rBtn.off(Event.CLICK,this,refreshFun);
			if(cellList)
			{
				for (var i:int = 0; i < cellList.length; i++) 
				{
					(cellList[i] as GeneLevelCellMgr).fBtn.off(Event.CLICK,this,btnClick);
				}
			}
		}
		
		
		private function refreshFun():void
		{
			if(!rwitem)
			{
				AlertManager.instance().AlertByType(AlertType.BASEALERTVIEW,GameLanguage.getLangByKey("L_A_38046"),0,function(v:uint):void{
					if(v == AlertType.RETURN_YES)
					{
						refreshSend();
					}
				});
				return ;
			}
			
			ConsumeHelp.Consume([rwitem],Handler.create(this,refreshSend),GameLanguage.getLangByKey("L_A_38047"));
		}
		private function refreshSend():void
		{
			WebSocketNetService.instance.sendData(ServiceConst.FIGHTING_GENE_LEVEL_REFRESH,[]);
			Signal.intance.on(
				ServiceConst.getServerEventKey(ServiceConst.FIGHTING_GENE_LEVEL_REFRESH),
				this,sendChapetrInfoBack);
		}
		
		public function getBuyNum(n:Number,ftype:Number = 1):ItemData{
			var stage_buy_json:Object=ResourceManager.instance.getResByURL("config/convict_buy.json");
			var leftStr:String;
			if(stage_buy_json)
			{
				for each (var c:Object in stage_buy_json)
				{
					leftStr = c.price;
					if(Number(c.type) == ftype && n >= Number(c.down) && n <= Number(c.up))
					{
						return ItemManager.StringToReward(c.price)[0];
					}
				}
			}
			
			return ItemManager.StringToReward(leftStr)[0];
			
		}
		
		public function getReNum(n:Number):ItemData{
			var stage_buy_json:Object=ResourceManager.instance.getResByURL("config/convict_refresh.json");
			var leftStr:String;
			if(stage_buy_json)
			{
				for each (var c:Object in stage_buy_json)
				{
					leftStr = c.price;
					if(n >= Number(c.down) && n <= Number(c.up))
					{
						return ItemManager.StringToReward(c.price)[0];
					}
				}
			}
			
			return ItemManager.StringToReward(leftStr)[0];
			
		}
		
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			
			_helpB.pos(Laya.stage.width - 90 , 20);
			_listBox.pos(Laya.stage.width - _listBox.width >> 1, Laya.stage.height - _listBox.height >> 1);
			
			rBtn.pos(10,Laya.stage.height - 20 - rBtn.height);
		}
		
		override public function destroy(destroyChild:Boolean=true):void{
			if(_helpB)
			{
				_helpB.removeSelf();
				_helpB.destroy();
				_helpB = true;
			}
			UIRegisteredMgr.DelUi(mV.genReq, "FightLimit");
			UIRegisteredMgr.DelUi(mV.genReward, "FightReward");
			UIRegisteredMgr.DelUi(mV.FreeBtn, "FreeFight");
			
			
			if(cellList && cellList.length)
			{
				for (var i:int = 0; i < cellList.length; i++) 
				{
					(cellList[i] as GeneLevelCellMgr).destroy();
				}
			}
			
			
			
			
			super.destroy(destroyChild);
			
			rBtn = null;
			rNumBox = null;
			rNumLbl = null;
			cellList = null;
			dataList = null;
			_helpB = null;
			_listBox = null;
			rwitem = null;
			mV = null;
		}

	}
}