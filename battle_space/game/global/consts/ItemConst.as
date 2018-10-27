/***
 *作者：罗维
 */
package game.global.consts
{
	public class ItemConst
	{
		
		public static const ITEM_TYPE_EQUIP:uint = 10;   //装备
		public static const ITEM_TYPE_MATERIAL:uint = 11;   //材料 or 碎片
		public static const ITEM_TYPE_GIFTBAG:uint = 13;   //礼包
		public static const ITEM_TYPE_HERO:uint = 14;   //英雄
		public static const ITEM_TYPE_SOLDIER:uint = 15;  //兵种
		public static const ITEM_TYPE_FIGHTING:uint = 16; //战斗时使用的道具
		public static const ITEM_TYPE_GENE:uint = 17;//基因
		public static const ITEM_TYPE_RANDOM:uint = 21;//随机兑换道具
		public static const ITEM_TYPE_CHANGENAME:uint = 22;//名称修改
		//装备道具子类型
		public static const ITEM_EQUIP_SUBTYPE_1:uint = 1;  //武器
		public static const ITEM_EQUIP_SUBTYPE_2:uint = 2;  //衣服
		public static const ITEM_EQUIP_SUBTYPE_3:uint = 3;  //戒指
		
		//材料 子类型(暂无)
		
		
		//礼包子类型
		public static const ITEM_GIFTBAG_SUBTYPE_1:uint = 1;  //1直接打开获得固定奖励  
		public static const ITEM_GIFTBAG_SUBTYPE_2:uint = 2;  //2获得随机奖励  
		public static const ITEM_GIFTBAG_SUBTYPE_3:uint = 3;  //3多个奖励选其N
		public static const ITEM_GIFTBAG_SUBTYPE_4:uint = 4;  //4 随机多个奖励选其N
		
		//英雄道具子类型 （客户端不用）
		//兵种道具子类型 （客户端不用）
		
		//基因子类型
		public static const GENE_STYPE_1:uint = 1;//1：位置1基因；
		public static const GENE_STYPE_2:uint = 2;//2：位置2基因 
		public static const GENE_STYPE_3:uint = 3;//3：位置3基因
		public static const GENE_STYPE_4:uint = 4;//4：经验基因
		public static const GENE_STYPE_5:uint = 5;//5：基因囚犯
		
		
		//战斗时使用的道具
		public static const ITEM_FIGHTING_SUBTYPE_1:uint = 1;  //1碎片
		public static const ITEM_FIGHTING_SUBTYPE_2:uint = 2;  //1完整
	}
}