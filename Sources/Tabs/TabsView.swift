//
//  ParallaxPagerView.swift
//  Foodora
//
//  Created by Peter Mosaad on 9/27/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import Foundation
import UIKit

fileprivate class TabView: UIView {
  let index: Int
  let button: UIButton
  unowned let tabsView: TabsView

  init(
    title: TabTitle,
    index: Int,
    horizontalInsets: CGFloat,
    height: CGFloat,
    tabsView: TabsView,
    accessibilityID: String
  ) {
    self.index = index
    self.button = UIButton(type: .custom)
    self.tabsView = tabsView
    button.setAttributedTitle(title.normal, for: .normal)
    button.setAttributedTitle(title.selected, for: .selected)
    button.isSelected = true // -> to always fit selected
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: horizontalInsets, bottom: 0, right: horizontalInsets)
    button.sizeToFit()
    let buttonFrame = button.frame
    button.isSelected = false
    let frame = CGRect(x: 0, y: 0, width: buttonFrame.size.width, height: height)
    super.init(frame: frame)
    button.addTarget(self, action: #selector(tabClicked), for: .touchUpInside)
    addSubview(button)
    self.accessibilityIdentifier = accessibilityID
  }

  func setSelected(selected: Bool) {
    button.isSelected = selected
  }

  override var frame: CGRect {
    didSet {
      var buttonFrame = frame
      buttonFrame.origin = CGPoint(x: 0, y: 0)
      button.frame = buttonFrame
    }
  }

  @objc private func tabClicked() {
    tabsView.clickedTab(at: index, origin: .click)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public enum TabChangeOrigin {
  case click
  case other
}

public class TabsView: UIView {

  public var onSelectedTabChanging: (_ oldTab: Int, _ newTab: Int, _ origin: TabChangeOrigin) -> Void = { _, _,_  in }

  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate weak var scrollViewWidthConstraint: NSLayoutConstraint!
  fileprivate let selectionIndicatorView = UIView()
  fileprivate var tabsConfig: TabsConfig!
  fileprivate var tabsList = [TabView]()

  private(set) var selectedIndex: Int = 0
  private(set) var tabsHeaderView: UIView?

  public static func tabsView(with config: TabsConfig) -> TabsView {

    let bundle = Bundle(identifier: "com.ParallaxPagerView.ParallaxPagerView-iOS")
    let tabsView = bundle!.loadNibNamed("TabsView", owner: nil, options: nil)?.first as! TabsView
    tabsView.tabsConfig = config
    tabsView.frame = CGRect(x: 0, y: 0, width: tabsView.frame.size.width, height: config.height)
    tabsView.createTabs()
    tabsView.setupSelectionIndicator()
    return tabsView
  }

  private func setupSelectionIndicator() {
    selectionIndicatorView.backgroundColor = tabsConfig.selectionIndicatorColor
    scrollView.addSubview(selectionIndicatorView)
  }

  private func createTabs() {

    let padding = tabsConfig.fullWidth ? 0 : tabsConfig.tabsPadding
    var xOrigin: CGFloat = padding

    for (index, title) in tabsConfig.titles.enumerated() {
      let tab = TabView(
        title: title,
        index: index,
        horizontalInsets: tabsConfig.horizontalTabTitleInsets,
        height: self.frame.size.height,
        tabsView: self,
        accessibilityID: tabsConfig.accessibilityID
      )

      tab.frame = CGRect(
        x: xOrigin,
        y: 0,
        width: tab.frame.size.width,
        height: tab.frame.size.height
      )
      xOrigin += tab.frame.size.width + padding
      scrollView.addSubview(tab)
      tabsList.append(tab)

      if index == 0 { tab.setSelected(selected: true) }
    }

    scrollView.contentSize = CGSize(width: xOrigin, height: 0)
  }

  private func couldHaveEqualTabsWidth() -> Bool {
    let maxWidth = frame.size.width / CGFloat(tabsList.count)
    for tab in tabsList {
      if tab.frame.size.width > maxWidth {
        return false
      }
    }
    return true
  }

  override public func layoutSubviews() {
    if scrollView.contentSize.width < frame.size.width {
      if tabsConfig.fullWidth {
        let diff = frame.size.width - scrollView.contentSize.width
        let valueToBeAdded = diff / CGFloat(integerLiteral: tabsList.count)
        let couldUseEqualWidth = couldHaveEqualTabsWidth()
        var xOrigin: CGFloat = 0
        for tab in tabsList {
          var tempFrame = tab.frame
          if couldUseEqualWidth {
            tempFrame.size.width = frame.size.width / CGFloat(tabsList.count)
          } else {
            tempFrame.size.width += valueToBeAdded
          }
          tempFrame.origin.x = xOrigin
          tab.frame = tempFrame
          xOrigin += tempFrame.size.width
        }
        scrollView.contentSize = CGSize(width: xOrigin, height: 0)
      } else if tabsConfig.tabsShouldBeCentered == true {
        scrollViewWidthConstraint?.isActive = false
        scrollView.addConstraint(
          NSLayoutConstraint(
            item: scrollView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: scrollView.contentSize.width
          )
        )
      }
    }
    updateSelectionIndicator()
  }

  fileprivate func updateSelectionIndicator() {

    guard tabsList.isEmpty == false else { return }
    let selectedTabFrame = tabsList[selectedIndex].frame
    let frame = CGRect(
      x: selectedTabFrame.origin.x,
      y: selectedTabFrame.size.height - tabsConfig.selectionIndicatorHeight,
      width: selectedTabFrame.size.width,
      height: tabsConfig.selectionIndicatorHeight
    )
    UIView.animate(withDuration: 0.3) { [weak self] in
      self?.selectionIndicatorView.frame = frame
    }
  }

  fileprivate func clickedTab(at index: Int, origin: TabChangeOrigin) {
    if index == selectedIndex { return }
    onSelectedTabChanging(index, selectedIndex, origin)
    selectedIndex = index
    let selectedTab = tabsList[index]

    let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.size.width
    var offsetX = selectedTab.center.x - scrollView.center.x
    offsetX = min(maxOffsetX, offsetX)
    offsetX = max(0.0, offsetX)
    scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    updateSelectionIndicator()
    for (tabIndex, tab) in tabsList.enumerated() {
      tab.setSelected(selected: tabIndex == index)
    }
  }

  func setSelected(index: Int, origin: TabChangeOrigin) {
    guard index >= 0, index < tabsList.count else { return }
    clickedTab(at: index, origin: origin)
  }
}

extension TabsView: PagerTab {

  public func currentSelectedIndex() -> Int {
    return selectedIndex
  }

  public func numberOfTabs() -> Int {
    return tabsList.count
  }

  public func setSelectedTab(at index: Int) {
    setSelected(index: index, origin: .other)
  }
}


