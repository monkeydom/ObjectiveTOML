# ObjectiveTOML

ObjectiveTOML is a clean and nice Objective-C API read wand write [TOML](https://github.com/toml-lang/toml) files. It is utilizing [cpptoml](https://github.com/skystrife/cpptoml) and therefore on par with its TOML compliance. At time of writing this is [TOML 0.5.0](https://github.com/toml-lang/toml/blob/master/versions/en/toml-v0.5.0.md)

The main project is a small command line utility to convert between TOML, JSON and the xml and binary plist format on macOS.

The API is aligned with `NSJSONSerlalization`.

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

## Changelog

* v0.1.0
	* Basic reading works, no support of Date format yet, or of the switches promised.  	

## Authors

* **Dominik Wagner** - [monkeydom](https://github.com/monkeydom) - [@monkeydom@mastodon.technology](https://mastodon.technology/@monkeydom) - [@monkeydom](https://twitter.com/monkeydom)

## License

Distributed under the MIT License - see [LICENSE.txt](LICENSE.txt) file for details

## Acknowledgments

* ObjectiveTOML relies on the excellent [cpptoml](https://github.com/skystrife/cpptoml)

