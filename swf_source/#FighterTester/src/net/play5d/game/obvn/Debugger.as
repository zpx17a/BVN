/**
 * 已重建完成
 */
package net.play5d.game.obvn {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	import net.play5d.game.obvn.ctrler.GameRender;
	import net.play5d.game.obvn.ctrler.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.GameConfig;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.GameRunFighterGroup;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterMC;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.ui.UIUtils;
	import net.play5d.game.obvn.vo.GameRunDataVO;
	import net.play5d.kyo.display.BitmapText;
	
	/**
	 * 调试类
	 */
	public class Debugger {
		
		public static var onErrorMsgCall:Function;				// 错误信息回调函数
		
//		public static const DRAW_AREA:Boolean = false;			// 绘制区域
//		public static const SAFE_MODE:Boolean = false;			// 安全模式
//		public static const DEBUG_ENABLED:Boolean = false;		// 是否启用 DEBUG
//		public static const HIDE_MAP:Boolean = false;			// 隐藏地图
//		public static const HIDE_HITEFFECT:Boolean = false;		// 隐藏攻击特效
		
		private static var _stage:Stage;						// 主场景
		
		/**
		 * 记录
		 */
		public static function log(...params):void {
			trace.call(null, params);
		}
		
		/**
		 * 输出错误信息
		 */
		public static function errorMsg(msg:String):void {
			if (msg) {
				trace("Debugger.errorMsg :: " + msg);
			}
			
			if (onErrorMsgCall != null) {
				onErrorMsgCall(msg);
			}
		}
		
		/**
		 * 初始化 Debugger
		 */
		public static function initDebug(stage:Stage):void {
			_stage = stage;
			
			showFPS();
			showMode();
		}
		
		public static function addChild(d:DisplayObject):void {
			_stage.addChild(d);
		}
		
		/**
		 * 显示 FPS
		 */
		public static function showFPS():void {
			var fpsCount:int = 0;
			
			var fpsText:BitmapText = new BitmapText(true, 0xFFFFFF, [new GlowFilter(0x000000, 1, 3, 3, 3)]);
			fpsText.font = "SimHei";
			UIUtils.formatText(fpsText.textfield, {
				color: 0xFFFFFF
			});
			
			_stage.addChild(fpsText);
			_stage.addEventListener(Event.ENTER_FRAME, countFPS);
			
			function countFPS(e:Event):void {
				fpsCount++;
			}
			
			var fpsTimer:Timer = new Timer(1000, 0);
			fpsTimer.addEventListener(TimerEvent.TIMER, updateFPS);
			fpsTimer.start();
			
			function updateFPS(e:TimerEvent):void {
//				if (fpsCount < 29) {
//					var rundata:GameRunDataVO = GameCtrler.I.gameRunData;
//					if (rundata && GameCtrler.I.actionEnable && !GameCtrler.I.isPauseGame) {
//						var p1FighterGroup:GameRunFighterGroup = rundata.p1FighterGroup;
//						var p2FighterGroup:GameRunFighterGroup = rundata.p2FighterGroup;
//						
//						if (p1FighterGroup && p2FighterGroup) {
//							var p1Fighter:FighterMain = p1FighterGroup.currentFighter;
//							var p2Fighter:FighterMain = p2FighterGroup.currentFighter;
//							var p1fz:Assister = p1FighterGroup.fuzhu;
//							var p2fz:Assister = p2FighterGroup.fuzhu;
//							
//							if (p1Fighter && p2Fighter && p1fz && p2fz) {
//								var p1MC:FighterMC = p1Fighter.getMC();
//								var p2MC:FighterMC = p2Fighter.getMC();
//								var p1fzMc:MovieClip = p1fz.mc;
//								var p2fzMc:MovieClip = p2fz.mc;
//								
//								if (p1MC && p2MC && p1fzMc && p2fzMc) {
//									trace("帧率低：" + fpsCount + "，帧数定位：");
//									
//									var msg:String = "";
//									msg += 
//										"-  P1 Fighter: " + p1MC.getCurrentFrame() + ", "
//										+ "Assister: " + p1fzMc.currentFrame;
//									msg += "\n";
//									msg += 
//										"-  P2 Fighter: " + p2MC.getCurrentFrame() + ", "
//										+ "Assister: " + p2fzMc.currentFrame;
//									
//									trace(msg);
//								}
//							}
//						}
//					}
//				}
//				
				fpsText.text = "FPS:" + fpsCount;
				fpsCount = 0;
			}
		}
		
		/**
		 * 显示模式
		 */
		public static function showMode():void {
			var modeText:BitmapText = new BitmapText(true, 0xFFFFFF, [new GlowFilter(0x000000, 1, 3, 3, 3)]);
			modeText.font = "SimHei";
			modeText.width = GameConfig.GAME_SIZE.x;
			modeText.y = GameConfig.GAME_SIZE.y - modeText.height * 1.5;
			UIUtils.formatText(modeText.textfield, {
				color: 0xFFFFFF
			});
			_stage.addChild(modeText);
			
			GameRender.add(render);
			function render():void {
				modeText.text = "当前模式：" + GameMode.toString();
			}
		}
		
		public static function showMain():void {
			DebugMain.showMain();
		}
		
		
	}
}
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;

import net.play5d.game.obvn.ctrler.GameRender;
import net.play5d.game.obvn.ctrler.game_ctrler.GameCtrler;
import net.play5d.game.obvn.fighter.Assister;
import net.play5d.game.obvn.fighter.FighterAttacker;
import net.play5d.game.obvn.fighter.FighterMain;
import net.play5d.game.obvn.fighter.vo.HitVO;
import net.play5d.game.obvn.interfaces.IGameSprite;
import net.play5d.game.obvn.stage.GameStage;

