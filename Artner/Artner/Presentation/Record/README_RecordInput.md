# 전시기록 입력 화면 (RecordInputView)

## 개요
전시회 방문 기록을 입력하고 저장하는 화면입니다. Clean Architecture 패턴을 따라 View - ViewController - ViewModel - UseCase - Repository - APIService 구조로 구현되어 있습니다.

## 주요 기능

### 1. 전시 이름 입력
- **필드**: `exhibitionNameTextField`
- **최대 글자 수**: 50자
- **실시간 카운터**: 우측 상단에 "0/50" 형식으로 표시
- **스타일**: 
  - 폰트: 20pt, Bold
  - 색상: #FFFFFF 80% opacity
  - 밑줄: #FFFFFF 80% opacity

### 2. 미술관 이름 입력
- **필드**: `museumNameTextField`
- **최대 글자 수**: 30자
- **실시간 카운터**: 필드 내 우측에 "0/30" 형식으로 표시
- **스타일**:
  - 배경색: #222222
  - 테두리: #FFFFFF 10% opacity (기본), #FF7C27 (포커스 시)
  - 라운드: 6px

### 3. 방문 날짜 선택 ⭐ NEW
- **필드**: `visitDateTextField`
- **입력 방식**: UIDatePicker (Wheel 스타일)
- **날짜 형식**: "YYYY-MM-DD" (예: "2024-01-15")
- **제약 사항**:
  - 최대 날짜: 오늘
  - 최소 날짜: 과거 10년
