/***
 *作者：罗维
 */
package game.global.vo
{
	import mx.utils.object_proxy;
	
	import game.global.GameConfigManager;
	import game.global.data.formatData.AttackFormatData;
	import game.global.data.formatData.AttackFormatTagetData;
	import game.global.data.formatData.SubReportFormatData;
	import game.global.fighting.BaseUnit;
	import game.global.fighting.manager.FightingSceneManager;
	import game.global.vo.skillControlActionVos.ChangeAttSkillActionVo;
	import game.global.vo.skillControlActionVos.alphaSkillActionVo;
	import game.global.vo.skillControlActionVos.baseSkillActionVo;
	import game.global.vo.skillControlActionVos.effectSkillActionVo;
	import game.global.vo.skillControlActionVos.modelSkllActionVo;
	import game.global.vo.skillControlActionVos.musicSkillActionVo;
	import game.global.vo.skillControlActionVos.spotlightSkillActionVo;
	import game.global.vo.skillControlActionVos.vibrationSkillActionVo;
	import game.module.fighting.adata.ActionData;
	import game.module.fighting.adata.UnitActionData;
	import game.module.fighting.scene.FightingScene;
	
	import laya.utils.Handler;
	
	import org.hamcrest.collection.array;

	public class SkillControlVo
	{
		//=======================键数据====================================
		public var key:String = "";    //技能KEY
		public var skillId:Number = 0;  //技能ID
		public var unitId:Number = 0;   //兵种ID
		public var actionAr:Array = [];  //动作集合
		
		public function SkillControlVo(_obj:Object,_key:String)
		{
			this.key = _key;
			var kar:Array = key.split("_");
			skillId = Number(kar[0]);
			if(kar.length > 1)
			{
				unitId = Number(kar[1]);
			}
			
			if(_obj.actionDataArr)
			{
				for (var i:int = 0; i < _obj.actionDataArr.length; i++) 
				{
					var adObj:Object = _obj.actionDataArr[i];
					switch(adObj.actionType)
					{
						case 0:
						{
							this.actionAr.push(VoHasTool.hasVo(baseSkillActionVo,adObj));
							break;
						}
						case 1:
						{
							this.actionAr.push(VoHasTool.hasVo(modelSkllActionVo,adObj));
							break;
						}
						case 2:
						{
							this.actionAr.push(VoHasTool.hasVo(effectSkillActionVo,adObj));
							break;
						}
						case 3:
						{
							this.actionAr.push(VoHasTool.hasVo(musicSkillActionVo,adObj));
							break;
						}
						case 4:
						{
							this.actionAr.push(VoHasTool.hasVo(vibrationSkillActionVo,adObj));
							break;
						}
						case 5:
						{
							this.actionAr.push(VoHasTool.hasVo(spotlightSkillActionVo,adObj));
							break;
						}	
						case 6:
						{
							this.actionAr.push(VoHasTool.hasVo(ChangeAttSkillActionVo,adObj));
							break;
						}
						case 7:
						{
							this.actionAr.push(VoHasTool.hasVo(alphaSkillActionVo,adObj));
							break;
						}
					}	
				}
			}
		}
		
		
		private var _skillVo:SkillVo;
		public function get skillVo():SkillVo
		{
			if(!_skillVo)
			{
				_skillVo = GameConfigManager.unit_skill_dic[skillId];
			}
			return _skillVo;
		}
		
		
		
		public function getActionList(fData:AttackFormatData,scene:FightingScene,stateTimer:Number = 0):Array{
			var list:Array = [];
			
			var aAr:Array = actionAr.concat();
			while(aAr.length){
				var vo:* = aAr.shift();
				if(vo is modelSkllActionVo)
				{
					list = list.concat(getActionData(fData,scene,vo));	
				}
				if(vo is effectSkillActionVo)
				{
					list = list.concat(getEffectData(fData,vo));	
				}
				if(vo is musicSkillActionVo)
				{
					list = list.concat(getMusicData(fData,vo));	
				}
				if(vo is vibrationSkillActionVo)
				{
					list = list.concat(getVibrationData(fData,vo));	
				}
				if(vo is spotlightSkillActionVo)
				{
					list = list.concat(getSpotlightData(fData,vo));	
				}
				if(vo is ChangeAttSkillActionVo)
				{
					list = list.concat(getChangeAttData(fData,scene,vo));	
				}
				if(vo is alphaSkillActionVo)
				{
					list = list.concat(getAlphaAttData(fData,scene,vo));	
				}
			}
			
			var maxTimer:Number = 0;
			for (var i:int = 0; i < list.length; i++) 
			{
				var ad:ActionData = list[i];
				ad.waitTimer += stateTimer;
				maxTimer = Math.max(ad.waitTimer + ad.endTimer ,maxTimer);
			}
			return list;
		}
		
		public static function getActionHsData(atd:AttackFormatTagetData ,scene:FightingScene , vo:modelSkllActionVo ,starTime:Number = 0):Array
		{
			var ar:Array = [];
			var isDeath:Boolean = atd.newHp ? !Boolean(Number(atd.newHp[0])) : false;
			var holdAcd:ActionData;
			var acD:ActionData;
			var dz:String = isDeath ?  BaseUnit.ACTION_DIE : vo.attackAName ;
			var nextPos:String = atd.newPos? atd.newPos : atd.tagetPos;
			var bitem:BaseUnit = scene.getUnitByPoint(atd.tagetPos,true);
			if(!bitem)
			{
				trace("getActionHsData bitem is  null", atd.tagetPos);
				 return ar;
			}
			
			if(dz == BaseUnit.ACTION_DIE)  //死亡动作
			{
				if(atd.skill2 && atd.skill2.length)
				{
					for (var i:int = 0; i < atd.skill2.length; i++) 
					{
						var afd:AttackFormatData = AttackFormatData.createBD(atd.skill2[i]);
						if(afd.impactArray && afd.impactArray.length)
						{
							for (var k:int = 0; k < afd.impactArray.length; k++) 
							{
								var arrrrr:Array = afd.impactArray[k];
								for (var i2:int = 0; i2 < arrrrr.length; i2++) 
								{
									var aft002:AttackFormatTagetData = arrrrr[i2];
									if(aft002.tagetPos == atd.tagetPos && aft002.newUnit)
									{
										atd.newUnit = aft002.newUnit;
										aft002.newUnit = null;
										dz = "siwang001";
									}
								}	
							}
							
						}
					}
				}
			}
			
			holdAcd = acD = ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_PLAY,[nextPos,dz]);
			
			if(dz != BaseUnit.ACTION_DIE)
			{
				acD.nextActionData = ActionData.create(0,1,ActionData.ACTION_PLAY,[{key:bitem.data.wyid},BaseUnit.ACTION_HOLDING]);
			}
			else
			{
				acD.nextActionData = ActionData.create(0,1,ActionData.ACTION_DELUNIT,[nextPos,bitem]);
			}
			
			ar.push(acD);
			
			if(nextPos != atd.tagetPos)
			{
				ar.push(ActionData.create(vo.startTime,1,ActionData.ACTION_POS_CHANGE,[nextPos,nextPos]));
//				var bitem:BaseUnit = scene.getUnitByPoint(atd.tagetPos);
				scene.tileMapData[bitem.showPointID] = 0;
				bitem.showPointID = nextPos;
				scene.tileMapData[bitem.showPointID] = 1;
			}
			
			var acD2:ActionData;
			var changAr:Array = getChangeData(atd,scene,vo.startTime);
			var san:Boolean = false;
			for (var j:int = 0; j < changAr.length; j++) 
			{
				acD2 = changAr[j];
				if(acD2.actionType == ActionData.ACTION_UNITCHANGE)
				{	
					acD2.waitTimer = 0;
					acD2.data[3] = BaseUnit.ACTION_SHOW;
					acD.nextActionData = acD2;
				}else
				{
					ar.push(acD2);
				}
				if(acD2.actionType == ActionData.ACTION_DODGED || acD2.actionType == ActionData.ACTION_INVINCIBLE)
				{
					san = true;
				}
			}
			if(san)	{
				ar.shift(ar.indexOf(acD),1);
//				acD.data[1] = BaseUnit.ACTION_HOLDING;
			}
			
//			if(acD.nextActionData && acD.nextActionData.actionType == ActionData.ACTION_DELUNIT)  //死透了
//			{
//				bitem.dieTag = true;
//			}
			
			return ar;
		}
		
		public static function getActionData(fData:AttackFormatData,scene:FightingScene, vo:modelSkllActionVo):Array
		{
			var ar:Array = [];
			var pos:String;
			var acD:ActionData;
			//1:出手者    2:所有受击者   3:主要受击者      4:次要受击者  5:溅射受击者
			if(vo.attackAPoint == 1)  //主攻对象
			{
				acD = ActionData.create(vo.startTime,vo.actionTime, ActionData.ACTION_PLAY ,[fData.fightUnitData.originPos,vo.attackAName]);
				ar.push(acD);
				acD.nextActionData = ActionData.create(0,1,ActionData.ACTION_PLAY,[fData.fightUnitData.originPos,BaseUnit.ACTION_HOLDING]);
				return ar;
			}
			
			if(	   vo.attackAPoint == 2 
				|| vo.attackAPoint == 3
				|| vo.attackAPoint == 4
				|| vo.attackAPoint == 5
			)
			{
				var ids:Array = [];
				var tagetPos = fData.tagetPos ? [fData.tagetPos] : [];
				var secondaryPos = fData.secondaryPos ? fData.secondaryPos : [];
				var sputteringPos = fData.sputteringPos ? fData.sputteringPos : [];
				if(vo.attackAPoint == 2)
				{
					ids = ids.concat(tagetPos);
					ids = ids.concat(secondaryPos);
					ids = ids.concat(sputteringPos);
				}else if(vo.attackAPoint == 3)
				{
					ids = ids.concat(tagetPos);
				}else if(vo.attackAPoint == 4)
				{
					ids = ids.concat(secondaryPos);
				}else if(vo.attackAPoint == 5)
				{
					ids = ids.concat(sputteringPos);
				}
				
				
				var ar1:Array = fData.impactArray;
				ar1 ||= [];
				var ar2:Array = ar1.length > vo.atcIndex ? ar1[vo.atcIndex] : [];
				for (var i:int = 0; i < ar2.length; i++) 
				{
					var atd:AttackFormatTagetData = ar2[i];
					var holdAcd:ActionData;
					if( ids.indexOf(atd.tagetPos) != -1)
					{
						ar = ar.concat( getActionHsData(atd,scene,vo));
					}
				}
				return ar;
			}
			
			return ar; 
		}
		
		public static function getChangeAttData(fData:AttackFormatData,scene:FightingScene ,vo:ChangeAttSkillActionVo):Array
		{
			var ar:Array = [];
			var pos:String;
			var acD:ActionData;
			//1:出手者    2:所有受击者   3:主要受击者      4:次要受击者  5:溅射受击者
			if(vo.attackAPoint == 1)  //主攻对象
			{
				if(fData.mainImpact)
				{
					var changAr:Array = getChangeData(fData.mainImpact,scene);
					for (var j:int = 0; j < changAr.length; j++) 
					{
						acD = changAr[j];
						acD.waitTimer += vo.startTime;
						ar.push(acD);
					}
				}
				return ar;
			}
			
			if(	   vo.attackAPoint == 2 
				|| vo.attackAPoint == 3
				|| vo.attackAPoint == 4
				|| vo.attackAPoint == 5
			)
			{
				var ids:Array = [];
				var tagetPos = fData.tagetPos ? [fData.tagetPos] : [];
				var secondaryPos = fData.secondaryPos ? fData.secondaryPos : [];
				var sputteringPos = fData.sputteringPos ? fData.sputteringPos : [];
				if(vo.attackAPoint == 2)
				{
					ids = ids.concat(tagetPos);
					ids = ids.concat(secondaryPos);
					ids = ids.concat(sputteringPos);
				}else if(vo.attackAPoint == 3)
				{
					ids = ids.concat(tagetPos);
				}else if(vo.attackAPoint == 4)
				{
					ids = ids.concat(secondaryPos);
				}else if(vo.attackAPoint == 5)
				{
					ids = ids.concat(sputteringPos);
				}
				
				
				var ar1:Array = fData.impactArray;
				ar1 ||= [];
				var ar2:Array = ar1.length > vo.atcIndex ? ar1[vo.atcIndex] : [];
				for (var i:int = 0; i < ar2.length; i++) 
				{
					var atd:AttackFormatTagetData = ar2[i];
					var holdAcd:ActionData;
					if( ids.indexOf(atd.tagetPos) != -1)
					{
						var changAr:Array = getChangeData(atd,scene);
						for (var j:int = 0; j < changAr.length; j++) 
						{
							acD = changAr[j];
							acD.waitTimer += vo.startTime;
							ar.push(acD);
						}
					}
				}
			}
			
			return ar;
		}
		
		
		public static function getAlphaAttData(fData:AttackFormatData,scene:FightingScene ,vo:alphaSkillActionVo):Array
		{
			var ar:Array = [];
			var pos:String;
			var acD:ActionData;
			//1:出手者    2:所有受击者   3:主要受击者      4:次要受击者  5:溅射受击者
			if(vo.attackAPoint == 1)  //主攻对象
			{
				if(fData.mainImpact)
				{
					acD = ActionData.create(vo.startTime,vo.actionTime, ActionData.ACTION_UNIT_ALPHA ,[fData.fightUnitData.originPos,vo.alphaValue,vo.alphaTimer]);
					ar.push(acD);
					return ar;
				}
				return ar;
			}
			
			if(	   vo.attackAPoint == 2 
				|| vo.attackAPoint == 3
				|| vo.attackAPoint == 4
				|| vo.attackAPoint == 5
			)
			{
				var ids:Array = [];
				var tagetPos = fData.tagetPos ? [fData.tagetPos] : [];
				var secondaryPos = fData.secondaryPos ? fData.secondaryPos : [];
				var sputteringPos = fData.sputteringPos ? fData.sputteringPos : [];
				if(vo.attackAPoint == 2)
				{
					ids = ids.concat(tagetPos);
					ids = ids.concat(secondaryPos);
					ids = ids.concat(sputteringPos);
				}else if(vo.attackAPoint == 3)
				{
					ids = ids.concat(tagetPos);
				}else if(vo.attackAPoint == 4)
				{
					ids = ids.concat(secondaryPos);
				}else if(vo.attackAPoint == 5)
				{
					ids = ids.concat(sputteringPos);
				}
				
				var ar1:Array = fData.impactArray;
				ar1 ||= [];
				var ar2:Array = ar1.length > vo.atcIndex ? ar1[vo.atcIndex] : [];
				for (var i:int = 0; i < ar2.length; i++) 
				{
					var atd:AttackFormatTagetData = ar2[i];
					var holdAcd:ActionData;
					if( ids.indexOf(atd.tagetPos) != -1)
					{
						acD = ActionData.create(vo.startTime,vo.actionTime, ActionData.ACTION_UNIT_ALPHA ,[atd.tagetPos,vo.alphaValue,vo.alphaTimer]);
						ar.push(acD);
					}
				}
			}
			
			return ar;
		}
		
		
		public static function getChangeData(atd:AttackFormatTagetData ,scene:FightingScene , starTime:Number = 0):Array{
			var ar:Array = [];
			var nextPos:String = atd.newPos? atd.newPos : atd.tagetPos;
			var bitem:BaseUnit = scene.getUnitByPoint(nextPos,true);
			if(!bitem)
			{
				trace("getChangeData unit null ",nextPos)
				return ar;
			}
			
			var acD:ActionData;
			if(atd.addHp){
				acD = ActionData.create(starTime,1,ActionData.ACTION_HPCHANGE_ADD,[{key:bitem.data.wyid},atd.addHp,atd.isCritHit]);
				ar.push(acD);
			}
			if(atd.delHp){
				acD = ActionData.create(starTime,1,ActionData.ACTION_HPCHANGE_DEL,[{key:bitem.data.wyid},atd.delHp,atd.isCritHit]);
				ar.push(acD);
			}
			if(atd.newHp){
				acD = ActionData.create(starTime,1,ActionData.ACTION_NEWHP,[{key:bitem.data.wyid},atd.newHp]);
				ar.push(acD);
			}
			if(atd.newBuff){
				acD = ActionData.create(starTime,1,ActionData.ACTION_ADDBUFF,[{key:bitem.data.wyid},atd.newBuff]);
				ar.push(acD);
			}
			if(atd.allBuff){
				acD = ActionData.create(starTime,1,ActionData.ACTION_CHANGEBUFF,[{key:bitem.data.wyid},atd.allBuff]);
				ar.push(acD);
			}
			if(atd.newUnit){
				acD = ActionData.create(starTime,1,ActionData.ACTION_UNITCHANGE,[{key:bitem.data.wyid},bitem ,atd.newUnit,null]);
				ar.push(acD);
			}
			if(atd.addUnit){
				acD = ActionData.create(starTime,1,ActionData.ACTION_UNIT_ADD,[{key:bitem.data.wyid},atd.addUnit]);
				ar.push(acD);
			}
			if(atd.isDodged)
			{
				ar.push( ActionData.create(starTime,1,ActionData.ACTION_DODGED,[{key:bitem.data.wyid}]) );
			}
			if(atd.isInvincible)
			{
				ar.push( ActionData.create(starTime,1,ActionData.ACTION_INVINCIBLE,[{key:bitem.data.wyid}]) );
			}
			if(atd.isAbsorbed)
			{
				ar.push( ActionData.create(starTime,1,ActionData.ACTION_ABSORBED,[{key:bitem.data.wyid}]) );
			}
			if(atd.skill2){
				
				var max:Number = 0;
				var acd2:ActionData;
				for (var j:int = 0; j < ar.length; j++) 
				{
					acd2 = ar[j];
					max = Math.max( acd2.waitTimer + acd2.endTimer , max);
				}
				
				for (var i:int = 0; i < atd.skill2.length; i++) 
				{
					var afd:AttackFormatData = AttackFormatData.createBD(atd.skill2[i]);
					var skillCont:SkillControlVo;
					skillCont = GameConfigManager.getSkillControl(afd.skillId,afd.fightUnitId);
					
					if(!skillCont)
					{
						skillCont = GameConfigManager.getSkillControl(1);
					}
					var ar2:Array = skillCont.getActionList(afd,scene);
					for (var k:int = 0; k < ar2.length; k++) 
					{
						acd2 = ar2[k];
						acd2.waitTimer += max;
						ar.push(acd2);
					}
					
				}
				
			}
			return ar;
		}
		
		public static function getEffectData(fData:AttackFormatData,vo:effectSkillActionVo):Array
		{
			var ar:Array = [];
			var pos:String;
			if(vo.effTarget == 1)
			{
				ar.push(ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_SHOWSKILLEFFECT ,
										[fData.fightUnitData.originPos,vo])
				);
				return ar;
			}
			
			if(	   vo.effTarget == 2 
				|| vo.effTarget == 3
				|| vo.effTarget == 4
				|| vo.effTarget == 5
			)
			{
				var ids:Array = [];
				var tagetPos = fData.tagetPos ? [fData.tagetPos] : [];
				var secondaryPos = fData.secondaryPos ? fData.secondaryPos : [];
				var sputteringPos = fData.sputteringPos ? fData.sputteringPos : [];
				if(vo.effTarget == 2)
				{
					ids = ids.concat(tagetPos);
					ids = ids.concat(secondaryPos);
					ids = ids.concat(sputteringPos);
				}else if(vo.effTarget == 3)
				{
					ids = ids.concat(tagetPos);
				}else if(vo.effTarget == 4)
				{
					ids = ids.concat(secondaryPos);
				}else if(vo.effTarget == 5)
				{
					ids = ids.concat(sputteringPos);
				}
				
				for (var i:int = 0; i < ids.length; i++) 
				{
					ar.push(ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_SHOWSKILLEFFECT ,
						[ids[i],vo])
					);
				}
				return ar;
				
			}
			
			if(	   vo.effTarget == 8   //自身第一排
				|| vo.effTarget == 9   //目标第一排
			)
			{
				var psStr:String = vo.effTarget == 8 ? fData.fightUnitData.originPos : fData.tagetPos;
			    var toStr:String = psStr.substring(0,psStr.length - 2);
				toStr = toStr + "1" + psStr[psStr.length - 1];
				ar.push(ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_SHOWSKILLEFFECT ,
					[toStr,vo])
				);
				return ar;
				
			}
			
			return ar; 
		}
		
		public static function getMusicData(fData:AttackFormatData,vo:musicSkillActionVo):Array
		{
			var ar:Array = [];
			var pos:String;
			
			if(vo.musicTarget == 1 || vo.musicTarget == 0)
			{
				ar.push(ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_PLAY_MUSIC ,
					[fData.fightUnitData.originPos,vo])
				);
				return ar;
			}
			
			if(	   vo.musicTarget == 2 
				|| vo.musicTarget == 3
				|| vo.musicTarget == 4
				|| vo.musicTarget == 5
			)
			{
				var ids:Array = [];
				var tagetPos = fData.tagetPos ? [fData.tagetPos] : [];
				var secondaryPos = fData.secondaryPos ? fData.secondaryPos : [];
				var sputteringPos = fData.sputteringPos ? fData.sputteringPos : [];
				if(vo.musicTarget == 2)
				{
					ids = ids.concat(tagetPos);
					ids = ids.concat(secondaryPos);
					ids = ids.concat(sputteringPos);
				}else if(vo.musicTarget == 3)
				{
					ids = ids.concat(tagetPos);
				}else if(vo.musicTarget == 4)
				{
					ids = ids.concat(secondaryPos);
				}else if(vo.musicTarget == 5)
				{
					ids = ids.concat(sputteringPos);
				}
				
				for (var i:int = 0; i < ids.length; i++) 
				{
					ar.push(ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_PLAY_MUSIC ,
						[ids[i],vo])
					);
				}
				return ar;
				
			}
			return ar; 
		}
		
		public static function getVibrationData(fData:AttackFormatData,vo:vibrationSkillActionVo):Array
		{
			return [ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_VIBRATION,["",vo])];
		}
		
		public static function getSpotlightData(fData:AttackFormatData,vo:spotlightSkillActionVo):Array
		{
			var ids:Array = [];
			var possTypes:Array = vo.spotlightPoss.split(",");
			
			var tagetPos = fData.tagetPos ? [fData.tagetPos] : [];
			var secondaryPos = fData.secondaryPos ? fData.secondaryPos : [];
			var sputteringPos = fData.sputteringPos ? fData.sputteringPos : [];
			
			if( possTypes.indexOf("1") != -1)  //主攻对象
			{
				ids.push(fData.fightUnitData.originPos);
			}
			if(possTypes.indexOf("2") != -1)
			{
				ids = ids.concat(tagetPos);
				ids = ids.concat(secondaryPos);
				ids = ids.concat(sputteringPos);
			}
			if(possTypes.indexOf("3") != -1)
			{
				ids = ids.concat(tagetPos);
			}
			if(possTypes.indexOf("4") != -1)
			{
				ids = ids.concat(secondaryPos);
			}
			if(possTypes.indexOf("5") != -1)
			{
				ids = ids.concat(sputteringPos);
			}
			return [ActionData.create(vo.startTime,vo.actionTime,ActionData.ACTION_SPOTLIGHT,["",ids,vo.spotlightTime])];
		}
		
	
	}
}