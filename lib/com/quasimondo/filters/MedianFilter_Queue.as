package com.quasimondo.filters
{
	final public class MedianFilter_Queue
	{
		public var value:uint;
		public var next:MedianFilter_Queue;
		
		public function MedianFilter_Queue( rgb:uint )
		{
			value = rgb;
		}
	}
}