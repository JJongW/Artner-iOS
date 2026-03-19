# ios.persistence.add_storage

## 설명
Keychain 또는 UserDefaults 저장 패턴을 추가한다. 기존 TokenManager/KeychainTokenManager 패턴을 따른다.

## 파라미터
- `storageType` (String, 필수): Keychain | UserDefaults
- `dataKey` (String, 필수): 저장 키 이름
- `valueType` (String, 필수): 저장 값 타입 (String, [String], Data, Bool, Int 등)

## 수정 대상 파일
- `Artner/Artner/Data/Storage/` 하위 (기존 파일 수정 또는 신규 생성)

## 핵심 패턴

### UserDefaults 패턴
```swift
// TokenManager 또는 별도 StorageManager에 추가
final class {Feature}StorageManager {
    static let shared = {Feature}StorageManager()
    private init() {}

    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let {dataKey} = "com.artner.{data_key}"
    }

    var {dataKey}: {ValueType} {
        get {
            return userDefaults.object(forKey: Keys.{dataKey}) as? {ValueType} ?? {defaultValue}
        }
        set {
            userDefaults.set(newValue, forKey: Keys.{dataKey})
        }
    }

    func clear{DataKey}() {
        userDefaults.removeObject(forKey: Keys.{dataKey})
    }
}
```

### Keychain 패턴 (KeychainTokenManager 참고)
```swift
// KeychainTokenManager 확장 또는 별도 KeychainManager
func save{DataKey}(_ value: String) -> Bool {
    return saveToKeychain(value, forKey: Keys.{dataKey})
}

var {dataKey}: String? {
    return getFromKeychain(forKey: Keys.{dataKey})
}

func clear{DataKey}() {
    deleteFromKeychain(forKey: Keys.{dataKey})
}
```

### Keychain 기본 CRUD (Security 프레임워크)
```swift
private func saveToKeychain(_ value: String, forKey key: String) -> Bool {
    guard let data = value.data(using: .utf8) else { return false }
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    return status == errSecSuccess
}

private func getFromKeychain(forKey key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
    return String(data: data, encoding: .utf8)
}
```

## 체크리스트
- [ ] Singleton 패턴 (static let shared)
- [ ] Keys enum으로 키 상수 관리 (com.artner. 프리픽스)
- [ ] 민감 데이터 → Keychain, 비민감 데이터 → UserDefaults
- [ ] clear 메서드 제공
- [ ] 기존 Storage 파일 구조와 일관성 유지
