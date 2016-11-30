package classes
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.*;


	public class GoalAnimation extends Sprite
	{
		
		private var _frame:uint;
		private var goalLabel:TextField;
		private var goalLabelFormat:TextFormat;
		private var fireworks:ColorfulFireworks;
			
		private static var instance:GoalAnimation;
			
		public function GoalAnimation()
		{
			super();
			if ( instance != null ) throw new Error("singleton error");
			initialize();
		}
		public static function getInstance():GoalAnimation{
			if ( instance == null )
			{
				instance = new GoalAnimation();
			}
			return instance;			
		}
		
		private function initialize():void
		{
			goalLabel = new TextField;
			goalLabelFormat = new TextFormat;
			goalLabel.setTextFormat(goalLabelFormat);
			goalLabel.text = "  GOAL !!  ";
			this.addChild(goalLabel);
			goalLabel.visible = false;
			fireworks = new ColorfulFireworks;
			addChild(fireworks);
			
		}
		private function onEnterFrame(e:Event):void
		{
			if (_frame > GameSettingsData.getInstance().numberOfFramesForGoalAnimation ) 
			{
				endGoalAnimation();
				return;
			}
			_frame++;
			goalLabelFormat.size = _frame * 3;
			goalLabel.setTextFormat(goalLabelFormat);
			
			goalLabel.autoSize = TextFieldAutoSize.CENTER;
			goalLabel.background = true;
			goalLabel.backgroundColor = 0xf19441;
			goalLabel.border = true;
			
					
			goalLabelFormat.font = "Verdana";
			goalLabelFormat.color = 0x000000;
		
			//goalLblFormat.size = this.height *.3;
			if ( goalLabelFormat.size < 50 ) 
			{
				goalLabelFormat.size = _frame*10;
			} else
			{
				goalLabelFormat.size = 110 + ( 10 * Math.sin(_frame/3));
			}
			
			
			
			goalLabel.x = (this.parent.width /2) - goalLabel.width/2;
			goalLabel.y = (this.parent.height / 2) - goalLabel.height;
			goalLabel.setTextFormat(goalLabelFormat);			
		}		
		
		private function endGoalAnimation():void
		{
			this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			GameSettingsData.getInstance().goalAnimation = false;			
			goalLabel.visible = false;
			fireworks.stop();
			fireworks.visible = false;
			
		}
		public function play():void
		{
			_frame = 0;
			goalLabel.visible = true;
			this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			fireworks.start();
			fireworks.visible = true;
		}
	}
}