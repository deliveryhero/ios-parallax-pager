//
//  TabsConfig.swift
//  ParallaxPagerView-iOS
//
//  Created by Peter Mosaad Selim on 10/8/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import Foundation
import UIKit

public struct TabsConfig {
  let titles: [String]

  let height: CGFloat
  let tabsPadding: CGFloat

  let tabsShouldBeCentered: Bool

  let defaultTabTitleColor: UIColor
  let selectedTabTitleColor: UIColor
  let defaultTabTitleFont: UIFont
  let selectedTabTitleFont: UIFont

  let selectionIndicatorHeight: CGFloat
  let selectionIndicatorColor: UIColor

  public init(
    titles: [String],
    height: CGFloat,
    tabsPadding: CGFloat,
    tabsShouldBeCentered: Bool,
    defaultTabTitleColor: UIColor,
    selectedTabTitleColor: UIColor,
    defaultTabTitleFont: UIFont,
    selectedTabTitleFont: UIFont,
    selectionIndicatorHeight: CGFloat,
    selectionIndicatorColor: UIColor
    ) {
    self.titles = titles
    self.height = height
    self.tabsPadding = tabsPadding
    self.tabsShouldBeCentered = tabsShouldBeCentered
    self.defaultTabTitleColor = defaultTabTitleColor
    self.selectedTabTitleColor = selectedTabTitleColor
    self.defaultTabTitleFont = defaultTabTitleFont
    self.selectedTabTitleFont = selectedTabTitleFont
    self.selectionIndicatorHeight = selectionIndicatorHeight
    self.selectionIndicatorColor = selectionIndicatorColor
  }
}

