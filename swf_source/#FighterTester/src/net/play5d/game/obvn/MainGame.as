/**
 * 已重建完成
 */
package net.play5d.game.obvn {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.DataEvent;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrler.GameRender;
	import net.play5d.game.obvn.ctrler.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.model.EffectModel;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.stage.CongratulateStage;
	import net.play5d.game.obvn.stage.CreditsStage;
	import net.play5d.game.obvn.stage.GameLoadingStage;
	import net.play5d.game.obvn.stage.GameOverStage;
	import net.play5d.game.obvn.stage.GameStage;
	import net.play5d.game.obvn.stage.HowToPlayStage;
	import net.play5d.game.obvn.stage.LoadingStage;
	import net.play5d.game.obvn.stage.LogoStage;
	import net.play5d.game.obvn.stage.MenuStage;
	import net.play5d.game.obvn.stage.SelectFighterStage;
	import net.play5d.game.obvn.stage.SettingStage;
	import net.play5d.game.obvn.stage.WinnerStage;
	import net.play5d.game.obvn.utils.GameLogger;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.KyoStageCtrler;
	import net.play5d.game.obvn.data.GameConfig;
	
	public class MainGame {
		
		public static const VER_LABEL:String = "开放BVN"
		public static const VERSION:String = "V3.x " + VER_LABEL;		// 版本
//		public static const VERSION_DATE:String = "2019.3.32";			// 版本日期
//		public static var UPDATE_INFO:String;
		
		public static var stageCtrler:KyoStageCtrler;					// 场景控制器
		public static var I:MainGame;
		
		private var _rootSprite:Sprite;
		private var _stage:Stage;
		
		private var _fps:Number = 60;
		
		public function MainGame() {
			I = this;
		}
		
		/**
		 * 获得根精灵
		 */
		public function get root():Sprite {
			return _rootSprite;
		}
		
		/**
		 * 获得主场景
		 */
		public function get stage():Stage {
			return _stage;
		}
		
		/**
		 * 初始化
		 */
		public function initlize(root:Sprite, stage:Stage, initBack:Function = null, initFail:Function = null):void {
			ResUtils.I.initalize(resInitBack, initFail);
			
			function resInitBack():void {
				GameLogger.log("初始化资源完成！");
				_rootSprite = root;
				_stage = stage;
				
				GameLogger.log("初始化游戏渲染");
				GameRender.initlize(stage);
				
				GameLogger.log("初始化输入器");
				GameInputer.initlize(_stage);
				
				GameLogger.log("初始化游戏数据");
				GameData.I.loadData();
				
				GameLogger.log("初始化配置");
				GameData.I.config.applyConfig();
				
				GameLogger.log("初始化输入器配置");
				GameInputer.updateConfig();
				
				GameLogger.log("初始化滚动域");
				root.scrollRect = new Rectangle(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
				
				GameLogger.log("初始化场景控制器");
				stageCtrler = new KyoStageCtrler(_rootSprite);
				stageCtrler.setChangeBack(changeBack);
				
				GameLogger.log("初始化加载场景");
				var loadingStage:GameLoadingStage = new GameLoadingStage();
				stageCtrler.goStage(loadingStage);
				loadingStage.loadGame(loadGameBack, initFail);
			}
			function loadGameBack():void {
				EffectModel.I.initlize();
				if (initBack != null) {
					initBack();
				}
			}
		}
		
		private function changeBack():void {
			Debugger.errorMsg("");
		}
		
		private static function resetDefault():void {
			GameCtrler.I.autoEndRoundAble = true;
			GameCtrler.I.autoStartAble = true;
			SelectFighterStage.AUTO_FINISH = true;
			LoadingStage.AUTO_START_GAME = true;
			
			GameMode.currentMode = GameMode.UNKOWN;
		}
		
		public function getFPS():Number {
			return _fps;
		}
		
		public function setFPS(v:Number):void {
			_fps = v;
			_stage.frameRate = v;
		}
		
		public function goLogo():void {
			stageCtrler.goStage(new LogoStage());
			setFPS(30);
		}
		
		public function goMenu():void {
			MainGame.I.stage.dispatchEvent(new DataEvent(
				"5d_message",
				false,
				false,
				JSON.stringify(["go_menu_stage"])
			));
			
			resetDefault();
			stageCtrler.goStage(new MenuStage());
			
			setFPS(30);
		}
		
		public function goHowToPlay():void {
			stageCtrler.goStage(new HowToPlayStage());
			
			setFPS(30);
		}
		
		public function goSelect():void {
			stageCtrler.goStage(new SelectFighterStage(), true);
			
			setFPS(30);
		}
		
		public function loadGame():void {
			var ls:LoadingStage = new LoadingStage();
			stageCtrler.goStage(ls, true);
			
			setFPS(30);
		}
		
		public function goGame():void {
			var gs:GameStage = new GameStage();
			stageCtrler.goStage(gs);
			
			GameCtrler.I.startGame();
			setFPS(GameConfig.FPS_GAME);
		}
		
		public function goOption():void {
			stageCtrler.goStage(new SettingStage());
			
			setFPS(30);
		}
		
		public function goContinue():void {
			var stg:GameOverStage = new GameOverStage();
			stg.showContinue();
			stageCtrler.goStage(stg);
			
			setFPS(30);
		}
		
//		public function goGameOver():void {
//			var stg:GameOverStage = new GameOverStage();
//			stg.showGameOver();
//			stageCtrl.goStage(stg);
//
//			setFPS(30);
//		}
		
		public function goWinner():void {
			var stg:WinnerStage = new WinnerStage();
			stageCtrler.goStage(stg);
			setFPS(30);
		}
		
		public function goCredits():void {
			stageCtrler.goStage(new CreditsStage());
			setFPS(30);
		}
		
//		public static function moreGames():void {
//			GameInterface.instance.moreGames();
//		}
		
		public function goCongratulations():void {
			stageCtrler.goStage(new CongratulateStage());
			setFPS(30);
		}
		
//		public function submitScore():void {
//			GameInterface.instance.submitScore(GameData.I.score);
//		}
		
//		public function showRank():void {
//			GameInterface.instance.showRank();
//		}
	}
}
