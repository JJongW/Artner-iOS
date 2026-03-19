//
//  ViewerSettingsManager.swift
//  Artner
//
//  뷰어 설정 싱글톤 매니저
//  사이드바에서 설정한 글자 크기/줄 간격을 Player 화면과 공유
//  UserDefaults로 영속 저장하여 앱 재시작 시에도 유지

import Foundation
import Combine
import CoreGraphics

final class ViewerSettingsManager {

    // MARK: - Singleton
    static let shared = ViewerSettingsManager()

    // MARK: - Constants
    private enum Keys {
        static let fontSize = "viewer_font_size"
        static let lineSpacing = "viewer_line_spacing"
    }

    private static let defaultValue: Float = 5

    // 슬라이더 값(1~10) → 실제 pt 값 매핑 테이블
    private static let fontSizeMap: [CGFloat] = [14, 15, 16, 17, 18, 19, 20, 22, 24, 26]
    private static let lineSpacingMap: [CGFloat] = [0, 2, 4, 6, 8, 10, 12, 14, 16, 20]

    // MARK: - Published Properties (슬라이더 값 1~10)

    @Published var fontSize: Float {
        didSet { UserDefaults.standard.set(fontSize, forKey: Keys.fontSize) }
    }

    @Published var lineSpacing: Float {
        didSet { UserDefaults.standard.set(lineSpacing, forKey: Keys.lineSpacing) }
    }

    // MARK: - Computed Properties (실제 pt 값)

    /// 실제 폰트 크기 (pt) - 기본값 5 = 18pt
    var actualFontSize: CGFloat {
        let index = min(max(Int(round(fontSize)) - 1, 0), Self.fontSizeMap.count - 1)
        return Self.fontSizeMap[index]
    }

    /// 실제 줄 간격 (pt) - 기본값 5 = 8pt
    var actualLineSpacing: CGFloat {
        let index = min(max(Int(round(lineSpacing)) - 1, 0), Self.lineSpacingMap.count - 1)
        return Self.lineSpacingMap[index]
    }

    // MARK: - Initializer

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.fontSize) != nil {
            fontSize = defaults.float(forKey: Keys.fontSize)
        } else {
            fontSize = Self.defaultValue
        }
        if defaults.object(forKey: Keys.lineSpacing) != nil {
            lineSpacing = defaults.float(forKey: Keys.lineSpacing)
        } else {
            lineSpacing = Self.defaultValue
        }
    }

    // MARK: - Public Methods

    /// 기본값(5)으로 초기화
    func reset() {
        fontSize = Self.defaultValue
        lineSpacing = Self.defaultValue
    }
}
