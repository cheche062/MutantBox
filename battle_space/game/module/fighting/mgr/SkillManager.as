/***
 *作者：罗维
 */
package game.module.fighting.mgr
{
	import game.common.ResourceManager;
	import game.common.SoundMgr;
	import game.global.GameConfigManager;
	import game.global.data.fightUnit.fightUnitData;
	import game.global.data.formatData.AttackFormatData;
	import game.global.data.formatData.AttackFormatTagetData;
	import game.global.data.formatData.SubReportFormatData;
	import game.global.fighting.BaseUnit;
	import game.global.fighting.manager.FightingSceneManager;
	import game.global.vo.SkillBuffVo;
	import game.global.vo.SkillControlVo;
	import game.global.vo.skillControlActionVos.effectSkillActionVo;
	import game.global.vo.skillControlActionVos.modelSkllActionVo;
	import game.global.vo.skillControlActionVos.musicSkillActionVo;
	import game.module.fighting.adata.ActionData;
	import game.module.fighting.adata.UnitActionData;
	import game.module.fighting.cell.FightingTile;
	import game.module.fighting.scene.FightingScene;
	
	import laya.maths.Point;
	import laya.net.Loader;
	import laya.ui.Panel;
	import laya.utils.Handler;
	import laya.utils.Timer;
	import laya.utils.Tween;

	public class SkillManager
	{
		
		private static var _instance:SkillManager;
		private var _damagePos:Array =[];
		private var _handler:Handler;
		private var _scene:FightingScene;
		private var _actionList:Array = [];  //对象内容 : 播放对象,延迟帧播放 ,[动作，动作.....]
		//		private var _uadataList:Array = [];  //动画组
		
		public function SkillManager()
		{
			if(_instance){				
				throw new Error("SkillManager是单例,不可new.");
			}
			_instance = this;
		}
		
		public static function get intance():SkillManager
		{
			if(_instance)
				return _instance;
			_instance = new SkillManager;
			return _instance;
		}
		
		
		
		
		public function removeData():void
		{
			_handler = null;
			_scene = null;
			if(_actionList && _actionList.length)
			{
				//trace(1,"清除未播放数据 ",_actionList.length);
				while(_actionList.length)
				{
					var _aData:ActionData = _actionList.shift();
					_aData.clear();
				};
			}
			if(!_actionList)_actionList = [];
			_damagePos = [];
		}
		
		
		public function useSkill(scene:FightingScene , fData:AttackFormatData , handler:Handler , skillCont:SkillControlVo = null ):void{
			_scene = scene;
			_handler = handler;
			
			if(!skillCont)
			{
				skillCont = GameConfigManager.getSkillControl(fData.skillId,fData.fightUnitId);
//				trace("预设断点");
			}

			if(!skillCont)
			{
				skillCont = GameConfigManager.getSkillControl(0);
			}
			
			
			
			_actionList = skillCont.getActionList(fData,scene);
			/*trace(1,"播放技能VO",skillCont);
			trace(1,"技能数据",fData);*/
			
//			var cpActionList:Array = [];
			for (var i:int = 0; i < _actionList.length; i++) 
			{
				var ad:ActionData = _actionList[i];
				ad.stopAction(_scene);
			}
//			
			/*trace(1,"技能动作组",_actionList.length);
			trace(1,"scene",scene);
			trace(1,"残留动作",_actionList);	*/
			toNextAData();
			
			if(!skillCont.skillVo.isSelfSkill)
			{
				var allPos:Array = fData.allPos;
				if(allPos)
				{
					scene.fightingTiles(allPos);
					_damagePos = allPos;
				}
			}
		}
		
		public function useBeidong(scene:FightingScene , dataAr:Array , handler:Handler ):void{
			_scene = scene;
			_handler = handler;
			_actionList = [];
			for (var i:int = 0; i < dataAr.length; i++) 
			{
				var atd:AttackFormatTagetData = dataAr[i];
				if(atd.delHp)
				{
					var vo:modelSkllActionVo = new modelSkllActionVo();
					vo.startTime = 0;
					vo.actionTime = 1;
					vo.attackAName = "shouji";
					_actionList = _actionList.concat(SkillControlVo.getActionHsData(dataAr[i],scene,vo));
				}
				else
					_actionList = _actionList.concat(SkillControlVo.getChangeData(dataAr[i],scene));
			}
			toNextAData();
		}
		
//		public function useBeidongJineng(atd:AttackFormatTagetData):Array{
//			
//			
//		}
		
		private function getMDList(_aData:ActionData,mlist:Array,slist:Array):void{
			if(!_aData)return ;
			var uitem:BaseUnit = _scene.getUnitByPoint(_aData.data[0]);
			if(!uitem)return;
			var jsonStr:String ;
			if(_aData.actionType == ActionData.ACTION_PLAY)  //模型
			{
				jsonStr = uitem.data.unitVo.getModel( uitem.data.direction,_aData.data[1],uitem.data.skin);
				if(mlist.indexOf(jsonStr) == -1)
					mlist.push(jsonStr);
				
				jsonStr = ResourceManager.getUnitMp3(uitem.data.unitId,_aData.data[1]);
				if(jsonStr)
				{
					jsonStr = ResourceManager.getSoundUrl(jsonStr,"fighting/action");
					if(slist.indexOf(jsonStr) == -1)
						slist.push(jsonStr);
				}
				
				
				getMDList(_aData.nextActionData,mlist,slist);
			}
			else if(_aData.actionType == ActionData.ACTION_SHOWSKILLEFFECT){
				var vo:effectSkillActionVo = _aData.data[1];
				var tile:FightingTile = _scene.tileList[_aData.data[0]];
				var dName:String;
				if(vo.effMirror)
					dName = "/up";
				else
				{
					dName = tile.direction == 1 ? "/up" : "/down";
				}
				
				jsonStr = "appRes/skillEffect/"+vo.effName+dName +".json";
				if(mlist.indexOf(jsonStr) == -1)
					mlist.push(jsonStr);
				getMDList(_aData.nextActionData,mlist,slist);
			}
			else if(_aData.actionType == ActionData.ACTION_PLAY_MUSIC)
			{
				var mfvo:musicSkillActionVo = _aData.data[1];
				jsonStr = ResourceManager.getSoundUrl(mfvo.musicName,"fighting/skill");
				if(slist.indexOf(jsonStr) == -1)
					slist.push(jsonStr);
				getMDList(_aData.nextActionData,mlist,slist);
			}
			else
			{
				getMDList(_aData.nextActionData,mlist,slist);
			}
		}
	
		private function toNextAData():void
		{
			var mList:Array = [];
			var sList:Array = [];
			for (var j:int = 0; j < _actionList.length; j++) 
			{
				getMDList(_actionList[j],mList,sList);
			}
			
			
			
			var mList2:Array = [];
			var i:int = 0;
			for (i = 0; i < mList.length; i++) 
			{
				mList2.push({url:mList[i],type:Loader.ATLAS});
			}
			for (i = 0; i < sList.length; i++)
			{
				mList2.push({url:sList[i],type:Loader.SOUND});
			}
			
			
			
			/*trace(1,"预载本回合模型资源",mList);
			trace(1,"预载本回合音效资源",sList);
			trace(1,"预载本回合资源数量",mList2.length);*/
			if(mList2.length)
				Laya.loader.load(mList2,Handler.create(this,toNextADataLoaderBack),null,null,1,true,FightingScene.figtingModerGroup);
			else
				toNextADataLoaderBack();
		}
		
		private function toNextADataLoaderBack():void
		{
			var jg:Number = 10;
			for (var i:int = _actionList.length - 1; i >= 0; i--) 
			{
				var _aData:ActionData  = _actionList[i];
				var adJg:Number = i * jg;
				var waitTimer:Number = _aData.waitTimer + adJg;
				if(waitTimer)
				{
					Laya.timer.once(
						Math.ceil(waitTimer / FightingManager.velocity)
						,this,timerToAction,[_aData],false);
				}else
				{
					timerToAction(_aData);
				}
			}
			Laya.timer.frameLoop(1,this,monitoringFun,null,false);
		}
		
		
		private function timerToAction(_aData:ActionData , _pData:ActionData = null):void{
			
			if(!_scene || !_aData)
				return ;
//			if(!_aData.data)
//			{
//				var a=1;
//			}
			var uitem:BaseUnit = _scene.getUnitByPoint(_aData.data[0]);
			
			//动作
			if(_aData.actionType == ActionData.ACTION_PLAY){
				if(uitem)
				{
					uitem.frameEnd();
					if(_aData.nextActionData && _aData.nextActionData.actionType == ActionData.ACTION_UNITCHANGE)
					{
						uitem.playAction(_aData.data[1],Handler.create(this,timerToAction,[_aData.nextActionData , _aData]));
					}
					else if(_aData.nextActionData && _aData.nextActionData.actionType == ActionData.ACTION_DELUNIT)
					{
						uitem.playAction(_aData.data[1],Handler.create(this,timerToAction,[_aData.nextActionData , _aData]));
					}
					else
					{
						uitem.playAction(_aData.data[1],Handler.create(this,timerToAction,[_aData.nextActionData ]));
						Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
					}
				}else
				{
					delAction(_aData);
					trace("找不到对象",_aData.data[0]);
				}
//				if(_pData)delAction(_pData);
				return ;
			}
			//特效
			if(_aData.actionType == ActionData.ACTION_SHOWSKILLEFFECT){
				var efvo:effectSkillActionVo = _aData.data[1];
				var tile:FightingTile = _scene.tileList[_aData.data[0]];
				if((uitem || efvo.effNullTarget) && tile)
				{
					tile.showSkillEffect(efvo);
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
				return ;
			}
			
			//音效
			if(_aData.actionType == ActionData.ACTION_PLAY_MUSIC){
				var mfvo:musicSkillActionVo = _aData.data[1];
				if(uitem || mfvo.musicNullTarget || mfvo.musicTarget == 0)
				{
					SoundMgr.instance.playSound(ResourceManager.getSoundUrl(mfvo.musicName,"fighting/skill"));
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
				return ;
			}
			
			//振屏幕
			if(_aData.actionType == ActionData.ACTION_VIBRATION)
			{
				_scene.Vibration(_aData.data[1]);
				this.timerToAction(_aData.nextActionData);
				Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
			}
			
			//特写
			if(_aData.actionType == ActionData.ACTION_SPOTLIGHT)
			{
				_scene.Spotlight(_aData.data[1],_aData.data[2]);
				this.timerToAction(_aData.nextActionData);
				Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
			}
			
			
			//移除单位
			if(_aData.actionType == ActionData.ACTION_DELUNIT)
			{
				uitem = _aData.data[1];
				//trace(1,"执行移除动作",uitem);
				if(uitem)
				{
					_scene.removerUnit(uitem);
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					trace(1,"没有UITEM");
					delAction(_aData);
				}
				delAction(_pData);
			}
			
			//变身
			if(_aData.actionType == ActionData.ACTION_UNITCHANGE)
			{
				uitem = _aData.data[1];
				if(uitem)
				{
					var nUid:Number = Number(_aData.data[2]["id"]);
					var nMHP:Number = Number(_aData.data[2]["hp"]);
					var nHP:Number = Number(_aData.data[2]["restHp"]);
					var skillId:String = _aData.data[2]["skillId"];
					uitem.rebirth(nUid,nHP,nMHP,skillId,Handler.create(this,function():void{
						uitem.playAction(BaseUnit.ACTION_HOLDING);
					}),_aData.data[3]);
				}
				
				this.timerToAction(_aData.nextActionData);
				Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				delAction(_pData);
			}
			//新增目标
			if(_aData.actionType == ActionData.ACTION_UNIT_ADD)
			{
				var addUnit:Array = _aData.data[1];
				for (var j:int = 0; j < addUnit.length; j++) 
				{
					var d:Object  = addUnit[j];
					var ud:fightUnitData = new fightUnitData();
					ud.unitId = Number(d.id);
					ud.hp = Number(d.restHp);
					ud.maxHp = Number(d.hp);
					ud.wyid = Math.random();
					if(d.skillId && d.skillId.length)
						ud.skillVos = FightingManager.intance.getSkillVos(d.skillId);
					ud.direction = d.pos.indexOf("point_1") == 0 ? 1: 2;	
					_scene.addUnit(ud,false,d.pos,true);
				}
				this.timerToAction(_aData.nextActionData);
				Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				delAction(_pData);
			}
			
			//头顶飘字
			if(	   _aData.actionType == ActionData.ACTION_HPCHANGE_ADD 
				|| _aData.actionType == ActionData.ACTION_HPCHANGE_DEL
			)
			{
				if(uitem)
				{
					var fonts:Array = _aData.data[1];
					var isCritHit:Number = _aData.data[2];
					if(_aData.actionType == ActionData.ACTION_HPCHANGE_ADD){
						uitem.floatingHp(fonts,isCritHit?4:3,Math.ceil(100 / FightingManager.velocity));
					}	
					else if(_aData.actionType == ActionData.ACTION_HPCHANGE_DEL){
						uitem.floatingHp(fonts,isCritHit?2:1,Math.ceil(100 / FightingManager.velocity));
					}
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
			}
			//血量设置
			if(_aData.actionType == ActionData.ACTION_NEWHP)
			{
				var newHp:Array = _aData.data[1];
				if(uitem)
				{
					uitem.data.hp = newHp[0];
					uitem.data.maxHp = newHp[1];
					uitem.changeHp();
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
			}
			//新增BUFF
			if(_aData.actionType == ActionData.ACTION_ADDBUFF)
			{
				var buffIds:Array = _aData.data[1] as Array;
				var buffVo:SkillBuffVo = GameConfigManager.skill_buff_dic[buffIds[0]];
				if(buffVo && uitem)
				{
					uitem.showBuff(buffVo);
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
			}
			//击飞
			if(_aData.actionType == ActionData.ACTION_POS_CHANGE)
			{
				if(uitem)
				{
					var newPoint:Point = new Point();
					newPoint.x = _scene.beginX + FightingSceneManager.intance.tilePointList[_aData.data[1]].x;
					newPoint.y = _scene.beginY + FightingSceneManager.intance.tilePointList[_aData.data[1]].y;
					Tween.to(uitem,{x:newPoint.x,y:newPoint.y},
						Math.ceil(100 / FightingManager.velocity)
						,null,Handler.create(
						this,delAction,[_aData]
					));
				}else
				{
					delAction(_aData);
				}
			}
			//闪避
			if(_aData.actionType == ActionData.ACTION_DODGED)
			{
				if(uitem)
				{
					uitem.floatingHp(["m"],5);
					uitem.dodged(Handler.create(
						this,delAction,[_aData]
					));
				}else
					delAction(_aData);
			}
			//无敌
			if(_aData.actionType == ActionData.ACTION_INVINCIBLE)
			{
				if(uitem)
				{
					uitem.floatingHp(["i"],5);
				}
				delAction(_aData);
			}
			//吸收
			if(_aData.actionType == ActionData.ACTION_ABSORBED)
			{
				if(uitem)
				{
					uitem.floatingHp(["a"],5);
				}
				delAction(_aData);
			}
			
			//刷新BUFF
			if(_aData.actionType == ActionData.ACTION_CHANGEBUFF)
			{
				if(uitem)
				{
					uitem.buffIds = _aData.data[1];
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
			}
			//改变透明度
			if(_aData.actionType == ActionData.ACTION_UNIT_ALPHA)
			{
				if(uitem)
				{
					Tween.to(uitem,{alpha:_aData.data[1]},_aData.data[2]);
					this.timerToAction(_aData.nextActionData);
					Laya.timer.once(_aData.endTimer,this,delAction,[_aData],false);
				}else
				{
					delAction(_aData);
				}
			}
			
		}
		
		private function delAction(_aData:ActionData):void{
			if(!_scene)
			{
				_aData.clear();
				return ;
			}
			if(!_aData)return ;
			var idx:Number = _actionList.indexOf(_aData);
			if(idx != -1)
				_actionList.splice(idx,1);
			if(_aData)
				_aData.clear();
		}
		
		private function monitoringFun():void
		{
			if(!_scene)
			{
				Laya.timer.clear(this,monitoringFun);
				return ;
			}
			if(_actionList.length)
			{
				return ;
			}
			
			if(_handler != null)
			{
//				trace("子回合执行完毕");
				_scene.fightingTiles(_damagePos,true);
				_damagePos = [];
				var copyHander:Handler =  _handler;
				_handler = null;
				copyHander.run();
				copyHander.clear();
			}
		}
		

		
		
	}
}