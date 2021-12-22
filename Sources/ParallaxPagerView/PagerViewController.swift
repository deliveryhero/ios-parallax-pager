//
//  PagerViewController.swift
//  Example
//
//  Created by Peter Mosaad Selim Abdelsaid on 10.04.19.
//  Copyright © 2019 Foodora. All rights reserved.
//

import Foundation

import UIKit

public final class PagerView: UIView {
    private var tabsHeight: CGFloat = 0
    public private(set) var tabsView: (UIView & PagerTab)?

    private var viewControllers = [UIViewController]()
    private let hasShownController = NSHashTable<UIViewController>.weakObjects()

    private var currentDisplayController: UIViewController?
    private var pagerDelegate: PagerDelegate?

    private let containerViewController: UIViewController

    private var contentViewLeadingConstraint: NSLayoutConstraint?
    private var contentViewTrailingConstraint: NSLayoutConstraint?
    private var tabsHeightConstraint: NSLayoutConstraint?

    private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer?
    private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer?

    public init(
        containerViewController: UIViewController,
        contentViewController: UIViewController
    ) {
        self.containerViewController = containerViewController
        viewControllers = [contentViewController]
        super.init(frame: containerViewController.view.bounds)
        baseConfig()
        layoutContentViewControllers()
    }

    public init(
        containerViewController: UIViewController,
        tabsView: PagerTab & UIView,
        viewControllers: [UIViewController],
        pagerDelegate: PagerDelegate?
    ) {
        self.containerViewController = containerViewController
        self.tabsView = tabsView
        tabsHeight = tabsView.frame.size.height
        self.viewControllers = viewControllers
        self.pagerDelegate = pagerDelegate
        super.init(frame: containerViewController.view.bounds)

        baseConfig()
        initialLayoutTabsView()
        layoutContentViewControllers()
    }

    public convenience init(
        containerViewController: UIViewController,
        tabsViewConfig: TabsConfig,
        viewControllers: [UIViewController],
        pagerDelegate: PagerDelegate? = nil
    ) {
        self.init(
            containerViewController: containerViewController,
            tabsView: TabsView.tabsView(with: tabsViewConfig),
            viewControllers: viewControllers,
            pagerDelegate: pagerDelegate
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) Shouldn't be used, Please use provided initializer")
    }

