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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfCells
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      if shouldUseTemplateCell1 {
        return tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
      }
      return tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
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
    return self.tableView
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
