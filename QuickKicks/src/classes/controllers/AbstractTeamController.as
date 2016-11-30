package classes.controllers
{
	import flash.display.Sprite;
	
	import mx.collections.ArrayCollection;
	import mx.core.INavigatorContent;
	
	import classes.data.FieldData;
	import classes.data.GameSettingsData;
	import classes.data.PlayerData;
	import classes.data.SoccerBallData;
	import classes.data.TeamData;
	import classes.tools.Calculator;
	import classes.tools.ESP;
	import classes.tools.RadiansCalculator;
	import classes.views.PassLineIndicator;
	import classes.views.PlayerShadow;
	
	public class AbstractTeamController extends Sprite 
	{
	
		protected var frameCount:uint = 0;
		protected var oldFrameCount:uint = 0;
		protected var radCalc:RadiansCalculator
		protected var passLine:PassLineIndicator;
		protected var autoPassFrameNum:Number = 0;		
		
		protected var keeper:AbstractPlayerController;
		protected var player1:AbstractPlayerController;
		protected var player2:AbstractPlayerController;
		protected var player3:AbstractPlayerController;
		protected var player4:AbstractPlayerController;		
		protected var playersArray:Array;		
		
		protected var keeperShadow:PlayerShadow;
		protected var player1Shadow:PlayerShadow;
		protected var player2Shadow:PlayerShadow;
		protected var player3Shadow:PlayerShadow;
		protected var player4Shadow:PlayerShadow;
		
		protected var _data:TeamData;
		
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
		
		public function set pwbd(val:PlayerData):void{
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
			
		
		public function AbstractTeamController()
		{		
			radCalc = new RadiansCalculator;
			passLine = new PassLineIndicator;
			
									
		}
		
//  __________________________________________________________________________________________________________________________________________
	
		protected function frameNumber():void{
			if ( _data.justChangedPassLineIndicator  )
			{
				if ( FieldData.getInstance().frameNumber > _data.passLineFrameNo + gsd.passLinePauseFrames )
				{
					_data.justChangedPassLineIndicator = false;
				}
			}
		}
		
		
		public function noPlayersHaveBall():void
		{
			keeper.data.hasBall = false;
			player1.data.hasBall = false;
			player2.data.hasBall = false;
			player3.data.hasBall = false;
			player4.data.hasBall = false;
		}
		public function resetAllPlayerProperties():void
		{	
			noPlayersHaveBall();
					
			for ( var i:int =0; i < playersArray.length; i++)
			{
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
			}
		}
		public function lostPossession():void
		{					
			noPlayersHaveBall();
			passLine.clear();
		
			var i:int;
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
			var i:int;
			for ( i=0; i < playersArray.length; i++)
			{
				playersArray[i].data.gettingBall = false;					
			}
		}
		protected function checkZonePlayerWithBallIsIn():void
		{
			if (_data.playerWithBallData.xPos < 750 ) // zone 1 or 2
			{
				if ( _data.playerWithBallData.yPos < 500 ) 
				{
					_data.playerWithBallData.zone = 1;
				} else 
				{
					_data.playerWithBallData.zone = 2;
				}
			} else  // zone 3 or 4 
			{
				if (_data.playerWithBallData.yPos < 500 )
				{
					_data.playerWithBallData.zone = 3;
				} else
				{
					_data.playerWithBallData.zone = 4;
				}				
			}		
		}
		
		protected function giveNewGetFreeDestination(player:uint):void
		{				
			playersArray[player].data.destinationX = calculateGetFreeX(playersArray[player].data.zone);
			playersArray[player].data.destinationY = calculateGetFreeY(playersArray[player].data.zone);	
		}
		protected function giveAllNewGetFreeDestinations():void
		{
			for (var i:uint=0; i<5; i ++)
			{		
				giveNewGetFreeDestination(i);
			}
		}	
		protected function calculatedDistanceFromGetFreeZone(player:uint):Number
		{
			var XDistance:Number = Math.abs( playersArray[player].data.xPos - playersArray[player].data.destinationX );
			var YDistance:Number = Math.abs( playersArray[player].data.yPos - playersArray[player].data.destinationY ); 
			var totalDistance:Number  = XDistance + YDistance;
			return totalDistance;
		}
			
		protected function calculateGetFreeX(zone:uint):Number
		{
			var getFreeX:Number = 0;
		
			switch (zone)
			{
				case 0:
					getFreeX = (Math.random() * 175) + 450;
					break;
				case 1:
					getFreeX = (Math.random() * 300) + 300;									
					break;
				case 2:				
					getFreeX = (Math.random() * 300) + 300;				
					break;
				case 3:				
					getFreeX = (Math.random() * 300) + 900;				
					break;
				case 4:				
					getFreeX = (Math.random() * 300) + 900;				
					break;
				case 5:
					getFreeX = 1050 - (Math.random() * 175);				
					break;
			}
			return getFreeX;				
		}
		
		protected function calculateGetFreeY(zone:uint):Number
		{
			var getFreeY:Number = 0;
		
			switch (zone)
			{
				case 0:
					getFreeY = (Math.random() * 200) + 400;
				case 1:
					getFreeY = (Math.random() * 300) + 100;			
					break;
				case 2:				
					getFreeY = (Math.random() * 300) + 600;
					break;
				case 3:				
					getFreeY = (Math.random() * 300) + 100;
					break;
				case 4:				
					getFreeY = (Math.random() * 300) + 600;
					break;
				case 5:				
					getFreeY = (Math.random() * 200) + 400;
					break;
			}
			return getFreeY;	
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
		
		protected function openPass():Boolean
		{		
			if ( pwbd.isKeeper ) return true;
			
			var angleOfReceiver:Number = RadiansCalculator.calc((_data.closestTeamMate.xPos - pwbd.xPos),(_data.closestTeamMate.yPos - pwbd.yPos));
			var angleOfDefender:Number = RadiansCalculator.calc((pwbd.playerMarking.xPos - pwbd.xPos),(pwbd.playerMarking.yPos - pwbd.yPos));
			var a:Number = Math.abs( angleOfReceiver - angleOfDefender );
			var xDistToDef:Number = Math.abs(pwbd.xPos - pwbd.playerMarking.xPos);
			var yDistToDef:Number = Math.abs(pwbd.yPos - pwbd.playerMarking.yPos);
			var distanceToDefender:Number = Math.sqrt( (xDistToDef*xDistToDef) + ( yDistToDef*yDistToDef) );
			
			var xDistToRec:Number = Math.abs(_data.closestTeamMate.xPos - pwbd.xPos );
			var yDistToRec:Number = Math.abs(_data.closestTeamMate.yPos - pwbd.yPos );
			var distToRec:Number = Math.sqrt( (xDistToRec*xDistToRec) + (yDistToRec*yDistToRec) );
			var x:Number;
			x = Math.abs( Math.sin(a) ) * distToRec;
			if ( x > gsd.playerRadius + sbd.radius )
				return true;		
			return false;
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
		
		
	
		protected function calculatePassOrShootAngle():void
		{		
			
			var playerAnglesArray:Array = new Array();
			for ( var a:uint = 0; a < playersArray.length; a++)
			{
				var eachPlayerController:AbstractPlayerController = playersArray[a];
				var eachPlayer:PlayerData = eachPlayerController.data;
				if ( eachPlayer === pwbd )
				{
					continue;
				}
				var angle:Number = RadiansCalculator.calc( eachPlayer.xPos - pwbd.xPos , eachPlayer.yPos - pwbd.yPos);
				var angleObject: Object = new Object();
				angleObject.player = eachPlayer;
				angleObject.angle = angle;
				angleObject.xPos = eachPlayer.xPos;
				angleObject.yPos = eachPlayer.yPos;
				playerAnglesArray.push(angleObject);
			}
			
			var lgX:Number; var lgY:Number;
			var rgX:Number; var rgY:Number;
			lgX = _data.scorePost.postsX;lgY = _data.scorePost.leftPostY;
			rgX = _data.scorePost.postsX;rgY = _data.scorePost.rightPostY;
			
			var leftGoalObject:Object = new Object();
			leftGoalObject.player = null;
			leftGoalObject.angle = RadiansCalculator.calc( lgX - pwbd.xPos, lgY - pwbd.yPos );
			leftGoalObject.xPos = lgX;
			leftGoalObject.yPos = lgY;
			
			var rightGoalObject:Object = new Object();
			rightGoalObject.player = null;
			rightGoalObject.angle = RadiansCalculator.calc (rgX - pwbd.xPos ,rgY -  pwbd.yPos );
			rightGoalObject.xPos = rgX;
			rightGoalObject.yPos = rgY;
			
			if ( ! pwbd.isKeeper )
			{
				playerAnglesArray.push( leftGoalObject );
				playerAnglesArray.push( rightGoalObject );
			}
			
			
			// find the smallest pass angle
			// draw the pass line to it
			//var smallestNumber : Number = 1000;
			//var biggestNumber : Number = 0;
			
			var smallestAngleDelta : Number = 7;
			var selectedAngleObject:Object;
			
			for ( var b:uint = 0; b < playerAnglesArray.length; b++)
			{
				var angleDelta:Number = playerAnglesArray[b].angle - pwbd.dribble;
				if ( Math.abs ( angleDelta ) < Math.abs(smallestAngleDelta) )
				{
					smallestAngleDelta = angleDelta;
					selectedAngleObject = playerAnglesArray[b];
				}
				//if ( playerAnglesArray[b].angle - <= smallestNumber ) smallestNumber = playerAnglesArray[b].angle;
				//if ( playerAnglesArray[b].angle >= biggestNumber ) biggestNumber = playerAnglesArray[b].angle;
				// find the angle that is closest to the pwbd dribble
				
			}
			
			passLine.clear();
			
			// now we have an angle object in our hands that should provide us with all the info we need
			
			// if the pass angle is too large then its not possible.
			if ( smallestAngleDelta > Math.PI * 0.5 || smallestAngleDelta < ( -1 ) * Math.PI * 0.5 ) return;
				
			pwbd.autoPassAngle = selectedAngleObject.angle;
			pwbd.playerPassingTo = selectedAngleObject.player;
			//ESP.p("player passing to : " + (selectedAngleObject.player as PlayerData).id,"abstract","passline");
			_data.autoPassAngle = selectedAngleObject.angle;
			if ( selectedAngleObject.player == null )
			{
				pwbd.scoreBall = true;
				_data.scorePost.goingForPost = selectedAngleObject.yPos;
			}else{
				_data.closestTeamMate = selectedAngleObject.player;
				//_data.closestTeamMate.passReceiver = true;
			}
			
			passLine.draw( pwbd.xPos, pwbd.yPos, selectedAngleObject.xPos, selectedAngleObject.yPos );// DRAW LINE   ----------------------------------
				
				
		}
	
	
		
		
	protected function noPlayersPassReceiver():void
	{
		keeper.data.passReceiver = false;
		player1.data.passReceiver = false;
		player2.data.passReceiver = false;
		player3.data.passReceiver = false;
		player4.data.passReceiver = false;
	}
	
	
	

	
	}// close class
}// close package