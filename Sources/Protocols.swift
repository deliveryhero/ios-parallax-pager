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

@objc public protocol ParallaxContentViewController {
  @objc func scrollableView() -> UIScrollView?
}

@objc public protocol ParallaxViewDelegate {
  @objc func parallaxViewDidScrollBy(percentage: CGFloat, oldOffset: CGPoint, newOffset: CGPoint)
}

@objc public protocol PagerDelegate {
  @objc func didSelectTab(at index: Int, previouslySelected: Int)
}

@objc public protocol PagerTab {
  @objc var onSelectedTabChanging: (_ oldTab: Int, _ newTab: Int) -> Void { set get }
  @objc func currentSelectedIndex() -> Int
  @objc func numberOfTabs() -> Int
  @objc func setSelectedTab(at index: Int)
}
