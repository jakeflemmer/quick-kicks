package classes.views
{
	import classes.data.*;
	
	import flash.display.Shape;
	import flash.events.Event;
	
	public class PlayerShadow extends Shape
	{

	private var _playerToShadow:PlayerData;
	
		public function PlayerShadow(thePlayer:PlayerData)
		{
			// original size is 50
						
			_playerToShadow = thePlayer;
			
				
			// Add Shadow
			
			with(graphics)
			{
			beginFill(0x000000,.5);
			
			moveTo(0,0);
			lineTo(0,- GameSettingsData.getInstance().playerRadius);
			curveTo( GameSettingsData.getInstance().playerRadius*2.66, 0, 0,GameSettingsData.getInstance().playerRadius);
			
			lineTo(0,- GameSettingsData.getInstance().playerRadius);
			}
			
			super();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function onEnterFrame(e:Event):void
		{
			var shadowLength:Number = 2;
			shadowLength += (Math.sqrt((_playerToShadow.xPos*_playerToShadow.xPos)+(_playerToShadow.yPos+_playerToShadow.yPos) ) )/1500;
			with(graphics)
			{
			clear();
			beginFill(0x000000,.5);
			
			moveTo(0,0);
			lineTo(0,- GameSettingsData.getInstance().playerRadius);
			curveTo( GameSettingsData.getInstance().playerRadius*shadowLength, 0, 0,GameSettingsData.getInstance().playerRadius);
			
			lineTo(0,- GameSettingsData.getInstance().playerRadius);
			}
			
			x = _playerToShadow.xPos;
			y = _playerToShadow.yPos;
			
			
			rotation = (_playerToShadow.lightSourceAngle*180/Math.PI)-45;
		}
		
	}
}