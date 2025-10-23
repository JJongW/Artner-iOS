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