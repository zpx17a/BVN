/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.ctrler.AssetManager;
	import net.play5d.game.obvn.model.FighterModel;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.game.obvn.vo.FighterVO;
	import net.play5d.game.obvn.vo.SelectCharListItemVO;
	
	/**
	 * 选择角色节点
	 */
	public class SelectFighterItem extends EventDispatcher {
		
		public var isAssister:Boolean = false;
		
		public var selectData:SelectCharListItemVO;
		public var fighterData:FighterVO;
		public var ui:MovieClip = ResUtils.I.createDisplayObject(ResUtils.I.select, "slt_item_mc");
//		public var position:Point = new Point();
		
//		private var faceSize:Point = new Point(50, 50);
		private var _listeners:Object = {};
		
		private var _orgFighterData:FighterVO;
		private var _isInMore:Boolean = false;
		
		public function get hasMore():Boolean {
			return selectData.moreFighterID ? true : false;
		}
		
		public function SelectFighterItem(fighterData:FighterVO, selectData:SelectCharListItemVO) {
			this.selectData = selectData;
			_orgFighterData = fighterData;
			
			if (hasMore) {
				var glow:GlowFilter = new GlowFilter(0xFFFF00);
				glow.blurX = glow.blurY = 16;
				glow.quality = BitmapFilterQuality.LOW;
				ui.filters = [glow];
			}
			
			setFighterData(fighterData);
			
			ui.mouseChildren = false;
			ui.buttonMode = true;
		}
		
		public function changeMore():FighterVO {
			if (isAssister || !hasMore) {
				return _orgFighterData;
			}
			
			var retVO:FighterVO = null;
			
			var moreFighterID:String = selectData.moreFighterID;
			var moreFighterData:FighterVO = moreFighterID ? FighterModel.I.getFighter(moreFighterID) : null;
			if (!_isInMore && moreFighterData) {
				retVO = moreFighterData;
				setFighterData(moreFighterData);
			}
			else {
				retVO = _orgFighterData;
				setFighterData(_orgFighterData);
			}
			
			_isInMore = !_isInMore;
			return retVO;
		}
		
		public function setFighterData(fighterData:FighterVO):void {
			this.fighterData = fighterData;
			
			var ct:MovieClip = ui.getChildByName("ct") as MovieClip;
			if (!ct) {
				return;
			}
			
			ct.removeChildren();
			
			var face:DisplayObject = AssetManager.I.getFighterFace(fighterData);
			if (face) {
				ct.addChild(face);
			}
		}
		
		override public function addEventListener(
			type:String, listener:Function,
			useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			if (ui.hasEventListener(type)) {
				return;
			}
			
			ui.addEventListener(type, selfHandler, useCapture, priority, useWeakReference);
			_listeners[type] = listener;
		}
		
		public function removeAllEventListener():void {
			for (var i:String in _listeners) {
				ui.removeEventListener(i, _listeners[i]);
			}
			
			_listeners = {};
		}
		
		private function selfHandler(e:Event):void {
			var listener:Function = _listeners[e.type] as Function;
			if (listener != null) {
				listener(e.type, this);
			}
		}
		
		public function destory():void {
			if (ui) {
				removeAllEventListener();
			}
			if (ui && ui.parent) {
				ui.filters = [];
				
				try {
					ui.parent.removeChild(ui);
				}
				catch (e:Error) {
				}
				
				ui = null;
			}
			
			selectData = null;
			fighterData = null;
			_orgFighterData = null;
		}
	}
}
