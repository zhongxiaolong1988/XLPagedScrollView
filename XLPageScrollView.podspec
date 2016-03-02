Pod::Spec.new do |s|

    ###################
    #      Source     #
    ###################
    
    s.name         = "XLPagedScrollView"
    s.version      = "0.0.1"
    s.summary      = "ZXL 'S PagedScrollview"
    s.homepage     = "http://www.camera360.com"
    s.license      = { :type => 'Copyright', :text =>
        <<-LICENSE
        Copyright 2010-2015 Pinguo Inc.
        LICENSE
    }
    s.author       = { "ZXL" => "383558522@qq.com" }
    s.platform     = :ios, "7.0"
    s.source       = { :git => "https://github.com/zhongxiaolong1988/XLPagedScrollView.git", :tag => "0.0.1"}
    
    s.requires_arc = true

    s.source_files = 'Classes/**/*.{h,m,mm,cpp,c,hpp}'

#    s.frameworks = 'ImageIO', 'CoreMotion', 'CoreMedia', 'CoreImage', 'CoreGraphics'
#    s.libraries = 'z', 'stdc++', 'c++'

end
