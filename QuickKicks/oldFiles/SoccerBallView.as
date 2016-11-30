package classes
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.controls.Alert;

	public class SoccerBallView extends Shape
	{
		private var _data:SoccerBallData;
		private var _redFilter:GlowFilter;
		private var _blueFilter:GlowFilter;
		
		public function SoccerBallView()
		{
			_data = SoccerBallData.getInstance();
			_data.addEventListener(GameEvents.SOCCER_BALL_MOVED, onDataChange);
			_data.addEventListener(GameEvents.CHANGE_POSSESSION,onChangePossession);
			this.addEventListener(MouseEvent.CLICK, displayDebugInfo);
					
			graphics.lineStyle(1,0x808000);
			var colors:Array = [0xf1fff1,0xf1f879,0x515800];
			var alphas:Array = [1,1,1];
			var ratios:Array = [0,128,255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(
				_data.radius*2,
				_data.radius*2,
				45*(Math.PI/180),
				-_data.radius,
				-_data.radius);
			graphics.beginGradientFill(
				GradientType.RADIAL,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
				
			graphics.drawCircle(0,0,_data.radius);
			
			_redFilter = new GlowFilter(0xff0000,1,SoccerBallData.getInstance().radius/2,SoccerBallData.getInstance().radius/2,1);
			_blueFilter = new GlowFilter(0x0000ff,1,SoccerBallData.getInstance().radius/2,SoccerBallData.getInstance().radius/2,1);			
		}
		private function onDataChange(e:Event = null):void
		{
			this.x = _data.xPos;
			this.y = _data.yPos;
		}
		private function onChangePossession(e:GameEvents):void
		{
			if(_data.redPossession)this.filters = [_redFilter];
			if (_data.bluePossession) this.filters = [_blueFilter];
		}
		private function displayDebugInfo(me:MouseEvent):void{
			GameSettingsData.getInstance().paused = true;
			
			var displayText:String;
			
			displayText = "isFree:  " + _data.isFree + "\n";
			displayText += "redPossession:   " + _data.redPossession + "\n";
			displayText += "bluePossesion:   " + _data.bluePossession + "\n";
//			displayText += "gettingBall:   " + _data.gettingBall+ "\n";
//			displayText += "destX:   " + _data.destinationX+ "\n";
//			displayText += "destY:   " + _data.destinationY+ "\n";
//			if (_data.playerMarking ){
//				displayText += "plyrMarkingId:   "+_data.playerMarking.id+ "\n";
//				displayText += "plyrMarkingTeamId:   "+_data.playerMarking.teamId+ "\n";
//			}
//			else{
//				displayText += "plyrMarkingId:   null" + "\n";
//				displayText += "plyrMarkingTeamId:   null"+ "\n";				
//			}
//			displayText += "isControlled:   "+_data.isControlled+ "\n";
//			displayText += "justBeaten:   "+_data.justBeaten+ "\n";
//			displayText += "justPassed:   "+_data.justPassed+ "\n";
//			displayText += "marking:   "+_data.marking + "\n";
//			displayText += "space:   " + _data.space + "\n";
			
			Alert.show(displayText,"esp panel",4,null,
				function(e:Event=null):void{
					GameSettingsData.getInstance().paused = false;
				});
		}
		
	}
}