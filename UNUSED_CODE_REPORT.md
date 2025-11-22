# 사용하지 않는 코드 및 불필요한 코드 정리 보고서

## 2025-01-27

### ✅ 삭제 완료된 항목

#### 1. PlayerViewModel - 사용하지 않는 메서드들 (삭제 완료)

##### 1.1. `updatePlayerState(_ isPlaying: Bool)` 메서드 ✅ 삭제됨
- **위치**: `Artner/Artner/Presentation/Player/ViewModel/PlayerViewModel.swift:87-90`
- **상태**: 빈 메서드였으며, 실제 구현 없음, 호출되는 곳 없음
- **처리**: 삭제 완료

##### 1.2. `currentPlayButtonTitle()` 메서드 ✅ 삭제됨
- **위치**: `Artner/Artner/Presentation/Player/ViewModel/PlayerViewModel.swift:451`
- **상태**: 정의되어 있으나 호출되는 곳 없음
- **처리**: 삭제 완료

#### 2. PlayerViewController - 사용하지 않는 메서드 (삭제 완료)

##### 2.1. `showSaveConfirmation()` 메서드 ✅ 삭제됨
- **위치**: `Artner/Artner/Presentation/Player/ViewController/PlayerViewController.swift:198-204`
- **상태**: 정의되어 있으나 호출되는 곳 없음
- **처리**: 삭제 완료

#### 3. TokenDebugger - 사용하지 않는 유틸리티 클래스 (삭제 완료)

##### 3.1. `TokenDebugger` 클래스 전체 ✅ 삭제됨
- **위치**: `Artner/Artner/Data/Storage/TokenDebugger.swift`
- **상태**: 정적 메서드 `checkTokenStatus()`만 있고, 어디서도 호출되지 않음
- **처리**: 파일 전체 삭제 완료

#### 4. DocentRepositoryImpl - 주석 처리된 코드 (삭제 완료)

##### 4.1. 주석 처리된 API 연동 코드 ✅ 삭제됨
- **위치**: `Artner/Artner/Data/RepositoryImpl/DocentRepositoryImpl.swift:24-43`
- **상태**: 주석 처리된 미래 API 연동 코드
- **처리**: 주석 처리된 코드 블록 삭제 완료

#### 5. BaseViewController - 사용하지 않는 메서드 (삭제 완료)

##### 5.1. `safeCreateSnapshot(of:)` 메서드 ✅ 삭제됨
- **위치**: `Artner/Artner/Presentation/Base/BaseViewController.swift:81-89`
- **상태**: 정의되어 있으나 호출되는 곳 없음
- **처리**: 삭제 완료

---

### 🔍 검토 필요 항목 (유지됨)

#### 5.2. 키보드 관련 스냅샷 경고 방지 메서드들
- **위치**: `Artner/Artner/Presentation/Base/BaseViewController.swift:54-78`
- **상태**: `preventKeyboardSnapshotWarnings()`, `checkAndFixKeyboardViews(in:)` 메서드가 `viewWillAppear`에서 호출됨
- **권장사항**: 
  - 실제로 키보드 관련 경고가 발생하지 않는다면 제거 고려
  - 또는 실제 문제가 발생할 때까지 유지

#### 6. KeychainTokenManager - 주석과 실제 사용 불일치

##### 6.1. 주석 내용
- **위치**: `Artner/Artner/Data/Storage/KeychainTokenManager.swift:12`
- **상태**: 주석에 "현재는 사용하지 않지만"이라고 되어 있으나, 실제로는 `TokenManager`에서 사용 중
- **코드**:
```swift
/// Keychain을 사용한 더 안전한 토큰 관리자
/// 현재는 사용하지 않지만, 향후 보안 강화 시 사용 가능
```
- **권장사항**: 주석 수정 필요 (실제로 사용 중임을 명시)

#### 7. UIView+Extension - 사용 여부 불명확한 메서드

##### 7.1. `isKeyboardRelated` 프로퍼티
- **위치**: `Artner/Artner/Extension/UIView+Extension.swift:59-66`
- **상태**: `BaseViewController`에서 사용되지만, 실제로 키보드 관련 뷰를 감지하는지 불명확
- **권장사항**: 실제로 키보드 관련 경고가 발생하는지 확인 후 필요 여부 결정

---

## 정리 완료 요약

### ✅ 삭제 완료된 항목 (6개)
1. ✅ `PlayerViewModel.updatePlayerState(_:)` - 빈 메서드 삭제
2. ✅ `PlayerViewModel.currentPlayButtonTitle()` - 미사용 메서드 삭제
3. ✅ `PlayerViewController.showSaveConfirmation()` - 미사용 메서드 삭제
4. ✅ `BaseViewController.safeCreateSnapshot(of:)` - 미사용 메서드 삭제
5. ✅ `DocentRepositoryImpl`의 주석 처리된 코드 - 주석 코드 블록 삭제
6. ✅ `TokenDebugger.swift` - 전체 파일 삭제

### 🔍 검토 후 결정할 항목 (3개)
1. `BaseViewController`의 키보드 관련 메서드들 - 실제 경고 발생 여부 확인 필요
2. `KeychainTokenManager` 주석 수정 - 실제 사용 중임을 반영 필요
3. `UIView+Extension.isKeyboardRelated` - 실제 사용 여부 확인 필요

### 📝 참고사항
- 삭제된 코드는 모두 호출되지 않는 것이 확인된 안전한 삭제입니다
- 빌드 및 실행 테스트 권장
- 향후 필요 시 Git 히스토리에서 복구 가능


