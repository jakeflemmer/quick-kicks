package classes.tools
{
	import classes.interfaces.*;
	
	public class ArrayIterator implements IIterator
	{
		private var _index:uint = 0;
		private var _collection:Array;
		
		public function ArrayIterator(collection:Array)
		{
			_collection = collection;
			_index = 0;
			
		}
		public function hasNext():Boolean{
			return _index < _collection.length;
		}
		
		public function next():Object{
			return _collection[_index++];
		}
		
		public function reset():void{
			_index = 0;
		}

	}
}