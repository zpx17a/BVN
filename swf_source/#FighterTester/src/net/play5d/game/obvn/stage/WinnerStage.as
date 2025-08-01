/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.DataEvent;
	import flash.events.Event;
//	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
//	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrler.AssetManager;
	import net.play5d.game.obvn.ctrler.GameRender;
	import net.play5d.game.obvn.ctrler.SoundCtrler;
	import net.play5d.game.obvn.ctrler.StateCtrler;
	import net.play5d.game.obvn.model.FighterModel;
	import net.play5d.game.obvn.vo.FighterVO;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.model.MessionModel;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.input.GameInputer;
//	import net.play5d.game.bvn.interfaces.GameInterface;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 胜利场景
	 */
	public class WinnerStage implements IStage {
		
		private var _ui:MovieClip;
		private var _scoreText:BitmapFontText;
		private var _winnerFaces:Array;
		private var _winSay:String;
		private var _bgmDelay:int;
		
		public function get display():DisplayObject {
			return _ui;
		}
		
		private function buildData():void {
			var winner:FighterVO = FighterModel.I.getFighter(GameData.I.winnerId);
			var winFighters:Vector.<FighterVO> = new Vector.<FighterVO>();
			var fs:Array = GameData.I.p1Select.getSelectFighters();
			
			for (var i:int = 0; i < fs.length; i++) {
				winFighters.push(FighterModel.I.getFighter(fs[i]));
			}
			
			_winSay = winner.getRandSay();
			if (winFighters.length == 1) {
				_winnerFaces = [AssetManager.I.getFighterFaceWin(winFighters[0])];
			}
			else {
				_winnerFaces = [];
				
				var index:int = winFighters.indexOf(winner);
				_winnerFaces.push(AssetManager.I.getFighterFaceWin(winFighters[index]));
				winFighters.splice(index, 1);
				
				for (var j:int = 0; j < winFighters.length; j++) {
					_winnerFaces.push(AssetManager.I.getFighterFaceWin(winFighters[j]));
				}
			}
		}
		
		private function initText():void {
			var txtmc:MovieClip = _ui.getChildByName("txtmc") as MovieClip;
			if (txtmc) {
				txtmc.addEventListener(Event.COMPLETE, txtCompleteHandler);
			}
			
			function txtCompleteHandler(e:Event):void {
				txtmc.removeEventListener(Event.COMPLETE, txtCompleteHandler);
				
				var txt:TextField = new TextField();
				txt.x = 33;
				txt.width = 548;
				txt.height = 66;
				txt.multiline = true;
				txt.wordWrap = true;
				txt.mouseEnabled = false;
				
				var tf:TextFormat = new TextFormat();
				tf.font = "SimHei";
				tf.color = 0;
				tf.size = 18;
				tf.align = TextFormatAlign.CENTER;
				tf.leading = 5;
				
				txt.defaultTextFormat = tf;
				setText(txt, _winSay);
				txtmc.addChild(txt);
			}
		}
		
//		private function testFighterSays(txt:TextField):void {
//			var winner:FighterVO = FighterModel.I.getFighter(GameData.I.winnerId);
//			var sayIndex:int = 0;
//
//			var says:Array = [];
//			for each(var k:String in winner.says) {
//				says.push({
//					id : winner.id,
//					say: k
//				});
//			}
//			for each(var i:FighterVO in FighterModel.I.getAllFighters()) {
//				for each(var j:String in i.says) {
//					says.push({
//						id : i.id,
//						say: j
//					});
//				}
//			}
//			MainGame.I.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
//
//			function keyHandler(e:KeyboardEvent):void {
//				switch (e.keyCode) {
//					case Keyboard.LEFT:
//						sayIndex--;
//						if (sayIndex < 0) {
//							sayIndex = 0;
//							break;
//						}
//						break;
//					case Keyboard.RIGHT:
//						sayIndex++;
//						if (sayIndex > says.length - 1) {
//							sayIndex = says.length - 1;
//							break;
//						}
//						break;
//					default:
//						return;
//				}
//
//				setText(txt, says[sayIndex].say);
//				trace(says[sayIndex].id);
//			}
//		}
		
		private static function setText(txt:TextField, str:String):void {
			txt.text = str.split("|").join("\n");
			txt.height = txt.textHeight + 5;
			
			txt.y = 10 + (90 - txt.height) / 2;
		}
		
		public function build():void {
			buildData();
			
			_scoreText = new BitmapFontText(AssetManager.I.getFont("font1"));
			_scoreText.text = "SCORE " + GameData.I.score;
			_scoreText.x = -_scoreText.width / 2;
			_scoreText.y = -_scoreText.height / 2;
			
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.loading, ResUtils.WINNER);
			_ui.addEventListener(Event.COMPLETE, onUIPlayComplete);
			_ui.scoremc.addChild(_scoreText);
			
			if (_winnerFaces[0]) {
				_ui.f0.addChildAt(_winnerFaces[0], 0);
			}
			else {
				_ui.f0.visible = false;
			}
			if (_winnerFaces[1]) {
				_ui.f1.addChildAt(_winnerFaces[1], 0);
			}
			else {
				_ui.f1.visible = false;
			}
			if (_winnerFaces[2]) {
				_ui.f2.addChildAt(_winnerFaces[2], 0);
			}
			else {
				_ui.f2.visible = false;
			}
			
			SoundCtrler.I.BGM(null);
			SoundCtrler.I.playAssetSound("win");
			GameInputer.enabled = false;
			initText();
			
			_bgmDelay = setTimeout(function ():void {
				SoundCtrler.I.BGM(AssetManager.I.getSound("winloop"));
			}, 6500);
		}
		
		private function onUIPlayComplete(e:Event):void {
			_ui.removeEventListener(Event.COMPLETE, onUIPlayComplete);
			MainGame.I.stage.dispatchEvent(new DataEvent("5d_message", false, false, JSON.stringify(["winner_show"])));
			
			var btns:MovieClip = _ui.getChildByName("btns") as MovieClip;
			btns.btn_more.addEventListener(MouseEvent.CLICK, btnHandler);
			btns.btn_cont.addEventListener(MouseEvent.CLICK, btnHandler);
			btns.btn_exit.addEventListener(MouseEvent.CLICK, btnHandler);
			btns.btn_more.addEventListener(MouseEvent.MOUSE_OVER, btnHandler);
			btns.btn_cont.addEventListener(MouseEvent.MOUSE_OVER, btnHandler);
			btns.btn_exit.addEventListener(MouseEvent.MOUSE_OVER, btnHandler);
			
			GameRender.add(render);
			GameInputer.enabled = true;
		}
		
		private function render():void {
			if (GameInputer.select(GameInputType.MENU)) {
				goNext();
			}
		}
		
		private function btnHandler(e:MouseEvent):void {
			if (e.type == MouseEvent.MOUSE_OVER) {
				SoundCtrler.I.sndSelect();
				
				return;
			}
			
			var btns:MovieClip = _ui.getChildByName("btns") as MovieClip;
			switch (e.currentTarget) {
				case btns.btn_more:
//					GameInterface.instance.moreGames();
					break;
				case btns.btn_cont:
					goNext();
					break;
				case btns.btn_exit:
					GameUI.confirm("BACK TITLE", "返回到主菜单？", MainGame.I.goMenu);
			}
			
			SoundCtrler.I.sndConfrim();
		}
		
		private function goNext():void {
			GameInputer.enabled = false;
			
			StateCtrler.I.transIn(function ():void {
				MessionModel.I.messionComplete();
				MainGame.I.loadGame();
			});
		}
		
		public function afterBuild():void {}
		
		public function destory(back:Function = null):void {
			GameRender.remove(render);
			GameInputer.enabled = false;
			clearTimeout(_bgmDelay);
			
			MainGame.I.stage.dispatchEvent(new DataEvent("5d_message", false, false, JSON.stringify(["winner_end"])));
			if (_ui) {
				_ui.gotoAndStop("destory");
				_ui = null;
			}
		}
	}
}
