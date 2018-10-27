package game.module.guild
{
	import MornUI.StoryTask.StoryTaskViewUI;
	import MornUI.guild.TechnologyGroupUI;
	import MornUI.guild.TechnologyItemUI;
	import MornUI.guild.TechnologyUI;
	
	import game.common.ResourceManager;
	import game.common.XFacade;
	import game.common.XTip;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.ModuleName;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.global.vo.User;
	import game.net.socket.WebSocketNetService;
	
	import laya.events.Event;
	import laya.ui.Button;
	
	public class TechnologyView extends BaseView
	{

		private var itemArr:Array;
		public function TechnologyView()
		{
			super();
		}
		override public function show(...args):void
		{
			super.show(args);
			
		}
		override public function createUI():void 
		{
			// TODO Auto Generated method stub 
			super.createUI();
			this.addChild(view);
			view.pan.vScrollBarSkin = "";
//			model=0;//默认为1，调用setmodel会自动变为0
			addToStageEvent();
		}
		
		private function pullDownOrUp(e:Event):void//将大的模块编号
		{
			var target:Button = e.target as Button;
			for(var i:int=0;i<itemArr.length;i++)
			{
				var item:TechnologyGroupUI = itemArr[i];
				if(target!=item.btn_open)
				{
					item.btn_open.selected = false;
				}
			}
			
			trace("target.selected:"+target.selected);
			if(target.selected)
			{
				target.selected = false;
				setOptionUp(parseInt(target.name)); 
				trace("收起");
			}else
			{
				target.selected = true;
				curOption = parseInt(target.name);
				setOptionDown(curOption); 
				trace("展开");
			}
			
		}
		private function setOptionUp(z:int):void
		{
			for(var i:int=0;i<itemArr.length;i++)
			{
				var item:TechnologyGroupUI = itemArr[i];
				if(i==z)
				{
					item.gBox.visible = false;
				}else
				{
					item.gBox.visible = false;
				}
			}
			resetPan();
		}
		private function setOptionDown(z:int):void//将某一项展开,从0开始
		{
			for(var i:int=0;i<itemArr.length;i++)
			{
				var item:TechnologyGroupUI = itemArr[i];
				if(i==z)
				{
					item.gBox.visible = true;
					item.btn_open.selected = true;
				}else
				{
					item.gBox.visible = false;
					item.btn_open.selected = false;
				}
			}
			resetPan();
		}
		private function resetPan():void
		{
			var delY:Number = 0;
			for(var i:int=0;i<itemArr.length;i++)
			{
				var item:TechnologyGroupUI = itemArr[i];
				var litY:Number = 0;//小项间距
				for(var j:int=0;j<item.gBox.numChildren;j++)
				{
					var cell:TechnologyItemUI = item.gBox.getChildAt(j);
					cell.y =litY;
					litY += cell.height;
				}
				item.y = delY;
				delY += item.height;
			}
			view.pan.refresh();
		}
		private function addToStageEvent():void
		{
			this.on(Event.ADDED, this, this.addToStageHandler);
			this.on(Event.REMOVED, this, this.removeFromStageHandler);
		}
		
		private function removeFromStageHandler():void
		{
			removeSelfEvent();
		}
		
		private function addSelfEvent():void
		{
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_PANNEL),this,serviceResultHandler,[ServiceConst.TECHNOLOGY_PANNEL]);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_RECOMMOND),this,serviceResultHandler,[ServiceConst.TECHNOLOGY_RECOMMOND]);
			view.btnCommond.on(Event.CLICK,this,changeModel);
			Signal.intance.on("refreshDonate",this,refrshDonate);
//			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ERROR), this, onError);
		}
		
		private function refrshDonate(left:int):void
		{
			trace("捐献刷新");
			view.num1.text = User.getInstance().contribution; 
			view.num2.text = left+"/"+totolNum;
		}
		//		private function onError(...args):void{
