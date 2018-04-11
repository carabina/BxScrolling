// Copyright 2018 Oliver Borchert
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import RxSwift
import RxCocoa
import BxLayout
import BxUI

open class PageView: View, Layoutable {
    
    public enum Direction {
        
        case vertical
        case horizontal
    }
    
    public enum InteractionStyle {
        
        case none
        case panFromLeftEdge
        case scroll
    }
    
    private lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: direction == .vertical ? .vertical : .horizontal,
                                              options: [UIPageViewControllerOptionInterPageSpacingKey: interitemSpacing])
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()
    
    public weak var dataSource: PageViewDataSource? {
        didSet {
            reloadData(animated: false)
        }
    }
    
    public weak var delegate: PageViewDelegate?
    
    public var isCarouselEnabled: Bool = false
    
    public var interactionStyle: InteractionStyle = .scroll {
        didSet {
            switch interactionStyle {
            case .none:
                pageViewController.dataSource = nil
            case .panFromLeftEdge, .scroll:
                pageViewController.dataSource = self
            }
        }
    }
    
    open override var clipsToBounds: Bool {
        get { return super.clipsToBounds && pageViewController.view.clipsToBounds }
        set {
            super.clipsToBounds = newValue
            pageViewController.view.clipsToBounds = newValue
        }
    }
    
    private let direction: Direction
    private let interitemSpacing: CGFloat
    
    public private(set) var position = 0
    
    public var count: Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    public init(direction: Direction = .horizontal, interitemSpacing: CGFloat = 0) {
        self.direction = direction
        self.interitemSpacing = interitemSpacing
        super.init()
        clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func defineLayout() {
        self.addSubviews(pageViewController.view)
            .layout { $1.follow($0) }.apply()
    }
    
    public func reloadData(animated: Bool) {
        setPosition(to: 0, animated: animated)
    }
    
    public func move(to position: Int, animated: Bool) {
        guard position != self.position else { return }
        self.setPosition(to: position, animated: animated)
    }
    
    internal func setPosition(to position: Int, animated: Bool) {
        guard let dataSource = dataSource, dataSource.numberOfItems(in: self) > 0 else {
            pageViewController.setViewControllers([UIViewController()], direction: .forward,
                                                  animated: false, completion: nil)
            return
        }
        let previous = pageViewController.viewControllers
        pageViewController.setViewControllers([dummyViewController(for: position)], direction: .forward,
                                              animated: animated, completion: nil)
        pageViewController(pageViewController, didFinishAnimating: true,
                           previousViewControllers: previous ?? [], transitionCompleted: true)
    }
    
    public var currentItem: PageViewItem? {
        let controller = pageViewController.viewControllers?.first
        if let dummy = controller as? PageViewDummyScene {
            return dummy.managedView
        } else if let scene = controller as? ScenePageViewItem {
            return scene
        }
        return nil
    }
}

extension PageView: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PageViewIndexable, let next = position(after: vc.index) else {
            return nil
        }
        return dummyViewController(for: next)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PageViewIndexable, let previous = position(before: vc.index) else {
            return nil
        }
        return dummyViewController(for: previous)
    }
    
    private func position(after position: Int) -> Int? {
        guard let dataSource = self.dataSource else {
            return nil
        }
        let items = dataSource.numberOfItems(in: self)
        if isCarouselEnabled && items > 1 {
            return (position + 1) % items
        } else if position + 1 < items {
            return position + 1
        } else {
            return nil
        }
    }
    
    private func position(before position: Int) -> Int? {
        guard let dataSource = self.dataSource else {
            return nil
        }
        let items = dataSource.numberOfItems(in: self)
        if isCarouselEnabled && items > 1 {
            return (position - 1 + items) % items
        } else if position > 0 {
            return position - 1
        } else {
            return nil
        }
    }
    
    private func dummyViewController(for position: Int) -> UIViewController {
        guard let dataSource = self.dataSource else {
            fatalError("Data source not set.")
        }
        let view = dataSource.pageView(self, viewForItemAt: position)
        if let sceneView = view as? ScenePageViewItem {
            return sceneView
        } else if let managedView = view as? PageViewItemView {
            return PageViewDummyScene(managing: managedView, index: position)
        }
        fatalError("Expected either `ScenePageViewItem` or `PageViewItemView`.")
    }
}

extension PageView: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { // prevent overlapping on dynamic size change
            if let controller = pageViewController.viewControllers?.first {
                pageViewController.setViewControllers([controller], direction: .forward,
                                                      animated: false, completion: nil)
            }
        }
        guard let controller = pageViewController.viewControllers?.first as? PageViewIndexable, completed else {
            self.position = 0
            return
        }
        self.position = controller.index
        delegate?.pageView?(self, didTransitionToItemAt: controller.index)
    }
}
