//
//  AIDocentSettingsViewModel.swift
//  Artner
//
//  AI 도슨트 설정 화면의 상태와 로직을 담당

import AVFoundation
import Combine
import Foundation
import UIKit

final class AIDocentSettingsViewModel {

    // MARK: - AI 유형 모델
    struct AIDocentType {
        let personal: String
        let displayName: String
        let description: String
    }

    // MARK: - 말하기 설정 옵션 모델
    struct SpeakingOption {
        let apiValue: String      // API에 전달되는 값
        let displayName: String   // 화면 표시 이름
    }

    // MARK: - 지원 AI 목록
    static let availableAITypes: [AIDocentType] = [
        AIDocentType(personal: "anna", displayName: "친절한 애나",
                     description: "애나는 친절한 선생님처럼 예술 작품을 설명해줍니다. 예술이 어려운 분들께 추천드려요."),
        AIDocentType(personal: "adam", displayName: "유쾌한 아담",
                     description: "아담은 친절한 선생님처럼 예술 작품을 설명해줍니다. 예술이 어려운 분들께 추천드려요."),
        AIDocentType(personal: "jia",  displayName: "귀여운 지아",
                     description: "지아는 친절한 선생님처럼 예술 작품을 설명해줍니다. 예술이 어려운 분들께 추천드려요.")
    ]

    // MARK: - 말하기 설정 옵션 목록
    static let lengthOptions: [SpeakingOption] = [
        SpeakingOption(apiValue: "very_short", displayName: "아주 간단히"),
        SpeakingOption(apiValue: "short",      displayName: "간단히"),
        SpeakingOption(apiValue: "medium",     displayName: "보통"),
        SpeakingOption(apiValue: "long",       displayName: "자세히"),
        SpeakingOption(apiValue: "very_long",  displayName: "아주 자세히")
    ]

    static let speedOptions: [SpeakingOption] = [
        SpeakingOption(apiValue: "very_fast", displayName: "빠르게"),
        SpeakingOption(apiValue: "fast",      displayName: "약간 빠르게"),
        SpeakingOption(apiValue: "medium",    displayName: "보통"),
        SpeakingOption(apiValue: "slow",      displayName: "약간 느리게"),
        SpeakingOption(apiValue: "very_slow", displayName: "느리게")
    ]

    static let difficultyOptions: [SpeakingOption] = [
        SpeakingOption(apiValue: "beginner",     displayName: "초급"),
        SpeakingOption(apiValue: "intermediate", displayName: "중급"),
        SpeakingOption(apiValue: "advanced",     displayName: "고급")
    ]

    // MARK: - Published Properties

    // AI 유형
    @Published var selectedPersonal: String
    @Published var displayName: String

    // 슬라이더 인덱스 (Float — UISlider와 직접 바인딩)
    @Published var lengthIndex: Float
    @Published var speedIndex: Float
    @Published var difficultyIndex: Float

    // 화면 우측에 표시할 한글 현재값
    @Published var lengthDisplayName: String
    @Published var speedDisplayName: String
    @Published var difficultyDisplayName: String

    // MARK: - Private: 기본 인덱스 (초기화용)
    private let defaultLengthIndex: Float
    private let defaultSpeedIndex: Float
    private let defaultDifficultyIndex: Float

