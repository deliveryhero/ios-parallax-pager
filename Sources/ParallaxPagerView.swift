//
//  ParallaxPagerView.swift
//  Foodora
//
//  Created by Peter Mosaad on 9/27/18.
//  Copyright © 2018 Foodora. All rights reserved.
//

import Foundation
import UIKit

@available(iOSApplicationExtension 9.0, *)
public final class ParallaxPagerView: UIView {

  private var tabsHeight: CGFloat = 0
  private var headerHeight: CGFloat
  private let minimumHeaderHeight: CGFloat

  private var originalTopInset: CGFloat = 0

  private var headerView = UIView()
  public private(set) var tabsView: (UIView & PagerTab)?

  private var viewControllers = [TabViewController]()
  private let hasShownController = NSHashTable<UIViewController>.weakObjects()
  private var ignoreOffsetChanged = false

  private var currentDisplayController: TabViewController?

  private let scaleHeaderOnBounce: Bool

  private var parallaxDelegate: ParallaxViewDelegate?
  private var pagerDelegate: PagerDelegate?

  private var contentOffsetObservation: NSKeyValueObservation?
  private var contentInsetObservation: NSKeyValueObservation?

  private let containerViewController: UIViewController

  private var headerHeightConstraint: NSLayoutConstraint?
  private var contentViewLeadingConstraint: NSLayoutConstraint?
  private var contentViewTrailingConstraint: NSLayoutConstraint?

  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer?
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer?

  private var internalScrollView: UIScrollView

  public init(
    containerViewController: UIViewController,
    headerView: UIView,
    headerHeight: CGFloat,
    minimumHeaderHeight: CGFloat,
    scaleHeaderOnBounce: Bool,
    contentViewController: TabViewController,
    parallaxDelegate: ParallaxViewDelegate?
  ) {
    self.containerViewController = containerViewController
    self.headerView = headerView
    self.headerHeight = headerHeight
    self.minimumHeaderHeight = minimumHeaderHeight
    self.scaleHeaderOnBounce = scaleHeaderOnBounce
    self.viewControllers = [contentViewController]
    self.parallaxDelegate = parallaxDelegate
    internalScrollView = UIScrollView(frame: containerViewController.view.bounds)
    super.init(frame: containerViewController.view.bounds)

    baseConfig()
    initialLayoutsHeaderView()
    layoutContentViewControllers()
  }

  public init(
    containerViewController: UIViewController,
    headerView: UIView,
    headerHeight: CGFloat,
    minimumHeaderHeight: CGFloat,
    scaleHeaderOnBounce: Bool,
    tabsView: (PagerTab & UIView),
    viewControllers: [TabViewController],
    pagerDelegate: PagerDelegate?,
    parallaxDelegate: ParallaxViewDelegate?
  ) {
    self.containerViewController = containerViewController
    self.headerView = headerView
    self.headerHeight = headerHeight
    self.minimumHeaderHeight = minimumHeaderHeight
    self.scaleHeaderOnBounce = scaleHeaderOnBounce
    self.tabsView = tabsView
    self.tabsHeight = tabsView.frame.size.height
    self.viewControllers = viewControllers
    self.parallaxDelegate = parallaxDelegate
    self.pagerDelegate = pagerDelegate
    internalScrollView = UIScrollView(frame: containerViewController.view.bounds)
    super.init(frame: containerViewController.view.bounds)

    baseConfig()
    initialLayoutsHeaderView()
    layoutContentViewControllers()
    initialLayoutTabsView()
  }

