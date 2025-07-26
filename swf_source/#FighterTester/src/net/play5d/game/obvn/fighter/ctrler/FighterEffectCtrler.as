/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.ctrler.EffectCtrler;
	import net.play5d.game.obvn.ctrler.SoundCtrler;
	import net.play5d.game.obvn.fighter.data.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.BaseGameSprite;
	
	/**
	 * 角色特效控制器
	 */
	public class FighterEffectCtrler {
		
		private var _target:BaseGameSprite;
		private var _targetDisplay:DisplayObject;
		
		private var _inGhostStep:Boolean;
		private var _faceObj:Object = {};
		private var _isShakeIng:Boolean;
		private var _isShadowIng:Boolean;
		private var _isGlowIng:Boolean;
		
		public function FighterEffectCtrler(target:BaseGameSprite) {
			_target = target;
			_targetDisplay = target.getDisplay();
		}
		
		public function destory():void {
			_target = null;
			_targetDisplay = null;
			_faceObj = null;
		}
		
		public function setBishaFace(id:String, face:Class):void {
			_faceObj[id] = face;
		}
		
		private function getFace(id:String):DisplayObject {
			if (!id) {
				return null;
			}
			
			var faceClass:Class = _faceObj[id] as Class;
			if (!faceClass) {
				Debugger.errorMsg("未定义必杀特写：" + id);
				return null;
			}
			
			var bd:BitmapData = new faceClass() as BitmapData;
			var bp:Bitmap = new Bitmap(bd);
			bp.smoothing = true;
			
			return bp;
		}
		
		public function shine(color:uint = 0xFFFFFF):void {
			var alpha:Number = color == 0xFFFFFF ? 0.3 : 0.2;
			EffectCtrler.I.shine(color, alpha);
		}
		
		public function shake(powX:Number = 0, powY:Number = 3, time:Number = 0):void {
			var pow:Number = Math.max(powX, powY);
			EffectCtrler.I.shake(0, pow * 2, time * 1000);
		}
		
		public function startShake(powX:Number = 0, powY:Number = 3):void {
			_isShakeIng = true;
			EffectCtrler.I.startShake(powX, powY);
		}
		
		public function endShake():void {
			if (_isShakeIng) {
				EffectCtrler.I.endShake();
				_isShakeIng = false;
			}
		}
		
		public function shadow(r:int = 0, g:int = 0, b:int = 0):void {
			_isShadowIng = true;
			EffectCtrler.I.startShadow(_targetDisplay, r, g, b);
		}
		
		public function endShadow():void {
			if (_isShadowIng) {
				EffectCtrler.I.endShadow(_targetDisplay);
			}
		}
		
		public function dash():void {
			if (_target.isInAir) {
				EffectCtrler.I.doEffectById("dash_air", _target.x, _target.y, _target.direct);
			}
			else {
				EffectCtrler.I.doEffectById("dash", _target.x, _target.y, _target.direct);
			}
		}
		
		public function bisha(isSuper:Boolean = false, face:String = null):void {
			var faceDisplay:DisplayObject = getFace(face);
			EffectCtrler.I.bisha(_target, isSuper, faceDisplay);
		}
		
		public function endBisha():void {
			EffectCtrler.I.endBisha(_target);
		}
		
		public function startWanKai(face:String = null):void {
			var faceDisplay:DisplayObject = face ? getFace(face) : null;
			EffectCtrler.I.wanKai(_target as FighterMain, faceDisplay);
		}
		
		public function endWanKai():void {
			if ((_target as FighterMain).actionState == FighterActionState.WAN_KAI_ING) {
				EffectCtrler.I.endWanKai(_target as FighterMain);
			}
		}
		
		public function walk():void {
			if (_inGhostStep) {
				EffectCtrler.I.doEffectById("ghost_step", _target.x, _target.y, _target.direct);
				return;
			}
			
			SoundCtrler.I.playAssetSoundRandom("se_step1", "se_step2", "se_step3");
		}
		
		public function jump():void {
			EffectCtrler.I.jumpEffect(_targetDisplay.x, _targetDisplay.y);
		}
		
		public function jumpAir():void {
			EffectCtrler.I.jumpAirEffect(_targetDisplay.x, _targetDisplay.y);
		}
		
		public function touchFloor():void {
			EffectCtrler.I.touchFloorEffect(_targetDisplay.x, _targetDisplay.y);
		}
		
		public function hitFloor(type:int):void {
			EffectCtrler.I.hitFloorEffect(type, _targetDisplay.x, _targetDisplay.y);
		}
		
		public function slowDown(time:Number):void {
			EffectCtrler.I.slowDown(1.5, time * 1000);
		}
		
		public function energyExplode():void {
			EffectCtrler.I.energyExplode(_target);
		}
		
		public function replaceSkill():void {
			EffectCtrler.I.replaceSkill(_target);
		}
		
		public function ghostStep():void {
			_inGhostStep = true;
			shadow(0, 0, 255);
			
			EffectCtrler.I.ghostStep(_target);
		}
		
		public function endGhostStep():void {
			_inGhostStep = false;
			endShadow();
			
			EffectCtrler.I.endGhostStep(_target);
		}
		
		public function startGlow(color:uint = 0xFFFFFF):void {
			_isGlowIng = true;
			
			var offset:Point = new Point(20, 20);
			var filter:GlowFilter = new GlowFilter(color, 1, offset.x, offset.y, 2, 1, false, true);
			
			EffectCtrler.I.startFilter(_target, filter, offset);
		}
		
		public function endGlow():void {
			if (_isGlowIng) {
				EffectCtrler.I.endFilter(_target);
			}
			
			_isGlowIng = false;
		}
		
		/**
		 * 播放轻砍声音
		 */
		public function playSoundHit1():void {
			SoundCtrler.I.playAssetSound("se_hit1");
		}
		
		/**
		 * 播放重砍声音
		 */
		public function playSoundHit2():void {
			SoundCtrler.I.playAssetSound("se_hit2");
		}
	}
}
