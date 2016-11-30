package classes
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import mx.containers.Canvas;
	
	public class PlayIcon extends Sprite
	{
		private var _data:GameSettingsData;
		private var playIcon:Shape;
		private var circle:Shape;
		private var playFilter:GlowFilter;
		
		public function PlayIcon()
		{
			_data = GameSettingsData.getInstance();
			_data.addEventListener(GameEvents.GAME_PAUSED,onGamePaused);
			playIcon = new Shape;
			circle = new Shape;
			playFilter = new GlowFilter(0x630909,1,12,12,5);
			this.addEventListener(MouseEvent.CLICK,onClick);
			
			this.addChild(playIcon);
			this.addChild(circle);
			this.playIcon.visible = false;  // invisible by default - becomes visible when game is paused	
			this.circle.visible = false;
			draw();
		}
		
		private function draw():void
		{
			with (playIcon.graphics)
			{
				lineStyle(1,0xffffff,1)
				moveTo(0,0);
				beginFill(0xffffff,.6);
				moveTo(-50,-50);
				lineTo(-50,50);
				lineTo(50,0);
				lineTo(-50,-50);
				
				endFill();
			}
			with (circle.graphics)
			{
				lineStyle(1,0xffffff);
				drawCircle(-15,0,75);
				drawCircle(-15,0,80);
			}
			//circle.filters = [playFilter];
			
		}
		private function onGamePaused(e:GameEvents):void
		{
//			var field:DisplayObject = (this.parent as DisplayObject);
//			var gc:DisplayObject = (field.parent as DisplayObject);
//			var stageCvs:Canvas = (gc.parent as Canvas);
//			var bsc:Canvas = (stageCvs.parent as Canvas);
//			this.x = bsc.width/2;
//			this.y = bsc.height/2;
			playIcon.visible = true;
			circle.visible = true;
		}
		private function onClick(e:MouseEvent):void
		{
			GameSettingsData.getInstance().paused = false;
			playIcon.visible = false;
			circle.visible = false;
		}

	}
}