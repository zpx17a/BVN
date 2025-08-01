/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import net.play5d.game.obvn.data.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrler.AssetManager;
	import net.play5d.game.obvn.ctrler.GameRender;
	import net.play5d.game.obvn.ctrler.SoundCtrler;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.event.GameEvent;
	import net.play5d.game.obvn.event.SetBtnEvent;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.ui.SetBtnGroup;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 祝贺场景类
	 */
	public class CongratulateStage implements IStage {
		
		private var _mainUI:Sprite;
		private var _ui:Sprite;
		
		private var _exitHeight:Number = 0;
		private var _btngroup:SetBtnGroup;
		private var _bg:Bitmap;
		
		
		public function get display():DisplayObject {
			return _mainUI;
		}
		
//		public function get innerUI():Sprite {
//			return _ui;
//		}
		
		public function build():void {
			_mainUI = new Sprite();
			
			var bgbd:BitmapData = ResUtils.I.createBitmapData(
				ResUtils.I.common_ui,
				"cover_bgimg",
				GameConfig.GAME_SIZE.x,
				GameConfig.GAME_SIZE.y
			);
			_bg = new Bitmap(bgbd);
			_bg.alpha = -1;
			_mainUI.addChild(_bg);
			
			_ui = new Sprite();
			_mainUI.addChild(_ui);
			
			var ctmc:MovieClip = ResUtils.I.createDisplayObject(ResUtils.I.common_ui, ResUtils.CONGRATULATIONS);
			_ui.addChild(ctmc);
			
			ctmc.addEventListener(Event.COMPLETE, playComplete, false, 0, true);
			ctmc.gotoAndPlay(2);
			
			SoundCtrler.I.BGM(AssetManager.I.getSound("congratulation"));
		}
		
//		public function getBtnY():Number {
//			return _btngroup.y;
//		}
		
		private function playComplete(e:Event):void {
			var winallmc:MovieClip = ResUtils.I.createDisplayObject(ResUtils.I.common_ui, "mc_win_all");
			winallmc.y = GameConfig.GAME_SIZE.y;
			_ui.addChild(winallmc);
			
			GameRender.add(render);
			
			var scoretxt:BitmapFontText = new BitmapFontText(AssetManager.I.getFont("font1"));
			scoretxt.text = "FINAL SCORE " + GameData.I.score;
			scoretxt.x = (GameConfig.GAME_SIZE.x - scoretxt.width) / 2;
			scoretxt.y = winallmc.y + winallmc.height + 100;
			
			_ui.addChild(scoretxt);
			_exitHeight = scoretxt.y - 320;
			
			_btngroup = new SetBtnGroup();
			_btngroup.x = 230;
			_btngroup.y = scoretxt.y + scoretxt.height + 100;
			_btngroup.setBtnData([{
				label: "BACK",
				cn   : "返回"
			}]);
			
			_btngroup.addEventListener(SetBtnEvent.SELECT, selectBtnHandler);
			_btngroup.keyEnable = false;
			_ui.addChild(_btngroup);
			
			GameEvent.dispatchEvent(GameEvent.GAME_PASS_ALL);
		}
		
		private function render():void {
			if (GameInputer.back(1)) {
				_ui.y = -_exitHeight;
				SoundCtrler.I.sndSelect();
			}
			
			_ui.y -= 1;
			_bg.alpha += 0.005;
			if (_ui.y < -_exitHeight) {
				GameRender.remove(render);
				_bg.alpha = 1;
				_btngroup.keyEnable = true;
			}
		}
		
		private static function selectBtnHandler(e:SetBtnEvent):void {
			MainGame.I.goLogo();
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			GameRender.remove(render);
			
			if (_btngroup) {
				_btngroup.destory();
				_btngroup.removeEventListener(SetBtnEvent.SELECT, selectBtnHandler);
				_btngroup = null;
			}
		}
	}
}
