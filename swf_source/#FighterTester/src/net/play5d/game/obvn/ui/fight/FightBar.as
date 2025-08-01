/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.WinUI;
	
	/**
	 * 战斗条类
	 */
	public class FightBar {
		
		
		private var _ui:MovieClip;
		
		private var _faceGroup1:FightFaceGroup;
		private var _faceGroup2:FightFaceGroup;
		
		private var _hpBar1:FighterHpBar;
		private var _hpBar2:FighterHpBar;
		
		private var _energyBar1:EnergyBar;
		private var _energyBar2:EnergyBar;
		
		private var _score:FightScoreUI;
		private var _isFadIn:Boolean;
		private var _timerMc:FightTimeUI;
		
		private var _winUI1:WinUI;
		private var _winUI2:WinUI;
		
		private var _isRenderAnimate:Boolean = false;
		
		private var _bp:Bitmap;
		private var _parent:DisplayObjectContainer;
		private var _children:Vector.<DisplayObject>;
		private var _drawMatrix:Matrix;
		private var _empytBd:BitmapData;
		
		public function FightBar(ui:MovieClip) {
			_ui = ui;
			
			_faceGroup1 = new FightFaceGroup(_ui.face1);
			_faceGroup2 = new FightFaceGroup(_ui.face2);
			_faceGroup2.setDirect(-1);
			
			_hpBar1 = new FighterHpBar(_ui.bar1);
			_hpBar2 = new FighterHpBar(_ui.bar2);
			
			_energyBar1 = new EnergyBar(_ui.energy1);
			_energyBar2 = new EnergyBar(_ui.energy2);
			_energyBar2.setDirect(-1);
			
			_winUI1 = new WinUI(_ui.win_p1, 1);
			_winUI2 = new WinUI(_ui.win_p2, 2);
			
			_timerMc = new FightTimeUI(_ui.timemc);
			
			if (GameUI.BITMAP_UI) {
				initBitmapUI();
			}
			else {
				_ui.scoremc.visible = false;
			}
			
			_ui.addEventListener(Event.COMPLETE, uiPlayComplete);
		}
		
		public function get ui():DisplayObject {
			return _ui;
		}
		
		private function initBitmapUI():void {
			_ui.gotoAndStop("fadin_fin");
			
			_parent = _ui.parent;
			try {
				_parent.removeChild(_ui);
			}
			catch (e:Error) {
			}
			
			var bds:Rectangle = _ui.getBounds(_ui);
			
			_drawMatrix = new Matrix(1, 0, 0, 1, -bds.x, -bds.y);
			_children = new Vector.<DisplayObject>();
			
			_bp = new Bitmap();
			_bp.bitmapData = new BitmapData(_ui.width, _ui.height, true, 0);
			_bp.x = bds.x;
			_bp.y = bds.y;
			
			_empytBd = new BitmapData(_ui.width, _ui.height, true, 0);
			
			addChildren( _faceGroup1.ui);
			addChildren( _faceGroup2.ui);
			addChildren(_hpBar1.ui);
			addChildren(_hpBar2.ui);
			addChildren(_energyBar1.ui);
			addChildren(_energyBar2.ui);
			addChildren(_bp);
			
			if (_timerMc.timeUI) {
				addChildren(_timerMc.timeUI);
			}
			
			addChildren(_winUI1.ui);
			addChildren(_winUI2.ui);
			addChildren(_ui.scoremc);
			
			updateBitmap();
			setChildrenVisible(false);
		}
		
		private function setChildrenPosition(d:DisplayObject):void {
			var parent:DisplayObjectContainer = d.parent;
			
			while (parent && parent != _ui) {
				d.x += parent.x;
				d.y += parent.y;
				parent = parent.parent;
			}
			
			d.x += _ui.x;
			d.y += _ui.y;
		}
		
		private function addChildren(d:DisplayObject, index:int = -1):void {
			setChildrenPosition(d);
			
			if (index == -1) {
				_parent.addChild(d);
			}
			else {
				_parent.addChildAt(d, index);
			}
			
			_children.push(d);
		}
		
		private function setChildrenVisible(v:Boolean):void {
			for each(var i:DisplayObject in _children) {
				i.visible = v;
			}
		}
		
		public function destory():void {
			if (_ui) {
				_ui.removeEventListener(Event.COMPLETE, uiPlayComplete);
				_ui.gotoAndStop("destory");
				_ui = null;
			}
			if (_hpBar1) {
				_hpBar1.destory();
				_hpBar1 = null;
			}
			if (_hpBar2) {
				_hpBar2.destory();
				_hpBar2 = null;
			}
			if (_energyBar1) {
				_energyBar1.destory();
				_energyBar1 = null;
			}
			if (_energyBar2) {
				_energyBar2.destory();
				_energyBar2 = null;
			}
			
			if (GameUI.BITMAP_UI) {
				if (_bp) {
					_bp.bitmapData.dispose();
					_bp = null;
				}
				if (_empytBd) {
					_empytBd.dispose();
					_empytBd = null;
				}
				_drawMatrix = null;
				for each(var d:DisplayObject in _children) {
					try {
						_parent.removeChild(d);
					}
					catch (e:Error) {
					}
				}
				
				_children = null;
			}
		}
		
		private function uiPlayComplete(e:Event):void {
			_ui.visible = _isFadIn;
		}
		
		public function initScore():void {
			if (!GameUI.BITMAP_UI) {
				_ui.scoremc.visible = true;
			}
			
			_score = new FightScoreUI(_ui.scoremc);
		}
		
		public function setScore(v:int):void {
			if (_score) {
				_score.setScore(v);
			}
		}
		
		public function showWin(fighter:FighterMain, wins:int):void {
			if (!fighter) {
				return;
			}
			if (wins < 0 || wins > 2) {
				return;
			}
			
			var winUI:WinUI = this["_winUI" + fighter.team.id] as WinUI;
			if (!winUI) {
				return;
			}
			
			winUI.show(fighter.data, wins);
		}
		
		public function setFighter(p1:GameRunFighterGroup = null, p2:GameRunFighterGroup = null):void {
			if (p1) {
				_faceGroup1.setFighter(p1);
				if (p1.currentFighter) {
					_hpBar1.setFighter(p1.currentFighter);
					_energyBar1.setFighter(p1.currentFighter);
				}
			}
			if (p2) {
				_faceGroup2.setFighter(p2);
				if (p2.currentFighter) {
					_hpBar2.setFighter(p2.currentFighter);
					_energyBar2.setFighter(p2.currentFighter);
				}
			}
			
			if (GameUI.BITMAP_UI) {
				updateBitmap();
			}
		}
		
		private function updateBitmap():void {
			_bp.bitmapData.copyPixels(_empytBd, new Rectangle(0, 0, _empytBd.width, _empytBd.height), new Point());
			_bp.bitmapData.draw(_ui, _drawMatrix);
		}
		
		public function render():void {
			_faceGroup1.render();
			_faceGroup2.render();
			_hpBar1.render();
			_hpBar2.render();
			_energyBar1.render();
			_energyBar2.render();
			_timerMc.render();
		}
		
		public function fadIn(animate:Boolean):void {
			if (_isFadIn) {
				return;
			}
			_isFadIn = true;
			if (GameUI.BITMAP_UI) {
				setChildrenVisible(true);
				return;
			}
			_ui.visible = true;
			if (animate) {
				_ui.gotoAndStop("fadin");
				_isRenderAnimate = true;
			}
			else {
				_ui.gotoAndStop("fadin_fin");
			}
		}
		
		public function fadOut(animate:Boolean):void {
			if (!_isFadIn) {
				return;
			}
			
			_isFadIn = false;
			if (GameUI.BITMAP_UI) {
				setChildrenVisible(false);
				return;
			}
			if (animate) {
				_ui.gotoAndStop("fadout");
				_isRenderAnimate = true;
			}
			else {
				_ui.visible = false;
			}
		}
		
		public function renderAnimate():void {
			if (!_isRenderAnimate) {
				return;
			}
			var curFrame:String = _ui.currentFrameLabel;
			if (curFrame == "fadin_fin" || curFrame == "fadout_fin") {
				_isRenderAnimate = false;
				return;
			}
			
			_ui.nextFrame();
		}
	}
}
