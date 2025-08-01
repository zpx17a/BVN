/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrler.GameLogic;
	import net.play5d.game.obvn.fighter.ctrler.FighterAttackerCtrler;
	import net.play5d.game.obvn.fighter.model.FighterHitModel;
	import net.play5d.game.obvn.fighter.vo.HitVO;
	import net.play5d.game.obvn.fighter.utils.McAreaCacher;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 攻击对象类
	 */
	public class FighterAttacker extends BaseGameSprite {
		
		public var onRemove:Function;
		public var isAttacking:Boolean;
		
		private var _ctrler:FighterAttackerCtrler;
		private var _owner:IGameSprite;
		
		public var moveToTargetX:Boolean;
		public var moveToTargetY:Boolean;
		public var followTargetX:Boolean;
		public var followTargetY:Boolean;
		public var rangeX:Point;
		public var rangeY:Point;
		
		private var _startX:Number = 0;
		private var _startY:Number = 0;
		private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
		private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
		private var _rectCache:Object = {};
		private var _mcOrgPoint:Point;
		
		private var _isRenderMainAnimate:Boolean = true;
		
		public function FighterAttacker(mainmc:MovieClip, params:Object = null) {
			super(mainmc);
			
			_mcOrgPoint = new Point(mainmc.x, mainmc.y);
			_startX = _mcOrgPoint.x;
			_startY = _mcOrgPoint.y;
			
			_x = _startX;
			_y = _startY;
			_ctrler = new FighterAttackerCtrler(this);
			
			if (mainmc.setAttackerCtrler) {
				mainmc.setAttackerCtrler(_ctrler);
			}
			if (!params) {
				return;
			}
			
			if (params.x != undefined) {
				if (params.x is Number) {
					_startX = params.x + _mcOrgPoint.x;
				}
				else {
					moveToTargetX = params.x.moveToTarget == true;
					followTargetX = params.x.followTarget == true;
					if (params.x.offset != undefined) {
						_startX = params.x.offset;
					}
					if (params.x.range != undefined && params.x.range is Array) {
						rangeX = new Point(params.x.range[0], params.x.range[1]);
					}
				}
			}
			if (params.y != undefined) {
				if (params.y is Number) {
					_startY = params.y + _mcOrgPoint.y;
				}
				else {
					moveToTargetY = params.y.moveToTarget == true;
					followTargetY = params.y.followTarget == true;
					if (params.y.offset != undefined) {
						_startY = params.y.offset;
					}
					if (params.y.range != undefined && params.y.range is Array) {
						rangeY = new Point(params.y.range[0], params.y.range[1]);
					}
				}
			}
			if (params.applyG != undefined) {
				isApplyG = params.applyG == true;
			}
		}
		
		public function getOwner():IGameSprite {
			return _owner;
		}
		
		public function get name():String {
			return _mainMc.name;
		}
		
		public function getCtrler():FighterAttackerCtrler {
			return _ctrler;
		}
		
		override public function destory(dispose:Boolean = true):void {
			if (_hitAreaCache) {
				_hitAreaCache.destory();
				_hitAreaCache = null;
			}
			if (_hitCheckAreaCache) {
				_hitCheckAreaCache.destory();
				_hitCheckAreaCache = null;
			}
			if (_ctrler) {
				_ctrler.destory();
				_ctrler = null;
			}
			
			onRemove = null;
			_rectCache = null;
			_owner = null;
			_mcOrgPoint = null;
			
			super.destory(true);
		}
		
		public function setOwner(v:IGameSprite):void {
			_owner = v;
			direct = v.direct;
			
			if (_owner is FighterMain) {
				_ctrler.effect = (_owner as FighterMain).getCtrler().getEffectCtrl();
			}
			if (_owner is Assister) {
				_ctrler.effect = (_owner as Assister).getCtrler().effect;
			}
		}
		
		public function init():void {
			if (!_owner) {
				return;
			}
			
			if (direct > 0) {
				_x = _owner.x + _startX;
			}
			else {
				_x = _owner.x - _startX;
			}
			
			_y += _owner.y;
			
			// 根据人物位置重定位
			if (_owner is FighterMain) {
				var fmc:FighterMC = (_owner as FighterMain).getMC();
				
				_x += fmc.x;
				_y += fmc.y;
			}
			
			if (!moveToTargetX && !moveToTargetY) {
				return;
			}
			
			isAttacking = true;
			var target:IGameSprite = getTarget();
			if (!target) {
				return;
			}
			
			if (moveToTargetX) {
				var tx:Number = target.x + _startX * direct;
				
				if (rangeX) {
					var xDis:Number;
					if (direct > 0) {
						xDis = tx - _owner.x;
						if (xDis < rangeX.x) {
							tx = _owner.x + rangeX.x;
						}
						if (xDis > rangeX.y) {
							tx = _owner.x + rangeX.y;
						}
					}
					else {
						xDis = _owner.x - tx;
						if (xDis < rangeX.x) {
							tx = _owner.x - rangeX.x;
						}
						if (xDis > rangeX.y) {
							tx = _owner.x - rangeX.y;
						}
					}
				}
				
				_x = tx;
			}
			
			if (moveToTargetY) {
				var ty:Number = target.y + _startY;
				
				if (rangeY) {
					var yDis:Number = ty - _owner.y;
					if (yDis < rangeY.x) {
						ty = target.y + rangeY.x;
					}
					if (yDis > rangeY.y) {
						ty = target.y + rangeY.y;
					}
				}
				
				_y = ty;
			}
		}
		
		override public function renderAnimate():void {
			if (!_isRenderMainAnimate) {
				return;
			}
			
			super.renderAnimate();
			mc.nextFrame();
			if (mc == null) {
				return;
			}
			
			findHitArea();
			if (mc.currentFrame == mc.totalFrames - 1) {
				removeSelf();
			}
		}
		
		override public function render():void {
			super.render();
			_ctrler.render();
			renderFollowTarget();
		}
		
		public function stopFollowTarget():void {
			followTargetX = false;
			followTargetY = false;
		}
		
		private function renderFollowTarget():void {
			if (!followTargetX && !followTargetY) {
				return;
			}
			
			var target:IGameSprite = getTarget();
			if (!target) {
				return;
			}
			
			if (followTargetX) {
				_x = target.x + _startX * direct;
			}
			if (followTargetY) {
				_y = target.y + _startY;
			}
		}
		
		public function moveToTarget(offsetX:Number = NaN, offsetY:Number = NaN):void {
			var target:IGameSprite = getTarget();
			if (!target) {
				return;
			}
			
			if (!isNaN(offsetX)) {
				_x = target.x + offsetX * direct;
			}
			if (!isNaN(offsetY)) {
				_y = target.y + offsetY;
			}
		}
		
		public function stop():void {
			_isRenderMainAnimate = false;
		}
		
		public function gotoAndPlay(frame:String):void {
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = true;
		}
		
		public function gotoAndStop(frame:String):void {
			_mainMc.gotoAndStop(frame);
			_isRenderMainAnimate = false;
		}
		
		public function getTargets():Vector.<IGameSprite> {
			var targets:Vector.<IGameSprite> = null;
			
			if (_owner is FighterMain || _owner is Assister) {
				targets = _owner is FighterMain ? 
					(_owner as FighterMain).getTargets() : 
					(_owner as Assister).getTargets();
			}
			
			return targets;
		}
		
		private function getTarget():IGameSprite {
			var target:IGameSprite = null;
			
			if (_owner is FighterMain || _owner is Assister) {
				target = _owner is FighterMain ? 
					(_owner as FighterMain).getCurrentTarget() : 
					(_owner as Assister).getCurrentTarget();
			}
			
			if (target && target is FighterMain) {
				return target;
			}
			
			return null;
		}
		
		public function removeSelf():void {
			if (onRemove != null) {
				onRemove(this);
			}
		}
		
		override public function getCurrentHits():Array {
			if (!_hitAreaCache) {
				return null;
			}
			var areas:Array = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame) as Array;
			if (!areas || areas.length < 1) {
				return null;
			}
			
			var hits:Array = [];
			for (var i:int = 0; i < areas.length; i++) {
				var dobj:Object = areas[i];
				var dname:String = dobj.name;
				var hitvo:HitVO = dobj.hitVO;
				
				if (hitvo) {
					var area:Rectangle = dobj.area;
					
					hitvo.currentArea = getCurrentRect(area, "hit" + i);
					hits.push(hitvo);
				}
			}
			
			return hits;
		}
		
		public function getHitCheckRect(name:String):Rectangle {
			var area:Rectangle = getCheckHitRect(name);
			if (area == null) {
				return null;
			}
			
			return getCurrentRect(area, "hit_check");
		}
		
		public function getCheckHitRect(name:String):Rectangle {
			var d:DisplayObject = _mainMc.getChildByName(name);
			if (!d) {
				return null;
			}
			
			var cacheObj:Object = _hitCheckAreaCache.getAreaByDisplay(d);
			if (cacheObj) {
				return cacheObj.area;
			}
			
			var rect:Rectangle = d.getBounds(_mainMc);
			_hitCheckAreaCache.cacheAreaByDisplay(d, rect);
			
			return rect;
		}
		
		private function getCurrentRect(rect:Rectangle, cacheId:String = null):Rectangle {
			var newRect:Rectangle = null;
			
			if (cacheId == null) {
				newRect = new Rectangle();
			}
			else if (_rectCache[cacheId]) {
				newRect = _rectCache[cacheId];
			}
			else {
				newRect = new Rectangle();
				_rectCache[cacheId] = newRect;
			}
			
			newRect.x = rect.x * direct + _x;
			if (direct < 0) {
				newRect.x -= rect.width;
			}
			newRect.y = rect.y + _y;
			newRect.width = rect.width;
			newRect.height = rect.height;
			
			return newRect;
		}
		
		private function getHitModel():FighterHitModel {
			if (_owner is FighterMain) {
				return (_owner as FighterMain).getCtrler().hitModel;
			}
			if (_owner is Assister) {
				return (_owner as Assister).getCtrler().hitModel;
			}
			
			throw new Error('Type of "owner" not supported!');
		}
		
		private function findHitArea():void {
			if(!_hitAreaCache) {
				return;
			}
			
			var hitModel:FighterHitModel = getHitModel();
			if(!hitModel) {
				return;
			}
			if(_hitAreaCache.areaFrameDefined(_mainMc.currentFrame)) {
				return;
			}
			
			var area:Object = _hitAreaCache.getAreaByFrame(_mainMc.currentFrame);
			if(area != null) {
				return;
			}
			
			var areaRects:Array = [];
			for (var i:int = 0; i < _mainMc.numChildren; i++) {
				var d:DisplayObject = _mainMc.getChildAt(i);
				var hitvo:HitVO = hitModel.getHitVOByDisplayName(d.name);
				if(d == null || hitvo == null) {
					continue;
				}
				
				var areaCached:Object = _hitAreaCache.getAreaByDisplay(d);
				if(areaCached == null) {
					var areaRect:Rectangle = d.getBounds(_mainMc);
					hitvo = hitvo.clone();
					hitvo.owner = this;
					
					var areaCacheObj:Object = 
						_hitAreaCache.cacheAreaByDisplay(d, areaRect, {
							hitVO: hitvo
						});
					areaRects.push(areaCacheObj);
				} else {
					areaRects.push(areaCached);
				}
			}
			
			if(areaRects.length < 1) {
				areaRects = null;
			}
			
			_hitAreaCache.cacheAreaByFrame(_mainMc.currentFrame, areaRects);
		}
		
		private function getOwnerFighter():FighterMain {
			if (_owner is FighterMain) {
				return _owner as FighterMain;
			}
			if (_owner is Assister) {
				return (_owner as Assister).getOwner() as FighterMain;
			}
			
			return null;
		}
		
		override public function hit(hitvo:HitVO, target:IGameSprite):void {
			var owner:FighterMain = this.getOwnerFighter();
			if (target && owner) {
				if (!hitvo.isBisha() && target is FighterMain) {
					owner.addQi(hitvo.power * 0.15);
				}
				GameLogic.hitTarget(hitvo, owner, target);
			}
		}
	}
}
