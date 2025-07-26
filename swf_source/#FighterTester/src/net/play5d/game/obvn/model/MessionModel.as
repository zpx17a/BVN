/**
 * 已重建完成
 */
package net.play5d.game.obvn.model {
	import net.play5d.game.obvn.ctrler.GameLogic;
	import net.play5d.game.obvn.vo.FighterVO;
	import net.play5d.game.obvn.vo.MessionStageVO;
	import net.play5d.game.obvn.vo.MessionVO;
	import net.play5d.game.obvn.vo.SelectVO;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	
	/**
	 * 闯关模型值对象
	 */
	public class MessionModel {
		
		private static var _i:MessionModel;
		
		public var AI_LEVEL:int = 6;
		private var _curMession:MessionVO;
		private var _curStageId:int;
		private var _curStage:MessionStageVO;
		private var _messions:Array;
		
		public static function get I():MessionModel {
			_i ||= new MessionModel();
			
			return _i;
		}
		
		public function initByXML(xml:XML):void {
			_messions = [];
			
			for each(var i:XML in xml.design) {
				var mv:MessionVO = new MessionVO();
				mv.initByXML(i);
				
				_messions.push(mv);
			}
		}
		
		public function getMession(comicType:int, gameMode:int):MessionVO {
			for each(var i:MessionVO in _messions) {
				if (i.comicType == comicType && i.gameMode == gameMode) {
					return i;
				}
			}
			
			return null;
		}
		
		public function getCurrentMessionStage():MessionStageVO {
			return _curStage;
		}
		
		public function initMession():void {
			var fighter:FighterVO = FighterModel.I.getFighter(GameData.I.p1Select.fighter1);
			
			var gameMode:int = GameMode.isTeamMode() ? 0 : 1;
			var mv:MessionVO = getMession(fighter.comicType, gameMode);
			
			_curMession = mv;
			_curStage = mv.stageList[_curStageId];
			
			GameData.I.p2Select ||= new SelectVO();
			
			var fighters:Array = _curStage.getFighters();
			for (var i:int = 0; i < fighters.length; i++) {
				GameData.I.p2Select["fighter" + (i + 1)] = fighters[i];
			}
			GameData.I.p2Select.fuzhu = _curStage.assister;
			GameData.I.selectMap = _curStage.map;
			
			AI_LEVEL = GameData.I.config.AI_level;
			
			trace("P1 :: " + GameData.I.p1Select.toString());
			trace("P2 :: " + GameData.I.p2Select.toString());
		}
		
		public function reset():void {
			_curStageId = 0;
			_curStage = null;
			_curMession = null;
			
			GameData.I.score = 0;
		}
		
		public function messionComplete():void {
			if (missionAllComplete()) {
				trace("关卡全部完成！");
				
				return;
			}
			
			_curStageId++;
			initMession();
			
			if (GameMode.isAcrade()) {
				GameLogic.addScoreByPassMission();
			}
		}
		
		public function missionAllComplete():Boolean {
			return _curStageId >= _curMession.stageList.length - 1;
		}
	}
}
