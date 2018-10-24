package game.module.armyGroup
{
	import game.common.XUtils;
	import game.global.GameConfigManager;
	import game.module.bingBook.ItemContainer;
	import laya.ui.TextArea;
	import MornUI.armyGroup.GroupChildViewUI;

	import game.common.base.BaseView;
	import game.global.GameLanguage;
	import game.global.consts.ServiceConst;
	import game.global.event.Signal;
	import game.net.socket.WebSocketNetService;

	import laya.events.Event;

	/**
	 * 军团公会击杀排行
	 * @author douchaoyang
	 *
	 */
	public class GroupChildView extends BaseView
	{
		// 存放列表数据
		private var gRankArr:Array=[];
		// 当前页数
		private var nowPage:int=1;
		// 最大页数
		private var maxPage:int=1;
		// 每页显示的个数，如果有变动，更改此处
		private const INIT_NUM:int=6;

		// 自己公会信息
		private var ownInfo:Object;
		
		public function GroupChildView()
		{
			super();
		}

		/**
		 * 请求数据之后的处理函数
		 * @param cmd 请求参数
		 * @param args 服务器返回参数
		 *
		 */
		private function onResultHandler(cmd:int, ... args):void
		{
			switch (cmd)
			{
				case ServiceConst.ARMY_GROUP_GET_GUILD_RANK:
					//trace("公会排行榜数据：", args);
					formatList(args[1][1]);
					ownInfo=Object(args[2]);
					// 设置自己公会的信息
					view.ownRank.text=GameLanguage.getLangByKey(ownInfo.rank);
					GameConfigManager.setGuildLogoSkin(view.ownIcon, ownInfo.guildIcon, 0.5);

					view.ownName.text=ownInfo.guildName;
					view.gScoreTxt.text = ownInfo.guildPoint;
					view.noReTxt.text = ownInfo.level;

					break;
				default:
					break;
			}
		}

		private function formatList(args:Object):void
		{
			gRankArr=[];
			for (var tid in args)
			{
				args[tid]["team_id"] = tid;
				gRankArr.push(args[tid]);
			}
			/*gRankArr = [ { "rank":"1", "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":5, "uid":3, "nickname":"Player3", "guildname":"F.F.F.", "killnum":0 },
			{"rank":99,"uid":3,"nickname":"Player3","guildname":"F.F.F.","killnum":0}];*/
			var len:int = gRankArr.length;
			if (len < 30)
			{
				for (var i:int = len; i < 30; i++) 
				{
					gRankArr.push( { rank:i + 1, uid:"-", nickname:"-", guildName:"", guildPoint:"-",guildIcon:-1,team_id:"-" } );
				}
			}
			view.totalList.array = gRankArr;
		}

		override public function show(... args):void
		{
			super.show();
		}

		override public function close():void
		{

		}

		override public function createUI():void
		{
			_view=new GroupChildViewUI();
			this.addChild(_view);
			// 添加列表项
			/*for (var j:int=0; j < INIT_NUM; j++)
			{
				listItem[j]=new GroupTotalItem();
				listItem[j].x=8;
				listItem[j].y=54 + j * 55;
				view.addChild(listItem[j]);
			}*/
			
			view.totalList.itemRender = GroupTotalItem;
			view.totalList.scrollBar.sizeGrid = "6,0,6,0";
			
			addEvent();
		}

		private function addToStageEvent():void
		{
			// 请求数据
			WebSocketNetService.instance.sendData(ServiceConst.ARMY_GROUP_GET_GUILD_RANK);
			Signal.intance.on(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_GUILD_RANK), this, this.onResultHandler, [ServiceConst.ARMY_GROUP_GET_GUILD_RANK]);
		}

		private function removeFromStageEvent():void
		{
			Signal.intance.off(ServiceConst.getServerEventKey(ServiceConst.ARMY_GROUP_GET_GUILD_RANK), this, this.onResultHandler);
		}

		override public function addEvent():void
		{
			this.on(Event.ADDED, this, addToStageEvent);
			this.on(Event.REMOVED, this, removeFromStageEvent);
			view.on(Event.CLICK, this, onclickHandler);
		}

		override public function removeEvent():void
		{
			this.off(Event.ADDED, this, addToStageEvent);
			this.off(Event.REMOVED, this, removeFromStageEvent);
			view.off(Event.CLICK, this, onclickHandler);
		}

		/**
		 * 处理点击逻辑
		 * @param e
		 *
		 */
		private function onclickHandler(e:Event):void
		{
			switch (e.target)
			{
				
				default:
					break;
			}
		}

		/**
		 * 什么都不做，直接返回
		 *
		 */
		private function doNothing():void
		{
			return;
		}

		/**
		 * 刷新列表数据方法
		 * @param page 显示第几页的数据
		 *
		 */
		private function refreshList(page:int):void
		{
			/*// 根据当前页计算从第几条数据开始
			var _num:int=(page - 1) * INIT_NUM;
			var _len:int=gRankArr.length;
			// 向view中添加列表数据
			for (var i:int=0; i < INIT_NUM; i++)
			{
				if (_num + i < _len) // 在数据个数内，添加数据并显示
				{
					// 添加数据
					listItem[i].renderData=gRankArr[_num + i];
					listItem[i].visible=true;
				}
				else // 不存在数据，隐藏item
				{
					listItem[i].visible=false;
				}
			}
			// 将页数信息显示在view上
			view.pageNum.text=String(page + "/" + maxPage);
			// 设置左右切换按钮是否可用
			view.pagePrevBtn.disabled=page <= 1;
			view.pageNextBtn.disabled=page >= maxPage;*/
		}

		private function get view():GroupChildViewUI
		{
			return _view as GroupChildViewUI;
		}
	}
}
