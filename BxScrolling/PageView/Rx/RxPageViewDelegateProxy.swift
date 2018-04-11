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

extension PageView: HasDelegate {
    
    public typealias Delegate = PageViewDelegate
}

open class RxPageViewDelegateProxy: DelegateProxy<PageView, PageViewDelegate>, DelegateProxyType, PageViewDelegate {
    
    public weak private(set) var pageView: PageView?
    
    public init(pageView: PageView) {
        self.pageView = pageView
        super.init(parentObject: pageView, delegateProxy: RxPageViewDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxPageViewDelegateProxy(pageView: $0) }
    }
}
