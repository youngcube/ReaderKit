source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

def myCommonPods
	pod 'FolioReaderKit'
    pod 'vfrReader'
    pod 'TesseractOCRiOS'
end

target 'ReaderKit_en' do
    myCommonPods
end

target 'ReaderKit_fr' do
    myCommonPods
end

target 'ReaderKit_de' do
    myCommonPods
end

target 'ReaderKit_es' do
    myCommonPods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
  end
