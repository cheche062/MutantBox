package game.module.fighting.view
{
	import MornUI.fightingChapter.fightingChapetrMenuUI;
	
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.GameSetting;
	import game.global.ModuleName;
	import game.global.StringUtil;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.fighting.BaseUnit;
	import game.global.util.UnitPicUtil;
	import game.global.vo.StageChapterVo;
	import game.global.vo.StageLevelVo;
	import game.global.vo.User;
	import game.module.fighting.cell.GuanQiaCell;
	import game.module.fighting.mgr.FightingStageManger;
	import game.module.fighting.sData.stageChapetrData;
	import game.module.fighting.sData.stageLevelData;
	
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	
	/**主线关卡*/
	public class FightingChapetrView extends BaseChapetrView 
	{
		
		public static var newOpenStageLevelID:Number = 0;
				
		protected var isJy:Boolean = false;
		protected var maxJifen:Number = 0;
		private var _newOpenEff:Animation;
		private var _dataIndex:Number = -1;
		protected var _data:StageChapterVo;
		private var _pArgs:Array;
		protected var btnList:Array = [];
		protected var _stageNum:Number;
		protected var _AllNum:Number;
		protected var _leftBtn:Button;
		protected var _rightBtn:Button;
		
		protected var _rewardBtn:Button;
		protected var _rNumBox:Image;
		protected var _rNumLbl:Label;
		protected var _errLbl:Label;
		protected var _faceImg:Image;
		
		protected var _errBg:Sprite;
		
		private var autoOpenId:*;
		
		//背景图,性能测试用
		private var _bgSkin:String;
		
		public function FightingChapetrView()
		{
			super();
			initUI();
		}
		
		/**设定数据源*/
		public function set pArgs(value:Array):void
		{
			trace(1,"设置pArgs",value);
			if(_pArgs != value)
			{
				_pArgs = value;
				if(value) bindArgs();
			}
		}
		
		protected function bindArgs():void
		{
//			trace("pArgs.length:"+pArgs[0]);
			if(pArgs && pArgs.length)
			{
				this.dataIndex = pArgs.shift();
				if(pArgs.length)
				{
					autoOpenId = pArgs.shift();
				}
			}else
			{
				this.dataIndex = passNum ? passNum - 1 : 0;
				var value:Number = passNum ? passNum - 1 : 0;
				//trace("passNum:"+passNum);
			}
			setChapetrInfo();
		}
		
		private function setChapetrInfo():void{
			var scData:stageChapetrData = FightingStageManger.intance.getChapetrData(_data.chapter_id,isJy);
			_errLbl.visible = false;
			_errBg.visible = false;
			_rNumBox.visible = false;
			var v1:Number = openNum;
			var v2:Number = passNum;
			
			if(_dataIndex > v1 - 1)
			{
				for (var i:int = 0; i < btnList.length; i++) 
				{
					var btn:GuanQiaCell = btnList[i];
					btn.showstate = -1;
				}
				_errLbl.text = errStr;
				_errLbl.visible = true;
				_errBg.visible = true;
				return ;
			}else if(_dataIndex > v2 - 1)
			{
				for (var i:int = 0; i < btnList.length; i++) 
				{
					var btn:GuanQiaCell = btnList[i];
					btn.showstate = -1;
				}
				return ;
			}
			
			for (var i:int = 0; i < btnList.length; i++) 
			{
				var btn:GuanQiaCell = btnList[i];
				if(i >= scData.levelList.length) 
				{
					break;
				}
				var slData:stageLevelData = scData.levelList[i];
				var leftSlData:stageLevelData = null;
				if(i)
					leftSlData = scData.levelList[i - 1];
				if(slData.star)
				{
					btn.showstate = 1;
				}else if( leftSlData && !leftSlData.star){
					btn.showstate = -1;
				}else
				{
					btn.showstate = 0;
				}
				btn.starValue = slData.star;
				
				if(newOpenId && newOpenId == btn.data.id)
				{
					showNewOpen(btn);
					newOpenId = 0;
				}
				
				//trace("自动打开关卡ID：", autoOpenId,"按钮数据:", btn.data.id);
				if(autoOpenId && autoOpenId == btn.data.id)
				{
					var ev:Event = new Event();
					ev.currentTarget = btn;
					btnClick(ev);
					autoOpenId = 0;
				}
			}
			//trace("_data.chapter_id:",_data.chapter_id);
			bindReward();
		}

		public function get AllNum():Number
		{
			return _AllNum;
		}

		public function set AllNum(value:Number):void
		{
			if(_AllNum != value)
			{
				_AllNum = value;
				bindBtnData();
			}
		}
		
		protected function get stageChapterArr():Array{
			return GameConfigManager.stage_chapter_arr;
		}
		

		public function set dataIndex(idx:Number):void
		{
			if(_dataIndex != idx)
			{
				trace(1,"设置设置"+idx);
				_dataIndex = idx;
				if(_dataIndex == -1) return ;
				_data =  stageChapterArr[_dataIndex];
				bindData();
				
				if(_bgSkin != "appRes/fightingMapImg/"+_data.chapter_back+".jpg"){
					Loader.clearRes(_bgSkin);
					_bgSkin = "appRes/fightingMapImg/"+_data.chapter_back+".jpg";
				}
				_faceImg.skin = UnitPicUtil.getUintPic(_data.c_r,UnitPicUtil.ICON);
				bindBtnData();
			}
			bgImg.skin = _bgSkin;
			if(_newOpenEff)frameEnd();
		}
		
		private function bindBtnData():void
		{
			_leftBtn.visible = (this._dataIndex > 0);
			_rightBtn.visible =  this._dataIndex < AllNum - 1;
		}
		
		public function get dataIndex():Number
		{
			return _dataIndex;
		}
		
		public function getStageBtn(id:Number):GuanQiaCell{
			var i:int = 0;
			for (i = 0; i < btnList.length; i++) 
			{
				var btn:GuanQiaCell = btnList[i];
				if(btn.data.id == id)
					return btn;
			}
			return ;
		}
		
	
		private function bindData():void{
			var i:int = 0;
			var btn:GuanQiaCell ;
			for (i = 0; i < btnList.length; i++) 
			{
				btn = btnList[i];
				btn.removeSelf();
			}
			var ar:Array = _data.levelList;
			for (i = 0; i < ar.length; i++) 
			{
				var v:StageLevelVo = ar[i];
				if(i < btnList.length)
				{
					btn = btnList[i];
				}else
				{
					btn = new btnClass();
					btn.on(Event.CLICK,this,btnClick);
					btnList.push(btn);
				}
				btn.data = v;
				
				//针对页游
				if(GameSetting.IsRelease){
					btn.scale(0.8, 0.8);
					btn.x = v.cPoint.x + GuanQiaCell.W*0.1;
					btn.y = v.cPoint.y + GuanQiaCell.H*0.1;
				}else{
					btn.x = v.cPoint.x;
					btn.y = v.cPoint.y;
				}
				
				bgBox.addChild(btn);
//				contentBox.addChild(btn);
			}
		}
		
		protected function get btnClass():Class{
			return GuanQiaCell;
		}
		
		public function gotoChtOne():void
		{
			dataIndex = 0;
			setChapetrInfo();
		}
		
		
		protected function bindReward():void
		{
			if(!_data) return ;
			var scData:stageChapetrData = FightingStageManger.intance.getChapetrData(_data.chapter_id,isJy);
			var num:Number = 0;
			for (var i:int = 0; i < scData.rewardGetState.length; i++) 
			{
				if(scData.rewardGetState[i] == 1)
					num ++;
			}
			
			_rNumBox.visible = num;
			if(num)
			{
				_rNumLbl.text = num;
			}
		}
		
		
		protected function get errStr():String{
			var s:String = GameLanguage.getLangByKey("L_A_1196");
			return StringUtil.substitute(s,_data.chapter_condition);
		}
		
		
		protected function get newOpenId():Number{
			return FightingChapetrView.newOpenStageLevelID;
		}
		
		protected function set newOpenId(v:Number):void{
			FightingChapetrView.newOpenStageLevelID = v;
		}
		
		protected function showNewOpen(btn:GuanQiaCell):void
		{
			btn.showstate = -1;
			var jsonStr:String = "appRes/effects/openCL_eff.json";
			Laya.loader.load([{url:jsonStr,type:Loader.ATLAS}],Handler.create(this,loaderOver,[jsonStr,btn]));
		}
		
		private function loaderOver(jsonStr:String,btn:GuanQiaCell):void
		{
			btn.parent.addChild(newOpenEff);
			newOpenEff.loadAtlas(jsonStr);
			newOpenEff.on(Event.COMPLETE,this,frameEnd,[btn]);
			newOpenEff.pos(btn.data.cPoint.x - 37,btn.data.cPoint.y - 38 );
			newOpenEff.play();
			
			var mp3Url = ResourceManager.getSoundUrl('ui_level_unlock','uiSound');
			SoundMgr.instance.playSound(mp3Url);
		}
		
		private function frameEnd(btn:GuanQiaCell = null):void
		{
			if(btn)btn.showstate = 1;
			newOpenEff.removeSelf();
			newOpenEff.off(Event.COMPLETE,this,frameEnd);
		}
		
		
		public function get newOpenEff():Animation
		{
			if(!_newOpenEff){
				_newOpenEff = new Animation();
				_newOpenEff.interval = BaseUnit.animationInterval;
			}
			return _newOpenEff;
		}
		
		protected function btnClick(e:Event):void{
			
			var mp3Url:String = ResourceManager.getSoundUrl("ui_bosswar_chapter_V2","uiSound");
			SoundMgr.instance.playSound(mp3Url);
			var scData:stageChapetrData = FightingStageManger.intance.getChapetrData(_data.chapter_id,isJy);
			var openName:String = isJy ? ModuleName.JYChapterLevelPanel : ModuleName.PTChapterLevelPanel;
			trace("打开关卡面板_data========================:",_data);
			trace("打开关卡面板scData========================:",scData);
			
			XFacade.instance.openModule(openName,
				[
					scData,
					scData.levelList,
					btnList.indexOf(e.currentTarget)
				]
			);
		}
		
		
		public override function addEvent():void
		{
			super.addEvent();
			_leftBtn.on(Event.CLICK,this,this.fanyeClick);
			_rightBtn.on(Event.CLICK,this,this.fanyeClick);
			_rewardBtn.on(Event.CLICK,this,this.rewardBtnClick);
			
			Signal.intance.on(FightingStageManger.FIGHTINGMAP_CHAPETR_INIT,this,chapetrDataInitBack);
			
			Signal.intance.on(FightingStageManger.FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE,this,rewardChange);
		
//			Signal.intance.on(GuildEvent.GOTO_CHAPTER_ONE,this,gotoChtOne);
			
			bindArgs();
			
			timer.clear(this,adEventFun);
			timer.once(100,this,adEventFun);
		}
		
		private function adEventFun():void
		{
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.ENTER_FIGHT_MAP);
			}
		}
		
		private function chapetrDataInitBack(_isJy:Boolean , _cid:Number):void
		{
			if(!_data) return ;
			if(_isJy != isJy) return ;
			if(_cid != _data.chapter_id) return ;
			setChapetrInfo();
		}
		
		
		private function rewardBtnClick(e:Event):void
		{
			if(!_data) return ;
			XFacade.instance.openModule(ModuleName.FightJifenjiangliPanel,[isJy,_data.chapter_id]);
		}
		
		
		
		private function rewardChange(_isJy:Boolean , _cid:Number):void
		{
			if(!_data) return ;
			if(isJy != _isJy)return ;
			if(_data.chapter_id != _cid) return ;
			bindReward();
		}
		
		
		private function fanyeClick(e:Event):void
		{
			FightingStageManger.intance.autoSelectCID = -1;
			switch(e.target)
			{
				case _leftBtn:
				{
					dataIndex --;
					setChapetrInfo();
					break;
				}
				case _rightBtn:
				{
					dataIndex ++;
					setChapetrInfo();
					break;
				}	
				default:
				{
					break;
				}
			}
		}
		
		protected override function stageSizeChange(e:Event = null):void
		{
			super.stageSizeChange(e);
			
			_leftBtn.x = _leftBtn.width + 20;
			_leftBtn.y = height - _leftBtn.height >> 1;
			
			_rightBtn.x = width - _rightBtn.width - 20;
			_rightBtn.y = _leftBtn.y;
			
			_rewardBtn.y = height - _rewardBtn.height - 20;
			_errBg.size(width,height);
			_errLbl.pos(width - _errLbl.width >> 1 , height - _errLbl.height >> 1);
			
			_errBg.graphics.clear();
			_errBg.graphics.drawRect(0,0,width,height,"#000000");
		}
		
		public function get openNum():Number
		{
			return FightingStageManger.intance.openNum(isJy);
		}
		
		protected function get passNum():Number
		{
			//trace("过关数:"+FightingStageManger.intance.passNum(isJy));
			//trace("章节大本营满足开启数："+openNum);
//			trace("isJy:"+);
			return Math.min(FightingStageManger.intance.passNum(isJy), openNum);
		}
		
		public function get pArgs():Array
		{
			return _pArgs;
		}
		
		private function initUI():void{
			var mV:fightingChapetrMenuUI = new fightingChapetrMenuUI();
			mV.mouseThrough = true;
			contentBox.addChild(mV);
			
			_leftBtn = new Button();
			contentBox.addChild(_leftBtn);
			_leftBtn.skin = "fightingMap/btn_arrow.png";
			_leftBtn.scaleX = -1;
			_leftBtn.name = "ChapterBackBtn";
			
			_rightBtn = new Button();
			contentBox.addChild(_rightBtn);
			_rightBtn.skin = "fightingMap/btn_arrow.png";
			
			_rewardBtn = mV.rewardBtn;
			UIRegisteredMgr.AddUI(_rewardBtn,"FightingChapetrView__rewardBtn");
			UIRegisteredMgr.AddUI(_leftBtn, "ChapterBackBtn");
			
			_rNumBox = mV.rNumBox;
			_rNumLbl = mV.rNumLbl;
			_errLbl = mV.errLbl;
			_faceImg = mV.faceImg;
			
			_errBg = new Sprite();
			_errBg.mouseEnabled = true;
			_errBg.alpha = .7;
			mV.addChildAt(_errBg,0);
			
			AllNum = stageChapterArr.length;
		}
	
		public override function removeEvent():void
		{
			super.removeEvent();
			_leftBtn.off(Event.CLICK,this,this.fanyeClick);
			_rightBtn.off(Event.CLICK,this,this.fanyeClick);
			_rewardBtn.off(Event.CLICK,this,this.rewardBtnClick);
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_CHAPETR_INIT,this,chapetrDataInitBack);
			
			Signal.intance.off(FightingStageManger.FIGHTINGMAP_CHAPETR_REWARDSTATE_CHANGE,this,rewardChange);
			
			
			//			Signal.intance.off(GuildEvent.GOTO_CHAPTER_ONE,this,gotoChtOne);
		}
		
		
		//回收，，测试性能+
		override public function destroy(destroyChild:Boolean=true):void{
			UIRegisteredMgr.DelUi("FightingChapetrView__rewardBtn");
			UIRegisteredMgr.DelUi("ChapterBackBtn");
			Loader.clearRes(_bgSkin);
			
			super.destroy(destroyChild);
			
			_newOpenEff = null;
			_data = null;
			pArgs = null;
			btnList = null;
			_leftBtn = null;
			_rightBtn = null;
			_rewardBtn = null;
			_rNumBox = null;
			_rNumLbl = null;
			_errLbl = null;
			_faceImg = null;
			_errBg = null;
			
		}
	}
}