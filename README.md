# ObjectiveTOML

ObjectiveTOML is a clean and nice Objective-C API read wand write [TOML](https://github.com/toml-lang/toml) files. It is utilizing [cpptoml](https://github.com/skystrife/cpptoml) and therefore on par with its TOML compliance. At time of writing this is [TOML 0.5.0](https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.5.0.md)

The main project is a small command line utility to convert between TOML, JSON and the xml and binary plist format on macOS.

The API is aligned with `NSJSONSerialization`.

```objectivec
#import "LMPTOMLSerialization.h"

NSData *inputData = [NSData dataWithContentsOfURL:fileURL];
NSDictionary <NSString *, id>* tomlObject = 
  [LMPTOMLSerialization TOMLObjectWithData:inputData error:&error];
// now tomlObject holds the contents of the TOML file. 

```

The `tomlutil` has nice parsing error reporting:

```
$> ./tomlutil ObjectiveTOML/toml-examples/example-v0.4.0.toml 
🚫 Input TOML could not be parsed
Failed to parse value type at line 32
  31: [x.y.z.w] # for this to work
> 32: unsupported =
  33: 
```

Simple conversion of the Mojave News.app plist to TOML:

```toml
$ ./tomlutil /Applications/News.app/Contents/Info.plist 
BuildMachineOSBuild = "17A405001"
CFBundleDevelopmentRegion = "en"
CFBundleDisplayName = "News"
CFBundleExecutable = "News"
CFBundleHelpBookFolder = "News.help"
CFBundleHelpBookName = "com.apple.News.help"
CFBundleIconFile = "AppIcon_macOS.icns"
CFBundleIconName = "AppIcon"
CFBundleIdentifier = "com.apple.news"
CFBundleInfoDictionaryVersion = "6.0"
CFBundleName = "News"
CFBundlePackageType = "APPL"
CFBundleShortVersionString = "4.0"
CFBundleSignature = "????"
CFBundleSupportedPlatforms = ["MacOSX"]
CFBundleVersion = "1637.9"
DTCompiler = "com.apple.compilers.llvm.clang.1_0"
DTPlatformBuild = "10L213p"
DTPlatformName = "macosx"
DTPlatformVersion = "10.14"
DTSDKBuild = "18A371"
DTSDKName = "macosx10.14internal"
DTXcode = "1000"
DTXcodeBuild = "10L213p"
HPDHelpProjectIdentifier = "news"
LSCounterpartIdentifiers = ["com.apple.nanonews"]
LSMinimumSystemVersion = "10.14"
LSSupportedRegions = ["US", "GB", "AU"]
NSCalendarsUsageDescription = "This will let you add events from News to your calendar."
NSContactsUsageDescription = ""
NSHumanReadableCopyright = "Copyright © 2018 Apple. All rights reserved."
NSLocationWhenInUseUsageDescription = "Your location is used to deliver locally relevant information such as search results and weather."
NSPhotoLibraryAddUsageDescription = ""
NSPhotoLibraryUsageDescription = ""
NSUserActivityTypes = ["com.apple.news.articleViewing", "com.apple.news.feedBrowsing", "com.apple.news.forYou", "com.apple.news.saved", "com.apple.news.history"]
SBAppUsesLocalNotifications = true
UIAppFonts = []
UIApplicationShortcutWidget = "com.apple.news.widget"
UIBackgroundModes = ["audio", "fetch", "remote-notification"]
UIDeviceFamily = [1, 2]
UILaunchStoryboardName = "LaunchScreen"
UIMainStoryboardFile = "Main"
UIMenuBarItemTitleAbout = "About News"
UIMenuBarItemTitleHelp = "News Help"
UIMenuBarItemTitleHide = "Hide News"
UIMenuBarItemTitleQuit = "Quit News"
UIRequiredDeviceCapabilities = ["armv7"]
UIStatusBarHidden = false
UISupportedInterfaceOrientations = ["UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"]
"UISupportedInterfaceOrientations~ipad" = ["UIInterfaceOrientationPortrait", "UIInterfaceOrientationPortraitUpsideDown", "UIInterfaceOrientationLandscapeLeft", "UIInterfaceOrientationLandscapeRight"]
UIUserInterfaceStyle = "Automatic"
UIViewControllerBasedStatusBarAppearance = true
UIViewEdgeAntialiasing = false
UIViewGroupOpacity = false
UIWhitePointAdaptivityStyle = "UIWhitePointAdaptivityStyleReading"
_LSSupportsRemoval = true
[CFBundleIcons]
["CFBundleIcons~ipad"]
[[CFBundleURLTypes]]
	CFBundleTypeRole = "Editor"
	CFBundleURLName = "com.apple.NewsCustomScheme"
	CFBundleURLSchemes = ["applenews", "applenewss", "feed"]
[[UIApplicationShortcutItems]]
	UIApplicationShortcutItemIconFile = "ios_for_you_icon_large"
	UIApplicationShortcutItemTitle = "ApplicationShortcutItemForYou"
	UIApplicationShortcutItemType = "com.apple.news.openforyou"

```

Full header:

```objectivec
@interface LMPTOMLSerialization : NSObject

/**
 Generate a Foundation Dictionary from TOML data.

 @param data NSData representing a TOML file
 @param error helpful information if the parsing fails
 @return NSDictionary representing the contents of the TOML file. Note that given dates will be represented as NSDateComponents, use +serializationObjectWtihTOMLObject: to convert those to RFC3339 strings that can be used in JSON or PropertyList serializations.
 */
+ (NSDictionary <NSString *, id>*)TOMLObjectWithData:(NSData *)data error:(NSError **)error;

/**
 Generates NSData representation of the TOMLObject. The representation is UTF8 and can be stored directly as a TOML file.
 
 Note that roundtripping is a lossy opreation, as all comments are stripped, the allowed number formats are reduced to canonical ones and doubles might lose or gain unwanted precision.
 
 @param tomlObject Foundation Object consisting of TOML serializable objects. In addition to plist objects this contains NSDateComponent objects with y-m-d filled, h-m-s-[nanoseconds] filled, all fields filled, or all fields + timezone filled.
 @param error helpful information if generation fails
 @return NSData representing the object.
 */
+ (NSData *)dataWithTOMLObject:(NSDictionary<NSString *, id> *)tomlObject error:(NSError **)error;

/**
 Takes a Dictionary representing a TOML file and translates the NSDateComponents into RFC339 strings to be able to be serialized in JSON or PropertyLists

 @param tomlObject foundation dictionary consisting of TOML serializable objects.
 @return NSDictionary containing property list serializable objects.
 */
+ (NSDictionary<NSString *, id> *)serializableObjectWithTOMLObject:(NSDictionary<NSString *, id> *)tomlObject;

@end
```

## Changelog

* v1.0
   * Reading and writing works. Dates are handeled. Conversion between json, plists and toml works as expected.

* v0.1.0
	* Basic reading works, no support of Date format yet, or of the switches promised.  	

## Authors

* **Dominik Wagner** - [monkeydom](https://github.com/monkeydom) - [@monkeydom@mastodon.technology](https://mastodon.technology/@monkeydom) - [@monkeydom](https://twitter.com/monkeydom)

## License

Distributed under the MIT License - see [LICENSE.txt](LICENSE.txt) file for details

## Acknowledgments

* ObjectiveTOML relies on the excellent [cpptoml](https://github.com/skystrife/cpptoml)

