/**
 * 已重建完成
 */
package net.play5d.kyo.display.ui {
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class KyoSimpButton extends Sprite {
		public var btnWidth:Number;
		public var btnHeight:Number;
		
		private var _txt:TextField = new TextField();
		
		public function KyoSimpButton(label:String, width:Number = 50, height:Number = 20) {
			btnWidth = width;
			btnHeight = height;
			
			drawBg([0xFFFFFF, 0xCCCCCC]);
			
			
			var tf:TextFormat = new TextFormat();
			tf.align = TextFormatAlign.CENTER;
			tf.size = 12;
			_txt.defaultTextFormat = tf;
			
			_txt.text = label;
			_txt.width = width;
			_txt.height = _txt.textHeight + 5;
			
			_txt.y = (height - _txt.height) / 2;
			
			addChild(_txt);
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, overHandler);
		}
		
		public function setLabel(label:String):void {
			_txt.text = label;
		}
		
		public function getLabel():String {
			return _txt.text;
		}
		
		public function onClick(fun:Function):void {
			addEventListener(MouseEvent.CLICK, fun);
		}
		
		private function overHandler(e:MouseEvent):void {
			if (e.type == MouseEvent.MOUSE_OVER) {
				drawBg([0xffffff, 0xF2F2F2]);
			}
			else {
				drawBg([0xffffff, 0xcccccc]);
			}
		}
		
		private function drawBg(color:Array):void {
			graphics.lineStyle(1, 0x666666);
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(btnWidth, btnHeight, 180 * 180 / 3.14, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, color, [1, 1], [0, 255], mtx);
			graphics.drawRect(0, 0, btnWidth, btnHeight);
			graphics.endFill();
		}
		
	}
}