# Uncomment the next line to define a global platform for your project
 source 'https://github.com/CocoaPods/Specs.git'
 platform :ios, '9.0'
 use_frameworks!

abstract_target 'AbstractTarget' do
    # Pods for RequestResponseMapper
    pod 'SwiftyJSON', '~> 3.1.4'
    pod 'Alamofire', '~> 4.4.0'

  target 'RequestResponseMapper' do
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        workDir = Dir.pwd
        
        installer.pods_project.build_configurations.each do |config|
            configuration = "#{config}".downcase
            xcconfigFilename = "#{workDir}/Pods/Target Support Files/#{target.name}/#{target.name}.#{configuration}.xcconfig"
            if File.exist?("#{xcconfigFilename}")
                if "#{config}" == "Debug"
                    config.build_settings['OTHER_SWIFT_FLAGS'] = '-D DEBUG'
                end
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
            end
        end
    end
    
end
