package game.module.armyGroup
{

	/**
	 * ...
	 * @author ...
	 */
	public class ArmyGroupFindPath
	{

		private var testData:Array=["1|2,3,5,6", "2|1,3", "3|2,5,4", "4|3,5", "5|1,3,4,6", "6|1,5"];
		private var maps:Object={};
		private var visited:Object={};
		private var progressArr:Object={};

		public function ArmyGroupFindPath()
		{
			var len:int=testData.length;
			var i:int=0;
			maps={};
			visited={};
		
		}

		public function setMapData(id:int, link:Array):void
		{
			var nod:nodeVo=new nodeVo();
			nod.nodeID=id;
			nod.nodeLink= link;
			maps[nod.nodeID]=nod;
		}
		
		private function filterFn(item):Boolean {
			return !!item;
		}
		
		public function findPath(startID:int, endID:int):Array
		{
			visited={};

			ergodicLink(startID, endID, 1);

			var pathArr:Array=[];
			var pathNode:int=endID;

			while (true)
			{
				pathArr.push(maps[pathNode]);
				//trace("pathNode: ",pathNode,"maps[pathNode]",maps[pathNode]);
				if (pathNode == 0 || pathNode == startID || maps[pathNode].parentId == 0)
				{
					break;
				}
				pathNode=maps[pathNode].parentID
			}
			///trace("pathTest pathArr:", pathArr);
			return pathArr.reverse();
		}

		public function ergodicLink(startID:int, endID:int, distance:int, pid:int=0):void
		{
			/*trace("startID:", startID, "endID:", endID, "distance:", distance, "pid:", pid);
			trace("maps[startID]:", maps[startID]);
			trace("");*/
			visited[startID]=distance;

			//maps[startID].isPassed = true;
			maps[startID].parentID=pid;

			//trace("pathTest startID:", startID,"endID:",endID);

			if (startID == endID)
			{
				//trace("pathTest maps[endID].parentID",maps[endID].parentID);
				if (maps[endID].parentID > 0 && visited[maps[endID].parentID] > visited[startID])
				{
					//trace("pathTest updatepath");
					maps[endID].parentID=pid;
				}
				return;
			}

			var len:int=maps[startID].nodeLink.length;

			for (var i:int=0; i < len; i++)
			{
				var v_id:int=maps[startID].nodeLink[i];
				/*if (maps[v_id].isPassed)
				{
					visited[v_id] = 9999;
					continue;
				}*/

				if (!visited[v_id] || visited[v_id] > distance + 1)
				{
					ergodicLink(v_id, endID, distance + 1, startID);
				}

			}
		}
	}

}

class nodeVo
{
	public var nodeID:int=0;
	public var nodeLink:Array=[];
	public var parentID:int=0;
	public var isPassed:Boolean=false;
}
