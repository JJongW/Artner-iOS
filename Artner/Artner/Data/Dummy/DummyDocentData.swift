//
//  DummyDocentData.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import Foundation

enum DummyDocentData {
    static let sampleDocents: [Docent] = [
        Docent(id: 1, title: "모나리자 해설", artist: "레오나르도 다 빈치", description: "모나리자는 1503년에서 1506년 사이에...", audioURL: nil),
        Docent(id: 2, title: "별이 빛나는 밤에", artist: "빈센트 반 고흐", description: "반 고흐의 걸작 중 하나...", audioURL: nil),
        Docent(id: 3, title: "진주 귀걸이를 한 소녀", artist: "요하네스 베르메르", description: "빛과 그림자 표현이 뛰어난 작품...", audioURL: nil)
    ]
}
