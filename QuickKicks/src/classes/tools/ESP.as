package classes.tools
{
	public class ESP
	{

		public function ESP()
		{
			
		}
		public static function p( message:String , team:String, tag : String ) : void {
			if ( tag != "getting ball")
			{
				return;
			}
			trace ( team + " - " + tag + " : " + message );
		}
	}
}