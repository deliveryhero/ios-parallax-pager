// Copyright © 2022 Delivery Hero. All rights reserved.

import Foundation

final class BundleToken {}

extension Foundation.Bundle {
  // NOTE: Can not use the `Bundle.module` right now because the b2c
  // still using ParallaxPagerView as a Carthage dependency, so we have to
  // support 2 kinds of source dependencies managements. Pls, switch
  // to `Bundle.module` when we already removed the Carthage in b2c.
  
  // swiftlint:disable:next variable_name
  static var _module: Bundle = {
#if SWIFT_PACKAGE
    return Bundle.module
#else
    return Bundle(for: BundleToken.self)
#endif
  }()
}
