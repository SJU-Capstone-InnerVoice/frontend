1. 임시 macOS로 디버깅하기 위해 권한 추가
```
macos/Runner/DebugProfile.entitlements
<key>com.apple.security.network.client</key>
<true/>
```