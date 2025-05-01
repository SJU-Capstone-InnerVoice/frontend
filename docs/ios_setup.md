1. 임시 macOS로 디버깅하기 위해 권한 추가
```html
macos/Runner/DebugProfile.entitlements
<key>com.apple.security.network.client</key>
<true/>
```

2.  ios 마이크, 카메라 접근 권한 추가
```html
 ios/Runner/Info.plist
<key>NSMicrophoneUsageDescription</key>
<string>이 앱은 음성 통화를 위해 마이크를 사용합니다.</string>
<key>NSCameraUsageDescription</key>
<string>이 앱은 영상 통화를 위해 카메라를 사용합니다.</string>
```


3. macOS 마이크, 카메라 접근 권한 추가
```html
macos/Runner/Info.plist 
<key>NSMicrophoneUsageDescription</key>
<string>이 앱은 음성 통화를 위해 마이크를 사용합니다.</string>

<key>NSCameraUsageDescription</key>
<string>이 앱은 영상 통화를 위해 카메라를 사용합니다.</string>
```

4. ios 갤러리 접근 권한 추가
```html
ios/Runner/Info.plist
<key>NSPhotoLibraryUsageDescription</key>
<string>사진을 선택하기 위해 필요합니다.</string>
```
