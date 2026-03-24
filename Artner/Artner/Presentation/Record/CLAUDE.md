# Record — 전시 기록

방문한 전시 기록을 조회하고 새로 입력하는 화면. 사이드바에서 진입.

> 전시기록 입력 화면 상세 스펙: `README_RecordInput.md`

## 파일 구조

```
Record/
├── Model/
│   └── RecordItemModel.swift            # 전시기록 UI 모델 (RecordInput 결과)
├── View/
│   ├── RecordView.swift                 # 기록 목록 레이아웃 (CollectionView)
│   ├── RecordCollectionViewCell.swift   # 기록 셀 (이미지, 전시명, 미술관, 날짜)
│   ├── RecordEmptyView.swift            # 빈 상태 뷰
│   └── RecordInputView.swift            # 전시기록 입력 폼 UI
├── ViewController/
│   ├── RecordViewController.swift       # 기록 목록 VC
│   └── RecordInputViewController.swift  # 전시기록 입력 VC (DatePicker, 이미지 선택)
└── ViewModel/
    ├── RecordViewModel.swift            # 목록 조회 + 삭제
    └── RecordInputViewModel.swift       # 입력값 유효성 검사 + 저장
```

## 데이터 흐름

### 기록 목록
```
RecordView
  ↓
RecordViewController → viewModel.fetchRecords()
  ↓
RecordViewModel → GetRecordsUseCase.execute()
  ↓ GET /records
RecordViewModel → records (Publisher)
```

### 기록 입력 (RecordInputViewController — fullScreen present)
```
RecordInputView (기록하기 버튼)
  ↓
RecordInputViewController → viewModel.saveRecord()
  ↓
RecordInputViewModel → CreateRecordUseCase.execute(name:museum:visitDate:note:image:)
  ↓ POST /api/records
성공 → NotificationCenter.post(.recordDidCreate) + Toast
       → RecordViewController가 목록 갱신
```

## UseCase / Repository / API 맵

| 항목 | 값 |
|------|----|
| UseCase | `GetRecordsUseCase`, `CreateRecordUseCase`, `DeleteRecordUseCase` |
| Repository | `RecordRepository` |
| API | GET `/records`, POST `/api/records`, DELETE `/records/{id}` |
| DIContainer | `makeRecordViewModel()`, `makeRecordInputViewModel()` |

## Request Body (POST /api/records)

```json
{
  "visit_date": "2024-01-15",   // 필수 YYYY-MM-DD
  "name": "전시 이름",           // 필수, 최대 50자
  "museum": "미술관 이름",        // 필수, 최대 30자
  "note": "메모",                // 선택 (없으면 파라미터 제외)
  "image": "base64..."          // 선택 JPEG 70% → Base64 (없으면 파라미터 제외)
}
```

## 유효성 검사 규칙

| 필드 | 조건 |
|------|------|
| 전시 이름 | 필수, 1~50자 (공백 제외) |
| 미술관 이름 | 필수, 1~30자 (공백 제외) |
| 방문 날짜 | 필수, UIDatePicker (Wheel), YYYY-MM-DD, 과거 10년~오늘 |
| 메모 | 선택 |
| 이미지 | 선택, 최대 1개 |

## 날짜 입력 특이사항

- TextField에 키보드 대신 UIDatePicker (Wheel 스타일) 연결
- 직접 텍스트 입력 불가 (`isUserInteractionEnabled = false` 또는 `inputView` 대체)
- 툴바: 완료 버튼 → 날짜 확정, 취소 버튼 → 선택 취소
- `formatDateToString(_ date: Date) -> String` → "YYYY-MM-DD" 변환

## NotificationCenter

```swift
// 발신 (RecordInputViewModel 저장 성공 시)
NotificationCenter.default.post(name: .recordDidCreate, object: record)

// 수신 (RecordViewController 목록 갱신)
NotificationCenter.default.addObserver(self, selector: #selector(handleRecordCreated), name: .recordDidCreate, object: nil)
```

## AI 작업 가이드

### 반드시 지킬 것
- 기록하기 버튼 활성화 조건: 전시 이름 + 미술관 이름 + 방문 날짜 모두 입력
- 저장 성공: `ToastManager.shared.showSuccess("전시기록이 저장되었습니다.")` + `.recordDidCreate` 알림
- 저장 실패: `ToastManager.shared.showError("전시기록 저장에 실패했습니다.")`
- RecordInputViewController는 `fullScreen` present → `onDismiss`/`onRecordSaved` 콜백 처리

### 금지사항
- RecordInputViewController에서 직접 RecordViewController 목록 갱신 금지 (NotificationCenter 사용)
- 이미지를 그대로 전송 금지 (JPEG 70% 압축 + Base64 인코딩 필수)

## 관련 문서
- `README_RecordInput.md` — 전시기록 입력 화면 전체 스펙 (UI 스타일, API, 메서드 상세)
- `../Common/CLAUDE.md` — Toast
- `../../Cooldinator/CLAUDE.md` — showRecord, showRecordInput 라우트
