package classes
{
	import flash.display.Shape;
	import flash.filters.GlowFilter;

	public class PassLineIndicator extends Shape
	{
		
		public var normalFilter:GlowFilter;
		public var lineThickness:uint = GameSettingsData.getInstance().soccerBallRadius;
		public function PassLineIndicator()
		{
			normalFilter = new GlowFilter(0xffcc99,1,100,100);	
			super();
		}
		public function draw(passLineInfo:Array):void
		{
			var fromX:Number = passLineInfo[0];
			var fromY:Number = passLineInfo[1];
			var toX:Number = passLineInfo[2];
			var toY:Number = passLineInfo[3];
			
			
			graphics.clear();
			graphics.lineStyle(this.lineThickness,0x00ff00,1);
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