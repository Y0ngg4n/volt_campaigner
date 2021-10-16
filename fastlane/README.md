fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## Android
### android test
```
fastlane android test
```
Runs all the tests
### android bump_major
```
fastlane android bump_major
```

### android bump_minor
```
fastlane android bump_minor
```

### android bump_patch
```
fastlane android bump_patch
```

### android read_version
```
fastlane android read_version
```

### android read_code
```
fastlane android read_code
```

### android apply_new_version
```
fastlane android apply_new_version
```

### android beta
```
fastlane android beta
```
Submit a new Beta Build to Beta
### android deploy
```
fastlane android deploy
```
Deploy a new version to the Google Play
### android tag_commit
```
fastlane android tag_commit
```


----

## iOS
### ios read_version
```
fastlane ios read_version
```

### ios read_code
```
fastlane ios read_code
```

### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Beta
### ios browserstack
```
fastlane ios browserstack
```
Upload to BrowserStack Applive

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