    public func setupPager(
        with viewControllers: [UIViewController],
        tabsView: PagerTab & UIView,
        pagerDelegate: PagerDelegate? = nil,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        self.pagerDelegate = pagerDelegate
        self.tabsView = tabsView
        tabsHeight = tabsView.frame.size.height
        initialLayoutTabsView()
        self.viewControllers = viewControllers
        currentDisplayController?.view.alpha = 0.0
        self.tabsView?.alpha = 0.0
        didSelectTabAtIndex(index: 0, previouslySelected: -1, animated: false, completion: completion)
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration) {
            self.currentDisplayController?.view.alpha = 1.0
            self.tabsView?.alpha = 1.0
        }
    }

    public func setupPager(
        with viewControllers: [UIViewController],
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

    public func setTabsHeight(_ height: CGFloat, animated _: Bool = false) {
        guard let constraint = tabsHeightConstraint,
              height >= 0
        else {
            return
        }
        tabsHeight = height
        constraint.constant = tabsHeight
    }

    private func baseConfig() {
        containerViewController.automaticallyAdjustsScrollViewInsets = false
        containerViewController.extendedLayoutIncludesOpaqueBars = false
        preservesSuperviewLayoutMargins = true
    }

    private func layoutContentViewControllers() {
        guard let firstVC = viewControllers.first else {
            return
        }
        layoutChildViewController(vc: firstVC, position: 0)
        layoutSubviews()
        currentDisplayController = firstVC
    }

    private func initialLayoutTabsView() {
        // Setup TabsView.
        if tabsView != nil {
            tabsView!.onSelectedTabChanging = { [weak self] newIndex, oldIndex, _ in
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
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0
            )
        )

        tabsHeightConstraint = NSLayoutConstraint(
            item: tabsView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: tabsHeight
        )
        tabsView.addConstraint(tabsHeightConstraint!)
    }

    private func getPositionConstraints(for view: UIView) -> [NSLayoutConstraint]? {
        return constraints.filter { (constraint) -> Bool in
            guard
                let firstItem = constraint.firstItem as? NSObject,
                let secondItem = constraint.secondItem as? NSObject
            else { return false }
            return (constraint.firstAttribute == .right &&
                constraint.secondAttribute == .right &&
                firstItem == view &&
                secondItem == self) ||
                (constraint.firstAttribute == .left &&
                    constraint.secondAttribute == .left &&
                    firstItem == view &&
                    secondItem == self)
        }
    }

    private func layoutChildViewController(vc: UIViewController, position: CGFloat) {
        guard let view = vc.view else { return }
        view.preservesSuperviewLayoutMargins = true
        view.translatesAutoresizingMaskIntoConstraints = false

        vc.willMove(toParent: containerViewController)
        insertSubview(vc.view, at: 0)
        containerViewController.addChild(vc)
        vc.didMove(toParent: containerViewController)

        contentViewTrailingConstraint = NSLayoutConstraint(
            item: view,
            attribute: .right,
            relatedBy: .equal,
            toItem: self,
            attribute: .right,
            multiplier: 1.0,
            constant: position
        )
        addConstraint(contentViewTrailingConstraint!)

        contentViewLeadingConstraint = NSLayoutConstraint(
            item: view,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1.0,
            constant: position
        )
        addConstraint(contentViewLeadingConstraint!)

        addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: 1.0,
                constant: 0.0
            )
        )

        if let tabsView = self.tabsView {
            addConstraint(
                NSLayoutConstraint(
                    item: view,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: tabsView,
                    attribute: .bottom,
                    multiplier: 1.0,
                    constant: 0.0
                )
            )
        } else {
            addConstraint(
                NSLayoutConstraint(
                    item: view,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .top,
                    multiplier: 1.0,
                    constant: 0.0
                )
            )
        }
        addConstraint(
            NSLayoutConstraint(
                item: view,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            )
        )

        if hasShownController.contains(vc) == false {
            hasShownController.add(vc)
            // set gestures priority.
            if let rightGesture = rightSwipeGestureRecognizer, let leftGesture = leftSwipeGestureRecognizer {
                vc.view.gestureRecognizers?.forEach {
                    $0.require(toFail: rightGesture)
                    $0.require(toFail: leftGesture)
                }
            }
        }
    }

    private func didSelectTabAtIndex(
        index: Int,
        previouslySelected: Int,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        guard index >= 0, index < viewControllers.count else {
            print("ERROR: Invalid Selection Index.")
            return
        }

        pagerDelegate?.willSelectTab(at: index, previouslySelected: previouslySelected)

        let selectedViewController = viewControllers[index]
        if currentDisplayController != nil, selectedViewController == currentDisplayController! {
            pagerDelegate?.didSelectTab(at: index, previouslySelected: previouslySelected)
            return
        }

        let shouldAnimateLeft = index > previouslySelected
        let newViewInitialPosition = shouldAnimateLeft ? bounds.size.width : -bounds.size.width

        layoutChildViewController(vc: selectedViewController, position: newViewInitialPosition)
        setNeedsLayout()
        layoutIfNeeded()

        if let currentViewConstraints = getPositionConstraints(for: currentDisplayController!.view) {
            currentViewConstraints.forEach { $0.constant = -newViewInitialPosition }
        }

        if let selectedViewConstraints = getPositionConstraints(for: selectedViewController.view) {
            selectedViewConstraints.forEach { $0.constant = 0.0 }
        }
        setNeedsLayout()
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, animations: {
            self.layoutIfNeeded()
        }) { _ in
            if let currentDisplayed = self.currentDisplayController {
                currentDisplayed.willMove(toParent: nil)
                currentDisplayed.view.removeFromSuperview()
                currentDisplayed.removeFromParent()
                currentDisplayed.didMove(toParent: nil)
            }
            self.currentDisplayController = selectedViewController
            self.pagerDelegate?.didSelectTab(at: index, previouslySelected: previouslySelected)
            completion?()
        }
    }

    @objc private func swipeDetected(gesture: UISwipeGestureRecognizer) {
        guard
            let index = tabsView?.currentSelectedIndex(),
            gesture.direction == .right || gesture.direction == .left
        else { return }

        let indexToBe = (gesture.direction == .left) ? index + 1 : index - 1
        guard
            let numberOfTabs = tabsView?.numberOfTabs(),
            indexToBe >= 0, indexToBe < numberOfTabs
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
}
