//
//  NetworkError.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Moya

/// 네트워크 에러 정의
enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case timeout
    case serverError(Int)
    case decodingError
    case unknownError
    case invalidURL
    case noData
    
    /// 사용자에게 표시할 에러 메시지
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "인터넷 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다. 다시 시도해주세요."
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .invalidURL:
            return "잘못된 요청입니다."
        case .noData:
            return "데이터를 불러올 수 없습니다."
        }
    }
}

// MARK: - Moya Error 확장
extension MoyaError {
    /// Moya 에러를 NetworkError로 변환
    func toNetworkError() -> NetworkError {
        switch self {
        case .underlying(let error, _):
            let nsError = error as NSError
            
            // 네트워크 연결 오류
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet,
                     NSURLErrorNetworkConnectionLost:
                    return .noInternetConnection
                case NSURLErrorTimedOut:
                    return .timeout
                default:
                    return .unknownError
                }
            }
            return .unknownError
            
        case .statusCode(let response):
            return .serverError(response.statusCode)
            
        case .objectMapping, .jsonMapping, .stringMapping:
            return .decodingError
            
        case .requestMapping, .parameterEncoding:
            return .invalidURL
            
        default:
            return .unknownError
        }
    }
}
