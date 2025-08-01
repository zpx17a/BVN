/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler.ai {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.fighter.FighterAction;
	import net.play5d.game.obvn.fighter.data.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.vo.HitVO;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 基本AI逻辑类
	 */
	public class FighterAILogicBase {
		
		protected var AILevel:int;
		
		protected var _fighter:FighterMain;
		protected var _fighterAction:FighterAction;
		
		protected var _target:IGameSprite;
		protected var _targetFighter:FighterMain;
		
		protected var _isConting:Boolean;
		private var _breakActCache:Object = {};
		private var _hitDownActCache:Object = {};
		private var _contOrder:Array = [];
		
		public function FighterAILogicBase(AILevel:int, fighter:FighterMain) {
			this.AILevel = AILevel;
			this._fighter = fighter;
		}
		
		public function destory():void {
			_fighter = null;
			_fighterAction = null;
			_target = null;
			_targetFighter = null;
			_breakActCache = null;
			_hitDownActCache = null;
		}
		
		protected function addContOrder(id:String, order:int):void {
			var index:int = _contOrder.indexOf(id);
			if (index != -1) {
				_contOrder[index].order = order;
				return;
			}
			
			_contOrder.push({
				id   : id,
				order: order
			});
		}
		
		protected function updateConting():void {
			_isConting = 
				_fighter.actionState == FighterActionState.ATTACK_ING || 
				_fighter.actionState == FighterActionState.SKILL_ING || 
				_fighter.actionState == FighterActionState.BISHA_ING || 
				_fighter.actionState == FighterActionState.BISHA_SUPER_ING
			;
		}
		
		public function render():void {
			_target = _fighter.getCurrentTarget();
			_targetFighter = _target as FighterMain;
			
			updateConting();
			
			if (!_fighterAction) {
				_fighterAction = _fighter.getCtrler().getMcCtrl().getAction();
			}
			
			updateActionAI();
			updateContOrder();
		}
		
		private function updateContOrder():void {
			if (_contOrder.length < 1) {
				return;
			}
			
			_contOrder.sortOn("order", 2);
			for (var i:int = 1; i < _contOrder.length; i++) {
				var id:String = _contOrder[i].id;
				this[id] = false;
			}
			_contOrder = [];
		}
		
		protected function updateActionAI():void {}
		
		protected function getAIByFighterState(stateObj:Object):Boolean {
			var defult:Array = stateObj.defult;
			
			var targetState:int = _targetFighter ? _targetFighter.actionState : -1;
			
			var arr:Array = (stateObj && stateObj[targetState] ? stateObj[targetState] : defult) as Array;
			
			return getAIResult(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
		}
		
		protected function getAIResult(a1:Number, a2:Number, a3:Number, a4:Number, a5:Number, a6:Number):Boolean {
			var rand:Number = Math.random() * 10;
			
			switch (AILevel) {
				case 0:
				case 1:
					return rand < a1;
				case 2:
					return rand < a2;
				case 3:
					return rand < a3;
				case 4:
					return rand < a4;
				case 5:
					return rand < a5;
				default:
					return rand < a6;
			}
		}
		
		protected function getTargetDistance(target:IGameSprite):Point {
			var xDis:Number = Math.abs(target.x - _fighter.x);
			var yDis:Number = Math.abs(target.y - _fighter.y);
			
			return new Point(xDis, yDis);
		}
		
//		protected function targetInDistance(target:IGameSprite, disX:Number, disY:Number):Boolean {
//			var dis:Point = getTargetDistance(target);
//
//			return dis.x <= disX && dis.y <= disY;
//		}
		
		protected function targetInRange(id:String):Boolean {
			var area:Rectangle = _target.getBodyArea();
			if (!area) {
				return false;
			}
			
			var hr:Rectangle = _fighter.getHitRange(id);
			if (!hr) {
				return false;
			}
			
			return !area.intersection(hr).isEmpty();
		}
		
//		protected function mergeRateObject(oldObj:Object, newObj:Object):void {
//			for (var i:String in newObj) {
//				if (oldObj[i] == undefined) {
//					oldObj[i] = newObj[i];
//				}
//				else {
//					for (var j:int = 0; j < newObj[i].length; j++) {
//						if (oldObj[i][j] < newObj[i][j]) {
//							oldObj[i][j] = newObj[i][j];
//						}
//					}
//				}
//			}
//		}
		
		protected function isBreakAct(hitId:String):Boolean {
			if (_breakActCache[hitId] != undefined) {
				return _breakActCache[hitId];
			}
			
			var breakHitVOs:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(hitId);
			for each(var i:HitVO in breakHitVOs) {
				if (i.isBreakDef) {
					_breakActCache[hitId] = true;
					return true;
				}
			}
			
			_breakActCache[hitId] = false;
			return false;
		}
		
		protected function isHitDownAct(hitId:String):Boolean {
			if (_hitDownActCache[hitId] != undefined) {
				return _hitDownActCache[hitId];
			}
			
			var breakHitVOs:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(hitId);
			for each(var i:HitVO in breakHitVOs) {
				if (i.hurtType == 1) {
					_breakActCache[hitId] = true;
					return true;
				}
			}
			
			_breakActCache[hitId] = false;
			return false;
		}
		
		protected function targetCanBeHit():Boolean {
			if (!_target) {
				return false;
			}
			if (_targetFighter) {
				return _targetFighter.isAllowBeHit;
			}
			
			return _target.getBodyArea() != null;
		}
	}
}
