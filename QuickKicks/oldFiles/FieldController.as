package classes
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.*;
	
	public class FieldController extends Sprite
	{
		public var ball:SoccerBallController;
		public var goalsAndWalls:GoalsAndWalls = new GoalsAndWalls();
		public var redTeam:HumanTeamController;	
		public var blueTeam:CPUTeamController;		
		public var maxDistanceFromGoal:Number; 
				
		private var _data:FieldData;
		private var goalAnimationFrame:uint = 0;		
		private var radCalc:RadiansCalculator;			
		private var goalAnimation:GoalAnimation = GoalAnimation.getInstance();	
		
		private static var instance:FieldController;
				
		public function FieldController() 	
		{
			if ( instance != null )
			{
				throw new Error("field controller cannot be instantiated directly");
			}						
		}
		public static function getInstance():FieldController{
			if ( instance == null)
			{
				instance = new FieldController();
			}
			return instance;
		}		
		public function startField():void
		{
			instantiateVariables();
			
			setVariables();	
			
			addAllChildren();
			
			initEventListeners();		
			
			setDefaultMarkedMen();
			
			placeSoccerBallInRedPossession();			
		}
		private function placeSoccerBallInRedPossession():void{
			
			sbd.xPos = redTeam.keeper.data.xPos + redTeam.keeper.data.radius + 5;
			sbd.yPos = redTeam.keeper.data.yPos;
			sbd.redPossession = true;			
		}		
		private function instantiateVariables():void
		{
			ball = SoccerBallController.getInstance();
			_data = FieldData.getInstance();
					
			redTeam = new HumanTeamController();
			blueTeam = new CPUTeamController();
			radCalc = new RadiansCalculator();
			//	goalsAndWalls = new GoalsAndWalls();
			//goalAnimation = new GoalAnimation();			
			calculateMaxDistanceFromGoal();			
		}
		private function setVariables():void
		{
			redTeam.data.id = "red";
			blueTeam.data.id = "blue";
			setTeamColors();			
		}	
		
		private function setTeamColors():void{
			for ( var i:uint=0; i< rpda.length;i++)
			{
				rpda[i].color = gsd.redTeamColor;
				bpda[i].color = gsd.blueTeamColor;
			}
		}

		private function addAllChildren():void
		{
			goalsAndWalls.draw();			
			addChild(goalsAndWalls);
			addChild(redTeam);
			addChild(blueTeam);
			addChild(ball);		
			//addChild(goalAnimation);
		}
		private function initEventListeners():void
		{
			this.addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);			
			GameSettingsData.getInstance().addEventListener(GameEvents.NEW_GAME,onNewGame);
			GameSettingsData.getInstance().addEventListener(GameEvents.GOAL_ANIMATION_OVER,onGoalAnimationEnd);
			sbd.addEventListener(GameEvents.CHANGE_POSSESSION, onChangePossession);
			sbd.addEventListener(GameEvents.BALL_NOW_FREE,onBallNowFree);
			KeyboardControls.getInstance().addEventListener(GameEvents.PASS_NOW, onKeyboardPassNow);			
		}		
		private function goalReset():void
		{
			redTeam.goalReset();
			blueTeam.goalReset();
			soccerBallResetAllProperties();	
		}
		private function soccerBallResetAllProperties():void
		{
			SoccerBallData.getInstance().speed = 0;
			SoccerBallData.getInstance().direction = 0;
			SoccerBallData.getInstance().isFree = true;
			SoccerBallData.getInstance().justKicked = false;
			SoccerBallData.getInstance().redPossession = false;
			SoccerBallData.getInstance().bluePossession = false;						
		}		
		
		//--------------------------------------------------------------------------------------------------
		//  ON ENTER FRAME
		//--------------------------------------------------------------------------------------------------
		private function ON_ENTER_FRAME(e:Event):void
		{				
			if (gsd.replayPlaying)
			{
				_data.frameCounter++;
				if ( _data.frameCounter >= _data.replayFrameCounter )
				{					
					gsd.replayPlaying = false;
					this.stage.frameRate *= 2;
					goalReset();
					giveSoccerBallToKeeperOfTeamJustScoredOn(_data.teamJustScoredOn);
				}
				else
				{
					showReplayMovie();
				}
				return;
			}			
			hitTestGoals();
		
			hitTestPlayers(); // this function also calulates each player's space
			
			hitTestBall();						
			
			calculatePressure();
			
			checkIfKeepersAreOnTheirLines();
			
			storeReplayData();
			
			clearPassNowCache();
		}		
		
		//--------------------------------------------------------------------------------------------------
		//  PUBLIC FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		
		private function showReplayMovie():void{
			displaySnapShot(theSnapShotOfFrame( _data.replayFrameCounter-_data.frameCounter));
		}
		private function displaySnapShot(s:FieldSnapshot):void{
			
			var i :uint;
			sbd.xPos = s.sbdXpos;
			sbd.yPos = s.sbdYpos;
			redTeam.keeper.data.xPos = s.rkx;
			redTeam.keeper.data.yPos = s.rky;
			redTeam.keeper.data.hasBall = s.rkHasBall;
			blueTeam.keeper.data.xPos = s.bkx;
			blueTeam.keeper.data.yPos = s.bky;
			blueTeam.keeper.data.hasBall = s.bkHasBall;
			
			for ( i=1; i < gsd.numberOfPlayers; i++)
			{
				(redTeam["player" + i] as AbstractPlayerController).data.xPos = s["rp"+i+"x"];
				(redTeam["player" + i] as AbstractPlayerController).data.yPos = s["rp"+i+"y"];
				(redTeam["player" + i] as AbstractPlayerController).data.hasBall = s["rp"+i+"HasBall"];
				
				(blueTeam["player" + i] as AbstractPlayerController).data.xPos = s["bp"+i+"x"];
				(blueTeam["player" + i] as AbstractPlayerController).data.yPos = s["bp"+i+"y"];
				(blueTeam["player" + i] as AbstractPlayerController).data.hasBall = s["bp"+i+"HasBall"];
			}
		}
		private function theSnapShotOfFrame(f:uint):FieldSnapshot{						
						
			var bookmark:uint;
			var totalLength:uint;
			var pos:uint;
			
			if ( _data.replayArrayA.length == 50 )
			{
				totalLength = 49 +_data.replayArrayB.length;
				pos = totalLength - f;
				if (pos <=49)
				{
					return _data.replayArrayA[pos];
				}
				else
				{
					return _data.replayArrayB[pos-50];
				}				
			}
			else if (_data.replayArrayB.length == 50 )
			{
				totalLength = 49 +_data.replayArrayA.length;
				pos = totalLength - f;
				if (pos <=49)
				{
					return _data.replayArrayB[pos];
				}
				else
				{
					return _data.replayArrayA[pos-50];
				}
			}
			else if (_data.replayArrayA.length > f )
			{
				totalLength = _data.replayArrayA.length;
				return _data.replayArrayA[totalLength - f];
			}
			
			else
			{
				throw new Error("less than 50 frames");
				return null;
			}			
		}
		public function openPass(teamId:String):Boolean{
						
			// plan :
			// take the pwbd
			// take the pass angle
			// get the distance to pass receiver
			
			// loop:
			// every player of other team ( interceptor )
			//		get their angle
			//		get their distance
			//		get the difference in angle between interceptor and passReceiver 		
			
			// calculate:
			// 		is the difference in angle * the distance greater than the radius of interceptor?			
			
			var pwbd:PlayerData;
			var op:Boolean = true;	//open pass
			
			if ( teamId == "red" )
			{
				pwbd = redTeam.pwbd;				
			}
			else 
			{
				pwbd = blueTeam.pwbd;
				
			}	
			
			var len:int = redTeam.pda.length;
			for ( var i:uint=0; i < len ; i++)
			{
				var interceptor:PlayerData = ( teamId == "red" ? blueTeam.pda[i] : redTeam.pda[i] );
				var ia:Number = RadiansCalculator.calc( interceptor.xPos - pwbd.xPos, interceptor.yPos - pwbd.yPos ); // interceptor angle
				var difference:Number = Math.abs( pwbd.autoPassAngle - ia );
				var distance:Number = Calculator.instance.distanceBetweenPlayers(pwbd,interceptor);
				
				//exclusions
				// interceptor is further away than pass receiver
				// difference is greater than PI
				if ( pwbd.teamMateAimingPassAt )
				{
					var dtpr:Number = Calculator.instance.distanceBetweenPlayers(pwbd, pwbd.teamMateAimingPassAt);
					if ( dtpr < distance) continue; 
				}
				if ( difference > Math.PI ) continue;				
				
				
				// is the difference in angle * the distance greater than the radius of interceptor?
			 	 
			 	// so cos ( difference ) = adjacent ( what we are solving for ) / hypotenuse ( distance );
			 	// cos( difference ) = x / distance;
			 	// distance * ( cose ( difference ) = x;
			 	// x = ( cos ( differnece )) * distance;
			 	
			 	var x:Number = Math.abs( Math.sin(difference) * distance );
			 	if ( x < gsd.playerRadius * 2 )
			 	{
			 		op = false;
				}				 	
			}
			return op;
		}

		
		//--------------------------------------------------------------------------------------------------
		//  PRIVATE FUNCTIONS
		//--------------------------------------------------------------------------------------------------
					
		private function storeReplayData():void{
			
			if ( _data.goalAnimationPlaying ) return;
			
			var snapshot:FieldSnapshot = new FieldSnapshot();
			snapshot.sbdXpos = sbd.xPos;
			snapshot.sbdYpos = sbd.yPos;
			snapshot.rkx = redTeam.keeper.data.xPos;
			snapshot.rky = redTeam.keeper.data.yPos;
			snapshot.rkHasBall = redTeam.keeper.data.hasBall;
			snapshot.bkx = blueTeam.keeper.data.xPos;
			snapshot.bky = blueTeam.keeper.data.yPos;
			snapshot.bkHasBall = blueTeam.keeper.data.hasBall;
			
			var i :uint;
			for ( i =1 ; i < gsd.numberOfPlayers; i++)
			{
				snapshot["rp"+i+"x"] = (redTeam["player"+i] as AbstractPlayerController).data.xPos;
				snapshot["rp"+i+"y"] = (redTeam["player"+i] as AbstractPlayerController).data.yPos;
				snapshot["rp"+i+"HasBall"] = (redTeam["player"+i] as AbstractPlayerController).data.hasBall;
				snapshot["bp"+i+"x"] = (blueTeam["player"+i] as AbstractPlayerController).data.xPos;
				snapshot["bp"+i+"y"] = (blueTeam["player"+i] as AbstractPlayerController).data.yPos;
				snapshot["bp"+i+"HasBall"] = (blueTeam["player"+i] as AbstractPlayerController).data.hasBall;
			} 
			if ( _data.replayArrayA.length < 50 )
			{
				_data.replayArrayA.push(snapshot);
				if (_data.replayArrayA.length == 50 )
				{
					_data.replayArrayB = new Array();
				}
			}
			else 
			{
				_data.replayArrayB.push(snapshot);
				if (_data.replayArrayB.length == 50 )
				{
					_data.replayArrayA = new Array();
				}				
			}
			
			
		}
		private function clearPassNowCache():void{
			
			if ( _data.frameCounter >= _data.clearPassCacheFrameNumber )
			{
				KeyboardControls.getInstance().passBall = false;
			}
			
		}
		private function checkIfKeepersAreOnTheirLines():void
		{
			// red keeper			
			if ( redTeam.keeper.data.yPos > 500  ) {
				_data.redKeeperOnHisLine = "left";			
			} else {			
				_data.redKeeperOnHisLine = "right";
			}			
			
			// blue keeper
			if ( blueTeam.keeper.data.yPos > 500 ) {
				_data.blueKeeperOnHisLine = "left";
			} else {
				_data.blueKeeperOnHisLine = "right";
			}
		}
		public function setDefaultMarkedMen():void
		{
			cpda = MarkingManager.getInstance().setDefaultPlayersToMark(rpda,bpda);
		}
		private function hitTestGoals():void
		{			
			// blue's goal
			if (SoccerBallData.getInstance().xPos >= ( 1450 - (gsd.soccerBallRadius*1.5) )  )
			{
				if ( SoccerBallData.getInstance().yPos >= 300 + gsd.soccerBallRadius && SoccerBallData.getInstance().yPos <= 700 - gsd.soccerBallRadius )
				{							
					trace("ball hit goal");								
					if ( ! blueTeam.keeper.data.hasBall ) 
					{
						score("red");
					}				
				} 
			}
			// red's goal
			if (SoccerBallData.getInstance().xPos <= ( 50 + (gsd.soccerBallRadius *1.5) ) )
			{
				if ( SoccerBallData.getInstance().yPos >= 300 + gsd.soccerBallRadius && SoccerBallData.getInstance().yPos <= 700 - gsd.soccerBallRadius )
				{			
					trace("ball hit goal");											
					if ( ! redTeam.keeper.data.hasBall ) 
					{
						score("blue");						
					}					
				} 
			}
		}
		
		private function score(team:String):void
		{
			switch (team){
				case "red":				
					//goalReset();
					_data.teamJustScoredOn = "blue";
					giveSoccerBallToKeeperOfTeamJustScoredOn("blue");
					ball.visible = false;
					GameSettingsData.getInstance().redScore ++;
					GameSettingsData.getInstance().goalAnimation = true;
					goalAnimation.play();
					_data.goalAnimationPlaying = true;
					break;
				case "blue":				
					//goalReset();
					giveSoccerBallToKeeperOfTeamJustScoredOn("red");
					_data.teamJustScoredOn = "red";						
					ball.visible = false;
					GameSettingsData.getInstance().blueScore ++;
					GameSettingsData.getInstance().goalAnimation = true;
					goalAnimation.play(); // dispatches event -- onGoalAnimationEnd
					_data.goalAnimationPlaying = true;
					break;					
			}
		}	
		private function giveSoccerBallToKeeperOfTeamJustScoredOn(teamId:String):void{
			
			sbd.xPos = (teamId == "red" ? redTeam.keeper.data.xPos + redTeam.keeper.data.radius + 5 : 
											blueTeam.keeper.data.xPos - redTeam.keeper.data.radius - 5);
			sbd.yPos = (teamId == "red" ? redTeam.keeper.data.yPos:	blueTeam.keeper.data.yPos);
			sbd.redPossession = (teamId == "red" ? true : false );
			sbd.bluePossession = (teamId == "blue" ? true : false );	
		}
		private function onGoalAnimationEnd(e:GameEvents):void
		{
			GameSettingsData.getInstance().goalAnimation = false;
			_data.goalAnimationPlaying = false;			
			this.stage.frameRate /= 2;
			//redTeam.reset();
			//blueTeam.reset();
			ball.visible = true;			
			goalReplay();
		}
		
