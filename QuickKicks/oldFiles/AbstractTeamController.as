package classes
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class AbstractTeamController extends Sprite 
	{
	
		protected var frameCount:uint = 0;
		protected var oldFrameCount:uint = 0;
		protected var radCalc:RadiansCalculator = new RadiansCalculator();
		protected var passLine:PassLineIndicator = new PassLineIndicator();
		protected var autoPassFrameNum:Number = 0;		
		
		public var keeper:AbstractPlayerController;
		public var player1:AbstractPlayerController;
		public var player2:AbstractPlayerController;
		public var player3:AbstractPlayerController;
		public var player4:AbstractPlayerController;	
		public var player5:AbstractPlayerController;
		public var player6:AbstractPlayerController;
		public var player7:AbstractPlayerController;
		public var player8:AbstractPlayerController;
		public var player9:AbstractPlayerController;
		public var player10:AbstractPlayerController;
		
		public var playersArray:Array = new Array();	// this is an array of PlayerControllers !		
		
		protected var keeperShadow:PlayerShadow;
		protected var player1Shadow:PlayerShadow;
		protected var player2Shadow:PlayerShadow;
		protected var player3Shadow:PlayerShadow;
		protected var player4Shadow:PlayerShadow;
		protected var player5Shadow:PlayerShadow;
		protected var player6Shadow:PlayerShadow;
		protected var player7Shadow:PlayerShadow;
		protected var player8Shadow:PlayerShadow;
		protected var player9Shadow:PlayerShadow;
		protected var player10Shadow:PlayerShadow;
		
		// composed classes
		protected var startPositioner:StartPositioner = new StartPositioner();
		protected var zoneManager:ZoneManager = new ZoneManager();
		protected var destinationManager:DestinationManager = new DestinationManager();
		protected var passOrShootAngleCalculator:PassOrShootAngleCalculator = new PassOrShootAngleCalculator();
		protected var ballCarrierAI:BallCarrierAI = new BallCarrierAI();
		
		protected var _data:TeamData = new TeamData;
		
		public var i:uint;  // used for loop counting
		
		
		//--------------------------------------------------------------------------------------------------
		
		public function AbstractTeamController()
		{		
					
		}
		
		protected function initPlayerEventListeners():void{
			for (i=0;i<playersArray.length;i++)
			{
				(playersArray[i] as IEventDispatcher).addEventListener(GameEvents.JUST_PASSED,onPlayerJustPassed);
					//function(e:Event):void{
					//	passLine.clear();
					//});
				(playersArray[i] as IEventDispatcher).addEventListener(GameEvents.PLAYER_JUST_GOT_BALL, onNewPlayerGotBall);
			}
		}		
		
		protected function initializeTeam(redTeam:Boolean):void
		{				
			addChild(passLine);			
			
			keeper = ( redTeam ? new HumanPlayerController() : new CPUPlayerController() );
			keeper.data.isKeeper = true;	
			keeper.data.id = "keeper";			
			keeperShadow = new PlayerShadow(keeper.data);
			playersArray[0] = keeper;			
			
			addChild(keeperShadow);		
			addChild(keeper);		
			
			for ( i=1;i<GameSettingsData.getInstance().numberOfPlayers;i++)
			{
				this["player"+i.toString()] = redTeam ? new HumanPlayerController() : new CPUPlayerController();
				// set basic team properties
				(this["player"+i.toString()].data as PlayerData).id = "player"+i.toString();
				(this["player"+i.toString()].data as PlayerData).teamId = ( redTeam ? "red" : "blue" );
				(this["player"+i.toString()].data as PlayerData).hitTestCaptureDistance = ( i < 4 ? gsd.playerRadius*4:gsd.playerRadius*2);
				
				this["player"+i.toString()+"Shadow"] = new PlayerShadow( this["player"+i.toString()].data);
			
				addChild( this["player"+i+"Shadow"]);
				addChild( this["player"+i]);
				playersArray[i] = this["player"+i.toString()];			
			}						
			
			initPlayerEventListeners();
			initializeTeamPlayers();		
		}
		
		protected function initializeTeamPlayers():void{
			assignAllPlayersTheirZones();
			setPlayersStartPositions(); // which also sets their destinations to their start positions		
			//FieldController.getInstance().setDefaultMarkedMen();	
		}
		
				
		//--------------------------------------------------------------------------------------------------
		// ON ENTER FRAME
		//--------------------------------------------------------------------------------------------------
		
		protected function ON_ENTER_FRAME(e:Event=null):void{	
			
			_data.currentFrameNumber ++;	
			
			keeperTracking();			
			
			determineState();
			
			if ( _data.state == "attacking")
			{
				
				setAllPlayersMarking(false);			
				
				assignAllPlayersTheirZones();	// which change depending on which zone pwb is in
			
				givePlayersNewGetFreeDestinations();
				
				if ( pwbd != null )
				{
				
					calculatePasses();						
					doBallCarrierStrategy();										
				
				}
				else if ( pwbd == null )
				{
			
					testCheckPassReceiverIsSet();    // this function can be removed in time	
						
					if ( passHasFailed() )
					{
						chooseWhoIsGettingBall();	
					}
					else
					{
						setPassRecieverDestinationToPassDestination();	// if its not a score ball							
					}					
					
				}	
				
			}
			else if ( _data.state == "defending")
			{
				
				setAllPlayersMarking(true);	
				
				noPlayersGettingBall();	//TODO ??
				
				//chooseWhoIsGettingBall();	// based on which player of the other team is getting ball and who is marking them
				
				//pda = MarkingManager.getInstance().assignMarkedMen(pda);
				
			//	checkEverybodyIsMarking(); // ( excpet guy getting ball )	
				
				
			}
			
			else throw new Error("no state");			
		
			// below test is not performed because now by default when defending all players simply mark unless they can steal or intercept
			//testThatOnePlayerIsEitherGettingTheBallOrHasTheBall();  // this function can be removed in time
			
			testThatOnlyOnePlayerIsGettingTheBall();
			
			testThatThereIsOnlyOnePassReceiver();
			
			//testThatIfAPlayerIsReceivingPassNoOtherPlayerIsGettingBall();
			
			testThatNoTwoPlayersAreMarkingTheSameMan();
			
			testThatIfDefendingAndPlayerNotGettingBallPlayerMarkingIsNotNull();
			
		
		}
		
		protected function passHasFailed():Boolean{
			if ( !_data.passing ) throw new Error("team is not passing ??!?!?!");
			
			if ( _data.currentFrameNumber > _data.passShouldBeCompletedByFrameNumber + 5)//TODO hard coding here
			{
				noPassReceiver();
				_data.passDestinationX = null;
				_data.passDestinationY = null;
				_data.passJustFailed = true;
				return true;
			}else{
				return false;
			}
		}
		
		protected function setPassRecieverDestinationToPassDestination():void{
			
			if ( passOrShootAngleCalculator.passReciever )
			{
				if ( passReceiver().isKeeper )
				{
					passReceiver().destinationX = (passReceiver().teamId == "red" ? 50 + gsd.playerRadius * 2 : 1450 - gsd.playerRadius * 2 );	
				} 
				else 
				{
					passReceiver().destinationX = _data.passDestinationX;
				}				
				passReceiver().destinationY = _data.passDestinationY;
				
			} else if (passOrShootAngleCalculator.scoreBall )
			{
				
			}else{
				throw new Error("no pass receiver but no score ball ?!");
			}	
		}
		
		protected function determineState():void{
			if ( sbd.redPossession && _data.id == "red" )
			{
				_data.state = "attacking";	
			}
			else if ( sbd.bluePossession && _data.id == "blue" )
			{
				_data.state = "attacking";
				
			}
			else if ( sbd.redPossession && _data.id == "blue" )
			{
				_data.state = "defending";
			}
			else if ( sbd.bluePossession && _data.id == "red" )
			{
				_data.state = "defending";
			}			
			else 
			{
				throw new Error("soccer ball is is nobody's possession");
			}
			
		}
		
			
		//--------------------------------------------------------------------------------------------------
		
		
		
		
		//--------------------------------------------------------------------------------------------------
		//  ESSENTIAL TEAM FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		
		protected function doTeamStrategy():void{
			//  this function determines if attacking and moving to free zones
			//  or defending and marking opponents
			if ( SoccerBallData.getInstance().redPossession && _data.id == "red" ||
				 SoccerBallData.getInstance().bluePossession && _data.id == "blue" )
			{
				_data.state = "attacking";
				
				setAllPlayersMarking(false);
				assignAllPlayersTheirZones();	// every player is assigned a zone every time so that when pwb moves into another player's zone
												// framework handles it automatically
				givePlayersNewGetFreeDestinations();
			}
			else
			{
				_data.state = "defending";
				setAllPlayersMarking(true);	
				
			}			
		}
		
		protected function doBallCarrierStrategy():void{
			
			ballCarrierAI.openPass = openPass();
			ballCarrierAI.scoreBall = passOrShootAngleCalculator.scoreBall;
			
			ballCarrierAI.decideWhatToDo(playersArray,pwbd);
//			if ( pwbd.passNow && ! passOrShootAngleCalculator.scoreBall )
//			{
//				pwbd.teamMateAimingPassAt.passReceiver = true;
//			} 
//			else if ( pwbd.passNow && passOrShootAngleCalculator.scoreBall )
//			{
//				noPassReceiver();
//			}			
		}
		
		//--------------------------------------------------------------------------------------------------
		//  DELEGATED FUNCTIONS
		//--------------------------------------------------------------------------------------------------		
		
		protected function calculatePassOrShootAngle():Number{
			return this.passOrShootAngleCalculator.calculatePassOrShootAngle(
				this.pda,this.pwbd,this.data.scorePost.postsX, this.data.scorePost.leftPostY,this.data.scorePost.rightPostY);				
		}
		
		protected function scoreBall():Boolean{
			return this.passOrShootAngleCalculator.scoreBall;
		}
		
		protected function passReceiver():PlayerData{
			return this.passOrShootAngleCalculator.passReciever;
		}
		protected function assignAllPlayersTheirZones():void{
			// the zoneManager assigns every player a zone every time
			// it automatically switches the player with balls zone with the zone pwb is in
			this.zoneManager.assignEveryPlayerTheirZone(this.playersArray);
		}
		
		protected function givePlayersNewGetFreeDestinations():void{
			this.playersArray = this.destinationManager.giveAllPlayersGetFreeDestinations( this.playersArray );		
		}
		protected function resetDestinations():void{
			this.playersArray = this.destinationManager.resetDestinations(this.playersArray);			
		}		
		
		protected function setPlayersStartPositions():void{		
			this.pda = this.startPositioner.setStartPositions( this.pda );		
		}
		
		//--------------------------------------------------------------------------------------------------
		//  COMPLEX FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		
		protected function openPass():Boolean
		{		
			if ( pwbd.isKeeper ) return true;
			
			return FieldController.getInstance().openPass(_data.id);
//			// TODO
//			// when is the closestTeamMate set and is it accurate??
//			// and BTW is this function even accurate anyway?
//			
//			var angleOfReceiver:Number = RadiansCalculator.calc((_data.closestTeamMate.xPos - pwbd.xPos),(_data.closestTeamMate.yPos - pwbd.yPos));
//			var angleOfDefender:Number = RadiansCalculator.calc((pwbd.playerMarking.xPos - pwbd.xPos),(pwbd.playerMarking.yPos - pwbd.yPos));
//			var a:Number = Math.abs( angleOfReceiver - angleOfDefender );
//			var xDistToDef:Number = Math.abs(pwbd.xPos - pwbd.playerMarking.xPos);
//			var yDistToDef:Number = Math.abs(pwbd.yPos - pwbd.playerMarking.yPos);
//			var distanceToDefender:Number = Math.sqrt( (xDistToDef*xDistToDef) + ( yDistToDef*yDistToDef) );
//			
//			var xDistToRec:Number = Math.abs(_data.closestTeamMate.xPos - pwbd.xPos );
//			var yDistToRec:Number = Math.abs(_data.closestTeamMate.yPos - pwbd.yPos );
//			var distToRec:Number = Math.sqrt( (xDistToRec*xDistToRec) + (yDistToRec*yDistToRec) );
//			var x:Number;
//			x = Math.abs( Math.sin(a) ) * distToRec;
//			if ( x > gsd.playerRadius + sbd.radius )
//				return true;		
//			return false;
		}	
		
		protected function receiverNotCovered():Boolean
		{		
			
			/*
			a. calc angle of defender
			b. calc angle of receiver
			c. get difference and call it "a"
			d. calc distance to defender
			e. sin(a) = opposite/ hypotenuese		
			f. sin(a) = x / hypoteneuse
			g. sin(a) * hypoteneuse = x		
			h if ( x > playerRadius + ballRadius )
			passNotBlockedByThisDefender = true;	
			*/
			
			var notCovered:Boolean = false;
			var xDistToReceiver:Number = Math.abs( _data.closestTeamMate.xPos - pwbd.xPos );
			var yDistToReceiver:Number = Math.abs( _data.closestTeamMate.yPos - pwbd.yPos );
			var totalDistanceToReceiver:Number = Math.sqrt( (xDistToReceiver*xDistToReceiver) + (yDistToReceiver*yDistToReceiver) );
			
			if ( _data.closestTeamMate.isKeeper ) // closest player is keeper 
			{ 
				if (pwbd.xPos <= 750 ) 
				{
					if ( pwbd.teamId == "red" )
						return true;		// too far to try to pass back to keeper
					else return false;
				} else {
					if ( pwbd.teamId == "red" )
						return false;		// too far to try to pass back to keeper
					else return true;
				}			
			}
			var xDistToInterceptor:Number = Math.abs( _data.closestTeamMate.playerMarking.xPos - pwbd.xPos );
			var yDistToIntercerptor:Number = Math.abs( _data.closestTeamMate.playerMarking.yPos - pwbd.yPos );
			var totalDistanceToIntercerptor:Number = Math.sqrt( (xDistToInterceptor*xDistToInterceptor) + (yDistToIntercerptor*yDistToIntercerptor) );
			
			if ( totalDistanceToIntercerptor > totalDistanceToReceiver )
			{
				notCovered = true;	
				return notCovered;			
			}
			var angleOfInterceptor:Number = RadiansCalculator.calc( (_data.closestTeamMate.playerMarking.xPos - pwbd.xPos),(_data.closestTeamMate.playerMarking.yPos - pwbd.yPos));
			var angleOfReceiver:Number = RadiansCalculator.calc(( _data.closestTeamMate.xPos - pwbd.xPos ),(_data.closestTeamMate.yPos - pwbd.yPos ));
			var a:Number = Math.abs( angleOfInterceptor - angleOfReceiver );
			// x = sin(a) * hypoteneuse;		
			var x:Number = Math.abs( Math.sin(a) ) * totalDistanceToReceiver;
			if ( x > gsd.playerRadius + sbd.radius)
				return true;
			
			//else
			return false;
			
		}
		
//		
		protected function calculatePasses():void{
			pwbd.autoPassAngle = calculatePassOrShootAngle();				
			passLine.draw( passOrShootAngleCalculator.returnPassLineInfo(pwbd) );	
		}
		
		protected function chooseWhoIsGettingBall():void{
			var playerGettingBall:AbstractPlayerController = determineWhoIsClosestToBall();
			noPlayersGettingBall();			
			playerGettingBall.data.gettingBall = true;			
		}
		protected function determineWhoIsClosestToBall():AbstractPlayerController{			
						
			// This funcion determines which player is closest to the ball
			// calculating in a bias against the keeper rushing out of the box and 
			// calculating in a bias for the last player who was controlled or getting the ball
			// remaining controlled or getting the ball
			
			// TODO  if a player has just passed should they be excluded from gettting the ball??
			
			var bX:Number = SoccerBallData.getInstance().xPos;
			var bY:Number = SoccerBallData.getInstance().yPos;
			var xDistance:Number = 0;
			var yDistance:Number = 0;
			var totalDistance:Number = 0;
			var smallestNumber:Number = 10000;
			var lastPlayerGettingBallOrControlled:int = -1;	
			var closestPlayer:uint;
					
			// get the last player who was getting the ball or controlled
			for ( i = 0 ; i < playersArray.length ; i ++ )
			{
				if ( playersArray[i].data.gettingBall ) lastPlayerGettingBallOrControlled = i;	
				if ( playersArray[i].data.isControlled ) lastPlayerGettingBallOrControlled = i;	
			}		
			// find the distance of each player from the ball
			var q:uint;
			for ( q = 0; q < playersArray.length; q++)
			{	
				if ( ! playersArray[q].data.justBeaten && ! playersArray[q].data.justPassed )
				{
					xDistance =  playersArray[q].data.xPos - bX ;
					yDistance =  playersArray[q].data.yPos - bY ;
					totalDistance = Math.sqrt( (xDistance*xDistance) + (yDistance*yDistance) ); // total distance of player from ball
					// bias the distance here
					// increase it for the keeper
					if ( playersArray[q].data.isKeeper ) totalDistance += 200;
					// decrease it for the player last in control
					if ( q == lastPlayerGettingBallOrControlled ) totalDistance -= gsd.playerRemainControlledBias;
		
					if ( totalDistance < smallestNumber ) 
					{
						smallestNumber = totalDistance;
						closestPlayer = q;
					}
				}			
			}
			return playersArray[closestPlayer];
		}	
		
		protected function keeperTracking():void
		{
			if ( keeper.data.gettingBall ) return;
			if ( keeper.data.justBeaten ) return;
			if ( keeper.data.hasBall ) return;
			
			// actually instead of all this lets just keep the keeper on his line
			
			keeper.data.destinationX = (this.data.id == "red" ? 50 + keeper.data.radius * 2 : 1450 - keeper.data.radius * 2 );
			
			keeper.data.destinationY = sbd.yPos;
			if ( keeper.data.destinationY < 300 + gsd.playerRadius ) keeper.data.destinationY = 300 + gsd.playerRadius;
			if ( keeper.data.destinationY > 700 - gsd.playerRadius ) keeper.data.destinationY = 700 - gsd.playerRadius;
			
			return;
			//------------------------------
			
//			var goalCenterX:uint = ( this.data.id == "red" ? 50 : 1450 );						
//			var deltaX:Number = ( this.data.id == "red" ? ( goalCenterX - sbd.xPos ) : ( sbd.xPos - goalCenterX ) );  
//			var deltaY:Number = ( 500 - sbd.yPos ); 
//				
//			var theAngleFromGoal:Number = RadiansCalculator.calc(deltaX,deltaY);
//		
//			var x:uint = ( this.data.id == "red" ? 25 : 1475 );
//			keeper.data.destinationX = (x - ( 150 * Math.cos(theAngleFromGoal)));
//			keeper.data.destinationY = (500 - ( 175 * Math.sin(theAngleFromGoal)));							
		}	
		
		//--------------------------------------------------------------------------------------------------
		//  BASIC FUNCTIONS
		//--------------------------------------------------------------------------------------------------
		
		protected function noPlayersControlled():void{
			for(var i :uint =0; i < this.playersArray.length;i++)
			{
				this.playersArray[i].data.isControlled = false;
			}
		}
		
		protected function setAllPlayersMarking(marking:Boolean):void{
			for ( var i:int = 0 ; i < this.playersArray.length ; i ++ )
			{
				this.playersArray[i].data.marking = marking;		
			}		
		}		
	
		protected function resetAfterGoal():void{
			
			resetDestinations();
			_data.pressureToPass = false;			
			noPlayersHaveBall();			
			
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.speed = 0;
				playersArray[i].data.speedX = 0;
				playersArray[i].data.speedY=0;
				playersArray[i].data.generatingKickPower = false;
				playersArray[i].data.kickPower = 0;
				playersArray[i].data.justPassed = false;
				playersArray[i].data.passReceiver = false;
				playersArray[i].data.autoPassing = false;				
				//playersArray[i].data.marking = false;
				playersArray[i].data.pressureToPass = false;
				playersArray[i].data.passNow = false;
				playersArray[i].data.justBeaten = false;						
				playersArray[i].data.isControlled = false;				
			}			
		}
		protected function resetAfterNewStart():void{
			
			passLine.clear();			
			resetAllPlayerProperties();
			resetAllTeamProperties();			
			assignAllPlayersTheirZones();			
			setPlayersStartPositions();			
		}
		protected function noPlayersHaveBall():void	{				
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.hasBall = false;
			}			
		}
		protected function noPlayersGettingBall():void	{				
			for ( i=0; i < playersArray.length; i++)
			{
				(playersArray[i] as AbstractPlayerController).data.gettingBall = false;
			}			
		}
		protected function resetAllTeamProperties():void{			
			
			_data.pressureToPass = false;						
			pwbd = null;
			_data.closestTeamMate = null;
			_data.justPassed = false;
			_data.playerWithMostSpace = null;
			_data.pressureToPass = false;
		}
		protected function resetAllPlayerProperties():void
		{					
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.hasBall = false;
				playersArray[i].data.speed = 0;
				playersArray[i].data.speedX = 0;
				playersArray[i].data.speedY = 0;
				playersArray[i].data.generatingKickPower = false;
				playersArray[i].data.kickPower = 0;
				playersArray[i].data.justPassed = false;
				playersArray[i].data.passReceiver = false;							
				playersArray[i].data.pressureToPass = false;
				playersArray[i].data.passNow = false;
				playersArray[i].data.justBeaten = false;	
				playersArray[i].data.isControlled = false;			
				playersArray[i].data.scoreBall = false;		
				playersArray[i].data.gettingBall = false;	
				playersArray[i].data.destinationManagerHasAssignedDestination = false;				
			}
		}
		public function lostPossession():void
		{	
			if ( pwbd != null )	pwbd.justBeaten = true;					
			pwbd = null;	
			_data.passing = false;
			_data.passCompleted = false;
			_data.passDestinationX = null;
			_data.passDestinationY = null;			
			noPlayersHaveBall();
			passLine.clear();		
			
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.passReceiver = false;
				playersArray[i].data.pressureToPass = false;
				playersArray[i].data.passNow = false;		
				playersArray[i].data.generatingKickPower = false;
			}		
		}
		public function wonPossession():void
		{			
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.gettingBall = false;					
			}
		}		
		
		protected function takeTheShot():void
		{
		//	if ( Math.abs(_data.autoPassAngle - pwbd.dribble) < Math.PI * .5 || Math.abs(_data.autoPassAngle - pwbd.dribble) > Math.PI * 1.5)
		//	{
				pwbd.passNow = true; // if goal is open always take shot immediately
				pwbd.scoreBall = false;
				sbd.passReceiver = null;
		//	}
		}		
		
		protected function noPassReceiver():void
		{		
			for ( i=0; i < this.playersArray.length; i++)
			{
				playersArray[i].data.passReceiver = false;
			}
		}


	//--------------------------------------------------------------------------------------------------
	// EVENT HANDLERS
	//--------------------------------------------------------------------------------------------------
	
		protected function onNewPlayerGotBall(ge:GameEvents):void{
				
			this.passLine.clear();
			this.data.playerWithBallData = ge.playerWhoJustGotBall.data;
			if ( ge.playerWhoJustGotBall.data.passReceiver )
			{
				_data.passCompleted = true;
				_data.passJustFailed = false;				
			}
			_data.passing = false;	
			noPassReceiver();
			_data.passDestinationX = null;
			_data.passDestinationY = null;		
			ballCarrierAI.dontHoldBallTooLongFrameCounter = 0;
			ballCarrierAI.state = "nothing";
			ballCarrierAI.action = "nothing";
		}	
		
		protected function onPlayerJustPassed(ge:GameEvents):void{
			
			this._data.playerWithBallData = null;			
			this.passLine.clear();
			//this.passOrShootAngleCalculator.passReciever = null;
			_data.passing = true;
			_data.passJustFailed = false;
			_data.passDestinationX = ge.passDestinationX;
			_data.passDestinationY = ge.passDestinationY;
			_data.passShouldBeCompletedByFrameNumber = _data.currentFrameNumber + ge.numberOfFramesToCompleteThePass;
			ballCarrierAI.dontHoldBallTooLongFrameCounter = 0;
			ballCarrierAI.state = "nothing";
			ballCarrierAI.action = "nothing";
		}
	
	//--------------------------------------------------------------------------------------------------
	//  TEST SUITES
	//--------------------------------------------------------------------------------------------------
	
		protected function testThatIfDefendingAndPlayerNotGettingBallPlayerMarkingIsNotNull():void{
			if ( _data.state == "defending" )
			{
				var i:uint;
				for ( i=1;i<playersArray.length;i++)
				{
					if ( !(playersArray[i] as AbstractPlayerController).data.gettingBall )
					{
						if ( (playersArray[i] as AbstractPlayerController).data.playerMarking == null)
						{
							throw new Error("defending but player not getting ball is not marking anybody");
						}
					}
				}
			}
			
		}
		protected function testThatNoTwoPlayersAreMarkingTheSameMan():void{
			var i:uint; var j:uint;
			
			for ( i=1;i<playersArray.length;i++)
			{
				for ( j=1; j <playersArray.length; j++)
				{
					if ( i != j )
					{
						if ( (playersArray[i] as AbstractPlayerController).data.playerMarking && (playersArray[j] as AbstractPlayerController).data.playerMarking )
						{							
							if ( (playersArray[i] as AbstractPlayerController).data.playerMarking.id == (playersArray[j] as AbstractPlayerController).data.playerMarking.id )
							{
								throw new Error("two players marking same man");
							}
						}
					}
				}	
			}
		}
		
		protected function testThatOnlyOnePlayerIsGettingTheBall():void{
			
			var i:uint;
			var numOfPlayersGettingBall:uint =0;
			for ( i=0; i < playersArray.length; i++)
			{
				if ( (playersArray[i] as AbstractPlayerController).data.gettingBall )
				{
					numOfPlayersGettingBall ++;
				}
			}
			if ( numOfPlayersGettingBall > 1 )
			{
				throw new Error("more than one player getting ball");
			}
		}
		
		protected function testThatOnePlayerIsEitherGettingTheBallOrHasTheBall():void{
			
			if ( pwbd ) return;
			
			var onePlayerGettingBall:Boolean = false;
			
			if (keeper.data.gettingBall)
			{
				//	trace("keeper getting ball");
				onePlayerGettingBall = true;
			}
			for ( var i:uint = 1; i <playersArray.length; i++)
			{
				if ( (playersArray[i] as AbstractPlayerController).data.gettingBall )
				{
					if ( onePlayerGettingBall )
					{
						throw new Error("two people getting ball");
					}
					onePlayerGettingBall = true;
				}
			}
			if ( !onePlayerGettingBall )
			{
				throw new Error("nobody getting ball");
			}
			
		}
		protected function testCheckPassReceiverIsSet():void{
			
			var passReceiverSet:Boolean = false;			
			var i:uint;
			for ( i=1; i < gsd.numberOfPlayers; i++)
			{
				if ( keeper.data.passReceiver )
				{
					passReceiverSet = true;
				}
				if ( (this["player"+i.toString()] as AbstractPlayerController).data.passReceiver )
				{
					passReceiverSet = true;
				}
			}

			if ( passOrShootAngleCalculator.scoreBall )
			{
				if ( passReceiverSet ) throw new Error("pass receiver set on score ball");
			} 
			else
			{
				if ( ! passReceiverSet && _data.passJustFailed != true ) 
				{
					throw new Error("no pass receiver set"); // TODO
				}
			}
	
		}
		
		private function testThatThereIsOnlyOnePassReceiver():void{
			var i :uint;
			var numOfPlayersReceivingPass:uint =0;
			for ( i=0; i < playersArray.length; i++)
			{
				if ( (playersArray[i] as AbstractPlayerController).data.passReceiver )
				{
					numOfPlayersReceivingPass ++;
				}
			}
			if ( numOfPlayersReceivingPass > 1)
			{
				throw new Error("more than one passReceiver set");
			}
		}
	
	
	
	//--------------------------------------------------------------------------------------------------
	//  GETTERS  & SETTERS
	//--------------------------------------------------------------------------------------------------
	
		public function get data():TeamData{
			return _data;
		}
		
		public function get gsd():GameSettingsData{
			return GameSettingsData.getInstance();
		}
		
		public function get sbd():SoccerBallData{
			return SoccerBallData.getInstance();
		}
		
		public function get pwbd():PlayerData{
			return _data.playerWithBallData;
		}
		
		public function set pwbd(val:PlayerData):void{	// this is set when player hit tests ball and dispatches event heard by team
			_data.playerWithBallData = val;
		}
		
		public function get ctmd():PlayerData{
			return _data.closestTeamMate;
		}
		
		public function set ctmd(data:PlayerData):void{
			_data.closestTeamMate = data;
		}
		
		public function get ctmdefd():PlayerData{
			return _data.closestTeamMate.playerMarking;
		}
		
		public function set ctmdefd(data:PlayerData):void{
			_data.closestTeamMate.playerMarking = data;
		}
		
		public function get c():Calculator{
			return Calculator.instance;
		}
		
		public function get pda():Array{
			var p:Array = new Array();
			for (i=0; i < this.playersArray.length;i++)
			{
				p.push( this.playersArray[i].data );
			}
			return p;
		}
		public function set pda(val:Array):void{
			for (i=0;i<val.length;i++)
			{
				this.playersArray[i].data = val[i];
			}
		} 
		
		
		
		
		
		
		
		// OLD CODE
		
		
