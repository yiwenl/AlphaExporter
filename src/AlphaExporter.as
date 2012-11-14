package {
	import com.adobe.images.JPGEncoder;
	import com.bit101.components.HSlider;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	[SWF(width=1024, height=768, frameRate=30, backgroundColor=0x222222)]
	public class AlphaExporter extends Sprite {
		private var _container:Sprite;
		private var _loadFile:FileReference;
		private var _bmpd:BitmapData;
		private var _bmpdExport:BitmapData;
		private var _bmpdAlpha:BitmapData;
		private var _fileName:String;
		private var _quality:HSlider;
		private var _qualityLabel:Label;
		private var _fileNameLabel:Label;
		
		
		
		public function AlphaExporter() {
			_container = new Sprite();
			addChild(_container);
			
			var window:Window = new Window(this, 5, 5, "Controls");
			window.width = 250;
			window.height = 80;
			
			new PushButton(window.content, 5, 5, "Load Image", _onLoadImage);
			new PushButton(window.content, 5, 30, "Export Image", _onExportImage);
			
			new Label(window.content, 120, 0, "Export Quality:");
			_quality = new HSlider(window.content, 122, 20, _onSlide);
			_quality.value = 80;
			_qualityLabel = new Label(window.content, 230, 15, "80");
			_fileNameLabel = new Label(window.content, 122, 30);
		}
		
		
		private function _onSlide(e:Event) : void {
			_qualityLabel.text = Math.floor(_quality.value).toString();
		}
		
		
		private function _onLoadImage(e:Event) : void {
			_loadFile = new FileReference();
			_loadFile.addEventListener(Event.SELECT, _onSelectHandler);
			var fileFilter:FileFilter = new FileFilter("Images: (*.png)", "*.png");
			_loadFile.browse([fileFilter]);
		}
		
		
		private function _onSelectHandler(event:Event):void {
			_loadFile.removeEventListener(Event.SELECT, _onSelectHandler);
			_fileNameLabel.text = _loadFile.name;
			_fileName = _loadFile.name.split(".")[0];
			_loadFile.addEventListener(Event.COMPLETE, _onLoadCompleteHandler);
			_loadFile.load();
		}
		
		private function _onLoadCompleteHandler(event:Event):void {
			_loadFile.removeEventListener(Event.COMPLETE, _onLoadCompleteHandler);
			
			var loader:Loader = new Loader();
			
			// ... display the progress bar for converting the image data to a display object ...
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoadBytesHandler);
			loader.loadBytes(_loadFile.data);
		}
		
		
		private function _onLoadBytesHandler(event:Event):void {
			var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
			loaderInfo.removeEventListener(Event.COMPLETE, _onLoadBytesHandler);
			
			_bmpd = Bitmap(loaderInfo.content).bitmapData;
			_container.addChild(loaderInfo.content);
		}
		
		
		private function _onExportImage(e:Event) : void {
			if(_bmpd == null) return;
			_bmpdExport = new BitmapData(_bmpd.width, _bmpd.height, false, 0);
			_bmpdExport.copyChannel(_bmpd, _bmpd.rect, new Point, BitmapDataChannel.RED, BitmapDataChannel.RED);
			_bmpdExport.copyChannel(_bmpd, _bmpd.rect, new Point, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			_bmpdExport.copyChannel(_bmpd, _bmpd.rect, new Point, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			
			_bmpdAlpha = new BitmapData(_bmpd.width, _bmpd.height, false, 0);
			_bmpdAlpha.copyChannel(_bmpd, _bmpd.rect, new Point, BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
			_bmpdAlpha.copyChannel(_bmpd, _bmpd.rect, new Point, BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			_bmpdAlpha.copyChannel(_bmpd, _bmpd.rect, new Point, BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
			
			_fileNameLabel.text = "Processing ... ";
			
			var enc:JPGEncoder = new JPGEncoder(Math.floor(_quality.value));
			var ba:ByteArray = enc.encode(_bmpdExport);
			var fi:File = File.desktopDirectory.resolvePath(_fileName+"Export.jpg");
			var fs:FileStream = new FileStream();
			fs.open(fi, FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
			
			enc = new JPGEncoder(20);
			ba = enc.encode(_bmpdAlpha);
			fi = File.desktopDirectory.resolvePath(_fileName+"Alpha.jpg");
			fs = new FileStream();
			fs.open(fi, FileMode.WRITE);
			fs.writeBytes(ba);
			fs.close();
			
			_fileNameLabel.text = "Done !";
			
			while(_container.numChildren > 0) _container.removeChildAt(0);
			var bmpd:BitmapData = new BitmapData(_bmpd.width, _bmpd.height, true, 0);
			bmpd.draw(_bmpdExport);
			bmpd.copyChannel(_bmpdAlpha, bmpd.rect, new Point, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			_container.addChild(new Bitmap(bmpd));
		}
		
	}
	
}