  public convenience init(
    containerViewController: UIViewController,
    headerView: UIView,
    headerHeight: CGFloat,
    minimumHeaderHeight: CGFloat,
    scaleHeaderOnBounce: Bool,
    tabsViewConfig: TabsConfig,
    viewControllers: [TabViewController],
    pagerDelegate: PagerDelegate? = nil,
    parallaxDelegate: ParallaxViewDelegate? = nil
  ) {
    self.init(
      containerViewController: containerViewController,
      headerView: headerView,
      headerHeight: headerHeight,
      minimumHeaderHeight: minimumHeaderHeight,
      scaleHeaderOnBounce: scaleHeaderOnBounce,
      tabsView: TabsView.tabsView(with: tabsViewConfig),
      viewControllers: viewControllers,
      pagerDelegate: pagerDelegate,
      parallaxDelegate: parallaxDelegate
    )
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) Shouldn't be used, Please use provided initializer")
  }

  public func setupPager(
    with viewControllers: [TabViewController],
    tabsView: (PagerTab & UIView),
    pagerDelegate: PagerDelegate? = nil,
    animated: Bool,
    completion: (() -> Void)? = nil
  ) {

    self.pagerDelegate = pagerDelegate
    self.tabsView = tabsView
    tabsHeight = tabsView.frame.size.height
    initialLayoutTabsView()
    self.viewControllers = viewControllers
    internalScrollView.alpha = 0.0
    self.tabsView?.alpha = 0.0
    didSelectTabAtIndex(index: 0, previouslySelected: -1, animated: false, completion: completion)
    let duration = animated ? 0.3 : 0.0;
    UIView.animate(withDuration: duration) {
      self.internalScrollView.alpha = 1.0
      self.tabsView?.alpha = 1.0
    }
  }

  public func setupPager(
    with viewControllers: [TabViewController],
    tabsViewConfig: TabsConfig,
    pagerDelegate: PagerDelegate? = nil,
    animated: Bool,
    completion: (() -> Void)? = nil
  ) {
    setupPager(
      with: viewControllers,
      tabsView: TabsView.tabsView(with: tabsViewConfig),
      pagerDelegate: pagerDelegate,
      animated: animated,
      completion: completion
    )
  }

  public func setHeaderHeight(_ height: CGFloat, animated: Bool = false) {
    guard height > minimumHeaderHeight else { return }

    let heightDiff = height - headerHeight
    headerHeight = height
    layoutContentViewControllers()
    let heightToBe = headerHeightConstraint?.constant ?? 0 + heightDiff
    if heightToBe > minimumHeaderHeight {
      headerHeightConstraint?.constant = heightToBe
      guard let currentDisplayController = currentDisplayController,
            let currentScrollView = scrollViewInViewController(vc: currentDisplayController) else {
        return
      }
      let offsetToBe = currentScrollView.contentOffset.y - heightDiff
      currentScrollView.setContentOffset(CGPoint(x: internalScrollView.contentOffset.x, y: offsetToBe), animated: animated)
    }
  }

  @available(iOSApplicationExtension 9.0, *)
  private func layoutInternalScrollView() {
    insertSubview(internalScrollView, at: 0)
    internalScrollView.translatesAutoresizingMaskIntoConstraints = false
    internalScrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
    internalScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    internalScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
    internalScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
  }

  private func baseConfig() {

    layoutInternalScrollView()

    containerViewController.automaticallyAdjustsScrollViewInsets = false
    containerViewController.extendedLayoutIncludesOpaqueBars = false
    preservesSuperviewLayoutMargins = true

    headerView.clipsToBounds = true
    addSubview(headerView)
  }

  private func layoutContentViewControllers() {
    if let firstVC = viewControllers.first {
      layoutChildViewController(vc: firstVC, position: 0)
      internalScrollView.layoutIfNeeded()
      layoutSubviews()
      let scrollView = scrollViewInViewController(vc: firstVC) ?? internalScrollView
      addObserver(for: scrollView)
      currentDisplayController = firstVC
    }
  }

  private func initialLayoutsHeaderView() {
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerHeightConstraint = NSLayoutConstraint(
      item: headerView,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: headerHeight
    )
    headerView.addConstraint(headerHeightConstraint!)

    addConstraint(
      NSLayoutConstraint(
        item: headerView,
        attribute: .left,
        relatedBy: .equal,
        toItem: self,
        attribute: .left,
        multiplier: 1.0,
        constant: 0.0
      )
    )
    addConstraint(
      NSLayoutConstraint(
        item: headerView,
        attribute: .top,
        relatedBy: .equal,
        toItem: self,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0
      )
    )
    addConstraint(
      NSLayoutConstraint(
        item: headerView,
        attribute: .right,
        relatedBy: .equal,
        toItem: self,
        attribute: .right,
        multiplier: 1.0,
        constant: 0.0
      )
    )
  }

  private func initialLayoutTabsView() {

    // Setup TabsView.
    if tabsView != nil {
      tabsView!.onSelectedTabChanging = { [weak self] newIndex, oldIndex in
        self?.didSelectTabAtIndex(index: newIndex, previouslySelected: oldIndex, animated: true)
      }
      addSubview(tabsView!)
      setupSwipeGestures()
    }

    guard let tabsView = tabsView else { return }
    tabsView.translatesAutoresizingMaskIntoConstraints = false

    addConstraint(
      NSLayoutConstraint(
        item: tabsView,
        attribute: .left,
        relatedBy: .equal,
        toItem: self,
        attribute: .left,
        multiplier: 1.0,
        constant: 0.0
      )
    )
    addConstraint(
      NSLayoutConstraint(
        item: tabsView,
        attribute: .right,
        relatedBy: .equal,
        toItem: self,
        attribute: .right,
        multiplier: 1.0,
        constant: 0.0
      )
    )
    addConstraint(
      NSLayoutConstraint(
        item: tabsView,
        attribute: .top,
        relatedBy: .equal,
        toItem: headerView,
        attribute: .bottom,
        multiplier: 1.0,
        constant: 0.0
      )
    )

    tabsView.addConstraint(
      NSLayoutConstraint(
        item: tabsView,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1.0,
        constant: tabsHeight
      )
    )
  }

  private func shouldIgnoreOffsetUpdate(
    scrollView: UIScrollView,
    oldOffset: CGPoint,
    newOffset: CGPoint
  ) -> Bool {
    let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
    let isMovingDown = translation.y > 0.0;
    let deltaOfOffsetY = newOffset.y - oldOffset.y

    // Results from debuging, found that there some awkward values are coming randomly on scrolling.
    // This condition below guarantee that this value are eliminated.
    if deltaOfOffsetY == 0.0 { return true }
    if (isMovingDown && deltaOfOffsetY > 0.0 && newOffset.y > 0.0) { return true }
    return false
  }

  private func addObserver(for scrollView: UIScrollView) {

    contentOffsetObservation = scrollView.observe(
      \.contentOffset,
      options: [.old, .new],
      changeHandler: { [weak self] (object, change) in
        self?.contentOffsetChanged(scrollView: object, newOffset: change.newValue, oldOffset: change.oldValue)
      }
    )

    contentInsetObservation = scrollView.observe(
      \.contentInset,
      options: [.old, .new],
      changeHandler: { [weak self] (_, change) in
        self?.contentInsetChanged(change.newValue)
      }
    )
  }

  private func contentOffsetChanged(scrollView: UIScrollView, newOffset: CGPoint?, oldOffset: CGPoint?) {
    guard ignoreOffsetChanged == false else { return }
    let newOffset = newOffset ?? CGPoint.zero
    let oldOffset = oldOffset ?? CGPoint.zero
    if shouldIgnoreOffsetUpdate(scrollView: scrollView, oldOffset: oldOffset, newOffset: newOffset) {
      return
    }
    layoutForContentOffsetUpdate(scrollView: scrollView, oldOffset: oldOffset, offset: newOffset)
    // Notify delegate
    let headerHeightConstraintConstant = headerHeightConstraint?.constant ?? 0.0
    let currentProgress = headerHeightConstraintConstant - minimumHeaderHeight
    let maximumHeight = headerHeight - minimumHeaderHeight
    let percentage = currentProgress / maximumHeight
    parallaxDelegate?.parallaxViewDidScrollBy(
      percentage: percentage,
      oldOffset: oldOffset,
      newOffset: newOffset
    )
  }

  private func contentInsetChanged(_ inset: UIEdgeInsets?) {
    let newInset = inset ?? UIEdgeInsets.zero
    if abs(newInset.top - originalTopInset) < 2 {
      ignoreOffsetChanged = false
    } else {
      ignoreOffsetChanged = true
    }
  }

  private func layoutForContentOffsetUpdate(scrollView: UIScrollView, oldOffset: CGPoint, offset: CGPoint) {

    guard let headerHeightConstraint = headerHeightConstraint else { return }
    let offsetY = offset.y
    let oldOffsetY = oldOffset.y
    let deltaOfOffsetY = offset.y - oldOffsetY
    let offsetYWithSegment = offset.y + tabsHeight

    if deltaOfOffsetY > 0 && offsetY >= -(headerHeight + tabsHeight) {
      if headerHeightConstraint.constant - deltaOfOffsetY <= 0 {
        headerHeightConstraint.constant = minimumHeaderHeight
      } else {
        headerHeightConstraint.constant -= deltaOfOffsetY
      }
      if headerHeightConstraint.constant <= minimumHeaderHeight {
        headerHeightConstraint.constant = minimumHeaderHeight
      }
    } else {
      if offsetY > 0 {
        if headerHeightConstraint.constant <= minimumHeaderHeight {
          headerHeightConstraint.constant = minimumHeaderHeight
        }
      } else {
        if headerHeightConstraint.constant >= headerHeight {
          if -offsetYWithSegment > headerHeight && scaleHeaderOnBounce {
            headerHeightConstraint.constant = -offsetYWithSegment
          } else {
            headerHeightConstraint.constant = headerHeight
          }
        } else {
          if headerHeightConstraint.constant < -offsetYWithSegment {
            headerHeightConstraint.constant -= deltaOfOffsetY
          }
        }
      }
    }
  }

  private func invalidateObservations() {
    contentOffsetObservation?.invalidate()
    contentInsetObservation?.invalidate()
  }

  private func scrollViewInViewController(vc: TabViewController) -> UIScrollView? {
    if let scrollView = vc.scrollableView() {
      return scrollView
    } else if let scrollView = vc.view as? UIScrollView {
      return scrollView
    }
    return nil
  }

  private func getPositionConstraints(for view: UIView) -> [NSLayoutConstraint]? {
    return internalScrollView.constraints.filter { (constraint) -> Bool in
      guard
        let firstItem = constraint.firstItem as? NSObject,
        let secondItem = constraint.secondItem as? NSObject else {
        return false
      }
      return (constraint.firstAttribute == .right &&
        constraint.secondAttribute == .right &&
        firstItem == view &&
        secondItem == internalScrollView) ||
        (constraint.firstAttribute == .left &&
          constraint.secondAttribute == .left &&
          firstItem == view &&
          secondItem == internalScrollView)
    }
  }

  private func layoutChildViewController(vc: TabViewController, position: CGFloat) {

    guard let view = vc.view else { return }
    view.preservesSuperviewLayoutMargins = true
    view.translatesAutoresizingMaskIntoConstraints = false

    internalScrollView.contentInset = UIEdgeInsets.zero

    vc.willMove(toParent: containerViewController)
    internalScrollView.insertSubview(vc.view, at: 0)
    containerViewController.addChild(vc)
    vc.didMove(toParent: containerViewController)

    contentViewTrailingConstraint = NSLayoutConstraint(
      item: view,
      attribute: .right,
      relatedBy: .equal,
      toItem: internalScrollView,
      attribute: .right,
      multiplier: 1.0,
      constant: position
    )
    internalScrollView.addConstraint(contentViewTrailingConstraint!)

    contentViewLeadingConstraint = NSLayoutConstraint(
      item: view,
      attribute: .left,
      relatedBy: .equal,
      toItem: internalScrollView,
      attribute: .left,
      multiplier: 1.0,
      constant: position
    )
    internalScrollView.addConstraint(contentViewLeadingConstraint!)

    internalScrollView.addConstraint(
      NSLayoutConstraint(
        item: view,
        attribute: .width,
        relatedBy: .equal,
        toItem: internalScrollView,
        attribute: .width,
        multiplier: 1.0,
        constant: 0.0)
    )

    internalScrollView.addConstraint(
      NSLayoutConstraint(
        item: view,
        attribute: .height,
        relatedBy: .equal,
        toItem: internalScrollView,
        attribute: .height,
        multiplier: 1.0,
        constant: 0.0)
    )

    let scrollView = scrollViewInViewController(vc: vc) ?? internalScrollView

    internalScrollView.contentSize = bounds.size
    if scrollViewInViewController(vc: vc) == nil {
      internalScrollView.isScrollEnabled = true
      internalScrollView.alwaysBounceVertical = false
      internalScrollView.contentOffset = CGPoint(x: 0, y: -headerHeight - tabsHeight)
    } else {
      internalScrollView.isScrollEnabled = false
      internalScrollView.alwaysBounceVertical = false
    }

    let constraintValue = headerHeightConstraint?.constant ?? 0
    let height = max(constraintValue, headerHeight)
    originalTopInset = height + tabsHeight
    if #available(iOS 11.0, *) {
      scrollView.contentInsetAdjustmentBehavior = .never
    }

    // fixed bottom tabbar inset
    var bottomInset: CGFloat = 0
    if containerViewController.tabBarController?.tabBar.isHidden == false {
      bottomInset = containerViewController.tabBarController?.tabBar.bounds.size.height ?? 0
    }
    scrollView.contentInset = UIEdgeInsets(
      top: originalTopInset,
      left: CGFloat(0),
      bottom: bottomInset,
      right: CGFloat(0)
    )

    if hasShownController.contains(vc) == false {
      hasShownController.add(vc)
      scrollView.contentOffset = CGPoint(x: 0, y: -headerHeight - tabsHeight)
      // set gestures priority.
      if let rightGesture = rightSwipeGestureRecognizer, let leftGesture = leftSwipeGestureRecognizer {
        scrollView.gestureRecognizers?.forEach {
          $0.require(toFail: rightGesture)
          $0.require(toFail: leftGesture)
        }
      }
    }
    internalScrollView.addConstraint(
      NSLayoutConstraint(
        item: view,
        attribute: .top,
        relatedBy: .equal,
        toItem: internalScrollView,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0
      )
    )
    internalScrollView.addConstraint(
      NSLayoutConstraint(
        item: view,
        attribute: .bottom,
        relatedBy: .equal,
        toItem: internalScrollView,
        attribute: .bottom,
        multiplier: 1.0,
        constant: 0.0
      )
    )
  }

  private func didSelectTabAtIndex(index: Int, previouslySelected: Int, animated: Bool, completion: (() -> Void)? = nil) {
    guard index >= 0, index < viewControllers.count else {
      print("ERROR: Invalid Selection Index.")
      return
    }

    let selectedViewController = viewControllers[index]
    if currentDisplayController != nil && selectedViewController == currentDisplayController! { return }

    invalidateObservations()

    let shouldAnimateLeft = index > previouslySelected
    let newViewInitialPosition = shouldAnimateLeft ? bounds.size.width : -bounds.size.width

    layoutChildViewController(vc: selectedViewController, position: newViewInitialPosition)
    internalScrollView.setNeedsLayout()
    internalScrollView.layoutIfNeeded()

    if let currentViewConstraints = getPositionConstraints(for: currentDisplayController!.view) {
      currentViewConstraints.forEach { $0.constant = -newViewInitialPosition }
    }

    if let selectedViewConstraints = getPositionConstraints(for: selectedViewController.view) {
      selectedViewConstraints.forEach { $0.constant = 0.0 }
    }
    internalScrollView.setNeedsLayout()
    let duration = animated ? 0.3 : 0.0
    UIView.animate(withDuration: duration, animations: {
      self.internalScrollView.layoutIfNeeded()
    }) { _ in
      self.currentDisplayController?.willMove(toParent: nil)
      self.currentDisplayController?.view.removeFromSuperview()
      self.currentDisplayController?.removeFromParent()
      self.currentDisplayController?.didMove(toParent: nil)
      self.currentDisplayController = selectedViewController

      self.pagerDelegate?.didSelectTab(at: index, previouslySelected: previouslySelected)
      completion?()
    }

    let scrollView = scrollViewInViewController(vc: selectedViewController) ?? internalScrollView
    let headerHeightConstant = headerHeightConstraint?.constant ?? 0.0
    if headerHeightConstant != headerHeight {
      if scrollView.contentOffset.y >= -(tabsHeight + headerHeight) && scrollView.contentOffset.y <= -tabsHeight {
        scrollView.contentOffset = CGPoint(x: 0.0, y: -tabsHeight - headerHeightConstant)
      }
    }
    addObserver(for: scrollView)
  }

  @objc private func swipeDetected(gesture: UISwipeGestureRecognizer) {
    guard
      let index = tabsView?.currentSelectedIndex(),
      gesture.direction == .right || gesture.direction == .left
      else { return }

    let indexToBe = (gesture.direction == .left) ? index + 1 : index - 1
    guard
      let numberOfTabs = tabsView?.numberOfTabs(),
      indexToBe >= 0 && indexToBe < numberOfTabs
      else { return }

    tabsView?.setSelectedTab(at: indexToBe)
  }

  private func setupSwipeGestures() {
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(
      target: self,
      action: #selector(swipeDetected(gesture:))
    )
    rightSwipeGestureRecognizer!.direction = .right
    addGestureRecognizer(rightSwipeGestureRecognizer!)

    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(
      target: self,
      action: #selector(swipeDetected(gesture:))
    )
    leftSwipeGestureRecognizer!.direction = .left
    addGestureRecognizer(leftSwipeGestureRecognizer!)
  }

  deinit {
    invalidateObservations()
  }
}