//  ----------------------------------------------------------------------------------------------------
//     HIT TEST PLAYERS
//  ----------------------------------------------------------------------------------------------------

	private function goalReplay():void{
		gsd.replayPlaying = true;		
		_data.replayFrameCounter = _data.frameCounter + gsd.numberOfFramesOfInstantReplay;
	}
	private function hitTestPlayers():void
	{			
		//okay we need to maintain player's spherical integrity
		//so if they are colliding then FIRST seperate them further apart then collision distance!
		var collisionDistance:Number = GameSettingsData.getInstance().collisionDistance;				 
		var plyrA:PlayerData; var plyrB:PlayerData;
		var i:uint=0; var j:uint;	
		
		resetPlayersSpaceAndClosestDefender();
		
		for (i = 0; i < cpda.length-1; i++)
		{			
			plyrA = cpda[i];
			
			for (j = i+1 ;j < cpda.length; j++)
			{
				plyrB = cpda[j];
				
					var distBetweenAandB:Number = calc.distanceBetweenPlayers(plyrA,plyrB); 
					if ( plyrA.space > distBetweenAandB && plyrA.teamId != plyrB.teamId )
					{
						plyrA.space = distBetweenAandB;
						plyrA.closestDefender = plyrB;	
					}					 	
					
					if ( distBetweenAandB <= collisionDistance )
					{						
						calc.doCollision(plyrA,plyrB);
					}
			}
		}
	}
	private function hitTestBall():void{
		// here our main purpose it to maintain the ball's spherical integrity
		// in fact we dont even doCollision for the ball!!
		var i:uint=0; var j:uint;
		var deltaX:Number; var deltaY:Number;
		for ( i=0;i<cpda.length;i++)
		{
			deltaX = SoccerBallData.getInstance().xPos - (cpda[i] as PlayerData).xPos;
			deltaY = SoccerBallData.getInstance().yPos - (cpda[i] as PlayerData).yPos;
			if ( calc.pythagoreanDistance(deltaX,deltaY) < GameSettingsData.getInstance().preventBallOverlapDistance)
			{
				//ball is overlapping someone !
				calc.maintainBallsSphericalIntegrity(cpda[i]as PlayerData);
			}
		}
	}
	
	
