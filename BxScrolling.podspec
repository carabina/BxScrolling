Pod::Spec.new do |s|

    s.name             = 'BxScrolling'
    s.version = '1.0.0'
    s.swift_version    = '4.1'
    s.summary          = 'An Implementation of Scrollable Interface Elements on iOS in Swift.'

    s.description      = 'BxScrolling implements a page view wrapping UIPageViewController'\
                         ' and mimicks the behavior of common iOS collection views.'

    s.homepage          = 'https://bxscrolling.borchero.com'
    s.documentation_url = 'https://bxscrolling.borchero.com/docs'
    s.license           = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author            = { 'Oliver Borchert' => 'borchero@icloud.com' }
    s.source            = { :git => 'https://github.com/borchero/BxScrolling.git', :tag => s.version.to_s }

    s.ios.deployment_target = '11.0'

    s.source_files = 'BxScrolling/**/*'

    s.dependency 'RxSwift'
    s.dependency 'RxCocoa'
    s.dependency 'BxUtility'
    s.dependency 'BxLayout'
    s.dependency 'BxUI'

    s.framework = 'UIKit'

end