- **스타일**:
  - DatePicker: 다크 모드 (배경 #222222, 텍스트 #FFFFFF)
  - 툴바 배경: #222222
  - 버튼 색상: #FF7C27 (완료/취소)
- **동작**:
  - 필드 클릭 시 DatePicker 표시 (키보드 대신)
  - 직접 텍스트 입력 불가 (DatePicker를 통해서만 입력)
  - 완료 버튼으로 날짜 확정
  - 취소 버튼으로 선택 취소

### 4. 이미지 추가
- **기능**: 갤러리에서 이미지 선택
- **최대 개수**: 1개
- **압축**: JPEG 70% 품질로 압축
- **인코딩**: Base64 문자열로 변환
- **삭제**: 우측 상단 X 버튼으로 삭제 가능

### 5. 기록하기 버튼
- **활성화 조건**: 전시 이름, 미술관 이름, 방문 날짜 모두 입력 완료
- **활성화 시 스타일**:
  - 배경색: #FF7C27
  - 텍스트 색상: #FFFFFF
- **비활성화 시 스타일**:
  - 배경색: #222222
  - 텍스트 색상: #FFFFFF 30% opacity

## API 연동

### 엔드포인트
```
POST /api/records
```

### Request Body
```json
{
  "visit_date": "2024-01-15",  // 필수, YYYY-MM-DD 형식
  "name": "현대 미술의 흐름",    // 필수, 전시 이름
  "museum": "국립현대미술관",    // 필수, 미술관 이름
  "note": "멋진 전시였어요",    // 선택, 메모 (없으면 파라미터에서 제외)
  "image": "base64_string..."   // 선택, Base64 인코딩된 이미지 (없으면 파라미터에서 제외)
}
```

**필수 필드:**
- `visit_date`: 방문 날짜 (YYYY-MM-DD 형식)
- `name`: 전시 이름
- `museum`: 미술관 이름

**선택 필드:**
- `note`: 메모 (값이 없거나 빈 문자열이면 request body에 포함되지 않음)
- `image`: Base64 인코딩된 이미지 (값이 없으면 request body에 포함되지 않음)

### Response
```json
{
  "id": 1,
  "user": 123,
  "visit_date": "2024-01-15",
  "name": "현대 미술의 흐름",
  "museum": "국립현대미술관",
  "note": "",
  "image_url": "https://...",
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z"
}
```

## 파일 구조

```
Presentation/Record/
├── View/
│   └── RecordInputView.swift          # UI 레이아웃 정의
├── ViewController/
│   └── RecordInputViewController.swift # 뷰 컨트롤러, DatePicker 설정
└── ViewModel/
    └── RecordInputViewModel.swift      # 비즈니스 로직, 유효성 검사

Data/RepositoryImpl/
└── RecordRepositoryImpl.swift          # Repository 구현체

Data/UseCaseImpl/
└── (GetRecordsUseCase.swift에 포함)
    ├── CreateRecordUseCaseImpl         # 전시기록 생성 UseCase
    └── GetRecordsUseCaseImpl           # 전시기록 조회 UseCase

Data/Network/
├── APIService.swift                    # API 호출 구현
├── APITarget.swift                     # API 엔드포인트 정의
└── DTOs/
    └── RecordDTO.swift                 # DTO 정의
```

## 데이터 흐름

```
View (RecordInputView)
  ↓
ViewController (RecordInputViewController)
  ↓ DatePicker로 날짜 선택 → formatDateToString() → "YYYY-MM-DD" 형식 변환
  ↓
ViewModel (RecordInputViewModel)
  ↓ 유효성 검사 (전시 이름, 미술관 이름, 방문 날짜)
  ↓
UseCase (CreateRecordUseCaseImpl)
  ↓
Repository (RecordRepositoryImpl)
  ↓
APIService
  ↓
APITarget (.createRecord)
  ↓ POST /api/records
API Server
```

## 주요 메서드

### RecordInputViewController

#### `formatDateToString(_ date: Date) -> String`
- **목적**: Date 객체를 "YYYY-MM-DD" 형식의 문자열로 변환
- **매개변수**: `date` - 변환할 Date 객체
- **반환값**: "YYYY-MM-DD" 형식의 문자열 (예: "2024-01-15")
- **사용 예시**: API 요청 시 날짜 포맷팅

```swift
// 사용 예시
let selectedDate = datePicker.date
let formattedDate = formatDateToString(selectedDate)
// 결과: "2024-01-15"
```

#### `datePickerDoneButtonTapped()`
- **목적**: DatePicker에서 날짜 선택 완료
- **동작**: 
  1. 선택한 날짜를 "YYYY-MM-DD" 형식으로 변환
  2. TextField에 표시
  3. ViewModel에 업데이트
  4. DatePicker 닫기

#### `datePickerCancelButtonTapped()`
- **목적**: DatePicker에서 날짜 선택 취소
- **동작**: DatePicker 닫기 (값 변경 없음)

#### `datePickerValueChanged()`
- **목적**: DatePicker에서 날짜가 변경될 때 실시간 업데이트
- **동작**:
  1. 변경된 날짜를 "YYYY-MM-DD" 형식으로 변환
  2. TextField에 실시간으로 표시
  3. ViewModel에 업데이트

### RecordInputViewModel

#### `saveRecord()`
- **목적**: 전시기록 저장
- **동작**:
  1. 입력값 유효성 검사
  2. 이미지를 Base64로 인코딩
  3. CreateRecordUseCase 실행
  4. 성공 시 Toast 표시 및 NotificationCenter로 알림
  5. 실패 시 에러 Toast 표시

## Toast 메시지

### 성공
- **메시지**: "전시기록이 저장되었습니다."
- **배경색**: #222222
- **아이콘 색**: #FF7C27

### 실패
- **메시지**: "전시기록 저장에 실패했습니다."
- **배경색**: #222222
- **아이콘 색**: #FC5959

## NotificationCenter

### `recordDidCreate`
- **목적**: 전시기록 생성 완료 알림
- **사용처**: RecordViewController에서 목록 새로고침
- **전달 데이터**: Record 객체

```swift
// 발신 (RecordInputViewModel)
NotificationCenter.default.post(name: .recordDidCreate, object: record)

// 수신 (RecordViewController)
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleRecordCreated),
    name: .recordDidCreate,
    object: nil
)
```

## 유효성 검사

### 전시 이름 (필수)
- 최소 1자 (공백 제외)
- 최대 50자

### 미술관 이름 (필수)
- 최소 1자 (공백 제외)
- 최대 30자

### 방문 날짜 (필수)
- 필수 입력
- "YYYY-MM-DD" 형식 (자동 포맷팅)
- 과거 10년 ~ 오늘 범위 내

### 메모 (선택)
- 선택 사항
- 입력하지 않으면 API request body에 포함되지 않음

### 이미지 (선택)
- 선택 사항
- JPEG 70% 압축
- Base64 인코딩
- 입력하지 않으면 API request body에 포함되지 않음

## 변경 이력

### 2025-10-30 (오후)
- **note 필드를 선택사항으로 변경**: 필수 → 선택
- **API 파라미터 최적화**: note와 image가 없으면 request body에 포함하지 않음
- **전체 레이어 시그니처 업데이트**: DTO, Repository, UseCase, APIService 모두 note를 `String?`로 변경

### 2025-10-30 (오전)
- **날짜 입력 방식 변경**: 텍스트 입력 → UIDatePicker (Wheel 스타일)
- **날짜 포맷 자동화**: "YYYY-MM-DD" 형식으로 자동 변환
- **DatePicker 스타일링**: 다크 모드 적용 (배경 #222222, 텍스트 #FFFFFF)
- **직접 입력 방지**: DatePicker를 통해서만 날짜 입력 가능
- **날짜 제약 추가**: 과거 10년 ~ 오늘까지만 선택 가능
- **완료/취소 버튼**: 툴바에 DatePicker 제어 버튼 추가

### 이전
- 전시기록 입력 화면 초기 구현
- 실시간 글자 수 카운터
- 이미지 선택 및 삭제 기능
- API 연동

