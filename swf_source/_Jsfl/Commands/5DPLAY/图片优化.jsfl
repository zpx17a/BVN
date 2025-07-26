fl.outputPanel.clear();

var trace = fl.outputPanel.trace;

var itemArray = fl.getDocumentDOM().library.items;
var length = itemArray.length;
for(var i = 0 ; i < length; ++i) {
	var item = itemArray[i];
	if(item.itemType == "bitmap") {
		item.allowSmoothing = true;
		item.compressionType = "photo";
		item.quality = 80;
		item.useDeblocking = false;
		trace("已优化图片：" + item.name);
	}
}

trace("------------------------优化完成!------------------------");