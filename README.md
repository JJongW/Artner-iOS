# Artner-iOS

## 🔐 개발 환경 설정

### 토큰 설정 (보안)
개발 시 API 토큰을 환경변수로 설정해야 합니다.

#### 1. 환경변수 설정
Xcode에서 다음 환경변수를 설정하세요:
- `DEV_ACCESS_TOKEN`: 개발용 액세스 토큰
- `DEV_REFRESH_TOKEN`: 개발용 리프레시 토큰

#### 2. Xcode에서 환경변수 설정 방법
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. 다음 변수들을 추가:
   ```
   DEV_ACCESS_TOKEN = your_access_token_here
   DEV_REFRESH_TOKEN = your_refresh_token_here
   ```

#### 3. 보안 주의사항
- ⚠️ **절대 하드코딩된 토큰을 코드에 포함하지 마세요**
- ⚠️ **환경변수 파일(.env)을 Git에 커밋하지 마세요**
- ⚠️ **프로덕션에서는 실제 로그인 시스템을 사용하세요**

### 현재 상태
- ✅ 하드코딩된 토큰 제거됨
- ✅ 환경변수 기반 토큰 관리
- ✅ 토큰 마스킹 처리
- ✅ .gitignore에 보안 파일 추가됨

## 코드 수정 내역

### 2025-01-27

#### EntryView - Lottie 애니메이션 적용

**수정할 내용:**
- EntryView의 blurredImageView를 Lottie 애니메이션으로 교체
- 기존 UIImageView 기반 이미지 표시 방식

**수정한 내용:**
- `EntryView.swift`: blurredImageView를 LottieRemoteView로 변경
```swift
// 변경 전
let blurredImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Artner_img")
    imageView.contentMode = .scaleAspectFit
    return imageView
}()

// 변경 후
let blurredAnimationView = LottieRemoteView()
```

- `LottieRemoteView.swift`: dotlottie-wc 웹 컴포넌트를 사용한 Lottie 애니메이션 뷰 생성
```swift
final class LottieRemoteView: UIView {
    private let webView: WKWebView
    
    func load(urlString: String) {
        // dotlottie-wc 웹 컴포넌트를 사용하여 .lottie 파일 로드
        let html = """
        <script src="https://unpkg.com/@lottiefiles/dotlottie-wc@0.8.5/dist/dotlottie-wc.js" type="module"></script>
        <dotlottie-wc src="\(urlString)" style="width: 100%; height: 100%;" autoplay loop></dotlottie-wc>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
```

- `EntryView.swift`: Lottie URL 설정
```swift
blurredAnimationView.load(urlString: "https://lottie.host/d0d08cf4-f3d6-40cd-b98c-e7babcc85851/MtTaxs6tEa.lottie")
```

#### SideMenuContainerView - 애니메이션 개선

**수정할 내용:**
- 사이드바가 열릴 때 내부 UI가 완전히 렌더링되기 전에 애니메이션이 시작되어 부자연스러움
- 사이드바가 닫힐 때 두 번으로 접히는 것처럼 보이는 문제

**수정한 내용:**
- `SideMenuContainerView.swift`: present 메서드 개선
```swift
func present(in parent: UIViewController) {
    // 레이아웃을 먼저 완료시켜서 내부 뷰들이 모두 렌더링되도록 함
    layoutIfNeeded()
    menuViewController.view.layoutIfNeeded()
    
    // 내부 요소들을 alpha 0으로 시작
    if let sidebarVC = menuViewController as? SidebarViewController {
        sidebarVC.sidebarView.setContentAlpha(0)
    }
    
    // 사이드바 슬라이드 인 애니메이션
    UIView.animate(withDuration: 0.3) {
        // 사이드바 슬라이드 인
    } completion: { _ in
        // 사이드바가 완전히 열린 후 내부 요소들을 fade-in
        UIView.animate(withDuration: 0.2, delay: 0.05) {
            sidebarVC.sidebarView.setContentAlpha(1)
        }
    }
}
```

- `SideMenuContainerView.swift`: dismissMenu 메서드 개선
```swift
@objc func dismissMenu(completion: (() -> Void)? = nil) {
    // 먼저 내부 요소들을 fade-out
    UIView.animate(withDuration: 0.15) {
        sidebarVC.sidebarView.setContentAlpha(0)
    } completion: { _ in
        // 내부 요소들이 사라진 후 사이드바를 슬라이드 아웃
        UIView.animate(withDuration: 0.3) {
            // 사이드바 슬라이드 아웃
        }
    }
}
```

- `SidebarView.swift`: setContentAlpha 메서드 추가
```swift
func setContentAlpha(_ alpha: CGFloat) {
    nameLabel.alpha = alpha
    statContainerView.alpha = alpha
    recentDocentButton.alpha = alpha
    // ... 기타 내부 요소들의 alpha 설정
}
```