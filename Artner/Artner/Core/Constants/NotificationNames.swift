//
//  NotificationNames.swift
//  Artner
//
//  Feature Isolation Refactoring - 피처 간 통신을 위한 Notification 이름 정의
//

import Foundation

/// 앱 전역에서 사용되는 Notification 이름 정의
/// 피처 간 직접적인 의존성 없이 데이터 동기화를 위해 사용
extension Notification.Name {

    // MARK: - 좋아요 관련

    /// 좋아요 상태 변경 알림
    /// - userInfo: ["id": Int, "isLiked": Bool]
    static let likeStatusChanged = Notification.Name("LikeStatusChanged")

    // MARK: - 도슨트 저장 관련

    /// 도슨트 저장 상태 변경 알림
    /// - userInfo: ["docentId": Int, "folderId": Int?, "isSaved": Bool]
    static let docentSaved = Notification.Name("DocentSaved")

    // MARK: - 인증 관련

    /// 강제 로그아웃 알림 (토큰 만료 시)
    static let forceLogout = Notification.Name("ForceLogout")

    // MARK: - 폴더 관련

    /// 폴더 업데이트 알림 (생성, 수정, 삭제)
    /// - userInfo: ["action": String ("created"/"updated"/"deleted"), "folderId": Int]
    static let folderUpdated = Notification.Name("FolderUpdated")

    // MARK: - 전시 기록 관련

    /// 전시 기록 업데이트 알림
    /// - userInfo: ["action": String ("created"/"deleted"), "recordId": Int]
    static let recordUpdated = Notification.Name("RecordUpdated")

    // MARK: - 하이라이트 관련

    /// 밑줄(하이라이트) 상태 변경 알림
    /// - userInfo: ["highlightId": String, "action": String ("created"/"deleted")]
    static let highlightStatusChanged = Notification.Name("HighlightStatusChanged")
}
