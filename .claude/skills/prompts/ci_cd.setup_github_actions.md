# ci_cd.setup_github_actions

## 설명
GitHub Actions 기반 iOS 빌드/테스트 워크플로우를 설정한다.

## 파라미터
- `triggers` (Array, 선택, 기본: [push, pull_request]): 워크플로우 트리거
- `includeTests` (Boolean, 선택, 기본: true): 테스트 단계 포함 여부

## 생성 파일
- `.github/workflows/ios-build.yml`

## 핵심 패턴

### 기본 워크플로우
```yaml
name: iOS Build & Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.4.app

    - name: Cache SPM
      uses: actions/cache@v4
      with:
        path: |
          ~/Library/Developer/Xcode/DerivedData/**/SourcePackages
        key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
        restore-keys: |
          ${{ runner.os }}-spm-

    - name: Build
      run: |
        xcodebuild build \
          -project Artner/Artner.xcodeproj \
          -scheme Artner \
          -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
          -configuration Debug \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO \
          | xcpretty

    - name: Test
      if: ${{ inputs.includeTests != false }}
      run: |
        xcodebuild test \
          -project Artner/Artner.xcodeproj \
          -scheme Artner \
          -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
          -configuration Debug \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO \
          | xcpretty
```

### 빌드 전용 (테스트 미포함)
```yaml
    - name: Build Only
      run: |
        xcodebuild build \
          -project Artner/Artner.xcodeproj \
          -scheme Artner \
          -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO
```

### PR 체크 워크플로우
```yaml
name: PR Check

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lint-and-build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v4
    - name: Build Check
      run: |
        xcodebuild build \
          -project Artner/Artner.xcodeproj \
          -scheme Artner \
          -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
          CODE_SIGN_IDENTITY="" \
          CODE_SIGNING_REQUIRED=NO
```

## 주의사항
- Artner.xcodeproj 경로: `Artner/Artner.xcodeproj`
- 코드 사이닝 비활성화 (CI 환경)
- 환경 변수 (DEV_ACCESS_TOKEN 등)는 GitHub Secrets로 관리
- SPM 캐시 설정 (빌드 시간 단축)

## 체크리스트
- [ ] Xcode 버전 명시
- [ ] 코드 사이닝 비활성화 설정
- [ ] 트리거 브랜치 설정
- [ ] SPM 의존성 캐시
- [ ] xcpretty로 출력 포맷팅
- [ ] 시크릿 환경 변수 (필요 시)
