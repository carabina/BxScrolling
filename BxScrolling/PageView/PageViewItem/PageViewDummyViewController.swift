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
import BxLayout

internal class PageViewDummyScene: Scene, Layoutable, PageViewIndexable {
    
    let managedView: PageViewItemView
    let index: Int
    
    internal init(managing view: PageViewItemView, index: Int) {
        self.managedView = view
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = .clear
    }
    
    func defineLayout() {
        self.view.addSubviews(managedView)
            .layout { $1.follow($0) }.apply()
    }
}
