package com.quasimondo.filters
{
	final public class MedianHistogram_RGB
	{
		public var bin_r:MedianHistogramBin;
		public var bin_g:MedianHistogramBin;
		public var bin_b:MedianHistogramBin;
		
		public var totalCount:int;
		
		public var next:MedianHistogram_RGB;
		
		private var queueStart:MedianFilter_Queue;
		private var queueEnd:MedianFilter_Queue;
		
		public function MedianHistogram_RGB()
		{
			init();
		}

		private function init():void
		{
			queueStart = queueEnd = new MedianFilter_Queue(0);
			bin_r = new MedianHistogramBin();
			bin_g = new MedianHistogramBin();
			bin_b = new MedianHistogramBin();
		}
		
		
		public function addValue( rgb:uint ):void
		{
			var r:int = ( rgb >> 16 ) & 0xff;
			var g:int = ( rgb >>  8 ) & 0xff;
			var b:int =   rgb         & 0xff;
			
			var bin:MedianHistogramBin = bin_r;
			while ( true )
			{
				if ( bin.next != null )
				{
					if ( bin.next.index == r )
					{
						bin.next.count++;
						break;
					} else if ( bin.next.index > r )
					{
						bin.next = new MedianHistogramBin( bin.next );
						bin.next.index = r;
						bin.next.count = 1;
						break;
					} else {
						bin = bin.next;
					}
				} else {
					bin = bin.next = new MedianHistogramBin();
					bin.index = r;
					bin.count = 1;
					break;
				}
			}
			
			bin = bin_g;
			while ( true )
			{
				if ( bin.next != null )
				{
					if ( bin.next.index == g )
					{
						bin.next.count++;
						break;
					} else if ( bin.next.index > g )
					{
						bin.next = new MedianHistogramBin( bin.next );
						bin.next.index = g;
						bin.next.count = 1;
						break;
					} else {
						bin = bin.next;
					}
				} else {
					bin = bin.next = new MedianHistogramBin();
					bin.index = g;
					bin.count = 1;
					break;
				}
			}
			
			bin = bin_b;
			while ( true )
			{
				if ( bin.next != null )
				{
					if ( bin.next.index == b )
					{
						bin.next.count++;
						break;
					} else if ( bin.next.index > b )
					{
						bin.next = new MedianHistogramBin( bin.next );
						bin.next.index = b;
						bin.next.count = 1;
						break;
					} else {
						bin = bin.next;
					}
				} else {
					bin = bin.next = new MedianHistogramBin();// b );
					bin.index = b;
					bin.count = 1;
					break;
				}
			}
			
			totalCount++;
		}
		
		public function subtractValue( rgb:uint ):void
		{
			var r:int = ( rgb >> 16 ) & 0xff;
			var g:int = ( rgb >> 8 ) & 0xff;
			var b:int =  rgb & 0xff;
			
			var bin:MedianHistogramBin = bin_r;
			var index:int = r;
			while ( true )
			{
				if ( bin.next != null )
				{
					if ( bin.next.index == index )
					{
						bin.next.count--;
						if ( bin.next.count <= 0 ) bin.next = bin.next.next;	
						break;
					} else {
						bin = bin.next;
					}
				} else {
					bin = bin.next;	
				}
			}
			
			bin = bin_g;
			index = g;
			while ( true )
			{
				if ( bin.next != null )
				{
					if ( bin.next.index == index )
					{
						bin.next.count--;
						if ( bin.next.count <= 0 ) bin.next = bin.next.next;	
						break;
					} else {
						bin = bin.next;
					}
				} else {
					bin = bin.next;	
				}
			}
			
			bin = bin_b;
			index = b;
			while ( true )
			{
				if ( bin.next != null )
				{
					if ( bin.next.index == index )
					{
						bin.next.count--;
						if ( bin.next.count <= 0 ) bin.next = bin.next.next;	
						break;
					} else {
						bin = bin.next;
					}
				} else {
					bin = bin.next;	
				}
			}
			
			totalCount--;
		}
		
		public function addToQueue( rgb:uint ):MedianHistogram_RGB
		{
			addValue( rgb );
			queueEnd = queueEnd.next = new MedianFilter_Queue(rgb);
			return next;
		}

		public function removeFromQueue():MedianHistogram_RGB
		{
			subtractValue( queueStart.next.value );
			queueStart.next = queueStart.next.next;
			return next;
		}
		
		public function addHistogram( histogram:MedianHistogram_RGB ):MedianHistogram_RGB
		{
			var bin:MedianHistogramBin = bin_r;
			var insert:MedianHistogramBin = histogram.bin_r.next;
			while ( insert != null )
			{
				while ( bin != null )
				{
					if ( bin.next != null )
					{
						if ( bin.next.index == insert.index )
						{
							bin.next.count += insert.count;
							break;
						} else if ( bin.next.index > insert.index )
						{
							bin.next = new MedianHistogramBin( bin.next );
							bin.next.index = insert.index;
							bin.next.count = insert.count;
							break;
						} else {
							bin.next;
						}
						
					} else {
						bin.next = new MedianHistogramBin();
						bin.next.index = insert.index;
						bin.next.count = insert.count;
						break;
					}
					bin = bin.next;
				}
				insert = insert.next;
			}
			
			bin = bin_g;
			insert = histogram.bin_g.next;
			while ( insert != null )
			{
				while ( bin != null )
				{
					if ( bin.next != null )
					{
						if ( bin.next.index == insert.index )
						{
							bin.next.count += insert.count;
							break;
						} else if ( bin.next.index > insert.index )
						{
							bin = bin.next = new MedianHistogramBin( bin.next );
							bin.index = insert.index;
							bin.count = insert.count;
							break;
						} else {
							bin = bin.next;
						}
					} else {
						bin = bin.next = new MedianHistogramBin();
						bin.index = insert.index;
						bin.count = insert.count;
						break;
					}
				}
				insert = insert.next;
			}
			
			bin = bin_b;
			insert = histogram.bin_b.next;
			while ( insert != null )
			{
				while ( bin != null )
				{
					if ( bin.next != null )
					{
						if ( bin.next.index == insert.index )
						{
							bin.next.count += insert.count;
							break;
						} else if ( bin.next.index > insert.index )
						{
							bin = bin.next = new MedianHistogramBin( bin.next );
							bin.index = insert.index;
							bin.count = insert.count;
							break;
						} else {
							bin = bin.next;
						}
					} else {
						bin = bin.next = new MedianHistogramBin();
						bin.index = insert.index;
						bin.count = insert.count;
						break;
					}
				}
				insert = insert.next;
			}
			
			totalCount += histogram.totalCount;
			return histogram.next;
		}
		
		public function subtractHistogram( histogram:MedianHistogram_RGB ):void
		{
			var bin:MedianHistogramBin = bin_r;
			var remove:MedianHistogramBin = histogram.bin_r.next;
			while ( remove != null )
			{
				while ( true )
				{
					if ( bin.next.index == remove.index )
					{
						bin.next.count -= remove.count;
						if ( bin.next.count == 0 ) bin.next = bin.next.next;
						break;
					} else {
						bin = bin.next;
					}
				}
				remove = remove.next;
			}
			
			bin = bin_g;
			remove = histogram.bin_g.next;
			while ( remove != null )
			{
				while ( true )
				{
					if ( bin.next.index == remove.index )
					{
						bin.next.count -= remove.count;
						if ( bin.next.count == 0 ) bin.next = bin.next.next;	
						break;
					} else {
						bin = bin.next;
					}
				}
				
				remove = remove.next;
			}
			
			bin = bin_b;
			remove = histogram.bin_b.next;
			
			while ( remove != null )
			{
				while ( true )
				{
					if ( bin.next.index == remove.index )
					{
						bin.next.count -= remove.count;
						if ( bin.next.count == 0 ) bin.next = bin.next.next;	
						break;
					} else {
						bin = bin.next;
					}
				}
				
				remove = remove.next;
			}
			
			totalCount -= histogram.totalCount;
		}
		
		public function clear():void
		{
			bin_r.next = null;
			bin_g.next = null;
			bin_b.next = null;
			totalCount = 0;
		}
		
		public function median():uint
		{
			var medianValue:int = totalCount >> 1;
			var result:uint = 0xff000000;
			var bin:MedianHistogramBin = bin_r;
			var count:int = medianValue;
			while ( count > 0 )
			{
				bin = bin.next;
				count -= bin.count;
			}
			result |= bin.index << 16;
			
			bin = bin_g;
			count = medianValue;
			while ( count > 0 )
			{
				bin = bin.next;
				count -= bin.count;
			}
			result |= bin.index << 8;
			
			bin = bin_b;
			count = medianValue;
			while ( count > 0 )
			{
				bin = bin.next;
				count -= bin.count;
			}
			
			return result | bin.index;
		}
		
		public function toString():String
		{
			var result:String = "";
			var bin:MedianHistogramBin = bin_b.next;
			
			while (bin != null){
				result += bin.index+"="+bin.count+" | ";
				bin = bin.next;
			}
			result += "Median: "+median();
			return result;	
		}
		

	}
}