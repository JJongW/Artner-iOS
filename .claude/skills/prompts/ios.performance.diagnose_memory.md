# ios.performance.diagnose_memory

## 설명
메모리 누수를 진단하고 수정 방안을 제시한다. Combine 구독, 클로저 캡처, delegate 패턴의 retain cycle을 중점 확인.

## 파라미터
- `targetArea` (String, 필수): 진단 대상 영역 (클래스/모듈명)
- `symptom` (String, 선택): 증상 (suspected_retain_cycle, high_memory, dealloc_not_called)

## 수정 대상 파일
- 상황 의존적

## 진단 포인트

### 1. Combine 구독 retain cycle
```swift
// 문제: self 강한 참조
viewModel.$items
    .sink { items in
        self.updateUI(items)  // ⚠️ retain cycle
    }
    .store(in: &cancellables)

// 수정: [weak self]
viewModel.$items
    .sink { [weak self] items in
        self?.updateUI(items)  // ✅
    }
    .store(in: &cancellables)
```

### 2. 클로저 캡처
```swift
// 문제: onTapped 클로저에서 self 강한 참조
cell.onLikeTapped = {
    self.viewModel.toggleLike()  // ⚠️
}

// 수정
cell.onLikeTapped = { [weak self] in
    self?.viewModel.toggleLike()  // ✅
}
```

### 3. Coordinator ↔ ViewController 순환
```swift
// 문제: Coordinator가 VC를 강하게 참조하고, VC가 Coordinator를 강하게 참조
// 수정: 프로젝트에서는 BaseViewController의 coordinator가 제네릭 타입으로
// 강한 참조. VC가 dismiss 되면 자연스럽게 해제됨을 확인.
```

### 4. NotificationCenter 미해제
```swift
// 문제: observer 미제거
NotificationCenter.default.addObserver(...)

// 수정: deinit에서 제거 또는 Combine sink 사용
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

### 5. Timer retain cycle
```swift
// 문제: Timer가 self를 강하게 참조
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    self.updateProgress()  // ⚠️
}

// 수정
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
    self?.updateProgress()  // ✅
}
```

## 코드 스캔 패턴
```
검색할 패턴:
1. `.sink {` (weak self 없는 sink)
2. `= {` + `self.` (클로저에서 self 강한 참조)
3. `Timer.scheduledTimer` (Timer retain)
4. `addObserver` (NotificationCenter 미해제)
5. `delegate = self` (delegate가 strong인 경우)
```

## Instruments 가이드
1. Xcode → Product → Profile → Leaks
2. 의심 화면 진입/퇴장 반복
3. Leaks 탭에서 누수 객체 확인
4. Allocations 탭에서 메모리 증가 추세 확인

## 체크리스트
- [ ] 모든 Combine `.sink` 클로저에 `[weak self]` 확인
- [ ] 모든 클로저 캡처에 `[weak self]` 확인
- [ ] Timer, NotificationCenter 정리 확인
- [ ] deinit에 print 추가하여 해제 확인
- [ ] 화면 전환 시 메모리 그래프 안정적인지 확인
