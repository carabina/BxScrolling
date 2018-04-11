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
import BxUI

extension Reactive where Base: PageView {
    
    public func items<S: Sequence, O: ObservableType>() -> (_ source: O)
        -> (_ factory: @escaping (PageView, Int, S.Iterator.Element) -> PageViewItem) -> Disposable where O.E == S {
            return { source in
                { factory in
                    let dataSource = RxPageViewReactiveArrayDataSourceSequenceWrapper<S>(viewFactory: factory)
                    return self.items(dataSource: dataSource)(source)
                }
            }
    }
    
    public func items<DataSource: RxPageViewDataSourceType & PageViewDataSource, O: ObservableType>(dataSource: DataSource)
        -> (_ source: O) -> Disposable where DataSource.Element == O.E {
            return { source in
                let disposable1 = source.subscribe { event in
                    dataSource.pageView(self.base, observedEvent: event)
                }
                let disposable2 = RxPageViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: true,
                                                                                   onProxyForObject: self.base)
                return Disposables.create(disposable1, disposable2)
            }
    }
    
    public var progress: Observable<CGFloat> {
        return didTransitionToItem
            .map { CGFloat($0) / CGFloat(self.base.count) }
            .startWith(CGFloat(self.base.position) / CGFloat(self.base.count))
    }
    
    public var displacedProgress: Observable<CGFloat> {
        return progress
            .map { 0.05 + $0 * 0.95 }
    }
    
    public var nonlinearProgress: Observable<CGFloat> {
        return progress
            .map { 0.05 + sqrt($0) * 0.95 }
    }
    
    public var indication: Observable<Indicatable.Data> {
        return didTransitionToItem
            .map { (CGFloat($0), self.base.count) }
            .startWith((CGFloat(self.base.position), self.base.count))
    }
    
    public var delegate: DelegateProxy<PageView, PageViewDelegate> {
        return RxPageViewDelegateProxy.proxy(for: base)
    }
    
    public var didTransitionToItem: Observable<Int> {
        return delegate.methodInvoked(#selector(PageViewDelegate.pageView(_:didTransitionToItemAt:)))
            .map { $0[1] as! Int }
    }
}
