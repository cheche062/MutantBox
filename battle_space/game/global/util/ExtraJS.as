package game.global.util
{
	import game.common.SoundMgr;
	
	import laya.ui.Button;

	/**
	 * ExtraJS
	 * author:huhaiming
	 * ExtraJS.as 2017-11-8 上午11:14:42
	 * version 1.0
	 *
	 */
	public class ExtraJS
	{
		public function ExtraJS()
		{
		}
		
		public static function exe():void{
			//			__JS__(
			//				"console.log = (function(oriLogFunc){
			//							return function()
			//							{
			//								if(arguments[0] == 1)  
			//									oriLogFunc.apply(console,arguments);
			//							}
			//				})(console.log);
			////					console.log('userName');"
			//				);
			
			__JS__(
				"var __proto=Button.prototype;
				__proto.onMouse=function(e){
					if (this.toggle===false && this._selected)return;
					if (e.type==='click'){
						this.toggle && (this.selected=!this._selected);
						if(this['clickSound']) SoundMgr.instance.playSound(this['clickSound']);
						else{
							var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
							SoundMgr.instance.playSound(mp3Url);
						}
						this._clickHandler && this._clickHandler.run();
						return;
					}
					!this._selected && (this.state=Button.stateMap[e.type]);
				}" 
			);
			
			
			__JS__(
				"var __proto=List.prototype;
					__proto.onCellMouse=function(e){
						if (e.type==='mousedown')this._isMoved=false;
						var cell=e.currentTarget;
						var index=this._startIndex+this._cells.indexOf(cell);
						if (index < 0)return;
						if (e.type==='click' || e.type==='rightclick'){
							if (this.selectEnable && !this._isMoved)this.selectedIndex=index;
							else this.changeCellState(cell,true,0);
							
							if(this['clickSound'] || this['clickSound'] == ''){
								if(this['clickSound'] != '')
									SoundMgr.instance.playSound(this['clickSound']);
							}
							else{
								var mp3Url = ResourceManager.getSoundUrl('ui_common_click','uiSound');
								SoundMgr.instance.playSound(mp3Url);
							}
						}else if ((e.type==='mouseover' || e.type==='mouseout')&& this._selectedIndex!==index){
							this.changeCellState(cell,e.type==='mouseover',0);
						}
						this.mouseHandler && this.mouseHandler.runWith([e,index]);
					}
				"
			);
		}
	}
}