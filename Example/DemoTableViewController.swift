//
//  ViewController.swift
//  Example
//
//  Created by Peter Mosaad Selim on 9/27/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import UIKit
import ParallaxPagerView

class DemoTableViewController: UITableViewController {

  var numberOfCells = 0
  var shouldUseTemplateCell1 = false

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfCells
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if shouldUseTemplateCell1 {
      return tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
    }
    return tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
  }

  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return shouldUseTemplateCell1 ? 100 : 300
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return shouldUseTemplateCell1 ? 100 : 300
  }

  override func viewWillAppear(_ animated: Bool) {
    tableView.reloadData()
  }
}

extension DemoTableViewController: ParallaxContentViewController {

  func scrollableView() -> UIScrollView? {
    return tableView
  }
}

class NoScrollViewController: UIViewController, ParallaxContentViewController {
  func tabTitle() -> String? {
    return "No scroll view controller"
  }

  func tabView() -> UIView? {
    return nil
  }

  func scrollableView() -> UIScrollView? {
    return nil
  }
}
