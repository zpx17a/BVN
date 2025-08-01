/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.model {
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.fighter.vo.HitVO;
	
	/**
	 * 角色攻击模型
	 */
	public class FighterHitModel {
		
		private var _hitObj:Object = {};
		private var _fighter:IGameSprite;
		
		public function FighterHitModel(fighter:IGameSprite) {
			_fighter = fighter;
		}
		
		public function destory():void {
			_hitObj = null;
			_fighter = null;
		}
		
		public function clear():void {
			_hitObj = {};
		}
		
		public function getHitVO(id:String):HitVO {
			return _hitObj[id];
		}
		
		public function getHitVOLike(likeId:String):Vector.<HitVO> {
			var hv:Vector.<HitVO> = new Vector.<HitVO>();
			
			for (var i:String in _hitObj) {
				if (i.indexOf(likeId) != -1) {
					hv.push(_hitObj[i]);
				}
			}
			
			return hv;
		}
		
		public function getHitVOByDisplayName(name:String):HitVO {
			var hv:HitVO = getHitVO(name);
			if (hv) {
				return hv;
			}
			if (name.indexOf("atm") == -1) {
				return null;
			}
			
			var id:String = name.replace("atm", "");
			return getHitVO(id);
		}
		
		public function addHitVO(id:String, obj:Object):void {
			var hv:HitVO = new HitVO(obj);
			hv.owner = _fighter;
			hv.id = id;
			
			_hitObj[id] = hv;
		}
		
		public function setPowerRate(v:Number):void {
			for each(var i:HitVO in _hitObj) {
				i.powerRate = v;
			}
		}
	}
}
