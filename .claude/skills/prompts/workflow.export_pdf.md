# workflow.export_pdf

## 설명
마크다운 문서를 PDF로 내보낸다. pandoc 또는 대안 도구를 사용.

## 파라미터
- `source_md` (String, 필수): 변환할 마크다운 파일 경로
- `output_pdf_name` (String, 필수): 출력 PDF 파일명

## 절차

### Step 1: 도구 확인
```bash
# pandoc 설치 확인
which pandoc || brew install pandoc

# wkhtmltopdf 또는 weasyprint 확인 (pandoc PDF 백엔드)
which wkhtmltopdf || which weasyprint
```

### Step 2: 변환 실행

#### 방법 1: pandoc (권장)
```bash
pandoc {source_md} \
  -o {output_pdf_name} \
  --pdf-engine=wkhtmltopdf \
  -V geometry:margin=1in \
  -V mainfont="AppleGothic" \
  --highlight-style=tango
```

#### 방법 2: pandoc + HTML 중간 단계
```bash
# MD → HTML → PDF (한글 폰트 호환성)
pandoc {source_md} -o /tmp/temp.html --standalone --css=github.css
wkhtmltopdf /tmp/temp.html {output_pdf_name}
```

#### 방법 3: 도구 미설치 시 안내
```
pandoc이 설치되어 있지 않습니다.
설치: brew install pandoc wkhtmltopdf
또는 마크다운 파일을 직접 사용하세요.
```

### Step 3: 결과 확인
```bash
# PDF 파일 생성 확인
ls -la {output_pdf_name}
# 페이지 수 확인
mdls -name kMDItemNumberOfPages {output_pdf_name}
```

## 한글 지원 참고
- macOS: AppleGothic, AppleSDGothicNeo 폰트 사용
- pandoc의 `--pdf-engine=xelatex`도 한글 지원 (CJK 패키지 필요)

## 체크리스트
- [ ] pandoc 또는 대안 도구 설치 확인
- [ ] 한글 렌더링 정상
- [ ] 코드 블록 문법 강조 유지
- [ ] 출력 PDF 파일 생성 확인
