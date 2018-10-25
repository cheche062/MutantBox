
function AdditionalInit(){
	
	//重写button的点击处理
	var __proto=Laya.Button.prototype;
	__proto.onMouse=function(e){
		if (this.toggle===false && this._selected)return;
		if (e.type==='click'){
			this.toggle && (this.selected=!this._selected);
			this['clickSound'] && getClass("SoundMgr").instance.playSound(this['clickSound']);
			this._clickHandler && this._clickHandler.run();
			return;
		}
		!this._selected && (this.state=Laya.Button.stateMap[e.type]);
	}
}


function getClass(clsName){
	var clssmap = Laya.__classmap;
	for (var name in clssmap){
		var cls = clssmap[name];
		if(cls.name == clsName)return cls;
	}
}