    // MARK: - Initialization
    init(currentPersonal: String,
         currentLength: String = "medium",
         currentSpeed: String = "medium",
         currentDifficulty: String = "beginner") {

        self.selectedPersonal = currentPersonal
        self.displayName = AIDocentSettingsViewModel.displayName(for: currentPersonal)

        let li = AIDocentSettingsViewModel.index(of: currentLength,   in: AIDocentSettingsViewModel.lengthOptions)
        let si = AIDocentSettingsViewModel.index(of: currentSpeed,    in: AIDocentSettingsViewModel.speedOptions)
        let di = AIDocentSettingsViewModel.index(of: currentDifficulty, in: AIDocentSettingsViewModel.difficultyOptions)

        self.lengthIndex     = li
        self.speedIndex      = si
        self.difficultyIndex = di

        self.defaultLengthIndex     = li
        self.defaultSpeedIndex      = si
        self.defaultDifficultyIndex = di

        self.lengthDisplayName     = AIDocentSettingsViewModel.lengthOptions[Int(li)].displayName
        self.speedDisplayName      = AIDocentSettingsViewModel.speedOptions[Int(si)].displayName
        self.difficultyDisplayName = AIDocentSettingsViewModel.difficultyOptions[Int(di)].displayName
    }

    // MARK: - Methods

    /// AI 유형 변경
    func selectAI(personal: String) {
        selectedPersonal = personal
        displayName = AIDocentSettingsViewModel.displayName(for: personal)
    }

    /// 슬라이더 값 변경 (소수점 → 정수 스냅 후 호출)
    func setLength(index: Int) {
        let clamped = max(0, min(index, AIDocentSettingsViewModel.lengthOptions.count - 1))
        lengthIndex = Float(clamped)
        lengthDisplayName = AIDocentSettingsViewModel.lengthOptions[clamped].displayName
    }

    func setSpeed(index: Int) {
        let clamped = max(0, min(index, AIDocentSettingsViewModel.speedOptions.count - 1))
        speedIndex = Float(clamped)
        speedDisplayName = AIDocentSettingsViewModel.speedOptions[clamped].displayName
    }

    func setDifficulty(index: Int) {
        let clamped = max(0, min(index, AIDocentSettingsViewModel.difficultyOptions.count - 1))
        difficultyIndex = Float(clamped)
        difficultyDisplayName = AIDocentSettingsViewModel.difficultyOptions[clamped].displayName
    }

    /// 말하기 설정 초기화
    func resetSpeakingSettings() {
        setLength(index: Int(defaultLengthIndex))
        setSpeed(index: Int(defaultSpeedIndex))
        setDifficulty(index: Int(defaultDifficultyIndex))
    }

    /// 현재 선택된 API 값 반환 (저장 시 사용)
    var selectedLengthApiValue: String {
        let i = Int(lengthIndex)
        return AIDocentSettingsViewModel.lengthOptions[i].apiValue
    }
    var selectedSpeedApiValue: String {
        let i = Int(speedIndex)
        return AIDocentSettingsViewModel.speedOptions[i].apiValue
    }
    var selectedDifficultyApiValue: String {
        let i = Int(difficultyIndex)
        return AIDocentSettingsViewModel.difficultyOptions[i].apiValue
    }

    // MARK: - Static Helpers

    static func displayName(for personal: String) -> String {
        return availableAITypes.first(where: { $0.personal == personal })?.displayName ?? "친절한 애나"
    }

    static func index(of apiValue: String, in options: [SpeakingOption]) -> Float {
        return Float(options.firstIndex(where: { $0.apiValue == apiValue }) ?? (options.count / 2))
    }

    /// personal 값에 해당하는 MP4 파일명과 확장자 반환
    static func videoResource(for personal: String) -> (name: String, ext: String) {
        switch personal {
        case "anna":  return ("kind_mv",  "MP4")
        case "adam":  return ("funny_mv", "MP4")
        case "jia":   return ("cute_mv",  "mp4")
        default:      return ("kind_mv",  "MP4")
        }
    }

    /// personal 값에 해당하는 MP4 첫 프레임 썸네일 이미지 반환 (백그라운드 호출 권장)
    static func thumbnail(for personal: String, completion: @escaping (UIImage?) -> Void) {
        let resource = videoResource(for: personal)
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: resource.name, withExtension: resource.ext) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 72, height: 72)
            let time = CMTimeMake(value: 0, timescale: 1)
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                let image = UIImage(cgImage: cgImage)
                DispatchQueue.main.async { completion(image) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
