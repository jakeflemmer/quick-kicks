package classes.controllers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import classes.data.FieldData;
	import classes.data.GameSettingsData;
	import classes.data.PlayerData;
	import classes.data.SoccerBallData;
	import classes.events.GameEvents;
	import classes.tools.Calculator;
	import classes.tools.RadiansCalculator;
	import classes.views.FieldView;
	import classes.views.GoalsAndWalls;
	import classes.views.PlayIcon;
	
	public class FieldController extends Sprite
	{
		private var _data:FieldData;
		
		private var _view:FieldView;
		
		public var ball:SoccerBallController;
		public var goalsAndWalls:GoalsAndWalls;
		public var redTeam:HumanTeamController;	
		public var blueTeam:CPUTeamController;		
		private var _soccerBallData:SoccerBallData;					
		private var _redPlayersData:Array;
		private var _bluePlayersData:Array;		
		private var frameNumber:uint = 0;
		private var oldFrameNumber:uint = 0;
		private var goalAnimationFrame:uint = 0;		
		private var radCalc:RadiansCalculator;
		private var gameSettings:GameSettingsData;		
		private var playIcon:PlayIcon;		
		private var goalAnimation:GoalAnimation;
		
		public var maxDistanceFromGoal:Number; 
		
		public function FieldController() 	
		{
			startField();			
		}
		public function resetEverything():void
		{
			setTeamsStartDestinations();			
			redTeam.reset();			
			blueTeam.reset();			
			soccerBallReset();			
			SoccerBallData.getInstance().yPos = 500;
			SoccerBallData.getInstance().xPos = 200;			
		}
		private function startField():void
		{
			instantiateVariables();
			
			setVariables();
			
			setTeamsStartDestinations();
			
			addAllChildren();
			
			addListeners();
			
			setBlueMarkedMen();
			
			setRedMarkedMen();			
		}
		private function instantiateVariables():void
		{
			ball = SoccerBallController.getInstance();
			_data = FieldData.getInstance();
			gameSettings = GameSettingsData.getInstance();			
			_soccerBallData = SoccerBallData.getInstance();			
			redTeam = new HumanTeamController();
			blueTeam = new CPUTeamController();
			radCalc = new RadiansCalculator();
			
			//goalsAndWalls = new GoalsAndWalls();
			_view = new FieldView();
			goalAnimation = new GoalAnimation();			
			playIcon = new PlayIcon();			
			_redPlayersData = new Array(5);
			_bluePlayersData = new Array(5);
			calculateMaxDistanceFromGoal();
		}
		private function setVariables():void
		{
			redTeam.data.id = "red";
			blueTeam.data.id = "blue";	
			playIcon.x = 750;
			playIcon.y = 500;			
			_redPlayersData = [redTeam.data.keeper, redTeam.data.player1, redTeam.data.player2, redTeam.data.player3, redTeam.data.player4];
			_bluePlayersData = [blueTeam.data.keeper, blueTeam.data.player1, blueTeam.data.player2, blueTeam.data.player3, blueTeam.data.player4];			
			SoccerBallData.getInstance().yPos = 500;
			SoccerBallData.getInstance().xPos = 200;			
		}
		private function addAllChildren():void
		{
			//goalsAndWalls.draw();			
			addChild(_view);
			addChild(redTeam);
			addChild(blueTeam);
			addChild(ball);
			addChild(playIcon);
			addChild(goalAnimation);
		}
		private function addListeners():void
		{
			setTimeout( function ():void {
				addEventListener(Event.ENTER_FRAME, ON_ENTER_FRAME);
			},1000);
			gameSettings.addEventListener(GameEvents.NEW_GAME,onNewGame);
			gameSettings.addEventListener(GameEvents.GOAL_ANIMATION_OVER,onGoalAnimationEnd);
			_soccerBallData.addEventListener(GameEvents.CHANGE_POSSESSION, onChangePossession);
			_soccerBallData.addEventListener(GameEvents.BALL_NOW_FREE,onBallNowFree);			
		}		
		private function setTeamsStartDestinations():void{			
			
			redTeam.data.keeper.xPos = 150;
			redTeam.data.keeper.yPos = 500;
			redTeam.data.player1.destinationX = 300;
			redTeam.data.player2.destinationX = 300;
			redTeam.data.player3.destinationX = 600;
			redTeam.data.player4.destinationX = 600;
			redTeam.data.player1.destinationY = 250;
			redTeam.data.player3.destinationY = 350;
			redTeam.data.player2.destinationY = 750;
			redTeam.data.player4.destinationY = 650;
			
			blueTeam.data.keeper.destinationX = 1350;
			blueTeam.data.keeper.destinationY = 500;
			blueTeam.data.player1.destinationX = 1200;
			blueTeam.data.player2.destinationX = 1200;
			blueTeam.data.player3.destinationX = 900;
			blueTeam.data.player4.destinationX = 900;
			blueTeam.data.player1.destinationY = 250;
			blueTeam.data.player2.destinationY = 750;
			blueTeam.data.player3.destinationY = 650;
			blueTeam.data.player4.destinationY = 350;			
		}
		private function onNewGame(e:GameEvents):void
		{
			resetEverything();
		}	
		private function onChangePossession(e:GameEvents):void
		{			
			if ( SoccerBallData.getInstance().redPossession ) 
			{
				blueTeam.lostPossession();
				redTeam.wonPossession();
				
				if ( blueTeam.data.playerWithBallData == null ) return;					
				blueTeam.data.playerWithBallData.justBeaten = true;
			}
			if ( SoccerBallData.getInstance().bluePossession )
			{
				redTeam.lostPossession();
				blueTeam.wonPossession();		
				
				if ( redTeam.data.playerWithBallData == null ) return;				
				redTeam.data.playerWithBallData.justBeaten = true;
			}					
		}
		private function onBallNowFree(e:GameEvents):void
		{
			redTeam.ballNowFree();
			redTeam.data.pressureToPass = false;
			
			blueTeam.ballNowFree();
			blueTeam.data.pressureToPass = false;
		}		
		private function goalReset():void
		{
			redTeam.goalReset();
			blueTeam.goalReset();
			soccerBallReset();	
		}
		private function soccerBallReset():void
		{
			SoccerBallData.getInstance().speed = 0;
			SoccerBallData.getInstance().direction = 0;
			SoccerBallData.getInstance().isFree = true;
			SoccerBallData.getInstance().justKicked = false;
			SoccerBallData.getInstance().redPossession = false;
			SoccerBallData.getInstance().bluePossession = false;						
		}		
//  _________________________________________________________________________________________________________________________
//  _________________________________________________________________________________________________________________________

		private function ON_ENTER_FRAME(e:Event):void
		{
			_data.frameNumber ++;
			
//			if (_data.frameNumber == 3)
//			{
//				_data.frameNumber = 0;
//			}
			_data.redTeamData = redTeam.data;
			_data.blueTeamData = blueTeam.data;
			
			//if (_data.frameNumber == 3) GameSettingsData.getInstance().paused = true;						
			
			hitTestGoals();
		
			hitTestPlayers();
			
			hitTestBall();		
			
			//hitTestBallAndTeamMatesWithPossession();			
			
			calculatePressure();
			
			checkIfKeepersAreOnTheirLines();
		}
//  _________________________________________________________________________________________________________________________
//  _________________________________________________________________________________________________________________________
	
				
		
		private function checkIfKeepersAreOnTheirLines():void
		{
			// red keeper
			
			if ( redTeam.data.keeper.yPos > 500  ) {
				_data.redKeeperOnHisLine = "left";			
			} else {			
				_data.redKeeperOnHisLine = "right";
			}			
			
			// blue keeper
			if ( blueTeam.data.keeper.yPos > 500 ) {
				_data.blueKeeperOnHisLine = "left";
			} else {
				_data.blueKeeperOnHisLine = "right";
			}
		}
		private function setBlueMarkedMen():void
		{// set blue player 1 to mark red player 4 etc...
			blueTeam.data.player1.playerMarking = redTeam.data.player4;
			blueTeam.data.player2.playerMarking = redTeam.data.player3;
			blueTeam.data.player3.playerMarking = redTeam.data.player2;
			blueTeam.data.player4.playerMarking = redTeam.data.player1;		
		}
		private function setRedMarkedMen():void
		{
			redTeam.data.player1.playerMarking = blueTeam.data.player4;
			redTeam.data.player2.playerMarking = blueTeam.data.player3;
			redTeam.data.player3.playerMarking = blueTeam.data.player2;
			redTeam.data.player4.playerMarking = blueTeam.data.player1;
		}
		
		private function hitTestGoals():void
		{			
			// blue's goal
			if (SoccerBallData.getInstance().xPos >=1440)
			{
				if ( SoccerBallData.getInstance().yPos >= 315 && SoccerBallData.getInstance().yPos <= 685 )
				{
					if ( blueTeam.data.keeper.hasBall ) return;										
					score("red");		
					//trace("fieldCont red score"); 	
				} 
			}
			// red's goal
			if (SoccerBallData.getInstance().xPos <= 60)
			{
				if ( SoccerBallData.getInstance().yPos >= 315 && SoccerBallData.getInstance().yPos <= 685 )
				{
					if ( redTeam.data.keeper.hasBall ) return; // prevent own goals										
					score("blue");				
					//trace ("fieldCont blue score");
				} 
			}
		}
		
		private function score(team:String):void
		{
			switch (team){
				case "red":
					//resetEverything();
					goalReset();
					SoccerBallData.getInstance().yPos = 500;
					SoccerBallData.getInstance().xPos = 1300;	
					ball.visible = false;
					GameSettingsData.getInstance().redScore ++;
					GameSettingsData.getInstance().goalAnimation = true;
					goalAnimation.play();
					break;
				case "blue":
					//resetEverything();
					goalReset();
					SoccerBallData.getInstance().yPos = 500;
					SoccerBallData.getInstance().xPos = 200;	
					ball.visible = false;
					GameSettingsData.getInstance().blueScore ++;
					GameSettingsData.getInstance().goalAnimation = true;
					goalAnimation.play();
					break;					
			}
		}	
		
		private function onGoalAnimationEnd(e:GameEvents):void
		{
			GameSettingsData.getInstance().goalAnimation = false;
			redTeam.reset();
			blueTeam.reset();
			ball.visible = true;			
		}
		
//  _____________________________________________________________________________________________________________________________
//  _________________________________________   HIT TEST PLAYERS   ___________________________________________________________

	
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
	
	private function resetPlayersSpaceAndClosestDefender():void{
		
		for ( var i:uint=0; i < cpda.length; i++)
		{
			(cpda[i] as PlayerData).space = 10000;
			(cpda[i] as PlayerData).closestDefender = null;
		}
	}
//  ____________________________________________________________________________________________________________________
//  __________________________________________  player A HIT player B    _______________________________________________
//  ____________________________________________________________________________________________________________________

	private function AHitB( A:PlayerData, B:PlayerData):void
	{			
		// A's effects on B 
		// a. direction A is moving
		// b. speed A is moving
		// c. angle of B to A
		// if the angle of B to A is more than 90 degrees away from the direction A is moving in
		// 		then it is a back bump and has no effect on B.  !!!
		// the speed 'given' from A to B is controlled by ratio - ' bumpSpeedTransfer ' which is stored on gameSettings
		// bumpSpeedTransfer usually means that about half of the totalSpeed from A is transferred to B in a direct hit.
		// it tapers down from 50% of total speed at zero degrees to 0% at 90 degrees
		// as much speed as A transfers to B is how much speed A loses
		// once the total speed transfered has been determined then we next calculate the direction B it pushed in
		// B is always pushed in the angle of the angle A hit it plus PI!
		// after we know the total speed given to B and the direction it is given in then we calculate 
		// the relative speedX and speedY given based on the direction
		// we want two hit tests and to perform the same calculations on each ball hit
		// CORRECTION! it should be A's speed relative to B - not A's absolute speed.
		
		
		var AX:Number = A.xPos;
		var AY:Number = A.yPos;
		var BX:Number = B.xPos;
		var BY:Number = B.yPos;
		
		var directionA:Number = RadiansCalculator.calc( A.speedX ,  A.speedY );
		var hitAngle:Number = RadiansCalculator.calc( BX - AX , BY - AY );
		
		// if angle difference is more than 90 degrees they are passing each other anyway so forget about it
		// OR!! do they in fact transfer speed in the opposite direction? i suspect they do
		
		
		var totalSpeedA : Number = Math.sqrt((A.speedX*A.speedX) + ( A.speedY*A.speedY) );
		var directnessOfHit:Number = Math.abs( ( Math.PI - Math.abs( directionA - hitAngle )) / 3 ); 
		
		if ( Math.abs( directionA - hitAngle ) >= Math.PI /2  )
		{
			//trace (" field controller AHitB() - reverse speed transfer ");
			speedTransfered = speedTransfered * (-1);
			
		}
		 
		var speedTransfered: Number =  directnessOfHit * totalSpeedA;
		
		if ( speedTransfered <= GameSettingsData.getInstance().minumumBumpSpeed ) speedTransfered = GameSettingsData.getInstance().minumumBumpSpeed;
								
		// calulate direction B is pushed in
		var pushDirection:Number = hitAngle;
				
		// calculate how B gains speed in terms of speedX and speedY
		var transferSpeedX:Number = speedTransfered * Math.cos( pushDirection + (Math.random() * .5));//random so  players move past past each other
		var transferSpeedY:Number = speedTransfered * Math.sin( pushDirection + (Math.random() * .5));
		
		// add it to B
		B.speedX += transferSpeedX;
		B.speedY += transferSpeedY;
		
		// then subtract it from A
		A.speedX -= transferSpeedX;
		A.speedY -= transferSpeedY;		
	}

//  ______________________________________________________________________________________________________________________

	
	
	private function calculatePressure():void
	{
		if ( SoccerBallData.getInstance().isFree ) return;
		
		var pressureThresholdDistance:Number = GameSettingsData.getInstance().pressureThresholdDistance;
		var deltaX:Number; var deltaY:Number;
		var ballX:Number; var ballY:Number;
		var totalDistance:Number;
		var mostAmountOfSpace:Number = 0;
		var i :int; var j: int; 
		
		//  CALCULATE RED PLAYERS SPACE
		if ( SoccerBallData.getInstance().redPossession )  //  ______  RED		
		{
			if ( redTeam.data.playerWithBallData == null ) return;
			
			ballX = SoccerBallData.getInstance().xPos; 
			ballY = SoccerBallData.getInstance().yPos;
			
			redTeam.data.playerWithBallData.space = 10000;
			
			for ( i=0; i < _bluePlayersData.length; i++)   
			{
				//if ( ! _bluePlayersData[i].justBeaten )
				//{
				
				    deltaX = Math.abs( ballX - _bluePlayersData[i].xPos );
					deltaY = Math.abs( ballY - _bluePlayersData[i].yPos );
					totalDistance = theTotalDistance(deltaX,deltaY);
					
					if ( totalDistance < redTeam.data.playerWithBallData.space)	
						redTeam.data.playerWithBallData.space = totalDistance;
					
				
					if ( redTeam.data.playerWithBallData.isKeeper ) redTeam.data.pressureToPass = true;
					if ( totalDistance <= pressureThresholdDistance && _bluePlayersData[i] != redTeam.data.playerWithBallData.playerMarking)
					{
						//redTeam.data.pressureToPass = true;
					} 				
				//}
			}
			mostAmountOfSpace = 0;
			for ( i=0; i < _redPlayersData.length; i++)
			{
				if ( _redPlayersData[i].space > mostAmountOfSpace )
					redTeam.data.playerWithMostSpace = _redPlayersData[i];
			}
		}
		//CALCULATE BLUE PLAYERS SPACE
		if ( SoccerBallData.getInstance().bluePossession )   //  ________   BLUE
		{
			if ( blueTeam.data.playerWithBallData == null ) return;
			
			ballX = SoccerBallData.getInstance().xPos; 
			ballY = SoccerBallData.getInstance().yPos;
			
			blueTeam.data.playerWithBallData.space = 10000;

			for ( i=0; i < _redPlayersData.length; i++)   
			{
				//if ( ! _redPlayersData[i].justBeaten )
				//{
					deltaX = Math.abs( ballX - _redPlayersData[i].xPos );
					deltaY = Math.abs( ballY - _redPlayersData[i].yPos );
					totalDistance = theTotalDistance(deltaX,deltaY); // the distance of each red player to the ball
					
					
					if ( totalDistance < blueTeam.data.playerWithBallData.space)
						blueTeam.data.playerWithBallData.space = totalDistance;
					
					
					
					if ( blueTeam.data.playerWithBallData.isKeeper ) blueTeam.data.pressureToPass = true;
					if ( totalDistance <= pressureThresholdDistance && _redPlayersData[i] != blueTeam.data.playerWithBallData.playerMarking)
					{
						//blueTeam.data.pressureToPass = true;
					}				
				//}
			}
			mostAmountOfSpace = 0;
			for ( i=0; i < _bluePlayersData.length; i++)
			{
				if ( _bluePlayersData[i].space > mostAmountOfSpace )
					blueTeam.data.playerWithMostSpace = _bluePlayersData[i];
			}
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
	
	
	
	
	
	
	// --------------------------------------------------------------------------------------------------
	//  GETTERS & SETTERS
	// --------------------------------------------------------------------------------------------------
	
	private function get cpda():Array{
		var c:Array = new Array();  // combined player data array
		var i:uint=0;		
		for (i=0;i < _redPlayersData.length; i++)
		{
			c.push( _redPlayersData[i]  );
		}
		for (i=0;i < _bluePlayersData.length; i++)
		{
			c.push( _bluePlayersData[i] );
		}		
		return c;		
	}	
	/*
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
	}	*/
	
	private function get calc():Calculator{
		return Calculator.instance;
	}	
	private function get gsd():GameSettingsData{
		return GameSettingsData.getInstance();
	}
	private function get sbd():SoccerBallData{
		return SoccerBallData.getInstance();
	}
	
	
	
	
	
	
	
	}// close class
}// close package