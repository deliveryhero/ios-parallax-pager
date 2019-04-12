//
//  TabsConfig.swift
//  ParallaxPagerView-iOS
//
//  Created by Peter Mosaad Selim on 10/8/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import Foundation
import UIKit

public struct TabTitle {
  let normal: NSAttributedString
  let selected: NSAttributedString

  public init(normal: NSAttributedString, selected: NSAttributedString) {
    self.normal = normal
    self.selected = selected
  }

  public init(
    title: String,
    normalColor: UIColor,
    selectedColor: UIColor,
    normalFont: UIFont,
    selectedFont: UIFont
  ) {
    let normalAttribute: [NSAttributedString.Key : Any] = [
      .font: normalFont,
      .foregroundColor: normalColor
    ]
    let selectedAttribute: [NSAttributedString.Key : Any] = [
      .font: selectedFont,
      .foregroundColor: selectedColor
    ]
    self.normal = NSAttributedString(string: title, attributes: normalAttribute)
    self.selected = NSAttributedString(string: title, attributes: selectedAttribute)
  }
}

public struct TabsConfig {
  public let titles: [TabTitle]
  public let height: CGFloat
  public let tabsPadding: CGFloat
  public let tabsShouldBeCentered: Bool
  public let fullWidth: Bool
  public let horizontalTabTitleInsets: CGFloat
  public let selectionIndicatorHeight: CGFloat
  public let selectionIndicatorColor: UIColor

  public init(
    titles: [TabTitle],
    height: CGFloat,
    tabsPadding: CGFloat,
    tabsShouldBeCentered: Bool,
    fullWidth: Bool,
    horizontalTabTitleInsets: CGFloat,
    selectionIndicatorHeight: CGFloat,
    selectionIndicatorColor: UIColor
    ) {
    self.titles = titles
    self.height = height
    self.tabsPadding = tabsPadding
    self.tabsShouldBeCentered = tabsShouldBeCentered
    self.fullWidth = fullWidth
    self.horizontalTabTitleInsets = horizontalTabTitleInsets
    self.selectionIndicatorHeight = selectionIndicatorHeight
    self.selectionIndicatorColor = selectionIndicatorColor
  }
}

