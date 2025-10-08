# Toast 컴포넌트 사용 가이드

## 📋 개요

Artner iOS 앱에서 사용하는 재사용 가능한 Toast 컴포넌트입니다. Clean Architecture 원칙을 따라 설계되어 유지보수성과 확장성을 보장합니다.

## 🏗️ 구조

### 주요 구성 요소

1. **ToastView**: UI 컴포넌트 (좌측 아이콘, 중앙 텍스트, 우측 버튼)
2. **ToastConfiguration**: Toast 설정을 담는 구조체
3. **ToastManager**: 전역 Toast 관리 싱글톤 매니저

### 디자인 스펙

- **위치**: 화면 가운데, 하단에서 20px 위
- **여백**: 
  - 텍스트만: 좌 18px, 우 14px, 상하 12px
  - 아이콘 있을 때: 아이콘-토스트끝 18px, 글자-토스트끝 14px, 상하 12px
- **아이콘**: 20x20 크기, 텍스트와 8px 간격
- **텍스트**: 16pt Bold 폰트
- **버튼**: 텍스트와 10px 간격
- **모서리**: cornerRadius 16

## 🚀 기본 사용법

### 1. 간단한 Toast 표시

```swift
// 기본 메시지만 표시
ToastManager.shared.showSimple("도슨트가 재생됩니다")
```

### 2. 성공 Toast 표시

```swift
// 체크마크 아이콘과 함께 성공 메시지 표시
ToastManager.shared.showSuccess("저장이 완료되었습니다")
```

### 3. 에러 Toast 표시

```swift
// 경고 아이콘과 함께 에러 메시지 표시
ToastManager.shared.showError("저장에 실패했습니다")
```

### 4. 저장 완료 Toast (버튼 포함)

```swift
// 저장 아이콘과 "보기" 버튼이 포함된 Toast (하단에서 스프링 애니메이션으로 표시)
ToastManager.shared.showSaved("하이라이트가 저장되었습니다") {
    // "보기" 버튼 클릭 시 실행될 코드
    print("저장된 목록으로 이동")
}
```

## 🛠️ 고급 사용법

### 커스텀 Toast 구성

```swift
let configuration = ToastConfiguration(
    message: "커스텀 메시지",
    leftIcon: UIImage(named: "my_icon"),
    rightButtonTitle: "확인",
    rightButtonAction: {
        // 버튼 클릭 액션
        print("커스텀 버튼 클릭됨")
    },
    backgroundColor: AppColor.toastBackground, // #222222
    textColor: AppColor.toastText,            // #FFFFFF
    duration: 5.0
)

ToastManager.shared.show(configuration)
```

### 특정 뷰에 Toast 표시

```swift
// 현재 뷰컨트롤러가 아닌 특정 뷰에 표시
ToastManager.shared.show(configuration, in: customView)
```

## 📱 실제 구현 예시

### PlayerViewModel에서 하이라이트 저장

```swift
func saveHighlight(_ highlight: TextHighlight) {
    // ... 저장 로직 ...
    
    if !isDuplicate {
        savedHighlights[highlight.paragraphId]?.append(highlight)
        saveHighlightsToStorage()
        
        // Toast 표시
        showHighlightSavedToast(highlight: highlight)
    }
}

private func showHighlightSavedToast(highlight: TextHighlight) {
    let message = "하이라이트가 저장되었습니다"
    
    let viewAction = { [weak self] in
        // 저장된 하이라이트 목록으로 이동
        self?.navigateToSavedHighlights()
    }
    
    ToastManager.shared.showSaved(message, viewAction: viewAction)
}
```

### SaveViewModel에서 도슨트 저장

```swift
func saveDocentItem(title: String, subtitle: String?, type: SaveItemType) {
    let newItem = SaveItem(
        id: UUID().uuidString,
        type: type,
        title: title,
        subtitle: subtitle,
        imageUrl: nil,
        isDocentAvailable: true,
        createdAt: Date()
    )
    
    saveItem(newItem) // 내부에서 Toast 자동 표시
}
```

## 🎯 사용 시나리오

### 1. 도슨트 재생 관련
- 재생 시작: `ToastManager.shared.showSimple("도슨트 재생을 시작합니다")` (하단 중앙에 표시)
- 일시정지: `ToastManager.shared.showSimple("도슨트가 일시정지되었습니다")`

### 2. 저장 관련
- 하이라이트 저장: `ToastManager.shared.showSaved("하이라이트가 저장되었습니다")` (아이콘과 버튼 포함)
- 작품 저장: `saveViewModel.saveDocentItem(title: "작품명", type: .artwork)`
- 중복 저장 시도: 자동으로 에러 Toast 표시

### 3. 에러 처리
- 네트워크 에러: `ToastManager.shared.showError("네트워크 연결을 확인해주세요")` (경고 아이콘 포함)
- 저장 실패: `ToastManager.shared.showError("저장에 실패했습니다")`

## 🔧 확장 방법

### 새로운 Toast 타입 추가

ToastManager에 새로운 편의 메서드를 추가할 수 있습니다:

```swift
extension ToastManager {
    func showInfo(_ message: String) {
        let infoIcon = UIImage(systemName: "info.circle.fill")
        let configuration = ToastConfiguration(
            message: message,
            leftIcon: infoIcon,
            backgroundColor: UIColor(hex: "#2196F3"),
            textColor: AppColor.toastText
        )
        show(configuration)
    }
}
```

## 📋 주의사항

1. **메모리 관리**: ToastManager는 싱글톤이므로 강한 참조 사이클을 피하기 위해 클로저에서 `[weak self]` 사용
2. **UI 스레드**: Toast는 자동으로 메인 스레드에서 표시되므로 별도의 처리 불필요
3. **동시 Toast**: 새로운 Toast가 표시되면 기존 Toast는 자동으로 숨겨짐
4. **Safe Area**: Toast는 하단 Safe Area에서 20px 위에 자동으로 표시됨 (가운데 정렬)
5. **애니메이션**: 스프링 애니메이션으로 부드럽게 나타나며, 아래로 슬라이드하며 사라짐

## 🎨 디자인 토큰

Toast에서 사용하는 앱의 디자인 토큰:

```swift
// 색상 (AppColor에서 참조)
- 기본 배경색: AppColor.toastBackground (#222222)
- 텍스트: AppColor.toastText (#FFFFFF)
- 아이콘: AppColor.toastIcon (#FF7C27)
- 성공: #2E7D32 (녹색)
- 에러: #D32F2F (빨간색)

// 폰트
- 텍스트: Bold 16pt

// 여백 및 크기
- 위치: 화면 가운데, 하단에서 20pt 위
- 모서리: 16pt radius
- 내부 여백: 상하 12pt, 좌우 18pt/14pt (아이콘 유무에 따라 동적)
- 아이콘: 20x20pt
```

---

**작성자**: 15년차 iOS 개발자  
**작성일**: 2025년 4월 5일  
**최종 수정**: 2025년 4월 5일  
**버전**: 2.0.0 (디자인 스펙 업데이트)
