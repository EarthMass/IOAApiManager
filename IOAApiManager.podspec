#
#  Be sure to run `pod spec lint HXPodTest.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#


Pod::Spec.new do |s|

  s.name         = "IOAApiManager"
  # 版本号
  s.version      = "0.0.4"
  # 描述一下项目的作用
  s.summary      = "网络请求框架对 YTKNetwork二次封装，使用方式多样，简单。"
  s.description  = <<-DESC
  
                      网络请求框架对 YTKNetwork二次封装，使用方式多样，简单。 Easy

                      
                   DESC

  # 项目首页                 
  s.homepage     = "https://github.com/EarthMass/IOAApiManager"
  # 开源许可证
  s.license      = {:type => "MIT", :file => "LICENSE" }
  # 作者信息
  s.author             = { "EarthMass" => "627556038@qq.com"}

  # 所支持的系统以及版本号
  s.platform     = :ios,"8.0"
  s.ios.deployment_target = "8.0"

  # 资源地址链接
  s.source       = { :git => "https://github.com/EarthMass/IOAApiManager.git", :tag => "#{s.version}" }
  # 文件
  s.source_files  = "IOAApiManagerDemo/**/IOAApiManager/*.{h,m}"


  # 是否支持arc
  s.requires_arc = true

  

  s.frameworks = "UIKit" , "Foundation"



  # 所用到 cocoapods 中的其他类库
  s.dependency 'MJExtension' ##数据解析
  s.dependency 'YTKNetwork','2.0.4'  ##网络
  s.dependency 'HXProgressHUD' ##提示





end

