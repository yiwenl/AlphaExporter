This is a simple tool to separate a image with transparency into 2 different non-transparent images, in order to reduce the file size.

To recreate the original image with actionscript : 

//	_bmpdExport 	: the export image without alpha channel
//	_bmpdAlpha 		: the alpha image

var bmpd:BitmapData = new BitmapData(_bmpd.width, _bmpd.height, true, 0x00000000);
bmpd.draw(_bmpdExport);
bmpd.copyChannel(_bmpdAlpha, bmpd.rect, new Point, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
_container.addChild(new Bitmap(bmpd));