//			var cmd:Number = args[1];
//			var errStr:String = args[2];
//			var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_PARAM);
//			trace("参数表"+JSON.stringify(storyObj));
//			for each(var obj:Object in storyObj)
//			{
//				if(obj["id"]==3)
//				{
//					XTip.showTip(GameLanguage.getLangByKey(errStr).replace("{0}",obj["value"]));
//					break;
//				}
//			}
//			
////			trace("11111");
//		}
		private function changeModel():void
		{
			if(!canRecom)
			{
				//弹提示
				XTip.showTip(GameLanguage.getLangByKey("L_A_921066"));
				return;//不能推荐
			}
			if(model==0)
			{
				model=1;
				setModel(model);
			}
			else if(model==1)
			{
				model=0;
				setModel(model);
			}
		}
		
		/**
		 *设置推荐模式 
		 * 
		 */
		private function setModel(m:int):void
		{
		 
			if(m==0)
			{
//				model=0;
				view.btnCommond.label=GameLanguage.getLangByKey("L_A_2640");
			}else if(m==1)
			{
//				model=1;
				view.btnCommond.label=GameLanguage.getLangByKey("L_A_83");
			}
			for(var i:int=0;i<itemArr.length;i++)
			{
				var item:TechnologyGroupUI = itemArr[i];
				for(var j:int=0;j<item.gBox.numChildren;j++)
				{
					var cell:TechnologyItemUI = item.gBox.getChildAt(j) as TechnologyItemUI;
					cell.btn2.label=GameLanguage.getLangByKey("L_A_2640");//推荐
					cell.btn3.label=GameLanguage.getLangByKey(" L_A_28");//"取消推荐"
					cell.btn1.label=GameLanguage.getLangByKey(" L_A_2594");//go
					cell.btn3.on(Event.CLICK,this,requestCommond,[cell,0]);
					cell.btn2.on(Event.CLICK,this,requestCommond,[cell,1]);
					cell.btn1.on(Event.CLICK,this,donate,[cell]);
					if(m==1)
					{
						cell.btn1.visible = false;
						if(cell.name=="1")
						{
							cell.btn2.visible = false;
							cell.btn3.visible = true;
						}else
						{
							cell.btn2.visible = true;
							cell.btn3.visible = false;
						}
					}else if(m==0)
					{
						cell.btn1.visible = true;
						cell.btn3.visible = false;
						cell.btn2.visible = false;		
					}
				}
			}
		}
		
		private function donate(cell:TechnologyItemUI):void
		{
			var id:String = cell._get$P("id");
			var data:Array = cell._get$P("dataCell");
			XFacade.instance.closeModule(ModuleName.DonateView);
			XFacade.instance.openModule(ModuleName.DonateView,data);
//			trace("强化的科技："+JSON.stringify(data));
		}
		
		private function requestCommond(cell:TechnologyItemUI,kinds:int):void
		{
			if(kinds==0)//取消推荐
			{
				curCancel = cell;
				var id:String = curCancel._get$P("id");
				trace("取消的id:"+id);
				var idArr:Array = id.split("-");
				WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_RECOMMOND,[idArr[0],idArr[1],kinds]);
			}else if(kinds==1)
			{
				curCommand = cell;
				var id:String = curCommand._get$P("id");
				trace("推荐的id:"+id);
				trace("推荐的name:"+curCommand.name);
				var idArr:Array = id.split("-");
				WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_RECOMMOND,[idArr[0],idArr[1],kinds]);
			}
			
		}
		private var GUILD_TEC:String = "config/guild_tec.json";
		private var GUILD_PARAM:String = "config/guild_tec_param.json";//参数
		private var commandArr:Array;

		private var model:int;//0是正常模式，1推荐模式

		private var canRecom:Boolean;

		private var curCancel:TechnologyItemUI;

		private var curCommand:TechnologyItemUI;

		private var totolNum:String;

		private var curOption:int;

		private function serviceResultHandler(cmd:int, ...args):void
		{
			switch(cmd)
			{
				case ServiceConst.TECHNOLOGY_PANNEL:
//					trace("科技面板:"+JSON.stringify(args[1]));
					
					var techData:Object = args[1]["techData"]; 
					canRecom = args[1]["canRecom"]; 
					createPanView(techData);
					
					view.num1.text = User.getInstance().contribution; 
					var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_PARAM);
					trace("参数表"+JSON.stringify(storyObj));
					
					for each(var obj:Object in storyObj)
					{
						if(obj["id"]==1)
						{
							totolNum = obj["value"];
							view.num2.text = args[1]["donateTimesleft"]+"/"+totolNum;
						}
					}
					model = 0;
					break;
				case ServiceConst.TECHNOLOGY_RECOMMOND:
					if(args[3]==0)
					{
						trace("取消推荐返回");
//						curCancel.visible = false;
						
//						var id:String = curCancel.name;
//						var idArr:Array = id.split("-");
//						var itemName:String = idArr[0]+"-"+idArr[1];
//						var item:TechnologyGroupUI = view.pan.getChildByName(itemName);
//						item.addChild(curCancel);
						var item:TechnologyGroupUI = view.pan.getChildByName("recomand");
						for(var i:int=item.gBox.numChildren-1;i>=0;i--)
						{
							var deleteCell:TechnologyItemUI = item.gBox.getChildAt(i);
							
							if(deleteCell._get$P("id")==curCancel._get$P("id"))
							{
								item.gBox.removeChildAt(i);
							}
						}
						
						if(item.gBox.numChildren==0)
						{
							item.btn_open.visible = false;
							item.btn_open.selected = false;
//							setOptionDown(1);
						}	
						for(var i:int=0;i<itemArr.length;i++)
						{
							var item:TechnologyGroupUI = itemArr[i];
							for(var j:int=0;j<item.gBox.numChildren;j++)
							{
								var cell:TechnologyItemUI = item.gBox.getChildAt(j);
								if(cell._get$P("id")==curCancel._get$P("id"))
								{
									cell.name="0";
								}
							}
							
						}
						curCancel.name="0";
						setModel(1);
					}else if(args[3]==1)
					{
						trace("推荐返回");
						var item:TechnologyGroupUI = view.pan.getChildByName("recomand");
						
						var cell:TechnologyItemUI = new TechnologyItemUI();
						cell.tName.text = curCommand.tName.text;
						cell.context.text = curCommand.context.text;
						cell.name="1";
						cell._set$P("id",curCommand._get$P("id"));
						cell.icon.skin = curCommand.icon.skin;
						cell.pro.value =  curCommand.pro.value;
						cell._set$P("dataCell",curCommand._get$P("dataCell"));
						item.gBox.addChild(cell);
						curCommand.name="1";
						setModel(1);//根据model和推荐状态设置视图
						
						//添加后调整推荐栏按钮状态
						var item:TechnologyGroupUI = view.pan.getChildByName("recomand");
						if(item.gBox.numChildren>0)
						{
							item.btn_open.visible = true;
							item.btn_open.selected = false;
//							setOptionDown(0);
						}
						var arr:Array = curCommand._get$P("dataCell");
						if(15==arr[1])
						{
							cell.btn1.disabled = true;
							cell.btn1.label = GameLanguage.getLangByKey("L_A_38052");
						}else
						{
							cell.btn1.disabled = false;
							cell.btn1.label = GameLanguage.getLangByKey("L_A_2594");
						}
					}
					resetPan();
					break;
			}
		}
		
		/**
		 *将可推荐数据提取出来，先创建可推荐部分UI 
		 * @param techData
		 * 
		 */
		private function createCommandView(techData:Object):void
		{
			trace("techData:"+JSON.stringify(techData));
			commandArr = [];
			for(var key:String in techData)
			{
				var bKind:Object = techData[key];
				for(var key1:String in bKind)
				{
					var lkind:Array = bKind[key1];
					
					var ifCommond:int = lkind[2];
					
					if(ifCommond==1)//代表可推荐
					{
						var lv:int = lkind[0];
						var pro:int = lkind[1];
						var technologyId:String = key+"-"+key1+"-"+lv;
						var arr:Array = [technologyId,lv,pro,ifCommond];
						commandArr.push(arr);
					}
				}
			}
			
			
			itemArr = [];
			var item:TechnologyGroupUI = new TechnologyGroupUI();
			view.pan.addChild(item);
			itemArr.push(item);
			item.btn_open.name = "0";
			item.btn_open.on(Event.CLICK,this,pullDownOrUp);
			item.name="recomand";
			item.gName.text = GameLanguage.getLangByKey("L_A_2654");
			var litY:Number = 0;//小项间距
			var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_TEC);
