# 🗣️ Inner Voice
부모와 아이의 소통을 돕는 실시간 음성 화상 대화 서비스


## 🛠️ Tech Stack

- **Flutter**  
  모바일 및 웹 앱을 동시에 개발할 수 있는 크로스 플랫폼 UI 프레임워크입니다.  
  빠른 UI 개발과 높은 생산성을 위해 채택했습니다.

- **Provider / BLoC**  
  상태 관리를 위한 핵심 도구입니다.  
  Provider는 간단한 전역 상태 공유에, BLoC은 이벤트 기반의 복잡한 상태 흐름 관리에 사용됩니다.

- **Dio**  
  강력한 기능을 제공하는 HTTP 클라이언트로,  
  API 통신 시 에러 핸들링, 인터셉터, 파일 업로드 등 다양한 네트워크 작업을 유연하게 처리합니다.

- **WebRTC / WebSocket**  
  실시간 양방향 통신을 구현하기 위해 사용됩니다.  
  WebRTC는 음성/영상 스트리밍에, WebSocket은 데이터 채널 및 호출 요청 전송에 사용됩니다.

- **FFmpeg**  
  오디오 파일 병합, 포맷 변환 등의 고급 멀티미디어 처리를 위해 사용됩니다.  
  TTS 결과 병합 및 녹음 파일 후처리 등에 활용됩니다.

- **Shared Preferences**  
  사용자의 로그인 정보, 설정 값을 기기에 JSON 형식으로 저장하기 위해 사용됩니다.  
  간단한 로컬 데이터 유지에 적합합니다.


## 📁 Directory Structure
```plaintext
lib
├── core
│   ├── constants
│   │   ├── api
│   │   │   ├── call_request_api.dart
│   │   │   ├── character_img_api.dart
│   │   │   ├── friends_api.dart
│   │   │   ├── login_api.dart
│   │   │   ├── socket_api.dart
│   │   │   ├── summary_api.dart
│   │   │   └── tts_api.dart
│   │   └── user
│   │       └── role.dart
│   ├── theme
│   │   ├── iv_colors.dart
│   │   └── iv_theme.dart
│   └── utils
│       ├── date_utils.dart
│       ├── logger.dart
│       ├── logs
│       │   └── audio_logger.dart
│       ├── string_utils.dart
│       └── validators.dart
├── data
│   ├── datasources
│   │   ├── local
│   │   │   └── auth_local_datasource.dart
│   │   └── remote
│   ├── models
│   │   ├── character
│   │   │   └── character_image_model.dart
│   │   ├── friend
│   │   │   ├── friend_model.dart
│   │   │   └── friend_request_model.dart
│   │   ├── record
│   │   │   ├── session_metadata_model.dart
│   │   │   ├── tts_record_model.dart
│   │   │   └── tts_segment_model.dart
│   │   ├── summary
│   │   │   └── summary_model.dart
│   │   └── user
│   │       └── user_model.dart
│   └── repositories
│       └── chat_repository_impl.dart
├── domain
│   ├── entities
│   │   ├── summary.dart
│   │   └── user.dart
│   ├── repositories
│   │   └── chat_repository.dart
│   └── usecases
│       ├── handle_conversation_flow.dart
│       ├── initiate_p2p_connection.dart
│       ├── register_child.dart
│       └── summarize_conversation.dart
├── injection.dart
├── logic
│   ├── blocs
│   │   └── summary
│   │       ├── summary_bloc.dart
│   │       ├── summary_event.dart
│   │       └── summary_state.dart
│   └── providers
│       ├── character
│       │   └── character_img_provider.dart
│       ├── communication
│       │   ├── call_request_provider.dart
│       │   └── call_session_provider.dart
│       ├── network
│       │   └── dio_provider.dart
│       ├── record
│       │   └── call_record_provider.dart
│       ├── summary
│       │   └── summary_provider.dart
│       └── user
│           └── user_provider.dart
├── main.dart
├── presentation
│   ├── routes
│   │   ├── auth_gate.dart
│   │   ├── child_routes.dart
│   │   ├── iv_router.dart
│   │   └── parent_routes.dart
│   ├── screens
│   │   ├── child
│   │   │   ├── call
│   │   │   │   ├── call_screen.child.dart
│   │   │   │   ├── end
│   │   │   │   │   └── call_end_screen.child.dart
│   │   │   │   ├── start
│   │   │   │   │   └── call_start_screen.child.dart
│   │   │   │   └── waiting
│   │   │   │       └── call_waiting_screen.child.dart
│   │   │   ├── child_screen.dart
│   │   │   └── setting
│   │   │       ├── friends
│   │   │       │   ├── check
│   │   │       │   │   └── friend_request_check_screen.dart
│   │   │       │   └── list
│   │   │       │       └── friend_list_screen.dart
│   │   │       └── setting_screen.child.dart
│   │   ├── go_design_screen.dart
│   │   ├── login
│   │   │   ├── login_screen.dart
│   │   │   └── sign-up
│   │   │       └── sign-up_screen.dart
│   │   └── parent
│   │       ├── call
│   │       │   ├── call_screen.parent.dart
│   │       │   ├── start
│   │       │   │   └── call_start_screen.parent.dart
│   │       │   └── waiting
│   │       │       └── call_waiting_screen.parent.dart
│   │       ├── character
│   │       │   ├── add
│   │       │   │   └── character_add_screen.dart
│   │       │   ├── info
│   │       │   │   └── character_info_screen.dart
│   │       │   └── voice
│   │       │       └── synthesis
│   │       │           └── voice_synthesis_screen.dart
│   │       ├── parent_screen.dart
│   │       ├── setting
│   │       │   ├── friends
│   │       │   │   ├── list
│   │       │   │   │   └── friend_list_screen.dart
│   │       │   │   └── request
│   │       │   │       └── friend_request_screen.dart
│   │       │   └── setting_screen.parent.dart
│   │       └── summary
│   │           └── summary_screen.dart
│   └── widgets
│       ├── error_dialog.dart
│       └── voice_waveform.dart
└── services
├── call_recording_service.dart
├── call_request_service.dart
├── friend_service.dart
├── login_service.dart
├── stt_summary_service.dart
├── summary_service.dart
├── tts_service.dart
└── web_rtc_service.dart
```


