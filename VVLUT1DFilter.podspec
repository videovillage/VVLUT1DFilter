Pod::Spec.new do |s|
  s.name             = "VVLUT1DFilter"
  s.version          = begin; File.read('VERSION'); rescue; '9000.0.0'; end
  s.summary          = "A Core Image Filter for 1D Lookup Tables."
  s.homepage         = "https://github.com/videovillage/VVLUT1DFilter"
  s.license          = 'MIT'
  s.author           = { "gregcotten" => "gregcotten@gmail.com" }
  s.source           = { :git => "https://github.com/videovillage/VVLUT1DFilter.git", :tag => s.version.to_s }

  s.platform     = :osx, '10.8'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**'

  s.resource_bundle = {'VVLUT1DFilterKernel' => 'Pod/Kernels/*.cikernel'}

  s.frameworks = 'QuartzCore'
end
