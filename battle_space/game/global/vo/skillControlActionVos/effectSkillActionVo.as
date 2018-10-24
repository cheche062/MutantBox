package game.global.vo.skillControlActionVos
{
	public class effectSkillActionVo extends baseSkillActionVo
	{
		public var effName:String;
		public var effTarget:Number = 0;
		public var effLayer:Number = 0;
		public var effPoint:Number = 0;
		public var effNullTarget:Number = 0;
		public var effMirror:Number = 0;
		public function effectSkillActionVo()
		{
			super();
		}
	}
}