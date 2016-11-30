package classes.views
{
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	
	import mx.states.AddChild;

	public class PassLineIndicator extends Shape
	{
		
		public var normalFilter:GlowFilter;
		
		public function PassLineIndicator()
		{
			normalFilter = new GlowFilter(0xffcc99,1,100,100);	
			super();
		}
		public function draw(fromX:Number,fromY:Number,toX:Number,toY:Number):void
		{
			graphics.clear();
			graphics.lineStyle(20,0x00ff00,.3);
			graphics.moveTo(fromX, fromY);
			graphics.lineTo(toX, toY);
			this.filters = [normalFilter];
			
//			setFilter();
		}
		public function clear():void
		{
			graphics.clear();
		}
		public function setFilter():void
		{
		}
		
	}
}