//		protected function determineWhoIsGettingBallOrControlledbbbbbbbbbbbbbbb():void{			
//				
//			if ( pwbd != null )	{
//				noPlayersGettingBall()			
//				return;
//			}			
//			
//			if ( ! gsd.demoMode )
//			{
//				noPlayersControlled();
//			}
//			// This funcion determines which player is controlled or which player is getting the ball
//			// depending on wether it is human or cpu player
//		// TODO  if a player has just passed should they be excluded from gettting the ball??
//			var bX:Number = SoccerBallData.getInstance().xPos;
//			var bY:Number = SoccerBallData.getInstance().yPos;
//			var xDistance:Number = 0;
//			var yDistance:Number = 0;
//			var totalDistance:Number = 0;
//			var smallestNumber:Number = 10000;
//			var lastPlayerGettingBall:uint;	
//					
//			// get the last player who was getting the ball
//			for ( i = 0 ; i < playersArray.length ; i ++ )
//			{
//				if ( playersArray[i].data.gettingBall ) lastPlayerGettingBall = i;					
//			}		
//			// find the distance of each player from the ball
//			var q:uint;
//			for ( q = 0; q < playersArray.length; q++)
//			{	
//				if ( ! playersArray[q].data.justBeaten )
//				{
//					xDistance =  playersArray[q].data.xPos - bX ;
//					yDistance =  playersArray[q].data.yPos - bY ;
//					totalDistance = Math.sqrt( (xDistance*xDistance) + (yDistance*yDistance) ); // total distance of player from ball
//					// bias the distance here
//					// increase it for the keeper
//					if ( playersArray[q].data.isKeeper ) totalDistance += 200;
//					// decrease it for the player last in control
//					if ( q == lastPlayerGettingBall ) totalDistance -= gsd.playerRemainControlledBias;
//		
//					if ( totalDistance < smallestNumber ) 
//					{
//						smallestNumber = totalDistance;
//						if ( ! gsd.demoMode )
//						{
//							noPlayersControlled();
//							playersArray[q].data.isControlled = true;
//						}else{
//							noPlayersGettingBall();
//							playersArray[q].data.gettingBall = true;
//						}							
//					}
//				}			
//			}
//		}	
	
	}// close class
}// close package