## 📦 Using Package

| 패키지명                  | 버전         | 설명                                                       |
|---------------------------|--------------|------------------------------------------------------------|
| `go_router`               | ^14.8.1      | 선언형 방식으로 라우팅을 관리하는 패키지                   |
| `provider`                | ^6.1.4       | 간단하고 직관적인 상태 관리 솔루션                          |
| `flutter_bloc`            | ^9.1.0       | BLoC 패턴 기반 상태 관리 프레임워크                         |
| `dio`                     | ^5.8.0+1     | 강력한 기능을 가진 HTTP 클라이언트                         |
| `shared_preferences`      | ^2.5.3       | 로컬 저장소에 JSON 데이터 저장                             |
| `flutter_webrtc`          | ^0.13.1      | WebRTC를 Flutter에서 사용하기 위한 패키지                   |
| `web_socket_channel`      | ^3.0.2       | WebSocket 통신을 위한 패키지                               |
| `path_provider`           | ^2.1.5       | 기기별 파일 경로 접근을 도와주는 패키지                    |
| `flutter_dotenv`          | ^5.2.1       | .env 파일로 환경변수 관리                                   |
| `flutter_advanced_calendar`| ^1.4.3      | 고급 캘린더 UI 컴포넌트 제공                               |
| `image_picker`            | ^1.1.2       | 갤러리/카메라에서 이미지/비디오 선택                      |
| `file_picker`             | ^10.1.2      | 파일 탐색기에서 파일 선택 기능 제공                        |
| `just_audio`              | ^0.10.2      | 다양한 오디오 포맷 재생 가능                               |
| `record`                  | ^6.0.0       | 오디오 녹음을 위한 Flutter 패키지                          |
| `collection`              | ^1.18.0      | 컬렉션 관련 유틸리티                                       |
| `http_parser`             | ^4.0.2       | HTTP 관련 데이터 파싱용 유틸리티                           |
| `audio_session`           | ^0.2.1       | 오디오 세션 구성 도우미                                    |
| `google_fonts`            | ^6.2.1       | Google Fonts 사용 지원                                     |
| `flutter_launcher_icons`  | ^0.14.3      | 앱 아이콘 생성 자동화 툴                                   |
| `shimmer`                 | ^3.0.0       | 로딩 시 반짝이는 효과 UI 제공                              |
| `lottie`                  | ^3.3.1       | 애니메이션 JSON(Lottie) 렌더링                             |
| `ffmpeg_kit_flutter`      | git 버전     | FFmpeg 기능을 Flutter에서 사용할 수 있도록 지원            |

## 📄 문서 목록 (Documentation)

Flutter 프로젝트 설정 및 문제 해결을 위한 문서들을 정리해두었습니다.

### 🔧 환경 설정

해당 앱은 iOS만 타겟을 하였기 때문에 Andoroid 설정 파일은 임의로 생성하였음.

- [Android 설정 가이드](./docs/android_setup.md)  
  Android 환경에서 프로젝트를 실행하기 위한 설정 방법을 설명합니다.

- [iOS 설정 가이드](./docs/ios_setup.md)  
  iOS 환경에서 필요한 설정 및 권한 관련 주의사항을 정리합니다.

### 🧪 디버깅 및 문제 해결

- [문제 해결 가이드 (Troubleshooting)](./docs/troubleshooting.md)  
  프로젝트 실행 중 발생할 수 있는 일반적인 오류와 해결 방법을 정리한 문서입니다.

### ✅ 작업 목록

- [할 일 목록 (TODO)](./docs/todo.md)  
  프로젝트 개발 중 해야 할 일들을 정리한 목록입니다. 기여 시 참고해주세요.



## 📄 License
This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.