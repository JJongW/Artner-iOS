# ios.networking.add_endpoint

## 설명
Moya 기반 APITarget enum에 새 API case를 추가한다.

## 파라미터
- `endpoint` (String, 필수): API 경로 (예: /docents/search)
- `method` (String, 필수): HTTP 메서드 (GET, POST, PUT, PATCH, DELETE)
- `parameters` (Object, 선택): 요청 파라미터 {name: type}

## 수정 대상 파일
- `Artner/Artner/Data/Network/APITarget.swift` - enum case + TargetType 구현

## 핵심 패턴

### enum case 추가
```swift
enum APITarget {
    // MARK: - 기존 API들...

    // MARK: - {Feature} API
    case {camelCaseAction}({paramName}: {ParamType})
}
```

### path 추가
```swift
var path: String {
    switch self {
    // ... 기존 ...
    case .{camelCaseAction}: return "{endpoint}"
    // 또는 파라미터가 path에 포함되는 경우
    case .{camelCaseAction}(let id): return "{endpoint}/\(id)"
    }
}
```

### method 추가
```swift
var method: Moya.Method {
    switch self {
    // ... 기존 ...
    case .{camelCaseAction}: return .{httpMethod}
    }
}
```

### task 추가
```swift
var task: Task {
    switch self {
    // ... 기존 ...

    // GET 쿼리 파라미터
    case .{action}(let query):
        return .requestParameters(
            parameters: ["query": query],
            encoding: URLEncoding.queryString
        )

    // POST JSON 바디
    case .{action}(let name, let description):
        return .requestParameters(
            parameters: ["name": name, "description": description],
            encoding: JSONEncoding.default
        )

    // 파라미터 없음
    case .{action}:
        return .requestPlain
    }
}
```

## 체크리스트
- [ ] APITarget enum에 case 추가 (camelCase 네이밍)
- [ ] path, method, task, headers 모두 switch에 case 추가
- [ ] GET → URLEncoding.queryString, POST/PUT/PATCH → JSONEncoding.default
- [ ] 파라미터 없으면 `.requestPlain`
- [ ] MARK 주석으로 API 그룹 분류
- [ ] 기존 case 네이밍 컨벤션 준수 (동사+명사: getFeedList, createFolder 등)