//			trace("剧情推荐："+JSON.stringify(storyObj));
			for(var i:int=0;i<commandArr.length;i++)
			{
				var cell:TechnologyItemUI = new TechnologyItemUI();
				item.gBox.addChild(cell);
				cell.y = litY;
				litY += cell.height;	
				cell._set$P("id",commandArr[i][0]);
				cell._set$P("dataCell",[commandArr[i][0],commandArr[i][1],commandArr[i][2]]);
				cell.name="1"; 
				if(15==commandArr[i][1])
				{
					cell.btn1.disabled = true;
					cell.btn1.label = GameLanguage.getLangByKey("L_A_38052");
				}else
				{
					cell.btn1.disabled = false;
					cell.btn1.label = GameLanguage.getLangByKey("L_A_2594");
				}
				for each(var obj:Object in storyObj)
				{
//					trace("obj:"+JSON.stringify(obj));
//					trace("obj[id]:"+obj["id"]);
//					trace("commandArr[i][0]"+commandArr[i][0]);
					if(obj["id"]==commandArr[i][0])
					{
//						trace("storyObj:"+JSON.stringify(storyObj));
					
						trace("item.gName"+item.gName);
						cell.tName.text = GameLanguage.getLangByKey(obj["tpye2lan"])+ "  "+GameLanguage.getLangByKey("L_A_34071").replace("{0}",commandArr[i][1]);
//						trace("参数2"+obj["param2"]);
						cell.context.text = GameLanguage.getLangByKey(obj["des"]).replace("{0}", Number(obj["param2"]).toFixed(1));
						cell.icon.skin = "appRes/icon/guildIcon/tec/"+GameLanguage.getLangByKey(obj["icon"])+".png";
						cell.pro.value = commandArr[i][2]/obj["need_exp"];	
						
					}
				}
			}
			if(item.gBox.numChildren==0)
			{
				item.btn_open.visible = false;
				item.btn_open.selected = false;
				//							setOptionDown(1);
			}
		}
		
		private function createPanView(techData:Object):void
		{
			view.pan.removeChildren();
			createCommandView(techData); //创建可推荐部分UI
			for(var key:String in techData)
			{
				var bKind:Object = techData[key];
				var item:TechnologyGroupUI = new TechnologyGroupUI();
				view.pan.addChild(item);
				itemArr.push(item);
				item.btn_open.name = key;
				item.btn_open.on(Event.CLICK,this,pullDownOrUp);
				var litY:Number = 0;//小项间距
				for(var key1:String in bKind)
				{
					var lkind:Array = bKind[key1];
					var lv:int = lkind[0];
					var pro:int = lkind[1];
					var ifConmand:int = lkind[2];
					var technologyId:String = key+"-"+key1+"-"+lv;
					//trace("科技id:"+technologyId);
					var cell:TechnologyItemUI = new TechnologyItemUI();
					item.gBox.addChild(cell);
					item.name = key+"-"+key1;
					cell.y = litY;
					litY += cell.height;
					cell.name = ifConmand+"";
					cell._set$P("id",technologyId);
					cell._set$P("dataCell",[technologyId,lv,pro]);
					if(15==lv)
					{
						cell.btn1.disabled = true;
						cell.btn1.label = GameLanguage.getLangByKey("L_A_38052");
					}else
					{
						cell.btn1.disabled = false;
						cell.btn1.label = GameLanguage.getLangByKey("L_A_2594");
					}
					var storyObj:Object = ResourceManager.instance.getResByURL(GUILD_TEC);
					for each(var obj:Object in storyObj)
					{
						if(obj["id"]==technologyId)
						{
							item.gName.text = GameLanguage.getLangByKey(obj["type1lan"]);
							trace("item.gName"+item.gName);
							cell.tName.text = GameLanguage.getLangByKey(obj["tpye2lan"]) + "  "+GameLanguage.getLangByKey("L_A_34071").replace("{0}",lv);
							trace("obj[param2]:"+obj["param2"]);
							cell.context.text = GameLanguage.getLangByKey(obj["des"]).replace("{0}", Number(obj["param2"]).toFixed(1));
							cell.icon.skin = "appRes/icon/guildIcon/tec/"+GameLanguage.getLangByKey(obj["icon"])+".png";
							cell.pro.value = pro/obj["need_exp"];
							
						}
					}
				}
			}
			setOptionDown(curOption);//将推荐设置为展开
			setModel(0);
//			resetPan();
		}
		private function addToStageHandler():void
		{
			curOption = 0;
			addSelfEvent();
			WebSocketNetService.instance.sendData(ServiceConst.TECHNOLOGY_PANNEL,[]);		
		}
		
		private function removeSelfEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.TECHNOLOGY_PANNEL),this,serviceResultHandler);
		}
		override public function removeEvent():void{
			super.removeEvent();
		}
		override public function addEvent():void{
			
		}
		private function onClose():void{
			super.close();
		}
		public function get view():TechnologyUI{
			if(!_view)
			{ 
				_view ||= new TechnologyUI;  
			} 
			return _view;
		}
	}
}