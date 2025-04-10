#import "UIColor+Expanded.h"

/*
 
 Thanks to Poltras, Millenomi, Eridius, Nownot, WhatAHam, jberry,
 and everyone else who helped out but whose name is inadvertantly omitted
 
 */

/*
 Current outstanding request list:
 
 - PolarBearFarm - color descriptions ([UIColor warmGrayWithHintOfBlueTouchOfRedAndSplashOfYellowColor])
 - Crayola color set
 - Eridius - UIColor needs a method that takes 2 colors and gives a third complementary one
 - Consider UIMutableColor that can be adjusted (brighter, cooler, warmer, thicker-alpha, etc)
 */

/*
 FOR REFERENCE: Color Space Models: enum CGColorSpaceModel {
 kCGColorSpaceModelUnknown = -1,
 kCGColorSpaceModelMonochrome,
 kCGColorSpaceModelRGB,
 kCGColorSpaceModelCMYK,
 kCGColorSpaceModelLab,
 kCGColorSpaceModelDeviceN,
 kCGColorSpaceModelIndexed,
 kCGColorSpaceModelPattern
 };
 */

// Static cache of looked up color names. Used with +colorWithName:
static NSMutableDictionary *colorNameCache = nil;

#if SUPPORTS_UNDOCUMENTED_API
// UIColor_Undocumented
// Undocumented methods of UIColor
@interface UIColor (UIColor_Undocumented)
- (NSString *)styleString;
@end
#endif // SUPPORTS_UNDOCUMENTED_API

@interface UIColor (UIColor_Expanded_Support)
+ (UIColor *)searchForColorByName:(NSString *)cssColorName;
@end

#pragma mark -

@implementation UIColor (UIColor_Expanded)

- (CGColorSpaceModel)colorSpaceModel {
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *)colorSpaceString {
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelUnknown:
			return @"kCGColorSpaceModelUnknown";
		case kCGColorSpaceModelMonochrome:
			return @"kCGColorSpaceModelMonochrome";
		case kCGColorSpaceModelRGB:
			return @"kCGColorSpaceModelRGB";
		case kCGColorSpaceModelCMYK:
			return @"kCGColorSpaceModelCMYK";
		case kCGColorSpaceModelLab:
			return @"kCGColorSpaceModelLab";
		case kCGColorSpaceModelDeviceN:
			return @"kCGColorSpaceModelDeviceN";
		case kCGColorSpaceModelIndexed:
			return @"kCGColorSpaceModelIndexed";
		case kCGColorSpaceModelPattern:
			return @"kCGColorSpaceModelPattern";
		default:
			return @"Not a valid color space";
	}
}

- (BOOL)canProvideRGBComponents {
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
		case kCGColorSpaceModelMonochrome:
			return YES;
		default:
			return NO;
	}
}

- (NSArray *)arrayFromRGBAComponents {
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -arrayFromRGBAComponents");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [NSArray arrayWithObjects:
			[NSNumber numberWithFloat:r],
			[NSNumber numberWithFloat:g],
			[NSNumber numberWithFloat:b],
			[NSNumber numberWithFloat:a],
			nil];
}

- (BOOL)red:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
	const CGFloat *components = CGColorGetComponents(self.CGColor);
	
	CGFloat r,g,b,a;
	
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			a = components[1];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			a = components[3];
			break;
		default:	// We don't know how to handle this model
			return NO;
	}
	
	if (red) *red = r;
	if (green) *green = g;
	if (blue) *blue = b;
	if (alpha) *alpha = a;
	
	return YES;
}

