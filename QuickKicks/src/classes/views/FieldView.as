package classes.views
{
	import flash.display.Sprite;
	
	public class FieldView extends Sprite
	{
		
		public function FieldView()
		{
			super();
			var grass:Grass = new Grass();
			var goalsAndWalls:GoalsAndWalls = new GoalsAndWalls();
			goalsAndWalls.draw();
			addChild(grass);
			addChild(goalsAndWalls);
		}
		
		
	}
}