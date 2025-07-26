/**
 * 批量发布源文件
 * 基于 TKCB 的 批量发布 fla 修改
 */

var trace = fl.trace;
main();

/**
 * 主方法
 */
function main() {
	var folderUrl = fl.browseForFolderURL("选择包含 fla 或 xfl 文件的文件夹");
	if (!FLfile.exists(folderUrl)) {
		return;
	}
	
	var count      = 0;
	var successArr = [];
	
	var files = getFilesByDir(folderUrl);
//	trace("全部文件: " + files);
//	return;
	
	for each (var file in files) {
		var smplUrl = file.replace(folderUrl, "");
		if (!publishFile(file, smplUrl)) {
			continue;
		}
		
		count++;
		successArr.push(smplUrl);
	}
	
	for each (var fileUrl in successArr) {
		trace("发布完成：" + fileUrl);
	}
	
	trace("一共 " + files.length + " 个文档，发布完成 " + count + " 个");
 }

/**
 * 获取指定目录下的所有 fla 和 xfl 文件
 */
function getFilesByDir(dirUrl) {
//	trace("\n搜索目录：" + dirUrl);
	
	var files = [];
	
	var flaMask = "*.fla";
	var xflSuf  = ".xfl";
	
	//////////////////////////////////////////////////////////////////////
	// 将当前目录下的所有 fla 文件加入文件列表
	var flaFileList = FLfile.listFolder(dirUrl + "/" + flaMask, "files");
	for each (var flaFile in flaFileList) {
		files.push(dirUrl + "/" + flaFile);
	}
//	trace("目录 " + dirUrl + " 的所有 fla 文件：" + files);
	//////////////////////////////////////////////////////////////////////
	
	
	
	//////////////////////////////////////////////////////////////////////
	// 将当前目录下符合 子目录名/子目录名.xfl 的 xfl 文件加入文件列表 
	var dirList = FLfile.listFolder(dirUrl, "directories");
	for each (var dir in dirList) {
		// 当前文件夹路径
		var curDir  = dirUrl + "/" + dir;
		// 当前可能存在的 xfl 文件名称
		var xflFile = curDir + "/" + dir + xflSuf;
		
		// 如果不存在 xfl 文件，将该子目录递归查找，并将子目录的结果链接
		if (!FLfile.exists(xflFile)) {
//			trace("xfl 文件 " + xflFile + " 不存在，将开始作为子目录递归查找");
			
			files = files.concat(getFilesByDir(curDir));
			continue;
		}
		
//		trace("目录 " + dirUrl + " 的 xfl 文件：" + xflFile);

		// 加入列表
		files.push(xflFile);
	}
	//////////////////////////////////////////////////////////////////////
	
//	trace("目录 " + dirUrl + " 的全部文件：" + files);
	return files;
}

/** 
 * 发布指定文件
 */
function publishFile(file, smplUrl) {
	var doc = fl.openDocument(file);
	
	if (!doc) {
		return false;
	}
	
	var isSwc = smplUrl.indexOf("/_") != -1;
	setPublishProfile(isSwc);
	doc.publish();
	fl.getDocumentDOM().deletePublishProfile();
	doc.close(false);
	
	return true;
}

/** 
 * 设置当前发布配置 XML 为只发布 SWF 格式的 XML 配置文件
 */
function setPublishProfile (isSwc) {
	var doc = fl.getDocumentDOM();
	
	// 创建新的 XML 发布配置文件
	var newPPName = "newPublishProfile5DPLAY" + new Date().getTime();
	var newPPNum  = doc.duplicatePublishProfile(newPPName);
	var newPPXML  = doc.exportPublishProfileString(newPPName);
	
	// 修改新的XML发布配置文件，使其只发布swf格式
	var reg = null;
	// SWF格式
	if (isSwc) {
		reg = /\<flash\>1\<\/flash\>/i;
		newPPXML = newPPXML.replace(reg, "<flash>0</flash>");
	}
	else {
		reg = /\<flash\>0\<\/flash\>/i;
		newPPXML = newPPXML.replace(reg, "<flash>1</flash>");
	}
	
	// HTML格式
	reg = /\<html\>1\<\/html\>/i;
	newPPXML = newPPXML.replace(reg, "<html>0</html>");
	
	// GIF格式
	reg = /\<gif\>1\<\/gif\>/i;
	newPPXML = newPPXML.replace(reg, "<gif>0</gif>");
	
	// JPEG格式
	reg = /\<jpeg\>1\<\/jpeg\>/i;
	newPPXML = newPPXML.replace(reg, "<jpeg>0</jpeg>");
	
	// PNG格式
	reg = /\<png\>1\<\/png\>/i;
	newPPXML = newPPXML.replace(reg, "<png>0</png>");
	
	// SWC格式
	if (isSwc) {
		reg = /\<swc\>0\<\/swc\>/i;
		newPPXML = newPPXML.replace(reg, "<swc>1</swc>");
		reg = /\<ExportSwc\>0\<\/ExportSwc\>/i;
		newPPXML = newPPXML.replace(reg, "<ExportSwc>1</ExportSwc>");
	}
	else {
		reg = /\<swc\>1\<\/swc\>/i;
		newPPXML = newPPXML.replace(reg, "<swc>0</swc>");
		reg = /\<ExportSwc\>1\<\/ExportSwc\>/i;
		newPPXML = newPPXML.replace(reg, "<ExportSwc>0</ExportSwc>");
	}
	
	// EXE格式
	reg = /\<projectorWin\>1\<\/projectorWin\>/i;
	newPPXML = newPPXML.replace(reg, "<projectorWin>0</projectorWin>");
	
	// APP格式
	reg = /\<projectorMac\>1\<\/projectorMac\>/i;
	newPPXML = newPPXML.replace(reg, "<projectorMac>0</projectorMac>");
	
	// SVG格式
	reg = /\>1\<\/publishFormat\>/i;
	newPPXML = newPPXML.replace(reg, ">0</publishFormat>");
	
	// 设置当前 XML 发布配置文件为新的 XML
	doc.importPublishProfileString(newPPXML);
}
