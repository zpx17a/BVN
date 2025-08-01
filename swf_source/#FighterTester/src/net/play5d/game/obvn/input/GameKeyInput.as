/**
 * 已重建完成
 */
package net.play5d.game.obvn.input {
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import net.play5d.game.obvn.vo.KeyConfigVO;
	import net.play5d.game.obvn.utils.KeyBoarder;
	import net.play5d.game.obvn.interfaces.IGameInput;
	
	/**
	 * 游戏键盘输入
	 */
	public class GameKeyInput implements IGameInput {
		
		private var _config:KeyConfigVO;
		private var _downKeys:Object = {};
		private var _enabled:Boolean = true;
		
		public function initlize(stage:Stage):void {
			KeyBoarder.initlize(stage);
			KeyBoarder.listen(keyBoardHandler);
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(v:Boolean):void {
			_enabled = v;
		}
		
		public function setConfig(config:Object):void {
			_config = config as KeyConfigVO;
		}
		
		public function focus():void {
			KeyBoarder.focus();
		}
		
		public function anyKey():Boolean {
			for (var i:String in _downKeys) {
				if (_downKeys[i] == 1) {
					return true;
				}
			}
			
			return false;
		}
		
		public function back():Boolean {
			return isDown(27);
		}
		
		public function select():Boolean {
			for each(var i:uint in _config.selects) {
				if (isDown(i)) {
					return true;
				}
			}
			
			return false;
		}
		
		public function up():Boolean {
			return isDown(_config.up);
		}
		
		public function down():Boolean {
			return isDown(_config.down);
		}
		
		public function left():Boolean {
			return isDown(_config.left);
		}
		
		public function right():Boolean {
			return isDown(_config.right);
		}
		
		public function attack():Boolean {
			return isDown(_config.attack);
		}
		
		public function jump():Boolean {
			return isDown(_config.jump);
		}
		
		public function dash():Boolean {
			return isDown(_config.dash);
		}
		
		public function skill():Boolean {
			return isDown(_config.skill);
		}
		
		public function superSkill():Boolean {
			return isDown(_config.superKill);
		}
		
		public function special():Boolean {
			return isDown(_config.beckons);
		}
		
		public function wankai():Boolean {
			return isDown(_config.attack) && isDown(_config.jump);
		}
		
		public function clear():void {
			_downKeys = {};
		}
		
		private function keyBoardHandler(e:KeyboardEvent):void {
			switch (e.type) {
				case KeyboardEvent.KEY_DOWN:
					_downKeys[e.keyCode] = 1;
					break;
				case KeyboardEvent.KEY_UP:
					_downKeys[e.keyCode] = 0;
			}
		}
		
		private function isDown(keycode:uint):Boolean {
			return _downKeys[keycode] == 1;
		}
	}
}
