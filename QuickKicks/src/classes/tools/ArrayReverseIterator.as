package classes.tools
{
	import classes.interfaces.*;
	
	public class ArrayReverseIterator implements IIterator
	{
		private var _index:uint = 0;
		private var _collection:Array;
		
		public function ArrayReverseIterator(collection:Array)
		{
			_collection = collection;
			_index = _collection.length-1;
						
		}
		public function hasNext():Boolean{
			return _index >= 0;
		}
		
		public function next():Object{
			return _collection[_index--];
		}
		
		public function reset():void{
			_index = _collection.length - 1;
		}
	}
}