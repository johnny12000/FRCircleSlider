Pod::Spec.new do |s|
  s.name             = 'FRCircleSlider'
  s.version          = '0.1.4'
  s.summary          = 'Select two values on a circular slider'
  s.description      = <<-DESC
Select two values on a circular slider
                       DESC
  s.homepage         = 'https://github.com/johnny12000/FRCircleSlider'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'johnny12000' => 'ristic.nikola@icloud.com' }
  s.source           = { :git => 'https://github.com/johnny12000/FRCircleSlider.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files     = 'FRCircleSlider/*'
end