/**
 * 调试面
 */
class DebugMain {
	
	private static var _isInitedShowMain:Boolean = false;
	private static var _isShowMain:Boolean = false;
	private static var _gameStage:GameStage;
	private static var _allMainShapeSp:Sprite;
	private static var _gameLayer:Sprite;
	
	public static function showMain():void {
		_isShowMain = !_isShowMain;
		
		if (!_isInitedShowMain) {
			GameRender.addAfter(startRenderMain);
			_isInitedShowMain = true;
		}
	}
	
	private static function startRenderMain():void {
		const LAYER_NAME:String = "allMainShapeSp";
		
		if (!_isShowMain) {
			cleanMain();
			return;
		}
		
		_gameStage = GameCtrler.I.gameStage;
		if (!_gameStage) {
			return;
		}
		
		_gameLayer = _gameStage.gameLayer;
		if (!_gameLayer) {
			return;
		}
		
		var p1:FighterMain = GameCtrler.I.gameRunData.p1FighterGroup.currentFighter;
		var p2:FighterMain = GameCtrler.I.gameRunData.p2FighterGroup.currentFighter;
		if (!p1 || !p2) {
			cleanMain();
			return;
		}
		
		if (!_gameLayer.getChildByName(LAYER_NAME)) {
			_allMainShapeSp = new Sprite();
			_allMainShapeSp.name = LAYER_NAME;
			_gameLayer.addChild(_allMainShapeSp);
		}
		_gameLayer.setChildIndex(_gameLayer.getChildByName(LAYER_NAME), _gameLayer.numChildren - 1);
		
		_allMainShapeSp.removeChildren();
		renderAllMain(p1, p2);
	}
	
	private static function cleanMain():void {
		if (!_allMainShapeSp) {
			return;
		}
		
		_allMainShapeSp.removeChildren();
		_gameLayer.removeChild(_allMainShapeSp);
		_allMainShapeSp = null;
	}
	
	private static function renderAllMain(p1:FighterMain, p2:FighterMain):void {
		renderFighterMain(p1);
		renderFighterMain(p2);
		
		var gameSprites:Vector.<IGameSprite> = _gameStage.getGameSprites();
		for each (var sp:IGameSprite in gameSprites) {
			var hitVOs:Array = sp.getCurrentHits();
			if (hitVOs) {
				renderHitMain(hitVOs);
			}
			
			if (sp is Assister || sp is FighterAttacker) {
				var targetChker:String;
				var targetChkerArea:Rectangle;
				if (sp is Assister) {
					targetChker = (sp as Assister).getCtrler().hitTargetChecker;
					if (targetChker) {
						targetChkerArea = (sp as Assister).getHitCheckRect(targetChker);
					}
				}
				else {
					targetChker = (sp as FighterAttacker).getCtrler().hitTargetChecker;
					if (targetChker) {
						targetChkerArea = (sp as FighterAttacker).getHitCheckRect(targetChker);
					}
				}
				
				if (targetChker && targetChkerArea) {
					var yellowShape:Shape = getNewMainShape(0xFFFF00);
					renderMain(yellowShape, targetChkerArea);
				}
			}
			
			if (sp is Assister) {
				var ownerChker:String = (sp as Assister).getCtrler().hitOwnerChecker;
				var ownerChkerArea:Rectangle;
				if (ownerChker) {
					ownerChkerArea = (sp as Assister).getHitCheckRect(ownerChker);
				}
				
				if (ownerChker && ownerChkerArea) {
					var buleShape:Shape = getNewMainShape(0x0000FF);
					renderMain(buleShape, ownerChkerArea);
				}
			}
		}
	}
	
	private static function getNewMainShape(color:uint, alpha:Number = 0.33):Shape {
		var shape:Shape = new Shape();
		
		shape.graphics.beginFill(color, alpha);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.endFill();
		
		return shape;
	}
	
	private static function renderMain(display:DisplayObject, rect:Rectangle):void {
		display.x = rect.x;
		display.y = rect.y;
		display.width = rect.width;
		display.height = rect.height;
		
		_allMainShapeSp.addChild(display);
	}
	
	private static function renderHitMain(hitVOs:Array):void {
		if (!hitVOs || hitVOs.length == 0) {
			return;
		}
		
		for each (var hitVO:HitVO in hitVOs) {
			var area:Rectangle = hitVO.currentArea;
			if (!area) {
				continue;
			}
			
			var redShape:Shape = getNewMainShape(0xFF0000);
			renderMain(redShape, area);
		}
	}
	
	private static function renderFighterMain(fighter:FighterMain):void {
		if (!fighter) {
			return;
		}
		
		var bodyArea:Rectangle = fighter.getBodyArea();
		if (bodyArea) {
			var greenShape:Shape = getNewMainShape(0x00FF00);
			renderMain(greenShape, bodyArea);
		}
		
//		renderHitMain(fighter.getCurrentHits());
		
		var chker:String = fighter.getCtrler().getMcCtrl().getAction().hitTargetChecker;
		if (chker) {
			var chkerArea:Rectangle = fighter.getCtrler().getHitCheckRect(chker);
			if (chkerArea) {
				var yellowShape:Shape = getNewMainShape(0xFFFF00);
				renderMain(yellowShape, chkerArea);
			}
		}
	}
}