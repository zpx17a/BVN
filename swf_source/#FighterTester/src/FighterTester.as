/**
 * 已重建完成
 */
package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrler.GameLogic;
	import net.play5d.game.obvn.ctrler.StateCtrler;
	import net.play5d.game.obvn.ctrler.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.ctrler.game_ctrler.TrainingCtrler;
	import net.play5d.game.obvn.data.GameConfig;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameInterface;
	import net.play5d.game.obvn.data.GameInterfaceManager;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameQuality;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.ctrler.FighterCtrler;
	import net.play5d.game.obvn.fighter.ctrler.FighterEffectCtrler;
	import net.play5d.game.obvn.fighter.ctrler.FighterVoice;
	import net.play5d.game.obvn.fighter.event.FighterEvent;
	import net.play5d.game.obvn.fighter.event.FighterEventDispatcher;
	import net.play5d.game.obvn.fighter.vo.HitVO;
	import net.play5d.game.obvn.model.MapModel;
	import net.play5d.game.obvn.stage.LoadingStage;
	import net.play5d.game.obvn.vo.GameRunDataVO;
	import net.play5d.game.obvn.vo.SelectVO;
	import net.play5d.kyo.display.ui.KyoSimpButton;
	
	[SWF(frameRate="30", backgroundColor="#000000", width="1000", height="600")]
	/**
	 * 游戏主类
	 */
	public class FighterTester extends Sprite {
		
		private var _mainGame:MainGame;
		private var _gameSprite:Sprite;
		private var _testUI:Sprite;
		
		private var _p1InputId:TextField;
		private var _p2InputId:TextField;
		private var _p1FzInputId:TextField;
		private var _p2FzInputId:TextField;
		private var _autoReceiveHp:TextField;
		private var _mapInputId:TextField;
		private var _fpsInput:TextField;
		private var _debugText:TextField;
		
		public function FighterTester() {
			if (stage) {
				initlize();
				return;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, initlize);
		}
		
		private function initlize(e:Event = null):void {
			Debugger.initDebug(stage);
			Debugger.onErrorMsgCall = onDebugLog;
			
			_gameSprite = new Sprite();
			_gameSprite.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
			addChild(_gameSprite);
			
			GameInterface.instance = new GameInterfaceManager();
			
			GameData.I.config.keyInputMode = 1;
			GameData.I.config.quality = GameQuality.LOW;
			GameData.I.config.fighterHP = 2;
			GameData.I.config.AI_level = 6;
			GameData.I.config.fightTime = -1;
			
			_mainGame = new MainGame();
			_mainGame.initlize(_gameSprite, stage, initBackHandler, initFailHandler);
			
			StateCtrler.I.transEnabled = false;
		}
		
		private function initBackHandler():void {
			buildTestUI();
		}
		
		private function initFailHandler(msg:String):void {}
		
		private function buildTestUI():void {
			_testUI = new Sprite();
			_testUI.x = 810;
			
			_testUI.graphics.beginFill(0x333333, 1);
			_testUI.graphics.drawRect(-10, 0, 200, 600);
			_testUI.graphics.endFill();
			
			addChild(_testUI);
			
			var yy:Number = 20;
			
			addLabel("玩家 1", yy);
			yy += 40;
			
			addLabel("角色id", yy);
			_p1InputId = addInput("ichigo", yy, 80);
			yy += 40;
			
			addLabel("辅助id", yy);
			_p1FzInputId = addInput("kon", yy, 80);
			yy += 80;
			
			addLabel("玩家 2", yy);
			yy += 40;
			
			addLabel("角色id", yy);
			_p2InputId = addInput("naruto", yy, 80);
			yy += 40;
			
			addLabel("辅助id", yy);
			_p2FzInputId = addInput("gaara", yy, 80);
			yy += 40;
			
			addLabel("地图id", yy);
			_mapInputId = addInput(MapModel.I.getAllMaps()[1].id, yy, 80);
			yy += 60;
			
			addLabel("帧率", yy);
			_fpsInput = addInput(GameConfig.FPS_GAME.toString(), yy, 80);
			yy += 40;
			
			addLabel("回血", yy);
			_autoReceiveHp = addInput("1", yy, 80);
			yy += 60;
			
			_debugText = addLabel("错误信息提示", yy, 0, {font: "Times New Roman", size: 12});
			_debugText.width = 190;
			_debugText.height = 200;
			_debugText.textColor = 0xFF0000;
			_debugText.multiline = true;
			
			addButton("开始测试", 500, 25, 65, 35, testClickHandler);
			addButton("显示判定", 500, 100, 65, 35, renderMainClickHandler);
			addButton("秒杀 P2", 550, 25, 65, 35, killP2ClickHandler);
			addButton("Esc 键", 550, 100, 65, 35, escKeyDownClickHandler);
		}
		
		private function addLabel(txt:String, y:Number = 0, x:Number = 0, param:Object = null):TextField {
			param ||= {};
			param.size  ||= 14;
			param.color ||= 0xFFFFFF;
			param.font  ||= "SimHei";
			
			var tf:TextFormat = new TextFormat();
			tf.size  = param.size;
			tf.color = param.color;
			tf.font  = param.font;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = txt;
			label.x = x;
			label.y = y;
			label.mouseEnabled = false;
			
			_testUI.addChild(label);
			return label;
		}
		
		private function addInput(txt:String, y:Number = 0, x:Number = 0):TextField {
			var tf:TextFormat = new TextFormat();
			tf.size = 14;
			tf.color = 0;
			
			var label:TextField = new TextField();
			label.defaultTextFormat = tf;
			label.text = txt;
			label.x = x;
			label.y = y;
			label.width = 100;
			label.height = 20;
			label.backgroundColor = 0xFFFFFF;
			label.background = true;
			label.type = TextFieldType.INPUT;
			label.condenseWhite = true;
			
			_testUI.addChild(label);
			return label;
		}
		
		private function addButton(
			label:String,
			y:Number = 0, x:Number = 0,
			width:Number = 100, height:Number = 50,
			click:Function = null):Sprite 
		{
			var btn:KyoSimpButton = new KyoSimpButton(label, width, height);
			btn.x = x;
			btn.y = y;
			
			if (click != null) {
				btn.onClick(click);
			}
			
			_testUI.addChild(btn);
			return btn;
		}
		
		private function onDebugLog(msg:String):void {
			if (!_debugText) {
				return;
			}
			
			_debugText.text = msg;
		}
		
		private function changeFps(...params):void {
			var fps:int = int(_fpsInput.text);
			
			GameConfig.setGameFps(fps);
			stage.frameRate = fps;
		}
		
		private function testClickHandler(...params):void {
			changeFps();
			
			GameMode.currentMode = GameMode.TRAINING;
			TrainingCtrler.RECOVER_HP = _autoReceiveHp.text != "0";
			
			GameData.I.p1Select = new SelectVO();
			GameData.I.p2Select = new SelectVO();
			
			GameData.I.p1Select.fighter1 = _p1InputId.text;
			GameData.I.p2Select.fighter1 = _p2InputId.text;
			GameData.I.p1Select.fuzhu = _p1FzInputId.text;
			GameData.I.p2Select.fuzhu = _p2FzInputId.text;
			GameData.I.selectMap = _mapInputId.text;
			
			loadGame();
		}
		
		private static function loadGame():void {
			var ls:LoadingStage = new LoadingStage();
			MainGame.stageCtrler.goStage(ls);
		}
		
		private function killP2ClickHandler(...params):void {
			var rundata:GameRunDataVO = GameCtrler.I.gameRunData;
			if (!rundata) {
				Debugger.errorMsg("没有游戏数据！");
				return;
			}
			if (!GameCtrler.I.actionEnable) {
				Debugger.errorMsg("正处于系统控制中！");
				return;
			}
			if (GameCtrler.I.isPauseGame) {
				Debugger.errorMsg("正处于暂停！");
				return;
			}
			
			var p1:FighterMain = rundata.p1FighterGroup.currentFighter;
			var p2:FighterMain = rundata.p2FighterGroup.currentFighter;
			if (!p1 || !p2) {
				return;
			}
			if (GameMode.currentMode == GameMode.TRAINING) {
				Debugger.errorMsg("当前为练习模式!");
				return;
			}
			if (!p1.isAlive || !p2.isAlive) {
				return;
			}
			
			killP2(p1, p2);
		}
		
		private function killP2(p1:FighterMain, p2:FighterMain):void {
			var hv:HitVO = new HitVO();
			hv.owner = p1;
			
			var p2hp:Number = p2.hp;
			p2.hurtHit = hv;
			p2.loseHp(p2hp);
			
			var p2Ctrler:FighterCtrler = p2.getCtrler();
			p2Ctrler.getMcCtrl().idle();
			p2Ctrler.getMcCtrl().hurtFly(-5, 0);
			p2Ctrler.getVoiceCtrl().playVoice(FighterVoice.DIE);
			
			var p2EffectCtrler:FighterEffectCtrler = p2Ctrler.getEffectCtrl();
			p2EffectCtrler.endBisha();
			p2EffectCtrler.endGhostStep();
			p2EffectCtrler.endGlow();
//			p2EffectCtrler.endShadow();
//			p2EffectCtrler.endShake();
			
			if (GameLogic.checkFighterDie(p2)) {
				Debugger.errorMsg("掉血：" + p2hp);
				
				FighterEventDispatcher.dispatchEvent(p2, FighterEvent.DIE);
				p2.isAlive = false;
				
				trace("秒杀 P2 成功！");
			}
		}
		
		private function escKeyDownClickHandler(...params):void {
			// 模拟按下
			var escKeyDownEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
			escKeyDownEvent.keyCode = Keyboard.ESCAPE;
			
			stage.dispatchEvent(escKeyDownEvent);
			
			// 模拟弹起
			setTimeout(function():void {
				var escKeyUpEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_UP);
				escKeyUpEvent.keyCode = Keyboard.ESCAPE;
				
				stage.dispatchEvent(escKeyUpEvent);
				
				trace("发送 ESC 按键事件完成!");
			}, 80);
		}
		
		private function renderMainClickHandler(e:Event):void {
			var btn:KyoSimpButton = e.target as KyoSimpButton;
			
			if (btn.getLabel() == "显示判定") {
				btn.setLabel("关闭判定");
			}
			else {
				btn.setLabel("显示判定");
			}
			
			Debugger.showMain();
		}
	}
}
