# ios.performance.optimize_rendering

## 설명
UI 렌더링 및 스크롤 성능을 최적화한다. TableView/CollectionView 셀 최적화, 이미지 로딩, 레이아웃 최적화.

## 파라미터
- `targetView` (String, 필수): 최적화 대상 뷰
- `issue` (String, 선택): 문제 유형 (scroll_frame_drop, layout_thrashing, image_loading)

## 수정 대상 파일
- Presentation 레이어 (View, ViewController, Cell)

## 최적화 패턴

### 1. TableView/CollectionView 셀 최적화
```swift
// 셀 재사용 등록
tableView.register(
    DocentTableViewCell.self,
    forCellReuseIdentifier: "DocentTableViewCell"
)

// 높이 계산 최적화
tableView.estimatedRowHeight = 137
tableView.rowHeight = UITableView.automaticDimension

// prefetchDataSource 활용
extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // 이미지 프리페치
        for indexPath in indexPaths {
            let url = viewModel.items[indexPath.row].thumbnailURL
            ImagePrefetcher.shared.prefetch(url)
        }
    }
}
```

### 2. 이미지 로딩 최적화
```swift
// 비동기 이미지 다운사이징
func loadImage(from url: URL?, targetSize: CGSize) {
    guard let url = url else { return }
    DispatchQueue.global(qos: .userInitiated).async {
        // 다운샘플링 (메모리 절약)
        let options: [CFString: Any] = [
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height) * UIScreen.main.scale
        ]
        // ImageIO 기반 다운샘플링
    }
}

// prepareForReuse에서 이미지 초기화
override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailImageView.image = nil
    // 진행 중인 이미지 로딩 취소
}
```

### 3. 레이아웃 최적화
```swift
// 불필요한 layoutIfNeeded 제거
// setNeedsLayout은 다음 런루프에서 배치 처리

// 오프스크린 렌더링 방지
layer.shouldRasterize = true
layer.rasterizationScale = UIScreen.main.scale

// 그림자 최적화
layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
```

### 4. Combine 바인딩 최적화
```swift
// 불필요한 UI 업데이트 방지
viewModel.$items
    .removeDuplicates()  // 동일 데이터 스킵
    .receive(on: DispatchQueue.main)
    .sink { [weak self] items in
        self?.tableView.reloadData()
    }
    .store(in: &cancellables)

// 검색 디바운싱
searchTextField.textPublisher
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .sink { [weak self] query in
        self?.viewModel.search(query: query)
    }
    .store(in: &cancellables)
```

## Instruments 프로파일링 가이드
1. **Time Profiler**: CPU 핫스팟 확인
2. **Core Animation**: 오프스크린 렌더링, 블렌딩 레이어 확인
3. **Allocations**: 메모리 사용량 추세

## 체크리스트
- [ ] 셀 재사용 정상 동작 (register + dequeueReusableCell)
- [ ] prepareForReuse에서 상태 초기화
- [ ] 이미지 다운사이징 (원본 크기 로딩 방지)
- [ ] 그림자에 shadowPath 설정
- [ ] Combine에 removeDuplicates/debounce 적용
- [ ] 메인 스레드에서만 UI 업데이트
