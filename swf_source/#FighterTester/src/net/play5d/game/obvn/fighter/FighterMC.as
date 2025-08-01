/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.fighter.ctrler.FighterMcCtrler;
	import net.play5d.game.obvn.fighter.event.FighterEvent;
	import net.play5d.game.obvn.fighter.event.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.model.FighterHitModel;
	import net.play5d.game.obvn.fighter.vo.HitVO;
	import net.play5d.game.obvn.fighter.utils.McAreaCacher;
	import net.play5d.game.obvn.utils.MCUtils;
	import net.play5d.game.obvn.fighter.data.FighterActionState;
	import net.play5d.game.obvn.fighter.data.FighterHitRange;
	
	/**
	 * 主人物MC类
	 */
	public class FighterMC {
		
		private var _mcCtrler:FighterMcCtrler;
		private var _fighter:FighterMain;
		private var _fighterDisplay:DisplayObject;
		
		private var _renderMainAnimate:Boolean = false;
		private var _renderMainAnimateFrame:int = 0;
		
		private var _curFrameName:String;
		private var _curMainFrameCount:int;
		private var _curFrameCount:int;
		
		private var _mc:MovieClip;
		
		private var _undefinedFrames:Array = [];
		private var _hurtFlyFrame:int = 0;
		private var _hurtDownFrame:int;
		private var _hurtFlyState:int;
		private var _hurtYMin:Number = 0;
		private var _isHeavyDownAttack:Boolean;
		
		private var _bodyAreaCache:McAreaCacher = new McAreaCacher("body");
		private var _hitAreaCache:McAreaCacher = new McAreaCacher("hit");
		private var _hitCheckAreaCache:McAreaCacher = new McAreaCacher("hit_check");
		
		private var _hitRangeInited:Boolean;
		private var _hitRangeObj:Object;
		
		private var _goFrameDelay:Object = null;
		
		private var _hitx:Number = 0;
		private var _hity:Number = 0;
		
		public function get currentFrameName():String {
			return _curFrameName;
		}
		
		public function getCurrentFrame():int {
			return _mc.currentFrame;
		}
		
		public function getCurrentFrameCount():int {
			return _curFrameCount;
		}
		
		public function get x():Number {
			return _mc.x;
		}
		
		public function set x(v:Number):void {
			_mc.x = x;
		}
		
		public function get y():Number {
			return _mc.y;
		}
		
		public function set y(v:Number):void {
			_mc.y = v;
		}
		
		public function initlize(
			mc:MovieClip, fighter:FighterMain, mcCtrler:FighterMcCtrler):void 
		{
			_mc = mc;
			_fighter = fighter;
			_fighterDisplay = fighter.getDisplay();
			_mcCtrler = mcCtrler;
			
			mcCtrler.setMc(this);
		}
		
		public function destory():void {
			if (_bodyAreaCache) {
				_bodyAreaCache.destory();
				_bodyAreaCache = null;
			}
			if (_hitAreaCache) {
				_hitAreaCache.destory();
				_hitAreaCache = null;
			}
			if (_hitCheckAreaCache) {
				_hitCheckAreaCache.destory();
				_hitCheckAreaCache = null;
			}
			
			_fighter = null;
			_fighterDisplay = null;
			_undefinedFrames = null;
		}
		
		public function getChildByName(name:String):DisplayObject {
			return _mc.getChildByName(name);
		}
		
		public function renderAnimate():void {
			if (_renderMainAnimate) {
				
				if (_renderMainAnimateFrame > 0) {
					
					if (--_renderMainAnimateFrame <= 0) {
						_renderMainAnimate = false;
					}
					
					_curMainFrameCount++;
				}
				
				_mc.nextFrame();
			}
			
			renderChildren();
			findBodyArea();
			findHitArea();
			
			if (_hurtFlyState != 0) {
				renderHurtFly();
			}
			
			_curFrameCount++;
			
			if (_goFrameDelay) {
				
				if (_goFrameDelay.delay-- <= 0) {
					
					if (_goFrameDelay.call != undefined) {
						_goFrameDelay.call();
					}
					else {
						goFrame(_goFrameDelay.name, _goFrameDelay.isPlay, _goFrameDelay.playFrame, null);
					}
					
					_goFrameDelay = null;
				}
			}
		}
		
		private function renderChildren():void {
			for (var i:int = 0; i < _mc.numChildren; i++) {
				var mc:MovieClip = _mc.getChildAt(i) as MovieClip;
				if (!mc) {
					continue;
				}
				
				var mcName:String = mc.name;
				if (mcName == "AImain" || mcName == "bdmn" || mcName.indexOf("atm") != -1) {
					continue;
				}
				
				var totalFrames:int = mc.totalFrames
				if (totalFrames < 2) {
					continue;
				}
				
				if (mc.currentFrameLabel != "stop") {
					if (mc.currentFrame == totalFrames) {
						mc.gotoAndStop(1);
					}
					else {
						mc.nextFrame();
					}
				}
			}
		}
		
		public function goFrame(
			name:String, isPlay:Boolean = true, playFrame:int = 0, goFrameDelay:Object = null):void 
		{
			_curFrameName = name;
			_curMainFrameCount = 0;
			_curFrameCount = 0;
			_renderMainAnimate = isPlay;
			
			if (_renderMainAnimate) {
				_renderMainAnimateFrame = playFrame;
			}
			else {
				_renderMainAnimateFrame = 0;
			}
			
			if (goFrameDelay && 
				(goFrameDelay.name || goFrameDelay.call) && 
				goFrameDelay.delay > 0) 
			{
				goFrameDelay.isPlay = goFrameDelay.isPlay != undefined ? goFrameDelay.isPlay : true;
				goFrameDelay.playFrame = goFrameDelay.playFrame != undefined ? goFrameDelay.playFrame : 0;
				
				_goFrameDelay = goFrameDelay;
			}
			else {
				_goFrameDelay = null;
			}
			
			_mc.gotoAndStop(name);
			renderChildren();
		}
		
		public function stopRenderMainAnimate():void {
			_renderMainAnimate = false;
		}
		
		public function resumeRenderMainAnimate():void {
			_renderMainAnimate = true;
		}
		
		public function checkFrame(name:String):Boolean {
			if (_undefinedFrames.indexOf(name) != -1) {
				return false;
			}
			if (MCUtils.hasFrameLabel(_mc, name)) {
				return true;
			}
			
			_undefinedFrames.push(name);
			trace("未找到特殊帧：" + name);
			return false;
		}
		
		public function getCurrentHitSprite():Array {
			var rt:Array = [];
			
			for (var i:int = 0; i < _mc.numChildren; i++) {
				var d:DisplayObject = _mc.getChildAt(i);
				
				if (d && d.name.indexOf("atm") != -1) {
					rt.push(d);
				}
			}
			
			return rt;
		}
		
		public function getCurrentBodyArea():Rectangle {
			var obj:Object = _bodyAreaCache.getAreaByFrame(_mc.currentFrame);
			if (obj) {
				return obj.area;
			}
			
			return null;
		}
		
		public function getCurrentHitArea():Array {
			return _hitAreaCache.getAreaByFrame(_mc.currentFrame) as Array;
		}
		
		public function getCheckHitRect(name:String):Rectangle {
			var d:DisplayObject = _mc.getChildByName(name);
			if (!d) {
				return null;
			}
			
			var cacheObj:Object = _hitCheckAreaCache.getAreaByDisplay(d);
			if (cacheObj) {
				return cacheObj.area;
			}
			
			var rect:Rectangle = d.getBounds(_fighterDisplay);
			_hitCheckAreaCache.cacheAreaByDisplay(d, rect);
			
			return rect;
		}
		
		private function findBodyArea():void {
			if (!_bodyAreaCache) {
				return;
			}
			
			if (_bodyAreaCache.areaFrameDefined(_mc.currentFrame)) {
				return;
			}
			
			var area:Object = _bodyAreaCache.getAreaByFrame(_mc.currentFrame);
			if (area != null) {
				return;
			}
			var areamc:DisplayObject = _mc.getChildByName("bdmn");
			if (areamc) {
				area = _bodyAreaCache.getAreaByDisplay(areamc);
				if (area == null) {
					var areaRect:Rectangle = areamc.getBounds(_fighterDisplay);
					area = _bodyAreaCache.cacheAreaByDisplay(areamc, areaRect);
				}
			}
			
			_bodyAreaCache.cacheAreaByFrame(_mc.currentFrame, area);
		}
		
		private function findHitArea():void {
			if (!_hitAreaCache) {
				return;
			}
			if (_hitAreaCache.areaFrameDefined(_mc.currentFrame)) {
				return;
			}
			
			var area:Object = _hitAreaCache.getAreaByFrame(_mc.currentFrame);
			if (area != null) {
				return;
			}
			
			var hitModel:FighterHitModel = _fighter.getCtrler().hitModel;
			var areaRects:Array = [];
			for (var i:int = 0; i < _mc.numChildren; i++) {
				var d:DisplayObject = _mc.getChildAt(i);
				var hitvo:HitVO = hitModel.getHitVOByDisplayName(d.name);
				
				if (d == null || hitvo == null) {
					continue;
				}
				
				var areaCached:Object = _hitAreaCache.getAreaByDisplay(d);
				if (areaCached == null) {
					var areaRect:Rectangle = d.getBounds(_fighterDisplay);
					var areaCacheObj:Object = _hitAreaCache.cacheAreaByDisplay(d, areaRect, {
						hitVO: hitvo
					});
					areaRects.push(areaCacheObj);
				}
				else {
					areaRects.push(areaCached);
				}
			}
			
			if (areaRects.length < 1) {
				areaRects = null;
			}
			
			_hitAreaCache.cacheAreaByFrame(_mc.currentFrame, areaRects);
		}
		
		public function playHurtFly(hitx:Number, hity:Number, showBeHit:Boolean = true):void {
			if (hitx != 0) {
				_fighter.direct = hitx > 0 ? -1 : 1;
			}
			
			if (showBeHit) {
				goFrame("被打", false, 0, {
					name  : "击飞",
					delay : 1,
					isPlay: false
				});
			}
			else {
				goFrame("击飞", false);
			}
			
			if (hity > 5) {
				_hurtFlyFrame = 0;
				_isHeavyDownAttack = true;
			}
			else {
				_isHeavyDownAttack = false;
				_hurtFlyFrame = 15;
			}
			
			_fighter.setVelocity(hitx, hity);
			_fighter.setDamping(0, 0.5);
			
			_hurtFlyState = 1;
			_hurtYMin = _fighter.y;
			_hitx = hitx;
			_hity = hity;
		}
		
		public function playHurtDown():void {
			goFrame("击飞_弹", false, 0, {
				call : playHurtDown2,
				delay: 2
			});
			
			_mcCtrler.effectCtrler.shake(0, 2);
			_mcCtrler.effectCtrler.hitFloor(1);
			
			_fighter.setDamping(2);
		}
		
		private function playHurtDown2():void {
			goFrame("击飞_倒", false);
			
			_hurtDownFrame = 15;
			_hurtFlyState = 4;
			
			_mcCtrler.touchFloor();
			_fighter.actionState = FighterActionState.HURT_DOWN;
			FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_DOWN);
		}
		
		public function stopHurtFly():void {
			_hurtFlyState = 0;
		}
		
		private function renderHurtFly():void {
			var yDiff:Number = NaN;
			var vecy:Number = NaN;
			
			switch (_hurtFlyState) {
				case 1:
					if (--_hurtFlyFrame <= 0 && !_fighter.isInAir) {
						goFrame("击飞_落");
						_hurtFlyState = 2;
					}
					if (_hurtYMin > _fighter.y) {
						_hurtYMin = _fighter.y;
						break;
					}
					break;
				case 2:
					if (_curFrameCount < 2) {
						return;
					}
					
					if (_isHeavyDownAttack) {
						_hurtDownFrame = 30;
						goFrame("击飞_倒", false);
						
						_fighter.actionState = FighterActionState.HURT_DOWN;
						FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_DOWN);
						
						_fighter.setDamping(4);
						_hurtFlyState = 4;
						
						yDiff = _fighter.y - _hurtYMin;
						vecy = yDiff / 25 * (1 + _hity * 0.1);
						
						if (vecy < 2) {
							vecy = 2;
						}
						if (vecy > 5) {
							vecy = 5;
						}
						
						_mcCtrler.effectCtrler.shake(0, vecy);
						_mcCtrler.effectCtrler.hitFloor(2);
						break;
					}
					
					goFrame("击飞_弹", false);
					
					yDiff = _fighter.y - _hurtYMin;
					vecy = yDiff / 25;
					
					if (vecy < 3) {
						vecy = 3;
					}
					if (vecy > 8) {
						vecy = 8;
					}
					
					_fighter.setVecY(-vecy);
					_hurtFlyState = 3;
					_fighter.actionState = FighterActionState.HURT_DOWN_TAN;
					
					if (vecy < 0.5) {
						vecy = 0.5;
					}
					if (vecy > 3) {
						vecy = 3;
					}
					
					_mcCtrler.effectCtrler.shake(0, vecy);
					_mcCtrler.effectCtrler.hitFloor(0);
					break;
				case 3:
					if (_curFrameCount < 2) {
						return;
					}
					if (_fighter.isInAir) {
						return;
					}
					
					goFrame("击飞_倒", false);
					
					_fighter.setDamping(2);
					_hurtDownFrame = 15;
					_hurtFlyState = 4;
					
					_mcCtrler.effectCtrler.shake(0, 1);
					_mcCtrler.effectCtrler.hitFloor(1);
					
					_fighter.actionState = FighterActionState.HURT_DOWN;
					FighterEventDispatcher.dispatchEvent(_fighter, FighterEvent.HURT_DOWN);
					break;
				case 4:
					if (!_fighter.isAlive) {
						_hurtFlyState = 0;
						_fighter.actionState = FighterActionState.DEAD;
						return;
					}
					
					if (--_hurtDownFrame <= 0) {
						goFrame("击飞_起", true);
						_hurtFlyState = 0;
						break;
					}
					break;
			}
		}
		
		public function getHitRange(id:String):Rectangle {
			if (!_hitRangeInited) {
				initHitRange();
				_hitRangeInited = true;
			}
			
			return _hitRangeObj[id];
		}
		
		private function initHitRange():void {
			var hrmc:MovieClip = _mc.getChildByName("AImain") as MovieClip;
			hrmc.gotoAndStop(2);
			
			_hitRangeObj = {};
			for each (var i:String in FighterHitRange.getALL()) {
				var d:DisplayObject = hrmc.getChildByName(i);
				if (d) {
					_hitRangeObj[i] = d.getBounds(_fighterDisplay);
				}
			}
			
			hrmc.gotoAndStop(1);
			hrmc.visible = false;
			
			try {
				_mc.removeChild(hrmc);
				trace("移除 AImain 完成！");
			}
			catch (e:Error) {
			}
			
			hrmc = null;
		}
	}
}
