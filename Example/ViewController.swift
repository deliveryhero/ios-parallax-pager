//
//  ViewController.swift
//  Example
//
//  Created by Peter Mosaad Selim on 9/27/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import UIKit
import ParallaxPagerView

class ViewController: UIViewController {

  var containerView: ContainerView?
  var headerHeight: CGFloat = 300
  var parallaxView: ParallaxPagerView!
  @IBOutlet weak var buttonsView: UIView!

  @IBAction func plusClicked(_ sender: Any) {
    //headerHeight += 30

    //parallaxView.setHeaderHeight(headerHeight, animated: true)

//    self.parallaxView.addTabsHeader(UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)))
    containerView?.showBanner()
    parallaxView.setTabsHeight(100)
  }

  @IBAction func minusClicked(_ sender: Any) {
    guard headerHeight > 0 else { return }
    // headerHeight -= 30
//    parallaxView.setHeaderHeight(headerHeight, animated: true)
//    self.parallaxView.removeTabsHeader()
    containerView?.hideBanner()
    parallaxView.setTabsHeight(50)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController1 = storyboard.instantiateViewController(withIdentifier: "DemoTableView") as! DemoTableViewController
    viewController1.numberOfCells = 20
    viewController1.shouldUseTemplateCell1 = true

    let viewController2 = storyboard.instantiateViewController(withIdentifier: "DemoTableView") as! DemoTableViewController
    viewController2.numberOfCells = 2
    viewController2.shouldUseTemplateCell1 = false

    let viewController3 = storyboard.instantiateViewController(withIdentifier: "DemoTableView") as! DemoTableViewController
    viewController3.numberOfCells = 20
    viewController3.shouldUseTemplateCell1 = true

    let viewController4 = storyboard.instantiateViewController(withIdentifier: "DemoTableView") as! DemoTableViewController
    viewController4.numberOfCells = 3
    viewController4.shouldUseTemplateCell1 = true

    let viewController5 = storyboard.instantiateViewController(withIdentifier: "NoScrollVC") as! NoScrollViewController
    let viewController6 = storyboard.instantiateViewController(withIdentifier: "NoScrollVC") as! NoScrollViewController

    let viewControllers: [TabViewController] = [viewController1, viewController2, viewController3, viewController4, viewController5, viewController6]
    let titles = ["View 1", "View 2", "View 3", "View 4", "View 5", "View 6"]

    let tabsConfig = TabsConfig(
      titles: titles,
      height: 50.0,
      tabsPadding: 16.0,
      tabsShouldBeCentered: false,
      defaultTabTitleColor: .black,
      selectedTabTitleColor: .black,
      defaultTabTitleFont: UIFont.systemFont(ofSize: 15.0),
      selectedTabTitleFont: UIFont.boldSystemFont(ofSize: 15.0),
      selectionIndicatorHeight: 2.0,
      selectionIndicatorColor: .blue
    )

    let imgView = UIImageView(image: UIImage(named: "photo.jpg"));
    imgView.contentMode = .scaleAspectFill

    parallaxView = ParallaxPagerView(
      containerViewController: self, headerView: imgView,
      headerHeight: headerHeight,
      minimumHeaderHeight: 84.0,
      scaleHeaderOnBounce: true,
      contentViewController: viewController6,
      parallaxDelegate: self
    )
    view.addSubview(parallaxView)

    let tabsView = TabsView.tabsView(with: tabsConfig)
    let containerView = ContainerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50), tabsView: tabsView)
    self.containerView = containerView
    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] (_) in
      guard let `self` = self else { return }
      self.parallaxView.setupPager(
        with: viewControllers,
        tabsView: containerView,
        pagerDelegate: self as? PagerDelegate,
        animated: true,
        completion: {
//          self.headerHeight += 100
//          self.parallaxView.setHeaderHeight(self.headerHeight, animated: true)
//          self.para
//          let duration = DispatchTime.now() + DispatchTimeInterval.seconds(3)
//          DispatchQueue.main.asyncAfter(deadline: duration, execute: {
//            containerView.hideBanner()
//            self.parallaxView.setTabsHeight(50)
//          })
        }
      )
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    view.bringSubviewToFront(buttonsView)
  }
}

extension ViewController: ParallaxViewDelegate {
  func parallaxViewDidScrollBy(percentage: CGFloat, oldOffset: CGPoint, newOffset: CGPoint) {

  }
}

class ContainerView: UIView, PagerTab {
  var tabsView: TabsView

  init(frame: CGRect, tabsView: TabsView) {
    tabsView.frame = CGRect(x: 0, y: 0, width: frame.width, height: tabsView.frame.height)
    self.tabsView = tabsView
    self.onSelectedTabChanging = { oldTab, newTab in
      tabsView.onSelectedTabChanging(oldTab, newTab)
    }
    super.init(frame: frame)
    addSubview(tabsView)
    backgroundColor = .red
    clipsToBounds = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  func hideBanner() {
    self.tabsView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: tabsView.frame.height)
    self.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: tabsView.frame.height)
  }

  func showBanner() {
    self.tabsView.frame = CGRect(x: 0, y: 50, width: self.frame.width, height: tabsView.frame.height)
    self.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: tabsView.frame.height + 50)
  }

  var onSelectedTabChanging: (Int, Int) -> Void = { _, _ in } {
    didSet {
      tabsView.onSelectedTabChanging = onSelectedTabChanging
    }
  }

  func currentSelectedIndex() -> Int {
    return tabsView.currentSelectedIndex()
  }

  func numberOfTabs() -> Int {
    return tabsView.numberOfTabs()
  }

  func setSelectedTab(at index: Int) {
    tabsView.setSelectedTab(at: index)
  }

  func addHeader(_ headerView: UIView) {

  }

  func removeHeader() {
  }
}
