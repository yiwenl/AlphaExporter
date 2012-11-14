package com.quasimondo.filters
{
	final public class MedianHistogramBin
	{
		public var index:int;
		public var count:int;
		
		public var next:MedianHistogramBin;
		
		/*
		public function MedianHistogramBin( index:int, count:int = 1, next:MedianHistogramBin = null)
		{
			this.index = index;
			this.count = count;
			this.next = next;
		}*/
		public function MedianHistogramBin( next:MedianHistogramBin = null )
		{
			this.next = next;
		}
	}
}