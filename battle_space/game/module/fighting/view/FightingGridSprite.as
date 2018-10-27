/***
 *作者：罗维
 */
package game.module.fighting.view
{
	import game.global.fighting.manager.FightingSceneManager;
	import game.module.mainScene.GridSprite;

	public class FightingGridSprite extends GridSprite
	{
		public function FightingGridSprite()
		{
			super();
			this.mouseEnabled = true;
		}
		
		public function get mainMapMatrix():Array
		{
			return FightingSceneManager.intance.mainMapMatrix;
		}
	}
}