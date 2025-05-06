### ✅ iOS에서 ffmpeg_kit_flutter 사용 시 404 오류 트러블슈팅
❗ 문제 요약
ffmpeg_kit_flutter: ^6.0.3 사용 시, 내부적으로 CocoaPods가
필요한 iOS용 .zip 프레임워크 파일을 HTTP URL을 통해 다운로드하는데,
해당 리소스가 삭제되어 404 오류가 발생하며 설치가 실패함.

🛠️ 해결 방법
404 오류를 우회한 커스텀 브랜치를 사용하는 Git 경로로 대체:
```yaml
ffmpeg_kit_flutter:
git:
url: https://github.com/Sahad2701/ffmpeg-kit.git
path: flutter/flutter
ref: flutter_fix_retired_v6.0.3  # CocoaPods 404 오류 수정 브랜치
```