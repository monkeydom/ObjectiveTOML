# ObjectiveTOML

ObjectiveTOML is a clean and nice Objective-C API to read and write [TOML](https://github.com/toml-lang/toml) files. It is utilizing [toml11](https://github.com/ToruNiina/toml11) and therefore on par with its TOML compliance. At time of writing this is [TOML 1.0.0](https://toml.io/en/v1.0.0)

The main target is a small command line utility `tomlutil` to convert between TOML, JSON and the xml and binary plist format on macOS.

The API is aligned with `NSJSONSerialization`:

```objectivec
#import "LMPTOMLSerialization.h"

NSData *inputData = [NSData dataWithContentsOfURL:fileURL];
NSDictionary <NSString *, id>* tomlObject = 
  [LMPTOMLSerialization TOMLObjectWithData:inputData error:&error];
// now tomlObject holds the contents of the TOML file. 

```

The `tomlutil` has nice parsing error reporting (if you only want this, you can use the `-lint` option:

```
$> ./tomlutil -lint toml-examples/wrong.toml 
🚫 Input TOML could not be parsed
[error] toml::parse_key_value_pair: invalid format for key
 --> toml-examples/wrong.toml
    |
 14 | asdfpoin1!@ j= ;alskjfasdf
    |          ^--- invalid character in key
    |
Hint: Did you forget '.' to separate dotted-key?
Hint: Allowed characters for bare key are [0-9a-zA-Z_-]. 
```

Current usage output:

```
tomlutil v2.0.0 (toml11 v3.7.1)

Usage: tomlutil [-f json|xml1|binary1|toml] file [outputfile]

A file of '-' reads from stdin. Can read json, plists and toml. Output defaults to stdout.
-f format   Output format. One of json, xml1, binary1, toml. Defaults to toml.
-lint       Just lint with toml11, no output.
┌─(...-cxgxrczcjchjyyhfjlnxipqyqbsh/Build/Products/Debug)───(dom@darthy:s001)─┐
```

Simple conversion of the Mojave News.app plist to TOML:

```toml
$> ./tomlutil /System/Applications/News.app/Contents/Info.plist 
SBAppUsesLocalNotifications = true
DTSDKBuild = "22D40"
UILaunchStoryboardName = "LaunchScreen"
CFBundleHelpBookName = "com.apple.News.help"
NSSupportsSuddenTermination = true
DTPlatformVersion = "13.2"
UIViewGroupOpacity = false
CFBundleDisplayName = "News"
CFBundleName = "News"
HPDHelpProjectIdentifier = "news"
UIDeviceFamily = [6]
CFBundlePackageType = "APPL"
UIRequiredDeviceCapabilities = ["armv7"]
CFBundleSignature = "????"
UIMenuBarItemTitleQuit = "Quit News"
CFBundleVersion = "3270.0.1"
LSSupportedRegions = ["US","GB","AU","CA"]
NSLocationDefaultAccuracyReduced = true
UIMenuBarItemTitleHelp = "News Help"
NSLocationUsageDescription = """
Get top local news and weather, and locally relevant search results an\
d ads.\
"""
UIMenuBarItemTitleAbout = "About News"
UIMenuBarItemTitleHide = "Hide News"
NSCalendarsUsageDescription = "This will let you add events from News to your calendar."
CFBundleSupportedPlatforms = ["MacOSX"]
NSLocationWhenInUseUsageDescription = """
Get top local news and weather, and locally relevant search r\
esults and ads.\
"""
CFBundleInfoDictionaryVersion = "6.0"
LSMinimumSystemVersion = "13.2"
CFBundleIdentifier = "com.apple.news"
NSHumanReadableCopyright = "Copyright © 2022 Apple Inc. All rights reserved."
NSPhotoLibraryAddUsageDescription = ""
UIWhitePointAdaptivityStyle = "UIWhitePointAdaptivityStyleReading"
NSContactsUsageDescription = ""
NSSupportsAutomaticTermination = true
CFBundleShortVersionString = "8.2.1"
CFBundleIconFile = "AppIcon"
CTIgnoreUserFonts = true
UIAppFonts = []
UIUserInterfaceStyle = "Automatic"
DTXcodeBuild = "14A6270d"
CFBundleExecutable = "News"
DTCompiler = "com.apple.compilers.llvm.clang.1_0"
CFBundleIconName = "AppIcon"
UIStatusBarHidden = false
"UISupportedInterfaceOrientations~ipad" = [
"UIInterfaceOrientationPortrait",
"UIInterfaceOrientationPortraitUpsideDown",
"UIInterfaceOrientationLandscapeLeft",
"UIInterfaceOrientationLandscapeRight",
]
BuildMachineOSBuild = "20A241133"
UIViewControllerBasedStatusBarAppearance = true
UIBackgroundModes = ["audio","fetch","remote-notification"]
NSAccentColorName = "NewsAccentColor"
UIViewEdgeAntialiasing = false
DTPlatformName = "macosx"
SBMatchingApplicationGenres = [
"News","Reference","Entertainment","Productivity","Education",
"Business",
]
NSUserActivityTypes = [
"TagIntent","TodayIntent","com.apple.news.articleViewing",
"com.apple.news.feedBrowsing","com.apple.news.feedBackCatalog",
"com.apple.news.forYou","com.apple.news.history","com.apple.news.saved",
"com.apple.news.magazineSections","com.apple.news.link",
]
UIApplicationShortcutWidget = "com.apple.news.widget"
CFBundleDevelopmentRegion = "en"
UISupportedInterfaceOrientations = ["UIInterfaceOrientationPortrait"]
CFBundleHelpBookFolder = "News.help"
BGTaskSchedulerPermittedIdentifiers = ["com.apple.news.backgroundFetchManager"]
_LSSupportsRemoval = true
DTSDKName = "macosx13.2.internal"
DTPlatformBuild = "22D40"
NSPhotoLibraryUsageDescription = ""
DTXcode = "1400"
LSCounterpartIdentifiers = ["com.apple.nanonews"]

[[UIApplicationShortcutItems]]
UIApplicationShortcutItemTitle = "ApplicationShortcutItemForYou"
UIApplicationShortcutItemIconFile = "ios_for_you_icon_large"
UIApplicationShortcutItemType = "com.apple.news.openforyou"

[UNUserNotificationCenter]
UNSuppressUserAuthorizationPrompt = false

[UIApplicationSceneManifest]
UIApplicationSupportsMultipleScenes = "1"

[UIApplicationSceneManifest.UISceneConfigurations]

[[UIApplicationSceneManifest.UISceneConfigurations.UIWindowSceneSessionRoleApplication]]
UISceneConfigurationName = "Default Configuration"
UISceneDelegateClassName = "NewsUI2.SceneDelegate"
UISceneClassName = "TeaUI.WindowScene"


[[CFBundleURLTypes]]
CFBundleURLSchemes = ["applenews","applenewss"]
CFBundleURLName = "com.apple.NewsCustomScheme"
CFBundleTypeRole = "Editor"
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

* v2.0.0
   * switched to [toml11] (https://github.com/ToruNiina/toml11

* v1.1.0
   * Updated to cpptoml v0.1.1
   * Added more arguments, help and error reporting to the `tomlutil`

* v1.0.1
   * Fixed an issue with cpptoml with trailing whitespace and comments in dates as well as allowing for empty inline tables now.

* v1.0
   * Reading and writing works. Dates are handeled. Conversion between json, plists and toml works as expected.

* v0.1.0
	* Basic reading works, no support of Date format yet, or of the switches promised.  	

## Authors

* **Dominik Wagner** - [monkeydom](https://github.com/monkeydom) - [@monkeydom@mastodon.social](https://mastodon.social/@monkeydom)

## License

Distributed under the MIT License - see [LICENSE.txt](LICENSE.txt) file for details

## Acknowledgments

* ObjectiveTOML relies on the excellent [cpptoml](https://github.com/skystrife/cpptoml)

