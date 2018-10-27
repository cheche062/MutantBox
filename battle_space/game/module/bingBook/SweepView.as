package game.module.bingBook
{
	import MornUI.bingBook.SweepViewUI;
	
	import game.common.AnimationUtil;
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.base.BaseDialog;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.data.bag.ItemCell3;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	public class SweepView extends BaseDialog
	{

		private var itemArr:Array;
		private var sweepQuanTimes:Number;

		private var sweepWaterTimes:*;
		public function SweepView()
		{
			super();
		}
		public function get view():SweepViewUI{
			if(!_view)
			{
				_view ||= new SweepViewUI;
			}
			return _view;
		}
		override public function addEvent():void
		{
			// TODO Auto Generated method stub
			super.addEvent();
			view.btn_close.on(Event.CLICK,this,this.close);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.RADER_SWEEP_PROP), this, onResult);
		}
		private function onResult(...args):void
		{
			switch(args[0])
			{
				case ServiceConst.RADER_SWEEP_PROP:
				{
					itemArr = [];
					trace("扫荡结果:"+JSON.stringify(args));
					var propArr:Array = [];
					var dataArr:Array = args[1];
					trace(dataArr);
					for each(var value1:Array in dataArr)
					{
						trace("id"+value1[0]+"数量"+value1[1]);
						var itemData:ItemData = new ItemData();
						itemData.iid = value1[0];
						itemData.inum = value1[1];
						propArr.push(itemData);
					}	
					
					sweepQuanTimes = Number(args[2])+1;  
					trace("当前用券进行的扫荡次数："+sweepQuanTimes);
					sweepWaterTimes = Number(args[3])+1;  
					trace("当前用水进行的扫荡次数："+sweepWaterTimes);
					createItemData();//更新道具的个数显示
					XFacade.instance.openModule(ModuleName.ShowRewardPanel, [propArr]);
					WebSocketNetService.instance.sendData(ServiceConst.BINGBOOK_MAIN,[]);
					break;
				}
			}
		}
		override public function close():void
		{
			// TODO Auto Generated method stub
			trace("close");
			super.close();
			AnimationUtil.flowOut(this, this.onClose);
		}
		private function onClose():void{
			super.close(); 
		}
		override public function removeEvent():void
		{
			// TODO Auto Generated method stub
			super.removeEvent();
			view.btn_close.off(Event.CLICK,this,this.close);
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.RADER_SWEEP_PROP), this, onResult);
		}
		
		override public function show(...args):void
		{
			// TODO Auto Generated method stub
			sweepQuanTimes = args[0][0]; 
			trace("传递的券扫荡次数："+args[0][0]);
			sweepWaterTimes = args[0][1];  
			trace("传递的水扫荡次数："+args[0][1]);
//			trace("面板:"+JSON.stringify(args));
		
			super.show(args);
			AnimationUtil.flowIn(this);
//			trace("刷新列表111111");  
			itemArr = [];
			createItemData();
		}
		
		override public function createUI():void
		{
			// TODO Auto Generated method stub
			super.createUI();
			this.closeOnBlank = true;
			isModel = true;
			addChild(view);
			view.list.renderHandler = Handler.create(this,onRender,null,false);	
		}
		 
		private function createItemData():void
		{
			
//			view.list.removeChildren();
//			view.list.array = []; 
			var itemData:ItemData = new ItemData();
//			itemData.iid = 20206;
//			itemData.inum = User.getInstance().getResNumByItem("20206");
//			itemArr.push(itemData);
			
			var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_sweep.json");
			trace("花费:"+JSON.stringify(jsonObj));
			var quanArr:Array = [];
			var waterArr:Array = [];
		
			if (jsonObj)
			{
				for each(var obj:Object in jsonObj)
				{
					if(sweepQuanTimes>=obj["down"]&&sweepQuanTimes<=obj["up"])
					{
						quanArr = obj["price_ticket"].split("=");
						itemData.iid = quanArr[0];
						itemData.inum = quanArr[1];
						itemArr.push(itemData);
						
						
					}
				}
				
				for each(var obj:Object in jsonObj)
				{
					if(sweepWaterTimes>=obj["down"]&&sweepWaterTimes<=obj["up"])
					{
						waterArr = obj["price_water"].split("=");
						itemData = new ItemData();
						itemData.iid = waterArr[0];
						itemData.inum = waterArr[1];
						itemArr.push(itemData);
					}
				}
			}
			
			var jsonObj:Object = ResourceManager.instance.getResByURL("config/book_canshu.json");
			trace("参数:"+JSON.stringify(jsonObj));
			var maxTimes:int=0;
			for each(var obj:Object in jsonObj)
			{
				if(obj["id"]=="9")
				{
					maxTimes = parseInt(obj["value"]);
				}
			}
			var remainTimes:int = maxTimes-sweepQuanTimes+1;
			view.remain.text = GameLanguage.getLangByKey("L_A_33041").replace("{0}",remainTimes);
//			itemData = new ItemData();
//			itemData.iid = 20208;
//			itemData.inum = User.getInstance().getResNumByItem("20208");
//			itemArr.push(itemData);
			view.list.array = itemArr;
			if(remainTimes<=0)
			{
				close();
			}
		} 
		private function onRender(cell:Box,index:int):void
		{
			var dataItem:ItemData = view.list.array[index];
			var itemBox:ItemCell3 =cell.getChildByName("prop") as ItemCell3;
			trace("刷新列表项");
			if(itemBox)
			{ 
				trace("列表项已存在");
				cell.removeChild(itemBox); 
			}
			itemBox = new ItemCell3();
			itemBox.data = dataItem;
			itemBox.name = "prop";
			cell.addChild(itemBox);
			var des:Label = cell.getChildByName("propDes") as Label;
//			des.text = dataItem.vo.des;
		
			var na:Label =  cell.getChildByName("propName") as Label;
			na.text = dataItem.vo.name;
			
			var num:Label =  cell.getChildByName("propNum") as Label;
			
			if(index==0)
			{
				num.visible = true;
				des.text = dataItem.vo.des;
				num.text = "("+GameLanguage.getLangByKey("L_A_33036")+User.getInstance().getResNumByItem("20206")+")";
			}else
			{
				des.text = GameLanguage.getLangByKey("L_A_33040");
				num.visible = false;
			}
			var btn:Button = cell.getChildByName("btn") as Button;

			btn.on(Event.CLICK,this,onbtnClick,[index+1]);
		}
		
		private function onbtnClick(index:int):void
		{
			sendData(ServiceConst.RADER_SWEEP_PROP,[index]);	//1扫荡，2购买
		}
		override public function dispose():void
		{
			// TODO Auto Generated method stub
			super.dispose();
		}
		
	}
}