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
  unowned let tabsView: TabsView
  
  init(
    title: String,
    index: Int,
    tabsView: TabsView,
    height: CGFloat
    ) {
    self.index = index
    self.button = UIButton(type: .custom)
    self.tabsView = tabsView
    button.setTitle(title, for: .normal)
    button.sizeToFit()
    button.setTitleColor(UIColor.black, for: .normal)
    self.title = title
    let buttonFrame = button.frame
    let frame = CGRect(x: 0, y: 0, width: buttonFrame.size.width, height: height)
    super.init(frame: frame)
    button.addTarget(self, action:#selector(tabClicked), for: .touchUpInside)
    addSubview(button)
  }
  
  func update(with font: UIFont?, color: UIColor?) {
    if let font = font {
      button.titleLabel?.font = font
    }
    if let color = color {
      button.setTitleColor(color, for: .normal)
    }
  }
  
  override var frame: CGRect {
    didSet {
      var buttonFrame = frame
      buttonFrame.origin = CGPoint(x: 0, y: 0)
      button.frame = buttonFrame
    }
  }
  
  @objc private func tabClicked() {
    tabsView.clickedTab(at: index, force: false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public protocol TabsViewDelegate: AnyObject {
  func didSelectTab(at index: Int, previouslySelected: Int)
}

public final class TabsView: UIView {
  
  public var onSelectedTabChanging:(_ oldTab: Int, _ newTab: Int) -> Void = {_, _ in }
  
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  public var selectionIndicatorColor: UIColor? {
    didSet { selectionIndicatorView.backgroundColor = selectionIndicatorColor}
  }
  fileprivate  weak var delegate : TabsViewDelegate?
  fileprivate  let selectionIndicatorView = UIView()
  fileprivate  var tabsList = [TabView]()
  private(set) var selectedIndex: Int = 0
  private var selectionIndicatorHeight:CGFloat = 1.0
  private var font: UIFont?
  private var textColor: UIColor?
  private var selectedTabFont: UIFont?
  private var selectedTabColor: UIColor?
  
  public static func tabsViewFor(titles: [String],
                                 height: CGFloat,
                                 selectionIndicatorHeight: CGFloat,
                                 font: UIFont?,
                                 textColor: UIColor?,
                                 selectedTabFont: UIFont?,
                                 selectedTabColor: UIColor?,
                                 delegate: TabsViewDelegate?
    ) -> TabsView {
    let bundle = Bundle(identifier:"com.ParallaxPagerView.ParallaxPagerView-iOS")
    let tabsView = bundle!.loadNibNamed("TabsView", owner: nil, options: nil)?.first as! TabsView
    tabsView.delegate = delegate
    tabsView.font = font
    tabsView.textColor = textColor
    tabsView.selectedTabFont = selectedTabFont
    tabsView.selectedTabColor = selectedTabColor
    tabsView.selectionIndicatorHeight = selectionIndicatorHeight
    tabsView.frame = CGRect(x: 0, y: 0, width: tabsView.frame.size.width, height: height)
    tabsView.createTabsFor(titles: titles)
    tabsView.setupSelectionIndicator()
    tabsView.clickedTab(at: tabsView.selectedIndex, force: true)
    return tabsView
  }
  
  private func setupSelectionIndicator() {
    selectionIndicatorView.backgroundColor = UIColor.red
    scrollView.addSubview(selectionIndicatorView)
  }
  
  private func createTabsFor(titles: [String]) {
    
    var xOrigin: CGFloat = 16.0
    for (index, title) in titles.enumerated() {
      let tab = TabView(
        title: title,
        index: index,
        tabsView: self,
        height: self.frame.size.height
      )
      
      tab.frame = CGRect(x: xOrigin,
                         y: 0,
                         width: tab.frame.size.width,
                         height: tab.frame.size.height)
      xOrigin += tab.frame.size.width + 16.0
      tab.update(with: font, color: textColor)
      scrollView.addSubview(tab)
      tabsList.append(tab)
    }
    var frame = scrollView.frame
    let middleX = ((frame.size.width - xOrigin) / 2.0)
    frame.origin.x = max(middleX, 0)
    frame.size.width = xOrigin
    scrollView.contentSize = CGSize(width: xOrigin, height: 0)
  }
  
  override public func layoutSubviews() {
    updateSelectionIndicator()
  }
  
  fileprivate func updateSelectionIndicator() {
    let selectedTabFrame = tabsList[selectedIndex].frame
    let frame = CGRect(
      x: selectedTabFrame.origin.x,
      y: selectedTabFrame.size.height - selectionIndicatorHeight,
      width: selectedTabFrame.size.width,
      height: selectionIndicatorHeight
    )
    UIView.animate(withDuration: 0.3) {[weak self] in
      self?.selectionIndicatorView.frame = frame
    }
  }
  
  fileprivate func clickedTab(at index: Int, force: Bool) {
    if index == selectedIndex && !force { return }
    delegate?.didSelectTab(at: index, previouslySelected: selectedIndex)
    onSelectedTabChanging(index, selectedIndex)
    tabsList[selectedIndex].update(with: font, color: textColor)
    selectedIndex = index
    tabsList[selectedIndex].update(with: selectedTabFont, color: selectedTabColor)
    let selectedTab = tabsList[index]
    
    let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.size.width
    var offsetX = selectedTab.center.x - scrollView.center.x
    offsetX = min(maxOffsetX, offsetX)
    offsetX = max(0.0, offsetX)
    scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    updateSelectionIndicator()
  }
  
  func setSelected(index: Int) {
    guard index >= 0, index < tabsList.count else { return }
    clickedTab(at: index, force: false)
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
    setSelected(index: index)
  }
}