//  ____________________________________________________________________________________________________________________
//  __________________________________________  player A HIT player B    _______________________________________________
//  ____________________________________________________________________________________________________________________



//  ______________________________________________________________________________________________________________________

	
	
	private function calculatePressure():void
	{
		// TODO this whole function is pretty useless in present incarnation because it doesn't set pressureToPass = true;
		
		if ( SoccerBallData.getInstance().isFree ) return;
		
		var pressureThresholdDistance:Number = GameSettingsData.getInstance().pressureThresholdDistance;
		var deltaX:Number; var deltaY:Number;
		var ballX:Number = SoccerBallData.getInstance().xPos; var ballY:Number = SoccerBallData.getInstance().yPos;
		var totalDistance:Number;
		var mostAmountOfSpace:Number = 0;
		var i :int; var j: int; 
		
		
		
		//  CALCULATE RED PLAYERS SPACE ( red pwb space from closest blue player )
		if ( SoccerBallData.getInstance().redPossession )  //  ______  RED		
		{
			if ( redTeam.data.playerWithBallData == null ) return;			
			
			redTeam.data.playerWithBallData.space = 10000;
			
			for ( i=0; i < bpda.length; i++)   
			{
				//if ( ! _bluePlayersData[i].justBeaten )
				//{				
				    deltaX = Math.abs( ballX - bpda[i].xPos );
					deltaY = Math.abs( ballY - bpda[i].yPos );
					totalDistance = theTotalDistance(deltaX,deltaY);
					
					if ( totalDistance < redTeam.data.playerWithBallData.space)	
						redTeam.data.playerWithBallData.space = totalDistance;					
				
					if ( redTeam.data.playerWithBallData.isKeeper ) redTeam.data.pressureToPass = true;
					//TODO ??
					if ( totalDistance <= pressureThresholdDistance && bpda[i] != redTeam.data.playerWithBallData.playerMarking)
					{
						//redTeam.data.pressureToPass = true;
					} 				
				//}
			}
			mostAmountOfSpace = 0;
			// TODO this playerWithMostSpace is a good idea but not implemented yet
			for ( i=0; i < rpda.length; i++)
			{
				if ( rpda[i].space > mostAmountOfSpace )
					redTeam.data.playerWithMostSpace = rpda[i];
			}
		}
		
		
		
		//CALCULATE BLUE PLAYERS SPACE
		if ( SoccerBallData.getInstance().bluePossession )   //  ________   BLUE
		{
			if ( blueTeam.data.playerWithBallData == null ) return;	
			
			blueTeam.data.playerWithBallData.space = 10000;

			for ( i=0; i < bpda.length; i++)   
			{
				//if ( ! _redPlayersData[i].justBeaten )
				//{
					deltaX = Math.abs( ballX - rpda[i].xPos );
					deltaY = Math.abs( ballY - rpda[i].yPos );
					totalDistance = theTotalDistance(deltaX,deltaY); // the distance of each red player to the ball
					
					
					if ( totalDistance < blueTeam.data.playerWithBallData.space)
						blueTeam.data.playerWithBallData.space = totalDistance;
					
					
					
					if ( blueTeam.data.playerWithBallData.isKeeper ) blueTeam.data.pressureToPass = true;
					if ( totalDistance <= pressureThresholdDistance && rpda[i] != blueTeam.data.playerWithBallData.playerMarking)
					{
						//blueTeam.data.pressureToPass = true;
					}				
				//}
			}
			mostAmountOfSpace = 0;
//			for ( i=0; i < _bluePlayersData.length; i++)
//			{
//				if ( _bluePlayersData[i].space > mostAmountOfSpace )
//					blueTeam.data.playerWithMostSpace = _bluePlayersData[i];
//			}
		}
	}		
	
	
	private function calculateMaxDistanceFromGoal():void
	{
		var xDistance:Number = 1500;
		var yDistance:Number = 550;
		var totalDistance:Number = Math.sqrt( (xDistance * xDistance) + (yDistance * yDistance) );
		maxDistanceFromGoal = totalDistance;
	}
	
	private function playersDistanceFromGoal(plyr:PlayerData):Number
	{			
		var yDistToGoal:Number;
		var xDistToGoal:Number;

		if (plyr.teamId == "red")
		{
			xDistToGoal = 1450 - plyr.xPos;			
		}else{
		 	xDistToGoal = plyr.xPos - 50;			
		}
		
		if (plyr.yPos > 550 && plyr.yPos < 950){ 
			yDistToGoal = 0;	
		} else if ( plyr.yPos < 550){
			yDistToGoal = 550 - plyr.yPos;
		} else if ( plyr.yPos > 950 ){
			yDistToGoal = plyr.yPos - 950;
		}	
		
		return theTotalDistance(xDistToGoal,yDistToGoal);		
	}
	
	private function theTotalDistance(xDist:Number,yDist:Number):Number
	{
		return Math.sqrt( (xDist*xDist) + (yDist * yDist) );	
	}
	
	private function calculateBestPass():void{
		
		var tacticalScore:Number;
		//tacticalScore
		
		
	}
	public function resetEverything():void
	{				
		redTeam.resetEverything();			
		blueTeam.resetEverything();
		cpda = MarkingManager.getInstance().resetDefaultMarking(cpda);			
		soccerBallResetAllProperties();			
	}
	
	private function resetPlayersSpaceAndClosestDefender():void{
		for ( var i:uint=0; i < cpda.length; i++)
		{
			(cpda[i] as PlayerData).space = 10000;
			(cpda[i] as PlayerData).closestDefender = null;
		}
	}
	
	// --------------------------------------------------------------------------------------------------
	//  EVENT HANDLERS
	// --------------------------------------------------------------------------------------------------
	
	private function onBallNowFree(e:GameEvents):void
		{
			redTeam.ballNowFree();
			redTeam.data.pressureToPass = false;
			
			blueTeam.ballNowFree();
			blueTeam.data.pressureToPass = false;
		}	
		
		private function onNewGame(e:GameEvents):void
		{
			resetEverything();
			placeSoccerBallInRedPossession();
		}	
		
		private function onChangePossession(e:GameEvents):void
		{			
			if ( SoccerBallData.getInstance().redPossession ) 
			{
				blueTeam.lostPossession();
				redTeam.wonPossession();			
			}
			if ( SoccerBallData.getInstance().bluePossession )
			{
				redTeam.lostPossession();
				blueTeam.wonPossession();				
			}					
		}
		
		private function onKeyboardPassNow(ge:GameEvents):void{
			_data.clearPassCacheFrameNumber = _data.frameCounter + 10;			
		}		
	
	
	// --------------------------------------------------------------------------------------------------
	//  GETTERS & SETTERS
	// --------------------------------------------------------------------------------------------------
	
	private function get cpda():Array{
		var c:Array = new Array();  // combined player data array
		var i:uint=0;		
		for (i=0;i < redTeam.playersArray.length; i++)
		{
			c.push( (redTeam.playersArray[i] as HumanPlayerController).data );
		}
		for (i=0;i < blueTeam.playersArray.length; i++)
		{
			c.push( (blueTeam.playersArray[i] as CPUPlayerController).data );
		}		
		return c;		
	}	
	private function set cpda(value:Array):void{
		var i:uint;
		var j:uint =0;
		for ( i=0;i<value.length;i++)
		{
			
			if ( (value[i] as PlayerData).teamId == "red" )
			{
				if ( i == 0)
				{
					redTeam.keeper.data = ( value[i] as PlayerData );
				} else {
					
					(redTeam["player"+i.toString()] as AbstractPlayerController).data = ( value[i] as PlayerData);
				}
			}else{
				if ( j == 0)
				{
					blueTeam.keeper.data = ( value[i] as PlayerData );
				}else{
				
					(blueTeam["player"+j.toString()] as AbstractPlayerController).data = ( value[i] as PlayerData);
				}
				j++;
			}
		}
	}	
	private function get rpda():Array{
		var r:Array = new Array(); var i :uint;
		for (i=0;i<redTeam.playersArray.length; i++)
		{
			r.push( (redTeam.playersArray[i] as HumanPlayerController).data );
		}
		return r;
	}	
	private function get bpda():Array{
		var b:Array = new Array();var i :uint;
		for (i=0;i < blueTeam.playersArray.length; i++)
		{
			b.push( (blueTeam.playersArray[i] as CPUPlayerController).data );
		}
		return b;
	}	
	private function set rpda(value:Array):void{
		redTeam.keeper.data = value[0] as PlayerData;
		for ( var i:uint=1 ; i< value.length; i++)
		{
			(redTeam["player"+i.toString()] as AbstractPlayerController).data = (value[i] as PlayerData);
		}
	}	
	private function set bpda(value:Array):void{
		blueTeam.keeper.data = value[0] as PlayerData;
		for ( var i:uint=1 ; i< value.length; i++)
		{
			(blueTeam["player"+i.toString()] as AbstractPlayerController).data = (value[i] as PlayerData);
		}
	}	
	private function get calc():Calculator{
			return Calculator.instance;
	}	
	private function get gsd():GameSettingsData{
		return GameSettingsData.getInstance();
	}
	private function get sbd():SoccerBallData{
		return SoccerBallData.getInstance();
	}
	
	//------------------------------------------------------------------------------------------------------------
	//------------------------------------------------------------------------------------------------------------
	//  OLD CODE
	
	//	private function AHitBb( A:PlayerData, B:PlayerData):void
