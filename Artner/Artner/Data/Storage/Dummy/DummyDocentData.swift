//
//  DummyDocentData.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import Foundation

struct DummyDocentData {
    let sampleDocents: [Docent]

    init() {
        self.sampleDocents = [
            Docent(
                id: 1,
                title: "모나리자 해설",
                artist: "레오나르도 다 빈치",
                description: "여러분, 지금 여러분 앞에 서 있는 이 작품은 인류 미술사에서 가장 유명한 그림 중 하나...",
                imageURL: "titleImage2",
                audioURL: nil,
                paragraphs: dummyDocentParagraphs
            ),
            Docent(
                id: 2,
                title: "별이 빛나는 밤에",
                artist: "빈센트 반 고흐",
                description: "반 고흐의 걸작 중 하나...",
                imageURL: "titleImage2",
                audioURL: nil,
                paragraphs: [
                    DocentParagraph(
                        id: "2",
                        startTime: 0.0,
                        endTime: 10.0,
                        sentences: [DocentScript(startTime: 0.0, text: "별이 빛나는 밤에 대한 설명입니다.")]
                    )
                ]
            ),
            Docent(
                id: 3,
                title: "진주 귀걸이를 한 소녀",
                artist: "요하네스 베르메르",
                description: "빛과 그림자 표현이 뛰어난 작품...",
                imageURL: "titleImage2",
                audioURL: nil,
                paragraphs: [
                    DocentParagraph(
                        id: "3",
                        startTime: 0.0,
                        endTime: 10.0,
                        sentences: [DocentScript(startTime: 0.0, text: "진주 귀걸이를 한 소녀에 대한 설명입니다.")]
                    )
                ]
            )
        ]
    }
}
