package game.module.armyGroup
{
	import MornUI.armyGroup.ArmyGroupChatItemUI;

	import laya.ui.Box;

	/**
	 * 军团聊天消息体
	 * @author douchaoyang
	 *
	 */
	public class ArmyGroupChatItem extends Box
	{
		private var _view:ArmyGroupChatItemUI;
		private var _data:Object;

		public function ArmyGroupChatItem()
		{
			super();
			creatUI();
		}

		private function creatUI():void
		{
			_view=new ArmyGroupChatItemUI();
			this.addChild(_view);
		}

		/**
		 * 重写组件UI渲染方法
		 * @param value 渲染数据
		 *
		 */
		override public function set dataSource(value:*):void
		{
			data=value;
			if (data)
			{
				// 初始化界面
				view.otWord.visible=false;
				view.myWord.visible=false;
				// 根据数据处理 UI
				switch (data.type)
				{
					case "other": // 如果是别人发的消息
						setMsgPanel("ot", data);
						break;
					case "self": // 如果是自己发的消息
						setMsgPanel("my", data);
						break;
					default:
						break;
				}
			}
		}

		/**
		 * 设置消息框UI
		 * @param str 哪一个消息框
		 *
		 */
		private function setMsgPanel(str:String, dat:Object):void
		{
			view[str + "Word"].visible=true;
			// 名字
			view[str + "NameTxt"].text=dat.name;
			// 公会
			view[str + "GroupTxt"].text=dat.group;
			// 时间
			view[str + "TimeTxt"].text=dat.time;
			// 消息
			view[str + "MsgTxt"].text=dat.word;
			// 如果文本高度超出了默认高度
			if (view[str + "MsgTxt"].textHeight > 48)
			{
				// trace("textHeight", view[str + "MsgTxt"].textHeight);
				// 超出了多少
				var overLen:Number=view[str + "MsgTxt"].textHeight - 48;
				// 增加view的高度
				view.height+=overLen;
				// 增加背景的高度
				view[str + "Bg"].height+=overLen;
				// 增加消息框高度
				view[str + "MsgTxt"].height+=overLen;
				// 调整时间的位置
				view[str + "TimeTxt"].y+=overLen;
			}
		}

		private function get data():Object
		{
			return _data;
		}

		private function set data(value:Object):void
		{
			_data=value;
		}

		private function get view():ArmyGroupChatItemUI
		{
			return _view as ArmyGroupChatItemUI;
		}
	}
}
