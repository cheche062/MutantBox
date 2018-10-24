package game.module.worldBoss
{
	import game.common.ResourceManager;
	import game.common.ToolFunc;
	import game.global.util.UnitPicUtil;
	import game.global.vo.User;
	
	import laya.ui.List;

	/**
	 *  npc军团的控制器 
	 * @author hejianbo
	 * 2018-04-25 15:39:04
	 */
	public class NpcArmyCtrl
	{
		/**npc  玩家等级所对应的各位置的npc起始数量*/
		public var npc_List:Object;
		private var view:List;
		/**npcid 对应的怪兽名字*/
		public var npcIdNameMap:Object = {
			"10001" : /*"L_A_105002"*/"Man-Eater",
			"10002" : /*"L_A_105003"*/"Planeta Core Lord",
			"10003" :  /*"L_A_105004"*/"Apocalypse"
		}
		
		public function NpcArmyCtrl(list:List)
		{
			view = list;
			
			init();
		}
		
		/**初始化*/
		private function init():void {
			npc_List = getNpcListInitNum();
			
//			trace('【玩家等级:】', npc_List);
			
		}
		
		/**npc起始数量*/
		private function getNpcListInitNum():Object {
			var level = User.getInstance().level;
			var changciData = ResourceManager.instance.getResByURL("config/p_boss/p_boss_changci.json");
			var npcShoujunData = ResourceManager.instance.getResByURL("config/p_boss/p_boss_npc_defender.json");
			
			var targetData = ToolFunc.getItemDataOfWholeData(level, changciData, "down", "up");
			var npc_List:Array = targetData["npc_num1"].split(",");
			var result:Object = {};
			
			npc_List.forEach(function(item:String) {
				var _itemArr:Array = item.split("|");
				var _data = ToolFunc.getTargetItemData(npcShoujunData, 'id', _itemArr[0]);
				var _key = _data["coordinate"];
				var id = _data['id'];
				// id 5 则为大boss  其它两个 安id 奇偶分配一下
				var npcId = (id == 5) ? "10002" : ((id % 2 == 0) ? "10001" : "10003");
				result[_key] = {
					"id": id,
					"collect": 0,
					"init_collect": Number(_itemArr[1]),
					"npcId": npcId   //主要是为了渲染对应的皮肤
				};
			});
			
			return result;
		}
		
		/**渲染视图*/
		public function renderView(npcData:Array):void {
			var array:Array = [];
			npcData.forEach(function(item:WorldBossInfoVo) {
				var result:Array = bossDataTranslate(item);
				// 根据id来排列
				array[result[0]] = result[1];
			});
			
			var isBossLast = checkBigBossView();
			if (isBossLast) {
				view.array = [array[array.length - 1]];
				view.x = 208;
			} else {
				view.x = 165;
				view.array = array.slice(0, -1);
			}
		}
		
		/**boss单个数据转变*/
		private function bossDataTranslate(item:WorldBossInfoVo):Array {
			var map_pos = item.index;
			var npc_ListItem = npc_List[map_pos];
			var init_collect = npc_ListItem["init_collect"];
			var head = item.icon || item.skin;
			var _url = head ? UnitPicUtil.getUintPic(head, UnitPicUtil.ICON) : "worldBoss/head.png";
			// 是否是大boss
			var isBigBoss = (npc_ListItem["id"] == 5);
			
			var data = {
				"dom_head": {
					"skin": _url,
					"gray": (item.collect == 0)
				},
				"dom_progress": {
					"width": isBigBoss ? 670 : 128,
					"value": Number(item.collect) / init_collect
				},
				"dom_blood": {
					"width": isBigBoss ? 670 : 128,
					"text": item.collect + "/" + init_collect
				},
				"dom_name": item.name,
				"dom_die": {
					"visible":  (item.collect == 0)
				}
			};
			
			//记录该npc还剩多少人
			npc_ListItem["collect"] = item.collect;
			// 数据的索引， 数据源
			return [Number(npc_ListItem["id"]) - 1, data];
		}
		
		/**获取大boss 的数据*/
		private function getBigBossInfo(npcArmyPosList):WorldBossInfoVo {
			// 寻找到id为5的大boss的位置index  再获取该info
			var pos_index = "";
			for (var key in npc_List) {
				if (npc_List[key]["id"] == "5") {
					pos_index = key;
					break;
				}
			};
			var info:WorldBossInfoVo = ToolFunc.find(npcArmyPosList, function(item:WorldBossInfoVo) {
				return item.index == pos_index;
			});
			
			return info;
		}
		
		/**改变单个顶部boss血量视图*/
		public function changeBossItemView(npcInfo:WorldBossInfoVo, npcArmyPosList):void {
			var result:Array = bossDataTranslate(npcInfo);
			var isBossLast:Boolean = checkBigBossView();
			if (isBossLast) {
				// 当最后一个npc被打完则需要切换最终的大boss
				if (view.length == 4) {
					var info = getBigBossInfo(npcArmyPosList);
					result = bossDataTranslate(info);
				}
				
				view.array = [result[1]];
				
			} else {
				view.changeItem(result[0], result[1]);
			}
		}
		
		/**检查是否还剩一个大boss*/
		public function checkBigBossView():Boolean {
			var result:Boolean = ToolFunc.everyObjectCheck(npc_List, function(item) {
				if (item["id"] == 5) return true;
				return item["collect"] == 0;
			});
			
			return result;
		}
		
		/**重置*/
		public function reset():void {
			npc_List = null;
			view.array = [];
		}
		
		
		
		
		
		
		
		
		
		
		
		
	}
}