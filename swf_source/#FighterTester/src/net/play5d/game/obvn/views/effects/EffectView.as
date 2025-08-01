/**
 * 已重建完成
 */
package net.play5d.game.obvn.views.effects {
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.ctrler.EffectCtrler;
	import net.play5d.game.obvn.ctrler.SoundCtrler;
	import net.play5d.game.obvn.vo.BitmapDataCacheVO;
	import net.play5d.game.obvn.vo.EffectVO;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.kyo.utils.KyoMath;
	
	/**
	 * 效果可视元件
	 */
	public class EffectView {
		
		public var display:Bitmap;
		
		public var autoRemove:Boolean = true;
		public var loopPlay:Boolean = false;
		
		public var holdFrame:int = -1;
		
		public var isActive:Boolean = true;
		
		protected var _target:IGameSprite;
		private var _onRemoveFuncs:Array;
		private var _isDestoryed:Boolean;
		
		protected var _data:EffectVO;
		private var _bitmapDatas:Vector.<BitmapDataCacheVO>;
		private var _frameLabels:Object;
		
		private var _orgX:Number = 0;
		private var _orgY:Number = 0;
		
		private var _curFrame:int;
		private var _rotation:int;
		private var _direct:int;
		
		public function EffectView(data:EffectVO) {
			_data = data;
			
			display = new Bitmap();
			display.blendMode = data.blendMode;
			display.smoothing = EffectCtrler.EFFECT_SMOOTHING;
			
			_bitmapDatas = data.bitmapDataCache;
			_frameLabels = data.frameLabelCache;
		}
		
		public function setTarget(v:IGameSprite):void {
			_target = v;
		}
		
		public function setPos(x:Number, y:Number):void {
			_orgX = x;
			_orgY = y;
		}
		
		public function start(x:Number = 0, y:Number = 0, direct:int = 1):void {
			_orgX = x;
			_orgY = y;
			_direct = _rotation != 0 ? 1 : direct;
			
			display.scaleX = _direct;
			_curFrame = 0;
			
			if (_data.randRotate) {
				randRotate();
			}
			if (_data.sound) {
				SoundCtrler.I.playEffectSound(_data.sound);
			}
			
			renderDisplay();
			isActive = true;
		}
		
		public function destory():void {
			_isDestoryed = true;
			
			if (isActive) {
				removeSelf();
			}
			
			display = null;
		}
		
		public function gotoAndPlay(frame:Object):void {
			if (frame is int) {
				_curFrame = int(frame);
			}
			if (frame is String) {
				for (var i:String in _frameLabels) {
					if (_frameLabels[i] == frame) {
						_curFrame = int(i);
					}
				}
			}
		}
		
		/**
		 * 随机角度
		 */
		private function randRotate():void {
			_rotation = Math.random() * 360;
			
			display.rotation = _rotation;
			display.scaleX = 1;
		}
		
		public function render():void {}
		
		public function renderAnimate():void {
			if (_isDestoryed) {
				return;
			}
			
			var removed:Boolean = false;
			if (loopPlay) {
				if (_curFrame == _bitmapDatas.length - 1) {
					_curFrame = 0;
				}
			}
			else if (autoRemove) {
				if (_curFrame == _bitmapDatas.length - 1) {
					if (holdFrame == -1) {
						removeSelf();
						removed = true;
					}
					else {
						_curFrame = 0;
					}
				}
				if (holdFrame != -1) {
					if (holdFrame-- <= 0) {
						removeSelf();
						removed = true;
					}
				}
			}
			
			if (!removed) {
				renderFrameLabel();
				renderDisplay();
				_curFrame++;
			}
		}
		
		private function renderDisplay():void {
			var frameVO:BitmapDataCacheVO = _bitmapDatas[_curFrame];
			
			if (frameVO == null) {
				display.bitmapData = null;
			}
			else {
				display.bitmapData = frameVO.bitmapData;
				if (_rotation != 0) {
					var radians:Number = KyoMath.asRadians(_rotation);
					var dis:Point = KyoMath.getPointByRadians(new Point(frameVO.offsetX, frameVO.offsetY), radians);
					
					display.x = _orgX + dis.x;
					display.y = _orgY + dis.y;
				}
				else {
					display.x = _orgX + frameVO.offsetX * _direct;
					display.y = _orgY + frameVO.offsetY;
				}
			}
		}
		
		private function renderFrameLabel():void {
			var frameLabel:String = _frameLabels[_curFrame] as String;
			if (frameLabel == "loop") {
				gotoAndPlay(1);
			}
		}
		
		public function remove():void {
			removeSelf();
		}
		
		public function addRemoveBack(func:Function):void {
			if (!_onRemoveFuncs) {
				_onRemoveFuncs = [];
			}
			if (_onRemoveFuncs.indexOf(func) != -1) {
				return;
			}
			_onRemoveFuncs.push(func);
		}
		
		private function removeSelf():void {
			isActive = false;
			for each(var i:Function in _onRemoveFuncs) {
				i(this);
			}
			
			_onRemoveFuncs = null;
			
			var _parent:DisplayObjectContainer = display.parent;
			if (display && _parent) {
				_parent.removeChild(display);
			}
		}
	}
}
