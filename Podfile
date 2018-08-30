# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

DEFAULT_DEVELOPMENT_TEAM = 'GFSP92A3FB'
DEFAULT_BUNDLE_IDENTIFIER = 'joshua.simplesequencer'

target 'SimpleSequencer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SimpleSequencer
  pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
  pod 'AudioKit', '~> 4.0'

end

post_install do |installer|
  root = File.dirname(__FILE__)

  dev_team_file = File.join(root, ".dev-team")
  dev_team = DEFAULT_DEVELOPMENT_TEAM
  if File.exist?(dev_team_file)
    dev_team = File.read(dev_team_file).chomp
  end

  bundle_id_file = File.join(root, ".bundle-identifier")
  bundle_id = DEFAULT_BUNDLE_IDENTIFIER
  if File.exist?(bundle_id_file)
    bundle_id = File.read(bundle_id_file).chomp
  end

  Dir.glob(File.join(root, "Pods/Target Support Files/Pods-SimpleSequencer/*.xcconfig")) do |xcconfig_file|
    File.open(xcconfig_file, 'a+') do |xcconfig|
      xcconfig.puts "DEVELOPMENT_TEAM = #{dev_team}"
      xcconfig.puts "PRODUCT_BUNDLE_IDENTIFIER = #{bundle_id}"
    end
  end
end
