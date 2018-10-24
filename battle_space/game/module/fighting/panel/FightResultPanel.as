/***
 *作者：罗维
 */
package game.module.fighting.panel
{
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.ModuleName;
	import game.global.event.NewerGuildeEvent;
	import game.global.event.Signal;
	import game.global.util.PreloadUtil;
	import game.global.vo.User;
	import game.module.fighting.adata.FightingResultsData;
	import game.module.fighting.mgr.FightingManager;
	
	import laya.events.Event;
	import laya.maths.Arith;
	import laya.utils.Handler;
	
	
	public class FightResultPanel extends BaseDialog
	{
		
		public var _frview:BaseFightResultsView;
		private var _callBackFun:Handler;
		private var _data:FightingResultsData;
		
		public function FightResultPanel()
		{
			super();
		}
		
	
		override public function createUI():void
		{
			super.createUI();
			
		}
		
		
		override public function show(...args):void{
			
			if (!args) return ;
			
			var dataAr:Array = args[0];
			_data = dataAr[0];
			
			var vClass:Class = getViewClass();
			_callBackFun = dataAr.length > 1 ? dataAr[1] : null;
			
			
			if(!_frview)
			{
				_frview = new vClass();
				this.addChild(_frview);
				_frview.init();
				_frview.closeBtn.on(Event.CLICK, this, closeClickFun);
			}
			
			
			UIRegisteredMgr.AddUI(_frview.closeBtn, "FightResultCloseBtn");
			_frview.data = _data;
			_frview.bindData();
			this.size(_frview.width,_frview.height);
			
			LayerManager.instence.setPosition(this,this.m_iPositionType);
			super.show();
			if (!User.getInstance().isInGuilding)
			{
				AnimationUtil.flowIn(this);
			}
			
			if (!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.CHAPTER_ONE_OVER);
			}
			
			
			if(_data.type != 5)
			{
				SoundMgr.instance.playMusicByURL(ResourceManager.instance.getSoundURL( 
					_data.isWin ? "victory":"defeat"
				));
			}
			
			
			if (User.getInstance().curGuideArr.length > 0 &&
				GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[User.getInstance().curGuideArr[0]].g_id].special &&
				GameConfigManager.common_guide_vec[GameConfigManager.fun_open_vec[User.getInstance().curGuideArr[0]].g_id].special == "waitFight")
			{
				trace("guidID: ", User.getInstance().curGuideArr[0].g_id);
				XFacade.instance.openModule(ModuleName.FunctionGuideView,GameConfigManager.fun_open_vec[User.getInstance().curGuideArr[0]].g_id);
			}
			
			
			//XFacade.instance.openModule(ModuleName.FunctionGuideView,1);
			PreloadUtil.preloadSecondBattle();	
		}
		
		override public function close():void{
			
			
			AnimationUtil.flowOut(this, this.onClose);
		}
		
		private function onClose():void{
			super.close();
			if(_frview)
			{
				_frview.removeSelf();
				_frview.closeBtn.off(Event.CLICK,this,closeClickFun)
				_frview.destroy();
				_frview = null;
			}
			XFacade.instance.disposeView(this);
		}
		
		
		private function closeClickFun(e:Event = null):void{
			UIRegisteredMgr.DelUi("FightResultCloseBtn");
			
			
			if(_frview.data.turnCard)
			{
				XFacade.instance.openModule(ModuleName.FightLuckyPanel,[_frview.data.turnCard,_callBackFun]);
				SoundMgr.instance.restoreMusic();
			}
			else if(_frview.data.gradesRewards && _frview.data.gradesRewards.length)
			{
				XFacade.instance.openModule(ModuleName.showPvpResultsPanel,[_frview.data.gradesRewards,_frview.data.integral,_callBackFun]);
				SoundMgr.instance.restoreMusic();
			}
			else if(_callBackFun != null)
			{
				_callBackFun.runWith(0);
			}
			
			if(!User.getInstance().hasFinishGuide)
			{
				Signal.intance.event(NewerGuildeEvent.BATTLE_GUILD_FINISH);
			}
			_data = null;
			if(_frview) _frview.data = null;
			super.close();
		}
		
		public function getViewClass():Class
		{
			switch(_data.rType)
			{
				case 1:  //主线
				{
					return StageFightResultsView;
				}
				case 3: //竞技场
				{
					return AreansResultsView;
				}
				case 4: //公会BOSS
				{
					return GuildBossRewardsView;
				}
				case 5://基地互动
				{
					return JiDiResultsView;
				}
				case 6://pvp
					return PvpResultsView;
				default:
					if(FightingManager.intance.fightingType == FightingManager.FIGHTINGTYPE_FORTRESS){
						return SurvivalResultView;
					}
					break;
			}
			return OrdinaryResultsView;
		}
		
		public override function destroy(destroyChild:Boolean=true):void{
			trace(1,"destroy FightResultPanel");
			if(_frview)
			{
				_frview.closeBtn.off(Event.CLICK,this,closeClickFun);
				_frview = null;
			}
			_callBackFun = null;
			_data = null;
			
			super.destroy(destroyChild);
		}
	}
}