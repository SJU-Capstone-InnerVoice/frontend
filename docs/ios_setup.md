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

5. ios 음성 녹음 및 UI에 업로드 권한 추가
```html
ios/Runner/Info.plist
<key>NSMicrophoneUsageDescription</key>
<string>음성 녹음을 위해 마이크 접근 권한이 필요합니다.</string>
<key>UIFileSharingEnabled</key>
<true/>
```

6. ios 오디오 세션을 활성화 권한 추가
```html
ios/Runner/Info.plist
<key>NSAppleMusicUsageDescription</key>
<string>오디오 재생을 위해 필요합니다.</string>
```

7. icon 적용을 위한 파일 추가
```html
flutter_launcher_icons.yaml
flutter_launcher_icons:
  ios: true
  android: true
  remove_alpha_ios: true
  image_path: "assets/icons/iv_icon.png"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/icons/iv_icon.png"
```

8. 테스트플라이트 빌드 시 암호화 없음을 자동 명시
```html
ios/Runner/Info.plist
<key>ITSAppUsesNonExemptEncryption</key><false/>
```