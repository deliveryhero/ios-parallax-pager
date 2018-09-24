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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let storyboard = UIStoryboard(name: "Main", bundle:nil)
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
    let titles = viewControllers.map { (item) -> String in
      return item.tabTitle()!
    }

    let tabsView = TabsView.tabsViewFor(titles: titles, height: 60.0, delegate: nil)
    let imgView = UIImageView(image: UIImage(named: "photo.jpg"));
    imgView.contentMode = .scaleAspectFill
    let parallex = ParallaxPagerView(
      containerViewController: self,
      headerView: imgView,
      tabsView: tabsView,
      viewControllers: viewControllers,
      delegate: self
    )
    view.addSubview(parallex)
  }
}

extension ViewController: ParallaxPagerViewDelegate {
  func parallaxViewDidScrollBy(percentage: CGFloat, oldOffset: CGPoint, newOffset: CGPoint) {

  }
}

