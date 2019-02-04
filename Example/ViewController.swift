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

  var headerHeight: CGFloat = 300
  var parallaxView: ParallaxPagerView!
  @IBOutlet weak var buttonsView: UIView!

  @IBAction func plusClicked(_ sender: Any) {
    //headerHeight += 30
    
    //parallaxView.setHeaderHeight(headerHeight, animated: true)

    self.parallaxView.addTabsHeader(UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)))
  }

  @IBAction func minusClicked(_ sender: Any) {
    guard headerHeight > 0 else { return }
   // headerHeight -= 30
//    parallaxView.setHeaderHeight(headerHeight, animated: true)
    self.parallaxView.removeTabsHeader()
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

    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] (_) in
      guard let `self` = self else { return }
      self.parallaxView.setupPager(
        with: viewControllers,
        tabsViewConfig: tabsConfig,
        pagerDelegate: self as? PagerDelegate,
        animated: true,
        completion: {
          self.headerHeight += 100
          self.parallaxView.setHeaderHeight(self.headerHeight)
          self.parallaxView.addTabsHeader(UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)))
          let duration = DispatchTime.now() + DispatchTimeInterval.seconds(3)
          DispatchQueue.main.asyncAfter(deadline: duration, execute: {
            self.parallaxView.removeTabsHeader()
          })
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
