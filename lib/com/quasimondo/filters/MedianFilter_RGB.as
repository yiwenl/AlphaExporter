package com.quasimondo.filters
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	public class MedianFilter_RGB extends EventDispatcher
	{
		
		public function MedianFilter_RGB()
		{
		}
		
		public function applyFilter( bitmapData:BitmapData, radius:int, asynchronous:Boolean = false ):void
		{
			bitmapData.lock();
			
			var w:int = bitmapData.width;
			var h:int = bitmapData.height;
			var x:int, y:int;
			
			var rowHistograms:Vector.<MedianHistogram_RGB> = new Vector.<MedianHistogram_RGB>( w, true );
			var mainHistogram:MedianHistogram_RGB = new MedianHistogram_RGB();
			
			
			var pixels:Vector.<uint> = bitmapData.getVector( bitmapData.rect );
			var firstRow:MedianHistogram_RGB;
			var currentRow:MedianHistogram_RGB = firstRow = rowHistograms[0] = new MedianHistogram_RGB();
			for ( x = 1; x < w; x++ )
			{
				currentRow = currentRow.next = rowHistograms[x] = new MedianHistogram_RGB();
			}
			
			var readIndex:uint = 0;
			for ( y = 0; y <= radius; y++ )
			{
				currentRow = firstRow;
				while ( currentRow = currentRow.addToQueue( pixels[uint(readIndex++)] )){}	
			}
			
			currentRow = firstRow;
			x = radius;
			while ( x-- > -1 )
			{
				mainHistogram.addHistogram( currentRow );
				currentRow = currentRow.next;
			}
			
			
			if ( asynchronous )
			{
				runAsynchronous( radius, 0, w, h, readIndex, 0, firstRow, mainHistogram, rowHistograms, pixels, bitmapData );
				return;
			}
			
			x = y = 0;
			var index:int;
			var ix:int;
			var radius2:int = radius+1;
			var writeIndex:uint = 0;
			
			while ( true ) 
			{
				pixels[uint(writeIndex++)] = mainHistogram.median();
				x++;
				if ( ( index = x + radius ) < w ) 
				{
					mainHistogram.addHistogram( rowHistograms[index] );
				}
				
				if ( ( index = x - radius2 ) > -1 )
				{
					mainHistogram.subtractHistogram( rowHistograms[index] );
				}
				
				if ( x == w )
				{
					x = 0;
					y++;
					if ( y == h ) break;
					
					mainHistogram.clear();
					
					if ( y > radius )
					{
						currentRow = firstRow;
						while ( currentRow = currentRow.removeFromQueue() ){}
					}
					
					if ( y < h - radius)
					{
						currentRow = firstRow;
						while ( currentRow = currentRow.addToQueue( pixels[uint(readIndex++)] ) ){}
					}	
					
					currentRow = firstRow;
					ix = radius;
					while ( ix-- > -1 )
					{
						currentRow = mainHistogram.addHistogram( currentRow );
					}
				}	
			}
			
			bitmapData.setVector( bitmapData.rect, pixels );
			bitmapData.unlock();
		}
		
		private function runAsynchronous( radius:int, y:int, w:int, h:int, readIndex:uint, writeIndex:uint, firstRow:MedianHistogram_RGB, mainHistogram:MedianHistogram_RGB, rowHistograms:Vector.<MedianHistogram_RGB>, pixels:Vector.<uint>, bitmapData:BitmapData ):void
		{
			var t:int = getTimer();
			var x:int = 0;
			var index:int, ix:int;
			var radius2:int = radius + 1;
			var currentRow:MedianHistogram_RGB;
			 
			while ( true ) 
			{
				pixels[uint(writeIndex++)] = mainHistogram.median();
				x++;
				if ( ( index = x + radius ) < w ) 
				{
					mainHistogram.addHistogram( rowHistograms[index] );
				}
				
				if ( ( index = x - radius2 ) > -1 )
				{
					mainHistogram.subtractHistogram( rowHistograms[index] );
				}
				
				if ( x == w )
				{
					x = 0;
					y++;
					if ( y == h ) break;
					
					mainHistogram.clear();
					
					if ( y > radius )
					{
						currentRow = firstRow;
						while ( currentRow = currentRow.removeFromQueue() ){}
					}
					
					if ( y < h - radius)
					{
						currentRow = firstRow;
						while ( currentRow = currentRow.addToQueue( pixels[uint(readIndex++)] ) ){}
					}	
					
					currentRow = firstRow;
					ix = radius;
					while ( ix-- > -1 )
					{
						currentRow = mainHistogram.addHistogram( currentRow );
					}
					if ( getTimer() - t > 20 ) 
					{
						setTimeout( runAsynchronous, 10, radius, y, w, h, readIndex, writeIndex, firstRow, mainHistogram, rowHistograms, pixels, bitmapData  );
						return;
					}
				}	
			}
			
			bitmapData.setVector( bitmapData.rect, pixels );
			bitmapData.unlock();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		
	}
}