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
  let title: String
  let defaultColor: UIColor
  let selectedColor: UIColor
  let defaultFont: UIFont
  let selectedFont: UIFont
  unowned let tabsView: TabsView

  init(
    title: String,
    index: Int,
    defaultColor: UIColor,
    selectedColor: UIColor,
    defaultFont: UIFont,
    selectedFont: UIFont,
    height: CGFloat,
    tabsView: TabsView
  ) {
    self.index = index
    self.button = UIButton(type: .custom)
    self.tabsView = tabsView
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = selectedFont // -> to always fit selected
    button.sizeToFit()
    button.setTitleColor(defaultColor, for: .normal)
    button.titleLabel?.font = defaultFont

    self.defaultColor = defaultColor
    self.selectedColor = selectedColor
    self.defaultFont = defaultFont
    self.selectedFont = selectedFont

    self.title = title
    let buttonFrame = button.frame
    let frame = CGRect(x: 0, y: 0, width: buttonFrame.size.width, height: height)
    super.init(frame: frame)
    button.addTarget(self, action: #selector(tabClicked), for: .touchUpInside)
    addSubview(button)
  }

  func setSelected(selected: Bool) {
    button.isSelected = selected
    let titleColor = selected ? selectedColor : defaultColor
    button.setTitleColor(titleColor, for: .normal)
    let titleFont = selected ? selectedFont : defaultFont
    button.titleLabel?.font = titleFont
  }

  override var frame: CGRect {
    didSet {
      var buttonFrame = frame
      buttonFrame.origin = CGPoint(x: 0, y: 0)
      button.frame = buttonFrame
    }
  }

  @objc private func tabClicked() {
    tabsView.clickedTab(at: index)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class TabsView: UIView {

  public var onSelectedTabChanging: (_ oldTab: Int, _ newTab: Int) -> Void = { _, _ in }


  @IBOutlet weak var tabsHeaderHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var tabsHeaderContainerView: UIView!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate weak var scrollViewWidthConstraint: NSLayoutConstraint!
  fileprivate let selectionIndicatorView = UIView()
  fileprivate var tabsConfig: TabsConfig!
  fileprivate var tabsList = [TabView]()
  private(set) var selectedIndex: Int = 0

  private(set) var tabsHeaderView: UIView?

  static func tabsView(with config: TabsConfig) -> TabsView {
    let bundle = Bundle(identifier: "com.ParallaxPagerView.ParallaxPagerView-iOS")
    let tabsView = bundle!.loadNibNamed("TabsView", owner: nil, options: nil)?.first as! TabsView
    tabsView.tabsConfig = config
    tabsView.frame = CGRect(x: 0, y: 0, width: tabsView.frame.size.width, height: config.height)
    tabsView.createTabs()
    tabsView.setupSelectionIndicator()
    return tabsView
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    tabsHeaderHeightConstraint.constant = 0
  }

  private func setupSelectionIndicator() {
    selectionIndicatorView.backgroundColor = tabsConfig.selectionIndicatorColor
    scrollView.addSubview(selectionIndicatorView)
  }

  private func createTabs() {

    var xOrigin: CGFloat = tabsConfig.tabsPadding

    for (index, title) in tabsConfig.titles.enumerated() {
      let tab = TabView(
        title: title,
        index: index,
        defaultColor: tabsConfig.defaultTabTitleColor,
        selectedColor: tabsConfig.selectedTabTitleColor,
        defaultFont: tabsConfig.defaultTabTitleFont,
        selectedFont: tabsConfig.selectedTabTitleFont,
        height: self.frame.size.height,
        tabsView: self
      )

      tab.frame = CGRect(
        x: xOrigin,
        y: 0,
        width: tab.frame.size.width,
        height: tab.frame.size.height
      )
      xOrigin += tab.frame.size.width + tabsConfig.tabsPadding
      scrollView.addSubview(tab)
      tabsList.append(tab)

      if index == 0 { tab.setSelected(selected: true) }
    }

    scrollView.contentSize = CGSize(width: xOrigin, height: 0)

    if xOrigin < scrollView.frame.size.width && tabsConfig.tabsShouldBeCentered == true {
      scrollViewWidthConstraint.isActive = false
      scrollView.addConstraint(
        NSLayoutConstraint(
          item: scrollView,
          attribute: .width,
          relatedBy: .equal,
          toItem: nil,
          attribute: .notAnAttribute,
          multiplier: 1.0,
          constant: xOrigin
        )
      )
      layoutSubviews()
    }
  }

  override public func layoutSubviews() {
    updateSelectionIndicator()
  }

  fileprivate func updateSelectionIndicator() {

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

  fileprivate func clickedTab(at index: Int) {
    if index == selectedIndex { return }
    onSelectedTabChanging(index, selectedIndex)
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

  func setSelected(index: Int) {
    guard index >= 0, index < tabsList.count else { return }
    clickedTab(at: index)
  }
}

extension TabsView: PagerTab {

  func addHeader(_ headerView: UIView) {
    guard headerView.superview != tabsHeaderContainerView else {
      return
    }

    tabsHeaderHeightConstraint.constant = headerView.frame.size.height
    headerView.frame = tabsHeaderContainerView.bounds
    tabsHeaderContainerView.addSubview(headerView)
    translatesAutoresizingMaskIntoConstraints = false
    headerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    headerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    headerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    headerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

    tabsHeaderContainerView.clipsToBounds = true
    layoutSubviews()
    tabsHeaderView = headerView
  }

  func removeHeader() {
    tabsHeaderView?.removeFromSuperview()
    tabsHeaderHeightConstraint.constant = 0
  }

  public func currentSelectedIndex() -> Int {
    return selectedIndex
  }

  public func numberOfTabs() -> Int {
    return tabsList.count
  }

  public func setSelectedTab(at index: Int) {
    setSelected(index: index)
  }
}


