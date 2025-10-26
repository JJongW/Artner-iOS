//
//  APITarget.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Moya

/// API 엔드포인트 정의
enum APITarget {
    // MARK: - Feed API
    case getFeedList
    case getFeedDetail(id: String)
    
    // MARK: - Docent API (현재 Dummy 데이터 사용으로 제외)
    // case getDocentList
    // case getDocentDetail(id: String) 
    // case playDocent(id: String)
    
    // MARK: - Exhibition API
    case getExhibitionList
    case getExhibitionDetail(id: String)
    
    // MARK: - Artwork API
    case getArtworkList
    case getArtworkDetail(id: String)
    
    // MARK: - Artist API
    case getArtistList
    case getArtistDetail(id: String)
    
    // MARK: - User API
    case getDashboardSummary
    case getAIDocentSettings
    
    // MARK: - Folder API
    case getFolders
    case createFolder(name: String, description: String)
    case updateFolder(id: Int, name: String, description: String)
    case deleteFolder(id: Int)
}

// MARK: - TargetType 구현
extension APITarget: TargetType {
    
    /// 베이스 URL
    var baseURL: URL {
        guard let url = URL(string: "https://artner.shop/api") else {
            fatalError("❌ Invalid base URL")
        }
        return url
    }
    
    /// API 경로
    var path: String {
        switch self {
        // Feed
        case .getFeedList:
            return "/feeds"
        case .getFeedDetail(let id):
            return "/feeds/\(id)"
            
        // Exhibition
        case .getExhibitionList:
            return "/exhibitions"
        case .getExhibitionDetail(let id):
            return "/exhibitions/\(id)"
            
        // Artwork
        case .getArtworkList:
            return "/artworks"
        case .getArtworkDetail(let id):
            return "/artworks/\(id)"
            
        // Artist
        case .getArtistList:
            return "/artists"
        case .getArtistDetail(let id):
            return "/artists/\(id)"
            
        // User
        case .getDashboardSummary:
            return "/users/dashboard_summary"
        case .getAIDocentSettings:
            return "/users/docent_settings"
            
        // Folder
        case .getFolders:
            return "/folders"
        case .createFolder:
            return "/folders"
        case .updateFolder(let id, _, _):
            return "/folders/\(id)"
        case .deleteFolder(let id):
            return "/folders/\(id)"
        }
    }
    
    /// HTTP 메서드
    var method: Moya.Method {
        switch self {
        case .getFolders,
             .getFeedList,
             .getFeedDetail,
             .getExhibitionList,
             .getExhibitionDetail,
             .getArtworkList,
             .getArtworkDetail,
             .getArtistList,
             .getArtistDetail,
             .getDashboardSummary,
             .getAIDocentSettings:
            return .get
            
        case .createFolder:
            return .post
            
        case .updateFolder:
            return .patch
            
        case .deleteFolder:
            return .delete
        }
    }
    
    /// 요청 태스크 (파라미터, 바디 등)
    var task: Task {
        switch self {
        case .getFeedList,
             .getExhibitionList,
             .getArtworkList,
             .getArtistList,
             .getDashboardSummary,
             .getAIDocentSettings,
             .getFolders:
            return .requestPlain
            
        case .getFeedDetail,
             .getExhibitionDetail,
             .getArtworkDetail,
             .getArtistDetail:
            return .requestPlain
            
        case .createFolder(let name, let description):
            let parameters = [
                "name": name,
                "description": description
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .updateFolder(_, let name, let description):
            let parameters = [
                "name": name,
                "description": description
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .deleteFolder:
            return .requestPlain
        }
    }
    
    /// HTTP 헤더
    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // 인증 토큰이 필요한 경우
        if let token = TokenManager.shared.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    /// 샘플 데이터 (테스트용 - 실제 FeedItem 구조 반영)
    var sampleData: Data {
        switch self {
        case .getFeedList:
            return """
            {
                "categories": [
                    {
                        "type": "exhibitions",
                        "title": "전시회",
                        "items": [
                            {
                                "id": 15,
                                "title": "오프사이트 2: 열한 가지 에피소드",
                                "description": "작가: 곽소진, 루킴, 문상훈, 성재윤, 야광, 윤희주, 장영해, 조현진, 하지민, 한솔, 홍지영",
                                "image": "/media/exhibitions/images/exhibition_15.jpg",
                                "type": "exhibition",
                                "likes_count": 0,
                                "created_at": "2025-09-01T17:06:10.919672+09:00",
                                "venue": "서울 종로구 소격동 59-1",
                                "start_date": "2025-08-26",
                                "end_date": "2025-10-26",
                                "status": "ongoing"
                            }
                        ]
                    },
                    {
                        "type": "artists",
                        "title": "작가",
                        "items": []
                    },
                    {
                        "type": "artworks",
                        "title": "작품",
                        "items": []
                    }
                ]
            }
            """.data(using: .utf8) ?? Data()
            
        default:
            return Data()
        }
    }
}
