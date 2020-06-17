//
//  Protocols.swift
//  ParallaxPagerView-iOS
//
//  Created by Peter Mosaad Selim on 10/8/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import Foundation
import UIKit

public typealias TabViewController = UIViewController & ParallaxContentViewController

public protocol ParallaxContentViewController {
  func scrollableView() -> UIScrollView?
}

public protocol ParallaxViewDelegate: AnyObject {
  func parallaxViewDidScrollBy(percentage: CGFloat, oldOffset: CGPoint, newOffset: CGPoint)
}

public protocol PagerDelegate {
  func willSelectTab(at index: Int, previouslySelected: Int)
  func didSelectTab(at index: Int, previouslySelected: Int)
}

public protocol PagerTab {
  var onSelectedTabChanging: (_ oldTab: Int, _ newTab: Int, _ origin: TabChangeOrigin) -> Void { set get }
  func currentSelectedIndex() -> Int
  func numberOfTabs() -> Int
  func setSelectedTab(at index: Int)
}