//	{		
//		// A's effects on B 
//		// a. direction A is moving
//		// b. speed A is moving
//		// c. angle of B to A
//		// if the angle of B to A is more than 90 degrees away from the direction A is moving in
//		// 		then it is a back bump and has no effect on B.  !!!
//		// the speed 'given' from A to B is controlled by ratio - ' bumpSpeedTransfer ' which is stored on gameSettings
//		// bumpSpeedTransfer usually means that about half of the totalSpeed from A is transferred to B in a direct hit.
//		// it tapers down from 50% of total speed at zero degrees to 0% at 90 degrees
//		// as much speed as A transfers to B is how much speed A loses
//		// once the total speed transfered has been determined then we next calculate the direction B it pushed in
//		// B is always pushed in the angle of the angle A hit it plus PI!
//		// after we know the total speed given to B and the direction it is given in then we calculate 
//		// the relative speedX and speedY given based on the direction
//		// we want two hit tests and to perform the same calculations on each ball hit
//		// CORRECTION! it should be A's speed relative to B - not A's absolute speed.
//		
//		
//		var AX:Number = A.xPos;
//		var AY:Number = A.yPos;
//		var BX:Number = B.xPos;
//		var BY:Number = B.yPos;
//		
//		var directionA:Number = RadiansCalculator.calc( A.speedX ,  A.speedY );
//		var hitAngle:Number = RadiansCalculator.calc( BX - AX , BY - AY );
//		
//		// if angle difference is more than 90 degrees they are passing each other anyway so forget about it
//		// OR!! do they in fact transfer speed in the opposite direction? i suspect they do
//		
//		
//		var totalSpeedA : Number = Math.sqrt((A.speedX*A.speedX) + ( A.speedY*A.speedY) );
//		var directnessOfHit:Number = Math.abs( ( Math.PI - Math.abs( directionA - hitAngle )) / 3 ); 
//		var speedTransfered: Number =  directnessOfHit * totalSpeedA;
//		
//		if ( Math.abs( directionA - hitAngle ) >= Math.PI /2  )
//		{
//			//trace (" field controller AHitB() - reverse speed transfer ");
//			speedTransfered = speedTransfered * (-1);
//			
//		}
//		 
//		
//		if ( speedTransfered <= GameSettingsData.getInstance().minumumBumpSpeed ) speedTransfered = GameSettingsData.getInstance().minumumBumpSpeed;
//								
//		// calulate direction B is pushed in
//		var pushDirection:Number = hitAngle;
//				
//		// calculate how B gains speed in terms of speedX and speedY
//		var transferSpeedX:Number = speedTransfered * Math.cos( pushDirection + (Math.random() * .5));//random so  players move past past each other
//		var transferSpeedY:Number = speedTransfered * Math.sin( pushDirection + (Math.random() * .5));
//		
//		// add it to B
//		B.speedX += transferSpeedX;
//		B.speedY += transferSpeedY;
//		
//		// then subtract it from A
//		A.speedX -= transferSpeedX;
//		A.speedY -= transferSpeedY;		
//	}	
	
	
	}// close class
}// close package