- (CGFloat)red {
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)green {
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat)blue {
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat)white {
	NSAssert(self.colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)alpha {
	return CGColorGetAlpha(self.CGColor);
}

- (UInt32)rgbHex {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return 0;
	
	r = MIN(MAX(self.red, 0.0f), 1.0f);
	g = MIN(MAX(self.green, 0.0f), 1.0f);
	b = MIN(MAX(self.blue, 0.0f), 1.0f);
	
	return (((int)roundf(r * 255)) << 16)
	| (((int)roundf(g * 255)) << 8)
	| (((int)roundf(b * 255)));
}

#pragma mark Arithmetic operations

- (UIColor *)colorByLuminanceMapping {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	// http://en.wikipedia.org/wiki/Luma_(video)
	// Y = 0.2126 R + 0.7152 G + 0.0722 B
	return [UIColor colorWithWhite:r*0.2126f + g*0.7152f + b*0.0722f
							 alpha:a];
	
}

- (UIColor *)colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r * red))
						   green:MAX(0.0, MIN(1.0, g * green)) 
							blue:MAX(0.0, MIN(1.0, b * blue))
						   alpha:MAX(0.0, MIN(1.0, a * alpha))];
}

- (UIColor *)colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r + red))
						   green:MAX(0.0, MIN(1.0, g + green)) 
							blue:MAX(0.0, MIN(1.0, b + blue))
						   alpha:MAX(0.0, MIN(1.0, a + alpha))];
}

- (UIColor *)colorByLighteningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [UIColor colorWithRed:MAX(r, red)
						   green:MAX(g, green)
							blue:MAX(b, blue)
						   alpha:MAX(a, alpha)];
}

- (UIColor *)colorByDarkeningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [UIColor colorWithRed:MIN(r, red)
						   green:MIN(g, green)
							blue:MIN(b, blue)
						   alpha:MIN(a, alpha)];
}

