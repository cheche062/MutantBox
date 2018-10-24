package game.module.newPata
{
	import MornUI.newPaTa.PataPreViewUI;
	import MornUI.newPaTa.PreItemUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.UIRegisteredMgr;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.event.Signal;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Image;
	
	public class NewPataPreView extends BaseDialog
	{

		public function NewPataPreView()
		{
			super();
		}
		
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btn_close.on(Event.CLICK,this,close);
			view.btn_enter.on(Event.CLICK,this,noticeFight);
		}
		
		override public function close():void
		{
			// TODO Auto Generated method stub
			
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void
		{
			// TODO Auto Generated method stub
			super.close();
		}
		
		override public function removeEvent():void
		{
			// TODO Auto Generated method stub
			super.removeEvent();
			view.btn_close.off(Event.CLICK,this,close);
			view.btn_enter.off(Event.CLICK,this,noticeFight);
		}
		
		private function noticeFight():void
		{
			Signal.intance.event("EnterPataFighting");
			close();
		}
		
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			super.show(args);
			trace("args:"+JSON.stringify(args));
			curId = args[0][0]; 
			battleGroup = args[0][1];
			trace("curId:"+curId);
			setBattleGroup(battleGroup); 
			UIRegisteredMgr.AddUI(view.guide1,"EnterPaTaFightBtn");
			UIRegisteredMgr.AddUI(view.btn_close,"ClosePreViewBtn");
			AnimationUtil.flowIn(this);
		}
		private var PATA_LEVEL_CONFIG:String = "config/pvepata_level.json";
		private var PATA_GROUP_CONFIG:String = "config/pvepata_type.json";
		private var curId:Number;
		private var groupArr:Array;

		private var groupId:Number;

		private var battleGroup:String;
		private function setBattleGroup(groupName:Number):void
		{
			var name:String = groupName;
			var levelObj:Object = ResourceManager.instance.getResByURL(PATA_LEVEL_CONFIG);
			groupArr = []; 
			for(var key:String in levelObj)
			{
				var id1:Number = Number(key);
				if(id1 == curId)
				{
					groupArr = levelObj[key][name].split(",");
					view.br.text =  levelObj[key]["recommand_br"];
				}
			}
			trace("groupArr:"+groupArr);
			
			var groupObj:Object = ResourceManager.instance.getResByURL(PATA_GROUP_CONFIG);
			var groupSourceArr:Array = [];
			var txtArr:Array = [];
			for(var i:int=0;i<groupArr.length;i++)
			{
				for(var key:String in groupObj)
				{
					var id1:Number = Number(key);
					if(id1 == groupArr[i])
					{
						groupSourceArr.push(groupObj[key]["icon"]);
						txtArr.push(groupObj[key]["language"])
					}
				}
			}
			trace("groupSourceArr:"+groupSourceArr);
			var box:Box = view.getChildByName("sp") as Box;
			if(!box)
			{
				box = new Box();
				box.name = "sp";
			}
			box.removeChildren();
			for(var i:int=0;i<groupSourceArr.length;i++)
			{
				var item:PreItemUI = new PreItemUI();
				item.icon.skin = "NewPataPreView/"+groupSourceArr[i]+".png";
				item.txt.text = GameLanguage.getLangByKey(txtArr[i]);
//				img.width = img.height = 90;
				item.x = i*(item.width+70);
				box.addChild(item);
			}
			view.addChild(box);
			box.y = 115;
			box.x = view.width/2-box.width/2;
			
		}
		private function get view():PataPreViewUI {
			_view = _view || new PataPreViewUI();
			return _view;
		}
		override public function createUI():void
		{
			addChild(view);
			closeOnBlank = true;
			// TODO Auto Generated method stub
			super.createUI();
		}
		
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
			UIRegisteredMgr.DelUi("EnterPaTaFightBtn");
			UIRegisteredMgr.DelUi("ClosePreViewBtn");
		}
		
	}
}