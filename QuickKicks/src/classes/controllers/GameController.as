package classes.controllers
{
	
	import classes.data.*;
	import classes.views.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.managers.IFocusManagerComponent;
	
	public class GameController extends Sprite 
	{
		
		public var theField:FieldController;
	
			
		
		public function GameController()
		{
			//this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
							
			theField = new FieldController;
			
			addChild(theField);
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