- (UIColor *)colorByMultiplyingBy:(CGFloat)f {
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *)colorByAdding:(CGFloat)f {
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *)colorByLighteningTo:(CGFloat)f {
	return [self colorByLighteningToRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *)colorByDarkeningTo:(CGFloat)f {
	return [self colorByDarkeningToRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *)colorByMultiplyingByColor:(UIColor *)color {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [self colorByMultiplyingByRed:r green:g blue:b alpha:1.0f];
}

- (UIColor *)colorByAddingColor:(UIColor *)color {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [self colorByAddingRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *)colorByLighteningToColor:(UIColor *)color {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [self colorByLighteningToRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *)colorByDarkeningToColor:(UIColor *)color {
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
	
	return [self colorByDarkeningToRed:r green:g blue:b alpha:1.0f];
}

#pragma mark String utilities

- (NSString *)stringFromColor {
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -stringFromColor");
	NSString *result;
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
			break;
		case kCGColorSpaceModelMonochrome:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f}", self.white, self.alpha];
			break;
		default:
			result = nil;
	}
	return result;
}

- (NSString *)hexStringFromColor {
	return [NSString stringWithFormat:@"%0.6X", self.rgbHex];
}

#pragma mark Class methods

+ (UIColor *)randomColor {
	return [UIColor colorWithRed:(CGFloat)RAND_MAX / random()
						   green:(CGFloat)RAND_MAX / random()
							blue:(CGFloat)RAND_MAX / random()
						   alpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}

// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
+ (UIColor *)colorWithTheHexString:(NSString *)stringToConvert {
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	return [UIColor colorWithRGBHex:hexNum];
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha {
    // 删除字符串中的空格
    NSString * colorStr = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([colorStr length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([colorStr hasPrefix:@"0X"]) {
        colorStr = [colorStr substringFromIndex:2];
    }
    
    // 如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([colorStr hasPrefix:@"#"]) {
        colorStr = [colorStr substringFromIndex:1];
    }
    
    // 除去所有开头字符后 再判断字符串长度
    if ([colorStr length] != 6) {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //red
    NSString * redStr = [colorStr substringWithRange:range];
    //green
    range.location = 2;
    NSString * greenStr = [colorStr substringWithRange:range];
    //blue
    range.location = 4;
    NSString * blueStr = [colorStr substringWithRange:range];
    
    // Scan values 将十六进制转换成二进制
    unsigned int r, g, b;
    [[NSScanner scannerWithString:redStr] scanHexInt:&r];
    [[NSScanner scannerWithString:greenStr] scanHexInt:&g];
    [[NSScanner scannerWithString:blueStr] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)color {
    return [self colorWithHexString:color alpha:1.0f];
}

// Lookup a color using css 3/svg color name
+ (UIColor *)colorWithName:(NSString *)cssColorName {
	UIColor *color;
	@synchronized(colorNameCache) {
		// Look for the color in the cache
		color = [colorNameCache objectForKey:cssColorName];
		
		if ((id)color == [NSNull null]) {
			// If it wasn't there previously, it's still not there now
			color = nil;
		} else if (!color) {
			// Color not in cache, so search for it now
			color = [self searchForColorByName:cssColorName];
			
			// Set the value in cache, storing NSNull on failure
			[colorNameCache setObject:(color ?: (id)[NSNull null])
							   forKey:cssColorName];
		}
	}
	
	return color;
}

#pragma mark UIColor_Expanded initialization

+ (void)load {
	colorNameCache = [[NSMutableDictionary alloc] init];
}

+(NSDictionary*) convertRGB2HSB:(NSDictionary*)rgbDic {
    //1. 数据准备
    CGFloat red   = NUMTOOK([rgbDic objectForKey:@"r"]).floatValue;
    CGFloat green = NUMTOOK([rgbDic objectForKey:@"g"]).floatValue;
    CGFloat blue  = NUMTOOK([rgbDic objectForKey:@"b"]).floatValue;
    
    //2. 转换RGB到HSB
    CGFloat hue, saturation, brightness;
    [[UIColor colorWithRed:red green:green blue:blue alpha:1.0] getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
    
    //3. 返回结果
    return @{@"h": @(hue),@"s": @(saturation),@"b": @(brightness)};
}

@end

#pragma mark -

#if SUPPORTS_UNDOCUMENTED_API
@implementation UIColor (UIColor_Undocumented_Expanded)
- (NSString *)fetchStyleString {
	return [self styleString];
}

// Convert a color into RGB Color space, courtesy of Poltras
// via http://ofcodeandmen.poltras.com/2009/01/22/convert-a-cgcolorref-to-another-cgcolorspaceref/
//
- (UIColor *)rgbColor {
	// Call to undocumented method "styleString".
	NSString *style = [self styleString];
	NSScanner *scanner = [NSScanner scannerWithString:style];
	CGFloat red, green, blue;
	if (![scanner scanString:@"rgb(" intoString:NULL]) return nil;
	if (![scanner scanFloat:&red]) return nil;
	if (![scanner scanString:@"," intoString:NULL]) return nil;
	if (![scanner scanFloat:&green]) return nil;
	if (![scanner scanString:@"," intoString:NULL]) return nil;
	if (![scanner scanFloat:&blue]) return nil;
	if (![scanner scanString:@")" intoString:NULL]) return nil;
	if (![scanner isAtEnd]) return nil;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:self.alpha];
}
@end
#endif // SUPPORTS_UNDOCUMENTED_API

@implementation UIColor (UIColor_Expanded_Support)
/*
 * Database of color names and hex rgb values, derived
 * from the css 3 color spec:
 *	http://www.w3.org/TR/css3-color/
 *
 * We think this is a very compact way of storing
 * this information, and relatively cheap to lookup.
 *
 * Note that we search for color names starting with ','
 * and terminated by '#', so that we don't get false matches.
 * For this reason, the database begins with ','.
 */
static const char *colorNameDB = ","
"aliceblue#f0f8ff,antiquewhite#faebd7,aqua#00ffff,aquamarine#7fffd4,azure#f0ffff,"
"beige#f5f5dc,bisque#ffe4c4,black#000000,blanchedalmond#ffebcd,blue#0000ff,"
"blueviolet#8a2be2,brown#a52a2a,burlywood#deb887,cadetblue#5f9ea0,chartreuse#7fff00,"
"chocolate#d2691e,coral#ff7f50,cornflowerblue#6495ed,cornsilk#fff8dc,crimson#dc143c,"
"cyan#00ffff,darkblue#00008b,darkcyan#008b8b,darkgoldenrod#b8860b,darkgray#a9a9a9,"
"darkgreen#006400,darkgrey#a9a9a9,darkkhaki#bdb76b,darkmagenta#8b008b,"
"darkolivegreen#556b2f,darkorange#ff8c00,darkorchid#9932cc,darkred#8b0000,"
"darksalmon#e9967a,darkseagreen#8fbc8f,darkslateblue#483d8b,darkslategray#2f4f4f,"
"darkslategrey#2f4f4f,darkturquoise#00ced1,darkviolet#9400d3,deeppink#ff1493,"
"deepskyblue#00bfff,dimgray#696969,dimgrey#696969,dodgerblue#1e90ff,"
"firebrick#b22222,floralwhite#fffaf0,forestgreen#228b22,fuchsia#ff00ff,"
"gainsboro#dcdcdc,ghostwhite#f8f8ff,gold#ffd700,goldenrod#daa520,gray#808080,"
"green#008000,greenyellow#adff2f,grey#808080,honeydew#f0fff0,hotpink#ff69b4,"
"indianred#cd5c5c,indigo#4b0082,ivory#fffff0,khaki#f0e68c,lavender#e6e6fa,"
"lavenderblush#fff0f5,lawngreen#7cfc00,lemonchiffon#fffacd,lightblue#add8e6,"
"lightcoral#f08080,lightcyan#e0ffff,lightgoldenrodyellow#fafad2,lightgray#d3d3d3,"
"lightgreen#90ee90,lightgrey#d3d3d3,lightpink#ffb6c1,lightsalmon#ffa07a,"
"lightseagreen#20b2aa,lightskyblue#87cefa,lightslategray#778899,"
"lightslategrey#778899,lightsteelblue#b0c4de,lightyellow#ffffe0,lime#00ff00,"
"limegreen#32cd32,linen#faf0e6,magenta#ff00ff,maroon#800000,mediumaquamarine#66cdaa,"
"mediumblue#0000cd,mediumorchid#ba55d3,mediumpurple#9370db,mediumseagreen#3cb371,"
"mediumslateblue#7b68ee,mediumspringgreen#00fa9a,mediumturquoise#48d1cc,"
"mediumvioletred#c71585,midnightblue#191970,mintcream#f5fffa,mistyrose#ffe4e1,"
"moccasin#ffe4b5,navajowhite#ffdead,navy#000080,oldlace#fdf5e6,olive#808000,"
"olivedrab#6b8e23,orange#ffa500,orangered#ff4500,orchid#da70d6,palegoldenrod#eee8aa,"
"palegreen#98fb98,paleturquoise#afeeee,palevioletred#db7093,papayawhip#ffefd5,"
"peachpuff#ffdab9,peru#cd853f,pink#ffc0cb,plum#dda0dd,powderblue#b0e0e6,"
"purple#800080,red#ff0000,rosybrown#bc8f8f,royalblue#4169e1,saddlebrown#8b4513,"
"salmon#fa8072,sandybrown#f4a460,seagreen#2e8b57,seashell#fff5ee,sienna#a0522d,"
"silver#c0c0c0,skyblue#87ceeb,slateblue#6a5acd,slategray#708090,slategrey#708090,"
"snow#fffafa,springgreen#00ff7f,steelblue#4682b4,tan#d2b48c,teal#008080,"
"thistle#d8bfd8,tomato#ff6347,turquoise#40e0d0,violet#ee82ee,wheat#f5deb3,"
"white#ffffff,whitesmoke#f5f5f5,yellow#ffff00,yellowgreen#9acd32";

+ (UIColor *)searchForColorByName:(NSString *)cssColorName {
	UIColor *result = nil;
	
	// Compile the string we'll use to search against the database
	// We search for ",<colorname>#" to avoid false matches
	const char *searchString = [[NSString stringWithFormat:@",%@#", cssColorName] UTF8String];
	
	// Search for the color name
	const char *found = strstr(colorNameDB, searchString);
	
	// If found, step past the search string and grab the hex representation
	if (found) {
		const char *after = found + strlen(searchString);
		int hex;
		if (sscanf(after, "%x", &hex) == 1) {
			result = [self colorWithRGBHex:hex];
		}
	}
	
	return result;
}
@end
