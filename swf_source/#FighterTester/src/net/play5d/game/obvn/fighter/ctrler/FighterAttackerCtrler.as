/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterAttacker;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.event.FighterEvent;
	import net.play5d.game.obvn.fighter.event.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.vo.HitVO;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 攻击道具控制器类
	 */
	public class FighterAttackerCtrler {
		
		
		public var effect:FighterEffectCtrler;
		public var ownerMc:FighterMcCtrler;
		private var _attacker:FighterAttacker;
		
		private var _touchFloor:Boolean;
		private var _touchFloorFrame:String;
		private var hitTargetAction:String;
		public var hitTargetChecker:String;
		
		public function FighterAttackerCtrler(attacker:FighterAttacker) {
			_attacker = attacker;
		}
		
		public function get owner_mc_ctrler():FighterMcCtrler {
			var fighter:FighterMain = _attacker.getOwner() as FighterMain;
			if (fighter) {
				return fighter.getCtrler().getMcCtrl();
			}
			
			return null;
		}
		
		public function get owner_fighter_ctrler():FighterCtrler {
			var fighter:FighterMain = _attacker.getOwner() as FighterMain;
			if (fighter) {
				return fighter.getCtrler();
			}
			
			return null;
		}
		
		public function destory():void {
			_attacker = null;
			effect = null;
			ownerMc = null;
		}
		
		public function getOwner():IGameSprite {
			return _attacker.getOwner();
		}
		
		public function endAct():void {
			_attacker.isAttacking = false;
		}
		
		public function render():void {
			renderCheckTargetHit();
			
			if (_attacker.isInAir) {
				_touchFloor = false;
				return;
			}
			
			if (!_touchFloor) {
				_touchFloor = true;
				if (_touchFloorFrame) {
					_attacker.gotoAndPlay(_touchFloorFrame);
					_touchFloorFrame = null;
				}
			}
		}
		
		private function renderCheckTargetHit():void {
			if (!hitTargetChecker) {
				return;
			}
			
			var rect:Rectangle = _attacker.getHitCheckRect(hitTargetChecker);
			if (!rect) {
				return;
			}
			
			var targets:Vector.<IGameSprite> = _attacker.getTargets();
			if (!targets) {
				return;
			}
			
			for each (var target:IGameSprite in targets) {
				var body:Rectangle = target.getBodyArea();
				
				if (body && rect.intersects(body)) {
					gotoAndPlay(hitTargetAction);
				}
			}
		}
		
		public function stopFollowTarget():void {
			_attacker.stopFollowTarget();
		}
		
		public function moveToTarget(offsetX:Number = NaN, offsetY:Number = NaN):void {
			_attacker.moveToTarget(offsetX, offsetY);
		}
		
		public function move(x:Number = 0, y:Number = 0):void {
			_attacker.setVelocity(x * _attacker.direct, y);
		}
		
		public function damping(x:Number = 0, y:Number = 0):void {
			_attacker.setDamping(x, y);
		}
		
		public function stopMove():void {
			_attacker.setVelocity(0, 0);
		}
		
		public function stop():void {
			_attacker.stop();
		}
		
		public function gotoAndPlay(frame:String):void {
			_attacker.gotoAndPlay(frame);
		}
		
		public function gotoAndStop(frame:String):void {
			_attacker.gotoAndStop(frame);
		}
		
		public function setTouchFloor(frame:String):void {
			_touchFloorFrame = frame;
		}
		
		public function justHit(hitId:String):Boolean {
			var owner:IGameSprite = _attacker.getOwner();
			
			if (owner is FighterMain) {
				return (_attacker.getOwner() as FighterMain).getCtrler().justHit(hitId);
			}
			if (owner is Assister) {
				return (_attacker.getOwner() as Assister).getCtrler().justHit(hitId);
			}
			
			return false;
		}
		
		public function setHitTarget(checker:String, action:String):void {
			hitTargetAction = action;
			hitTargetChecker = checker;
		}
		
		public function setCrossMap(v:Boolean):void {
			_attacker.isAllowCrossX = _attacker.isAllowCrossBottom = v;
		}
		
		public function removeSelf():void {
			_attacker.removeSelf();
		}
		
		public function fire(mcName:String, params:Object = null):void {
			if (!owner_fighter_ctrler || !owner_fighter_ctrler.hitModel) {
				trace("FighterAttacker.fire :: hitModel 出错！");
				return;
			}
			
			var mc:MovieClip = _attacker.mc.getChildByName(mcName) as MovieClip;
			if (mc) {
				if (!params) {
					params = {};
				}
				
				params.mc = mc;
				
				var hv:HitVO = owner_fighter_ctrler.hitModel.getHitVOByDisplayName(mcName);
				if (!hv) {
					trace("FighterAttacker.fire :: HitVO 出错！");
					return;
				}
				
				hv = hv.clone();
				hv.owner = _attacker;
				params.hitVO = hv;
				
				FighterEventDispatcher.dispatchEvent(_attacker, FighterEvent.FIRE_BULLET, params);
			}
			else {
				_attacker.setAnimateFrameOut(function ():void {
					fire(mcName, params);
				}, 1);
			}
		}
	}
}
