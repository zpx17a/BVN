/*
 * 作　　者：TKCB
 * 作者信息：身高（0.00167公里+）；体重（0.06吨±）；年龄（公元1990后）；籍贯（有兵马俑的地方）；星座（最后一个星座）；血型（万能型）；人生格言（The king come back.）。
 * 交流学习：加QQ群[AS3殿堂之路]（96759336）,群里有无数主城、架构、妹子、LOL战友，欢迎交流讨论。
 * 联系方式：QQ（2414268040）；E-mail（tkcb@qq.com）；手机（15029932353)。
 * 个人网站：www.tkcb.cc（来这里关注我吧，这里有我所有的作品，分享的资料，我的介绍和动态，还有更多你想不到的）
 */

var trace = fl.outputPanel.trace;

//// 重命名所有资源
var tlibrary = fl.getDocumentDOM().library;			// 当前文档库
var tItems = fl.getDocumentDOM().library.items;		// 当前文档库中所有元素（图片、元件、声音等等）
var tItem;											// 元素
var i;
var len = tItems.length;

var isChinese = confirm("点击【确定】则库文件夹以中文命名，点击【取消】则以英文命名");

var componetName = isChinese ? "组件" : "componet";
var fontName = isChinese ? "字体" : "font";
var soundName = isChinese ? "声音" : "sound";
var bitmapName = isChinese ? "图片" : "picture";
var videoName = isChinese ? "视频" : "video";
var mcName = isChinese ? "元件" : "mc";

//// 创建库文件夹
tlibrary.newFolder( componetName );
tlibrary.newFolder( fontName );
tlibrary.newFolder( soundName );
tlibrary.newFolder( bitmapName );
tlibrary.newFolder( videoName );
tlibrary.newFolder( mcName );

//// 为了在重命名时候，名称不冲突，故先将所有名称随机命名一次
len = tItems.length;
for ( i = 0; i < len; i++ )
{
	var myDate = new Date();
	tItem = tItems[ i ];
	if ( tItem.name != componetName && tItem.name != fontName && tItem.name != bitmapName && tItem.name != soundName && tItem.name != videoName && tItem.name != mcName )
	{
		tItem.name = "TKCB" + myDate.getTime() + Math.round( Math.random() * 100000000 );
	}
	if ( tItem.itemType != "folder" )
	{
		//// 根据库资源类型把资源移动相应的文件夹中
		switch ( tItem.itemType )
		{
			case "component":
				tlibrary.moveToFolder( componetName, tItem.name );
				break;
			case "font":
				tlibrary.moveToFolder( fontName, tItem.name );
				break;
			case "bitmap":
				tlibrary.moveToFolder( bitmapName, tItem.name );
				break;
			case "sound":
				tlibrary.moveToFolder( soundName, tItem.name );
				break;
			case "video":
				tlibrary.moveToFolder( videoName, tItem.name );
				break;
			default:
				tlibrary.moveToFolder( mcName, tItem.name );
				break;
		}
	}
}

//// 删除无用的库文件夹（上面的循环已经将多余的文件夹为空了）
len = tItems.length;
for ( i = 0; i < len; i++ )
{
	tItem = tItems[ i ];
	if ( tItem.itemType == "folder" )
	{
		if ( tItem.name != fontName && tItem.name != mcName && tItem.name != bitmapName && tItem.name != soundName && tItem.name != videoName && tItem.name != componetName )
		{
			tlibrary.deleteItem( tItem.name );
		}
	}
}

//// 循环重命名资源
var componentNum = 1;	// 资源序号（组件）
var fontNum = 1;		// 资源序号（字体）
var pictureNum = 1;		// 资源序号（图片）
var soundNum = 1;		// 资源序号（声音）
var videoNum = 1;		// 资源序号（视频）
var buttonNum = 1;		// 资源序号（按钮）
var mcNum = 1;			// 资源序号（元件）
var shapeNum = 1;		// 资源序号（图形）
var strPrefix;			// 重命名资源的前缀数字（000或者00或者0或者""）

len = tItems.length;
for ( i = 0; i < len; i++ )
{
	tItem = tItems[ i ];
	if ( tItem.name != fontName && tItem.name != mcName && tItem.name != bitmapName && tItem.name != soundName && tItem.name != videoName && tItem.name != componetName && tItem.itemType != "undefined" )
	{
		strPrefix = "";
		
		//// 根据库资源类型获取当前要命名的资源的序号
		var num;
		switch ( tItem.itemType )
		{
			case "component":
				num = componentNum;
				break;
			case "font":
				num = fontNum;
				break;
			case "bitmap":
				num = pictureNum;
				break;
			case "sound":
				num = soundNum;
				break;
			case "video":
				num =  videoNum;
				break;
			case "button":
				num =  buttonNum;
				break;
			case "movie clip":
				num =  mcNum;
				break;
			case "graphic":
				num =  shapeNum;
				break;
		}
		
		//// 如果资源数量为千位数（相信不会用上万的资源吧！！哈哈）
		if ( len >= 1000 )
		{
			if ( num < 10 )
			{
				strPrefix = "000";
			}
			else if ( num < 100 )
			{
				strPrefix = "00";
			}
			else if ( num < 1000 )
			{
				strPrefix = "0";
			}
		}
		//// 如果资源数量为百位数
		else if ( len >= 100 )
		{
			if ( num < 10 )
			{
				strPrefix = "00";
			}
			else if ( num < 100 )
			{
				strPrefix = "0";
			}
		}
		//// 如果资源数量为十位数
		else if ( len >= 10 )
		{
			if ( num < 10 )
			{
				strPrefix = "0";
			}
		}
		
		//// 根据库资源类型进行重命名
		switch ( tItem.itemType )
		{
			case "component":
				tItem.name = "component_" + strPrefix + componentNum;
				componentNum++;
				break;
			case "font":
				tItem.name = "font_" + strPrefix + fontNum;
				fontNum++;
				break;
			case "bitmap":
				tItem.name = "picture_" + strPrefix + pictureNum;
				pictureNum++;
				break;
			case "sound":
				tItem.name = "sound_" + strPrefix + soundNum;
				soundNum++;
				break;
			case "video":
				tItem.name = "video_" + strPrefix + videoNum;
				videoNum++;
				break;
			case "button":
				tItem.name = "button_" + strPrefix + buttonNum;
				buttonNum++;
				break;
			case "movie clip":
				tItem.name = "mc_" + strPrefix + mcNum;
				mcNum++;
				break;
			case "graphic":
				tItem.name = "shape_" + strPrefix + shapeNum;
				shapeNum++;
				break;
		}
	}
}


trace( "---------------------重命名并整理所有资源完成！---------------------" );