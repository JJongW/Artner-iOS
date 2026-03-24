# Entry — 도슨트 입장점 + 채팅

도슨트 상세 정보 표시 및 AI 채팅으로 커스텀 도슨트 생성 진입점. Chat → Player로 이어짐.

## 파일 구조

```
Entry/
├── View/
│   ├── EntryView.swift              # 도슨트 상세 (이미지, 제목, 작가, 설명, 재생 버튼)
│   ├── ChatView.swift               # 채팅 메시지 목록 (TableView)
│   ├── ChatInputBar.swift           # 채팅 입력바 (텍스트필드 + 전송 버튼)
│   ├── BotMessageCell.swift         # AI 봇 메시지 셀
│   ├── UserMessageCell.swift        # 사용자 메시지 셀
│   ├── DocentButtonCell.swift       # 도슨트 생성 완료 후 "재생" 버튼 셀
│   └── PaddingLabel.swift           # 패딩 포함 레이블 (말풍선 스타일)
├── ViewController/
│   ├── EntryViewController.swift    # 도슨트 상세 + 재생/채팅 진입
│   └── ChatViewController.swift    # 채팅 화면 (키보드 관리 포함)
└── ViewModel/
    ├── EntryViewModel.swift         # 도슨트 정보 보유, Player/Chat 이동 결정
    └── ChatViewModel.swift          # 채팅 메시지 관리, 실시간 도슨트 생성 API 호출
```

## 데이터 흐름

### Entry → Player (바로 재생)
```
EntryView (재생 버튼)
  ↓
EntryViewController → coordinator.showPlayer(docent:)
```

### Entry → Chat → Player (AI 채팅)
```
EntryView (채팅 버튼)
  ↓
EntryViewController → coordinator.showChat(docent:keyword:)
  ↓
ChatViewController → viewModel.sendMessage(text:)
  ↓
ChatViewModel → APIService.createRealtimeDocent(keyword:docentId:)
  ↓ SSE/Streaming 응답
ChatViewModel → messages (Publisher) → 메시지 목록 업데이트
  ↓ 도슨트 생성 완료
ChatViewModel → docentReady (Publisher)
  ↓
ChatViewController → coordinator.showPlayer(docent:) [새 Docent with audioJobId]
```

## UseCase / API 맵

| 항목 | 값 |
|------|----|
| UseCase | 없음 (직접 APIService 사용) |
| API | SSE/Streaming: 실시간 도슨트 생성 |
| DIContainer | `EntryViewModel`/`ChatViewModel` — DIContainer 미사용, 직접 init |

> **주의**: Entry/Chat은 DIContainer를 사용하지 않고 AppCoordinator에서 직접 init.

## 주요 컴포넌트

- `ChatViewModel.sendMessage(_:)` — 사용자 메시지 전송 + 봇 응답 스트리밍
- `ChatViewModel.docentReady` — 도슨트 생성 완료 Publisher → Player 이동 트리거
- `ChatInputBar` — 전송 버튼 활성화/비활성화, 키보드 높이에 따라 레이아웃 조정
- `DocentButtonCell` — 생성된 도슨트 "바로 듣기" 버튼

## AI 작업 가이드

### 반드시 지킬 것
- 채팅에서 도슨트 생성 완료 후 → `coordinator.showPlayer(docent:)` (audioJobId 포함 Docent 전달)
- 키보드 표시/숨김 시 ChatView 레이아웃 조정 (NotificationCenter keyboardWillShow/Hide)
- 스트리밍 메시지 수신 중 로딩 인디케이터 표시

### 금지사항
- ChatViewController에서 직접 PlayerViewController 생성/push 금지

## 관련 문서
- `../Player/CLAUDE.md` — 재생 화면
- `../../Cooldinator/CLAUDE.md` — showChat, showPlayer 라우트
