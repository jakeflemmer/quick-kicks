package classes
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.controls.Alert;

	public class PlayerView extends Sprite
	{
		private var _data:PlayerData;
		private var _radius:Number;
		private var controlledFilter:GlowFilter;
		private var gettingBallFilter:GlowFilter;
		private var redGettingBallFilter:GlowFilter;
		private var receiverFilter:GlowFilter;
		private var generatingKickPowerLevel1:GlowFilter;
		private var generatingKickPowerLevel2:GlowFilter;
		private var generatingKickPowerLevel3:GlowFilter;
		private var generatingKickPowerLevel4:GlowFilter;
		private var justBeatenFilter:GlowFilter;
		private var filtersArray:Array;
		private var frameNo:uint=0;
		private var oldFrameNo:uint=0;
		private var radCalc:RadiansCalculator;
		public var directionIndicator:Sprite = new Sprite();
		
	
	
	
		
		
		public function PlayerView(playerData:PlayerData)
		{
			_data = playerData;
			radCalc = new RadiansCalculator;
		
			_data.addEventListener(GameEvents.PLAYER_DATA_HAD_COLOR_SET, drawPlayer);

			_data.addEventListener(GameEvents.PLAYER_POS_CHANGED,ON_ENTER_FRAME);
			//_data.addEventListener(GameEvents.PLAYER_CONTROL_CHANGE, onPlayerControlChange);
			//_data.addEventListener(GameEvents.PLAYER_GETTING_BALL_CHANGE, onPlayerGettingBallChange);
			//_data.addEventListener(GameEvents.GENERATING_KICK_POWER, onGeneratingKickPower);
			_data.addEventListener(GameEvents.PASS_RECEIVER, onPassReceiver);
			//_data.addEventListener(GameEvents.JUST_PASSED, onJustPassed);
			//_data.addEventListener(GameEvents.GOT_BALL, onGotBall);
			//_data.addEventListener(GameEvents.JUST_BEATEN, onJustBeaten);
			//_data.addEventListener(GameEvents.PLAYER_RECOVERED,onPlayerRecovered);
			
			this.addEventListener(MouseEvent.CLICK, displayDebugInfo);
			
	
			var sizeOfGlow:uint = GameSettingsData.getInstance().playerRadius;
			controlledFilter = new GlowFilter(0xffcc99,1, sizeOfGlow, sizeOfGlow, 3,3);
			redGettingBallFilter = new GlowFilter(0xffcc99,1, sizeOfGlow, sizeOfGlow,2,1);		// here !!
			gettingBallFilter = new GlowFilter(0x99ccff, 1, sizeOfGlow, sizeOfGlow,3,3);
			
		
			justBeatenFilter = new GlowFilter(0x000000,1, sizeOfGlow, sizeOfGlow);		
			receiverFilter = new GlowFilter(0x9999ff,1, _radius, _radius,3,3);
			
			generatingKickPowerLevel1 = new GlowFilter(0xffffcc,1, _radius, _radius*5,2);
			generatingKickPowerLevel2 = new GlowFilter(0xffffcc,1, _radius, _radius*5,3);
			generatingKickPowerLevel3 = new GlowFilter(0xffffcc,1, _radius, _radius*5,4);
			generatingKickPowerLevel4 = new GlowFilter(0xffffcc,1, _radius, _radius*5,5);
		
			filtersArray = new Array();
			filtersArray = [];
			
		}
		
		private function drawPlayer(e:Event = null):void
		{			
			_radius = _data.radius;
			graphics.clear();
			
			if(_data.color == null ) {return;}//throw new Error("color is null") don't worry this get set very early on
					
			var lightSourceAngle:Number = RadiansCalculator.calc(0 - this.x, 500- this.y);
			lightSourceAngle += Math.PI;
			_data.lightSourceAngle = lightSourceAngle;
			
			// Draw Player
			graphics.lineStyle(1);
			var colors:Array = _data.color;
			var alphas:Array = [1,1];
			var ratios:Array = [0,255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_radius*2,
				_radius*2,
				lightSourceAngle,
				-_radius,
				-_radius);
			graphics.beginGradientFill(
				GradientType.RADIAL,
				colors,
				alphas,
				ratios,
				matrix,
				null,
				null,
				-0.5);
			
			graphics.drawCircle(0,0,_radius);
			
			drawDirectionIndicator();
		
			this.x = _data.xPos;
			this.y = _data.yPos;			
		}
		private function drawDirectionIndicator():void{
			
			with ( directionIndicator)
			{
				graphics.lineStyle(10,0xff0000,.3);
				graphics.moveTo(0,0);
				graphics.lineTo(_data.radius * 5,0 );
			}
			this.addChild(directionIndicator);
		}
		
		private function ON_ENTER_FRAME(e:Event):void
		{		
			this.x = _data.xPos;
			this.y = _data.yPos;
			
			if ( _data.isControlled )
			{
				directionIndicator.visible = true;
				directionIndicator.rotation = _data.direction;
			}else{
				directionIndicator.visible = false;
			}
			this.rotation = (_data.direction * 180)/Math.PI;
						
			var lightSourceAngle:Number = RadiansCalculator.calc(0 - this.x, 500- this.y);
			lightSourceAngle += Math.PI;
			_data.lightSourceAngle = lightSourceAngle;			 
			
			frameNo ++;
				
			var sizeOfGlow:uint = _data.hitTestCaptureDistance;
			controlledFilter = new GlowFilter(0xffcc99,1, sizeOfGlow, sizeOfGlow, 3,3);
			redGettingBallFilter = new GlowFilter(0xffcc99,1, sizeOfGlow, sizeOfGlow,2,1);		// here !!
			gettingBallFilter = new GlowFilter(0x99ccff, 1, sizeOfGlow, sizeOfGlow,3,3);
			
				if ( _data.hasBall || _data.gettingBall || _data.isControlled || _data.passReceiver )
				{
					if (_data.teamId == "red") this.filters = [redGettingBallFilter];
					
					if (_data.teamId == "blue") this.filters = [gettingBallFilter];
				} 
				else if ( _data.justBeaten || _data.justPassed )
				{
					this.filters = [justBeatenFilter];
				}
				else
				{
					this.filters = [];
				}
		
			//traceDebugInfo();
		}
		private function displayDebugInfo(e:MouseEvent):void{
			
			GameSettingsData.getInstance().paused = true;
			
			var displayText:String;
			
			displayText = "id:  " +_data.id + "\n";
			displayText += "zoneNum:   " + _data.zone.zoneNum+ "\n";
			displayText += "hasBall:   " + _data.hasBall+ "\n";
			displayText += "gettingBall:   " + _data.gettingBall+ "\n";
			displayText += "destX:   " + _data.destinationX+ "\n";
			displayText += "destY:   " + _data.destinationY+ "\n";
			if (_data.playerMarking ){
				displayText += "plyrMarkingId:   "+_data.playerMarking.id+ "\n";
				displayText += "plyrMarkingTeamId:   "+_data.playerMarking.teamId+ "\n";
			}
			else{
				displayText += "plyrMarkingId:   null" + "\n";
				displayText += "plyrMarkingTeamId:   null"+ "\n";				
			}
			displayText += "isControlled:   "+_data.isControlled+ "\n";
			displayText += "justBeaten:   "+_data.justBeaten+ "\n";
			displayText += "justPassed:   "+_data.justPassed+ "\n";
			displayText += "marking:   "+_data.marking + "\n";
			displayText += "space:   " + _data.space + "\n";
			
			Alert.show(displayText,"esp panel",4,null,
				function(e:Event=null):void{
					GameSettingsData.getInstance().paused = false;
				});
		}
		private function traceDebugInfo():void{
			
			//GameSettingsData.getInstance().paused = true;
			
			if (_data.id == "player1" && _data.teamId == "red")
			{
			var displayText:String;
			
			displayText = "id:  " +_data.id + "\n";
			displayText += "hasBall:   " + _data.hasBall+ "\n";
			displayText += "gettingBall:   " + _data.gettingBall+ "\n";
			displayText += "passReceiver:   " + _data.passReceiver+ "\n";
			displayText += "destX:   " + _data.destinationX+ "\n";
			displayText += "destY:   " + _data.destinationY+ "\n";
			displayText += "justPassed:   "+_data.justPassed+ "\n";
			displayText += "marking:   "+_data.marking + "\n";
			displayText += "zoneNum:   " + _data.zone.zoneNum+ "\n";
			if (_data.playerMarking ){
				displayText += "plyrMarkingId:   "+_data.playerMarking.id+ "\n";
				displayText += "plyrMarkingTeamId:   "+_data.playerMarking.teamId+ "\n";
			}
			else{
				displayText += "plyrMarkingId:   null" + "\n";
				displayText += "plyrMarkingTeamId:   null"+ "\n";				
			}
			displayText += "isControlled:   "+_data.isControlled+ "\n";
			displayText += "justBeaten:   "+_data.justBeaten+ "\n";
			displayText += "space:   " + _data.space + "\n";
			
			trace(displayText);
			}
		}
		private function onPlayerControlChange(e:Event):void
		{
			//var controlledFilterNum:int = filtersArray.indexOf(controlledFilter);

			//if ( ! _data.isControlled && controlledFilterNum == -1) return;
			//if ( _data.isControlled && controlledFilterNum == -1) filtersArray.push(controlledFilter);
			//if ( ! _data.isControlled && controlledFilterNum != -1) filtersArray.splice( controlledFilterNum , 1 ); 
//			if ( _data.hasBall || _data.gettingBall || _data.isControlled )
//				{
//					if (_data.teamId == "red") this.filters = [redGettingBallFilter];
//					if (_data.teamId == "blue") this.filters = [gettingBallFilter];
//				} else
//				{
//					this.filters = [];
//				}
			
		}
		private function onPlayerGettingBallChange(e:Event):void
		{
			//var gettingBallFilterNum:int = filtersArray.indexOf(gettingBallFilter);

			//if ( ! _data.gettingBall && gettingBallFilterNum == -1) return;
			//if ( _data.gettingBall && gettingBallFilterNum == -1) filtersArray.push(gettingBallFilter);
			//if ( ! _data.gettingBall && gettingBallFilterNum != -1) filtersArray.splice( gettingBallFilterNum , 1 ); 				
			
//			if ( _data.hasBall || _data.gettingBall || _data.isControlled )
//				{
//					if (_data.teamId == "red") this.filters = [redGettingBallFilter];
//					if (_data.teamId == "blue") this.filters = [gettingBallFilter];
//				} else
//				{
//					this.filters = [];
//				}
		}
		private function onGotBall(e:Event):void
		{
			/*var receiverFilterNum:int = filtersArray.indexOf(receiverFilter);
			if ( receiverFilterNum == -1 ) {
				return;
			} else {
				filtersArray.splice( receiverFilterNum , 1 );
			}*/
			//this.filters = filtersArray;
//			if ( _data.hasBall )
//			{
//				if (_data.teamId == "red") filtersArray = [redGettingBallFilter];
//				if (_data.teamId == "blue") filtersArray=[gettingBallFilter];						
//				this.filters = filtersArray;
//			} else {
//				this.filters = [];
//			}
			
			
		}
		
		
		
		private function onGeneratingKickPower(e:Event):void
		{	
//			if (_data.kickPower <=10 ) filtersArray = [generatingKickPowerLevel1];				
//			
//			if (_data.kickPower >= 10 && _data.kickPower <= 20) filtersArray = [generatingKickPowerLevel2];
//			
//			if (_data.kickPower >= 20 && _data.kickPower <= 30) filtersArray = [generatingKickPowerLevel3];
//			
//			if (_data.kickPower >= 30 ) filtersArray = [generatingKickPowerLevel4];
						
			//this.filters = filtersArray;		 
		}
		private function onJustPassed(e:Event):void
		{
			//filtersArray = [];
		}
		private function onPassReceiver(e:Event):void
		{
//			if (_data.passReceiver) {  // add receiver filter
//				 filtersArray.push(receiverFilter);
//			} else    // or remove it 
//			{	
//				var receiverFilterNum:int = filtersArray.indexOf(receiverFilter);
//				if ( receiverFilterNum == -1 ) {
//					return;
//				} else {
//					filtersArray.splice( receiverFilterNum , 1 );
//				}				
//			}			
//			this.filters = filtersArray;			
		}
		private function onJustBeaten(e:GameEvents):void
		{
			//filtersArray = [justBeatenFilter];
			//this.filters = filtersArray;
		}
		private function onPlayerRecovered(e:GameEvents):void
		{
			//filtersArray = [];
			//this.filters = filtersArray;			
		}
	}// close class
}// close package