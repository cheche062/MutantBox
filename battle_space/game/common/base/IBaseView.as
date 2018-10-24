package game.common.base
{	
	////////////////////////////////////////////////////////////////////////////
	//// 
	//// 所有 Controller都要实现的接口
	////
	////////////////////////////////////////////////////////////////////////////
	public interface IBaseView
	{
		/**
		 * 初始化 
		 * 
		 */		
		function init():void
		/**
		 * 添加事件 
		 * 要通过baseView 的
		 * 
		 */		
		function addEvent():void
		/**
		 * 移除时间 
		 * 
		 */			
		function removeEvent():void
			
		/**
		 * 销毁 
		 */			
		function dispose():void
			
		/**自适应方法,窗口大小变化时供底层调用*/
		function onStageResize():void;
			
		/**
		 * 显示处理逻辑,每次打开界面会调用
		 * @param data 数据定义
		 */
		function show(...args):void;
		
		/** 关闭 */
		function close():void;
		
		/**获取层级,层级定义在LayerManager中*/
		function get m_iLayerType():int;
		/**ui坐标位置类型*/
		function get m_iPositionType():int;
	}
}