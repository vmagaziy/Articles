# Articles

Sample iOS application for showing articles implemented as [an engineering challenge](https://gist.github.schibsted.io/volodymyr-magazii/a44fbca6481ae941295e162605d0ab61) for CNP in Schibsted.

## Dev environment and min spec

The project can be built using Xcode 11.1 and supposed to be running on iOS 11 or later. 

## Summary

The application can be used both on iPhone and iPad. 

Master-detail approach is used leveraging [split view controller](https://developer.apple.com/documentation/uikit/uisplitviewcontroller) to maximize the usage of available space on the screen.

`AppCoordinator` sets up a relationship between view controllers and organizes their presentations.  View controllers do not present other view controllers (see [the coordinator pattern](https://benoitpasquier.com/coordinator-pattern-swift/) for details), but have closures used by the coordinator to set up presentation logic.  The only exception is presenting error alert, which is done from the view controller itself (see `FeedViewController.loadData()`).  Its another responsibility is a propagation of data provider used by view controllers.

Getting info is abstracted by the data provider hiding behind the `FeedDataProviding` protocol.  Its concrete implementation (`FeedDataProvider`) uses [the test endpoint](https://raw.github.schibsted.io/gist/volodymyr-magazii/baaeb716d87d16218bd2dd9454fb5aa0/raw/e67bf40158ae22fce564a7e4a5b880c17a16c203/Payload.json?token=AAAM1614YuflnMbzsMF11cMFI4pGwF5fks5dzp3wwA%3D%3D).  Usage of this approach allows to mock data provider for development purposes as well as simulate various errors.  `FeedDataProvider` uses the `HTTPClient` abstraction to obtain data from the network (as well as handle network errors).  

Async data loading and cancellation is based on rocks of [futures](https://medium.com/@johnsundell/under-the-hood-of-futures-promises-in-swift-69bd6e7ab972) and [Swift 5 `Result` type](https://developer.apple.com/documentation/swift/result).  `Future` implementation is *inspired by* the mentioned article. The [Combine](https://developer.apple.com/documentation/combine) could be used instead as of iOS 13, but since min spec is iOS 11, the custom solution is to be implemented.

The list of articles (*feed*) is presented in [table view](https://developer.apple.com/documentation/uikit/uitableview) managed by the  `FeedViewController` class inherited from generic `TableViewController`.  `TableViewController` allows not only to manage and present teasers, but also show activity indicator when loading, and error page on error as well as reload data. `FeedViewController` is supposed to be presented in [navigation controller](https://developer.apple.com/documentation/uikit/uinavigationcontroller).

[Pull to refresh](https://en.wikipedia.org/wiki/Pull-to-refresh) is used to update the feed.

Articles are presented in [text view](https://developer.apple.com/documentation/uikit/uitextview) managed by `ArticleViewController`.  It also shows a special label when there is no selection in the table view (applicable for iPad and plus iPhones).  [Text Kit](https://developer.apple.com/documentation/appkit/textkit) is used for laying out images along with text data, and for that special text attachment containing `UIView` instance is used (see `TextAttachment` and `ImageTextAttachment`). 

Images are retrieved asynchronously using the `HTTPClient` entity too and this process is abstracted by the `ImageFetching` protocol.  The concrete implementation of that protocol (`ImageFetcher`) uses both in-memory and disk caches, which in turn allows to avoid their re-fetching from the network once fetched.

Special techniques are used to support [dynamic type](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/) as an important accessibility future.

Since standard UIKit controls are used, accessibility should **not** be an issue, but for sure requires auditing.

Ready for localisation by using `NSLocalizedString`.

Swift coding style is checked by [SwiftLint](https://github.com/realm/SwiftLint) if it's installed.

## What's missing and could be improved

- Self sizing of table view cells containing attributed strings is slow by design: especially because attributed strings are created every time, and measurements are not cached, but even performed twice: when size if determined (`sizeThatFits`) and when layout is performed (`layoutSubviews`).  This can be improved by caching attributed strings and results of measurements for various widths (for instance, in `NSCache` not to exceed memory limits).
- Offline support: the application is useless when there is no connection.  Its support can be added by using [CoreData](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html) or some persistent store like [YapDatabase](https://github.com/yapstudios/YapDatabase) or [FMDB](https://github.com/ccgus/fmdb).  When cached data is provided, a corresponding network request is performed and newly obtained data is merged with existing cached one causing update or the UI. [NSFetchedResultsController](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller) or similar entity may be used to update UI in animated fashion.
- Test harness has to be extended for UI code, in particular view controllers.  [Snapshot tests](https://github.com/uber/ios-snapshot-test-case) can be used to make sure there are no regressions.
- Tracking availability of network connection: it makes sense to reinitiate failed updates upon getting connected.
- Error handling requires improving; logging can be collected by using for instance [XCGLogger](https://github.com/DaveWoodCom/XCGLogger)
- Disk caches for images is not purged by the app, allowing it to grow until iOS starts experiencing the disk space pressure and starts removing local app caches
- Application icon and branding is missing, i.e. specific tint colours and assets
- Not 100% ready for internationalisation: in particular, layout has to be adjusted for [RTL](https://stackoverflow.com/questions/23497553/how-can-i-implement-ios-with-rtl-for-arabic-hebrew)
- Full screen mode for showing images with zooming support
- Moving build settings to configuration files is always a nice thing to do

## Known issues

- Minor layout issues can be observed when rotating device
