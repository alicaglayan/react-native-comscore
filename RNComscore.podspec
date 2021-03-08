
Pod::Spec.new do |s|
  s.name         = "RNComscore"
  s.version      = "1.0.0"
  s.summary      = "RNComscore"
  s.description  = "RNComscore"
  s.homepage     = "https://github.com/author/RNComscore"
  s.license      = "MIT"
  s.author       = { "author" => "ihsancaglayan@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/author/RNComscore.git", :tag => "master" }
  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "ComScore"
end

  