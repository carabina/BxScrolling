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

extension PageView: HasDataSource {

    public typealias DataSource = PageViewDataSource
}

fileprivate let pageViewDataSourceNotSet = PageViewDataSourceNotSet()

final fileprivate class PageViewDataSourceNotSet: PageViewDataSource {

    func numberOfItems(in pageView: PageView) -> Int {
        return 0
    }

    func pageView(_ pageView: PageView, viewForItemAt index: Int) -> PageViewItem {
        fatalError("Page view data source configured incorrectly.")
    }
}

public class RxPageViewDataSourceProxy: DelegateProxy<PageView, PageViewDataSource>,
                                        DelegateProxyType, PageViewDataSource {

    public weak private(set) var pageView: PageView?

    public init(pageView: ParentObject) {
        self.pageView = pageView
        super.init(parentObject: pageView, delegateProxy: RxPageViewDataSourceProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxPageViewDataSourceProxy(pageView: $0) }
    }

    private weak var _requiredMethodsDataSource: PageViewDataSource? = pageViewDataSourceNotSet

    public override func setForwardToDelegate(_ forwardToDelegate: PageViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? pageViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

    public func numberOfItems(in pageView: PageView) -> Int {
        return (_requiredMethodsDataSource ?? pageViewDataSourceNotSet).numberOfItems(in: pageView)
    }

    public func pageView(_ pageView: PageView, viewForItemAt index: Int) -> PageViewItem {
        return (_requiredMethodsDataSource ?? pageViewDataSourceNotSet).pageView(pageView, viewForItemAt: index)
    }
}

