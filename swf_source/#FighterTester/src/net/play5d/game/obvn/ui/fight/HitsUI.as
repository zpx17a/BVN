/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.geom.Point;
	
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.MCNumber;
	
	import flash.display.MovieClip;
	
	public class HitsUI {
		
		private var _mc:MovieClip;
		private var _txtmc:MCNumber;
		private var _isShow:Boolean
		private var _orgPos:Point;
		
		/**
		 * 连击数 UI类
		 */
		public function HitsUI(mc:MovieClip) {
			_mc = mc;
			
			var cls:Class = ResUtils.I.getItemClass(ResUtils.I.fight, "hits_num_mc");
			_txtmc = new MCNumber(cls, 0, 1, 35);
			_orgPos = new Point(mc.x, mc.y);
			
			_mc.ct.addChild(_txtmc);
		}
		
		public function destory():void {
			if (_txtmc) {
				try {
					_mc.ct.removeChild(_txtmc);
				}
				catch (e:Error) {
				}
				
				_txtmc = null;
			}
			if (_mc) {
				_mc = null;
			}
			
			_orgPos = null;
		}
		
		public function show(num:int):void {
			_txtmc.number = num;
			
			var xoffset:Number = -_txtmc.width + 45;
			_txtmc.x = xoffset;
			if (_mc.name == "hits1") {
				_mc.x = _orgPos.x - xoffset;
			}
			if (_isShow) {
				_mc.gotoAndPlay("update");
				return;
			}
			
			_isShow = true;
			_mc.gotoAndPlay("fadin");
		}
		
		public function hide():void {
			if (!_isShow) {
				return;
			}
			
			_isShow = false;
			_mc.gotoAndPlay("fadout");
		}
	}
}
