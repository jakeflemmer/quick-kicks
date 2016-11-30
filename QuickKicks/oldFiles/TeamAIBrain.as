package classes
{
	public class TeamAIBrain
	{
		public function TeamAIBrain()
		{
			// this class is here to perform strategy and do the thinking
			// of the CPU team
			// obviuosly no human player will have this class added to their team
		}

		public function decideWhatTodo(playersArray:Array,pwbd:PlayerData):Array{
			
			//doNothing
			return playersArray;
			
			// the below code is taken straight out of the abstract teams on_enter_frame
			// it should rather be done here
			
//			if ( pwbd != null ){
//				
//				pwbd.autoPassAngle = calculatePassOrShootAngle();
//				
//				if ( this.passOrShootAngleCalculator.passReciever ){
//					passLine.draw( pwbd.xPos, pwbd.yPos, this.passOrShootAngleCalculator.passReciever.xPos, this.passOrShootAngleCalculator.passReciever.yPos); 
//					
//				}				 
//				
//				if ( scoreBall() )
//				{
//					passLine.draw( pwbd.xPos, pwbd.yPos, this.passOrShootAngleCalculator.closestGoalPostX, this.passOrShootAngleCalculator.closestGoalPostY);
//					// if (openScoreBall() )  TODO still need to write this function
//					takeTheShot();
//					return;
//				}	
//								
//			
//				if ( ! pwbd.isKeeper ) 
//				{			
//					var space:Number = pwbd.space;					
//					var three:Number = gsd.playerRadius * 5;
//					var two:Number = gsd.playerRadius * 2;
//					var one:Number = gsd.playerRadius;
//					
//					if ( space >= three )
//					{
//				//		tryToBeatDefender();
//						_data.pressureToPass = false;
//						
//					}
//						//				else if ( space >= two )
//						//				{
//						//					lookForBestPass();					
//						//					
//						//				}
//					else //if ( space < two )
//					{
//			//			protectBall();
//						_data.pressureToPass = true;										
//					}
//					
//				} else {
//					_data.pressureToPass = true;
//				}
//				
//				if ( _data.pressureToPass )
//				{	
//					if ( Calculator.instance.openPass(pwbd,_data.closestTeamMate) )
//					{
////					if ( openPass() )
////					{					
////						if ( receiverNotCovered() )  // prevent interceptions
////						{
//							//if ( Math.abs(_data.autoPassAngle - pwbd.dribble) < Math.PI * .5 || Math.abs(_data.autoPassAngle - pwbd.dribble) > Math.PI * 1.5)
//							//{
//						//	precisionPass();
//							pwbd.passNow = true;
//							//sbd.passReceiver = pwbd;
//							//}						
////						}				 
////					}
//					}
//				}							
//			}	
			return null;	
		}
	}//close class
}// close package