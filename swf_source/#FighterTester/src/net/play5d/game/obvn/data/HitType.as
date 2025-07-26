/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	
	/**
	 * 攻击类型
	 */
	public class HitType {
		
		public static const NONE:int = 0;					// 无
		
		public static const KAN:int = 1;					// 砍
		public static const KAN_HEAVY:int = 6;				// 重砍
		
		public static const DA:int = 2;						// 打
		public static const DA_HEAVY:int = 3;				// 重打
		
		public static const MAGIC:int = 4;					// 魔法轻击
		public static const MAGIC_HEAVY:int = 5;			// 魔法重击
		
		public static const FIRE:int = 7;					// 火焰
		public static const ICE:int = 8;					// 冰冻
		public static const ELECTRIC:int = 9;				// 雷电
		
		public static const STONE:int = 10;					// 石化
		
		public static const CATCH:int = 11;					// 摔
		
		private static const heavyTypes:Array = [			// 重打击类型
			KAN_HEAVY, DA_HEAVY, MAGIC_HEAVY, 
			FIRE, ICE, ELECTRIC
		];
		
		private static const attributeTypes:Array = [		// 属性伤害
			FIRE, ICE, ELECTRIC, STONE
		];
		
		private static const physicalTypes:Array = [		// 物理伤害
			KAN, KAN_HEAVY, DA, DA_HEAVY
		];
		
		
		/**
		 * 是否是重击类型
		 */
		public static function isHeavy(v:int):Boolean {
			return heavyTypes.indexOf(v) != -1;
		}
		
		/**
		 * 是否是属性伤害
		 */
		public static function isAttribute(v:int):Boolean {
			return attributeTypes.indexOf(v) != -1;
		}
		
		/**
		 * 是否是物理伤害
		 */
		public static function isPhysical(v:int):Boolean {
			return physicalTypes.indexOf(v) != -1;
		}
	}
}
