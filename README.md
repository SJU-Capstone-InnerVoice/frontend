# 🗣️ Inner Voice
부모와 아이의 소통을 돕는 실시간 음성 화상 대화 서비스

## 📁 Directory Structure
```plaintext
lib
├── core
│   ├── constants
│   │   ├── api
│   │   │   ├── polling_api.dart
│   │   │   ├── socket_api.dart
│   │   │   └── tts_api.dart
│   │   └── user
│   │       └── role.dart
│   ├── theme
│   │   ├── iv_colors.dart
│   │   └── iv_theme.dart
│   └── utils
│       ├── date_utils.dart
│       ├── logger.dart
│       ├── string_utils.dart
│       └── validators.dart
├── data
│   ├── datasources
│   │   └── summary_remote_datasource.dart
│   ├── models
│   │   ├── summary_model.dart
│   │   └── user_model.dart
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
│       ├── communication
│       │   ├── call_polling_provider.dart
│       │   ├── call_session_provider.dart
│       │   └── signaling_provider.dart
│       └── summary
│           └── summary_provider.dart
├── main.dart
├── presentation
│   ├── routes
│   │   ├── child_routes.dart
│   │   ├── iv_router.dart
│   │   └── parent_routes.dart
│   ├── screens
│   │   ├── child
│   │   │   ├── call
│   │   │   │   └── call_screen.child.dart
│   │   │   ├── child_screen.dart
│   │   │   └── setting
│   │   │       └── setting_screen.child.dart
│   │   ├── login
│   │   │   ├── find-password
│   │   │   │   └── find-password.dart
│   │   │   ├── login_screen.dart
│   │   │   └── sign-up
│   │   │       └── sign-up_screen.dart
│   │   ├── mode
│   │   │   └── mode_screen.dart
│   │   └── parent
│   │       ├── call
│   │       │   └── call_screen.parent.dart
│   │       ├── parent_screen.dart
│   │       ├── setting
│   │       │   └── setting_screen.parent.dart
│   │       └── summary
│   │           └── summary_screen.dart
│   └── widgets
│       └── voice_waveform.dart
└── services
    ├── call_audio_recording_service.dart
    ├── call_polling_service.dart
    ├── stt_summary_service.dart
    ├── summary_service.dart
    ├── tts_service.dart
    └── web_rtc_service.dart
```


## 📦 Using Package
| 패키지명            | 버전         | 설명                                           |
|---------------------|--------------|------------------------------------------------|
| `go_router`         | ^14.8.1      | 선언형 방식으로 라우팅을 관리하는 패키지       |
| `provider`          | ^6.1.4       | 간단하고 직관적인 상태 관리 솔루션              |
| `dio`               | ^5.8.0+1     | 강력한 기능을 가진 HTTP 클라이언트              |
| `shared_preferences`| ^2.5.3       | 기기에 JSON 형식으로 로컬 데이터 저장           |
