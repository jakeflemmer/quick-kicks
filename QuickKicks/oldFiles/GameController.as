package classes
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class GameController extends Sprite 
	{
		
		public var theField:FieldController;
	
			
		
		public function GameController()
		{
			//this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
							
			theField = FieldController.getInstance();
			
			addChild(theField);
			
			theField.startField();
		}

//   _______________________________________________________   ON ENTER FRAME     ____________________________________

		private function onEnterFrame(event:Event):void
		{
								
		}
		
		public function reset():void
		{
			theField.resetEverything();
		}
	}
}