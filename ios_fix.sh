#!/bin/bash

# Скрипт для исправления конфигурации iOS в проекте Flutter
# Устанавливает минимальную версию iOS 13.0 во всех важных файлах

echo "Начинаем исправление iOS конфигурации..."

# Обновляем AppFrameworkInfo.plist
cat > ios/Flutter/AppFrameworkInfo.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>App</string>
  <key>CFBundleIdentifier</key>
  <string>io.flutter.flutter.app</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>App</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>MinimumOSVersion</key>
  <string>13.0</string>
</dict>
</plist>
EOL

echo "AppFrameworkInfo.plist обновлен"

# Создаем простой Podfile
cat > ios/Podfile << EOL
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
EOL

echo "Podfile создан"

# Создаем XCConfig файлы с минимальной версией iOS
echo "IPHONEOS_DEPLOYMENT_TARGET=13.0" > ios/Flutter/Debug.xcconfig
echo "#include \"Generated.xcconfig\"" >> ios/Flutter/Debug.xcconfig

echo "IPHONEOS_DEPLOYMENT_TARGET=13.0" > ios/Flutter/Release.xcconfig
echo "#include \"Generated.xcconfig\"" >> ios/Flutter/Release.xcconfig

echo "XCConfig файлы обновлены"

# Если проект уже инициализирован, обновляем project.pbxproj
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
  echo "Обновляем project.pbxproj..."
  sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9]*\.[0-9]*;/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/g' ios/Runner.xcodeproj/project.pbxproj
fi

echo "Конфигурация iOS исправлена. Запустите 'flutter clean && flutter pub get && cd ios && pod install && cd ..'" 