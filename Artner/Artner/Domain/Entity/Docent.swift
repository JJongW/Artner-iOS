//
//  Docent.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import Foundation

struct Docent {
    let id: Int
    let title: String
    let artist: String
    let description: String
    let imageURL: String
    let audioURL: URL?
    let audioJobId: String? // 오디오 생성 job_id (audioURL이 없을 때 streamAudio 호출에 사용)
    let paragraphs: [DocentParagraph]
}
