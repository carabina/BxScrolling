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

import RxSwift
import RxCocoa

class RxPageViewReactiveArrayDataSourceSequenceWrapper<S: Sequence>: RxPageViewReactiveArrayDataSource<S.Iterator.Element>, RxPageViewDataSourceType {
    
    typealias Element = S
    
    func pageView(_ pageView: PageView, observedEvent: Event<S>) {
        Binder(self) { pageViewDataSource, items in
            let items = Array(items)
            pageViewDataSource.pageView(pageView, observedElements: items)
        }.on(observedEvent)
    }
}

class RxPageViewReactiveArrayDataSource<Element>: PageViewDataSource {
    
    private var itemModels: [Element]? = nil
    
    let viewFactory: (PageView, Int, Element) -> PageViewItem
    
    init(viewFactory: @escaping (PageView, Int, Element) -> PageViewItem) {
        self.viewFactory = viewFactory
    }
    
    func numberOfItems(in pageView: PageView) -> Int {
        return itemModels?.count ?? 0
    }
    
    func pageView(_ pageView: PageView, viewForItemAt index: Int) -> PageViewItem {
        return viewFactory(pageView, index, itemModels![index])
    }
}

extension RxPageViewReactiveArrayDataSource where Element: Equatable {
    
    func pageView(_ pageView: PageView, observedElements: [Element]) {
        let _old = self.itemModels
        self.itemModels = observedElements
        guard let old = _old, old.count > 0 else {
            pageView.reloadData(animated: false)
            return
        }
        let oldSelected = old[pageView.position]
        if let first = observedElements.index(where: { $0 == oldSelected }) {
            pageView.setPosition(to: first, animated: false)
        } else {
            pageView.reloadData(animated: false)
        }
    }
}

extension RxPageViewReactiveArrayDataSource {
    
    func pageView(_ pageView: PageView, observedElements: [Element]) {
        let _old = self.itemModels
        self.itemModels = observedElements
        if let old = _old, old.count > 0 {
            pageView.reloadData(animated: false)
        } else {
            pageView.reloadData(animated: false)
        }
    }
}
