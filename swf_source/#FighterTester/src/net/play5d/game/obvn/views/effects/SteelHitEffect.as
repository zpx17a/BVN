/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.geom.ColorTransform;
	
	import net.play5d.game.obvn.ctrler.EffectCtrler;
	import net.play5d.game.obvn.vo.EffectVO;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 钢身特效
	 */
	public class SteelHitEffect extends EffectView {
		
		
		private var _fighter:FighterMain;							// 目标 FighterMain
		
		public function SteelHitEffect(data:EffectVO) {
			super(data);
		}
		
		/**
		 * 设置目标
		 */
		override public function setTarget(v:IGameSprite):void {
			super.setTarget(v);
			
			if (v is FighterMain) {
				_fighter = v as FighterMain;
				if (_fighter.isSteelBody) {
					var ct:ColorTransform = new ColorTransform();
					ct.redOffset = 150;
					ct.greenOffset = 150;
					ct.blueOffset = 150;
					
					if (_fighter.isSuperSteelBody) {
						ct.blueOffset = 0;
						EffectCtrler.I.shine(0xFFFF00, 0.3);
					}
					
					_fighter.changeColor(ct);
					EffectCtrler.I.setOnFreezeOver(function ():void {
						_fighter.resumeColor();
					});
				}
			}
		}
	}
}
