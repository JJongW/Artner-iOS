//
//  DummyDocentScript.swift
//  Artner
//
//  Created by 신종원 on 4/30/25.
//

let dummyDocentScripts: [DocentScript] = [
    DocentScript(startTime: 0.0, text: "안녕하세요, 아트너 도슨트입니다."),
    DocentScript(startTime: 3.0, text: "오늘 함께 감상할 작품은"),
    DocentScript(startTime: 5.5, text: "레오나르도 다 빈치의 모나리자입니다."),
    DocentScript(startTime: 9.0, text: "이 작품은 1503년부터 1519년 사이에"),
    DocentScript(startTime: 12.5, text: "제작된 르네상스 시대의 걸작입니다."),
    DocentScript(startTime: 16.0, text: "모나리자의 신비로운 미소는"),
    DocentScript(startTime: 19.0, text: "수많은 사람들을 매혹시켜 왔습니다."),
    DocentScript(startTime: 22.5, text: "다 빈치가 사용한 스푸마토 기법은"),
    DocentScript(startTime: 26.0, text: "윤곽선을 흐리게 처리하여"),
    DocentScript(startTime: 29.0, text: "몽환적인 분위기를 연출합니다."),
    DocentScript(startTime: 32.5, text: "그녀의 시선은 어디서 보든"),
    DocentScript(startTime: 35.5, text: "관람객을 따라오는 것처럼 느껴집니다."),
    DocentScript(startTime: 39.0, text: "이것은 다 빈치의 정교한 원근법과"),
    DocentScript(startTime: 42.5, text: "해부학적 지식이 결합된 결과입니다."),
    DocentScript(startTime: 46.0, text: "배경의 풍경 역시 주목할 만합니다."),
    DocentScript(startTime: 49.0, text: "좌우 비대칭의 산악 풍경은"),
    DocentScript(startTime: 52.0, text: "신비로운 분위기를 더욱 강조합니다."),
    DocentScript(startTime: 55.5, text: "모나리자는 현재 프랑스 루브르 박물관에"),
    DocentScript(startTime: 59.0, text: "소장되어 있으며"),
    DocentScript(startTime: 61.5, text: "매년 수백만 명의 관람객이 찾는"),
    DocentScript(startTime: 64.5, text: "세계에서 가장 유명한 그림입니다."),
    DocentScript(startTime: 68.0, text: "이제 작품을 자세히 살펴보시며"),
    DocentScript(startTime: 71.0, text: "다 빈치의 천재성을 느껴보시기 바랍니다.")
]

// MARK: - 문단으로 그룹화된 도슨트 데이터
let dummyDocentParagraphs: [DocentParagraph] = [
    DocentParagraph(
        id: "intro",
        startTime: 0.0,
        endTime: 8.5,
        sentences: [
            DocentScript(startTime: 0.0, text: "안녕하세요, 아트너 도슨트입니다."),
            DocentScript(startTime: 3.0, text: "오늘 함께 감상할 작품은 레오나르도 다 빈치의 모나리자입니다.")
        ]
    ),
    DocentParagraph(
        id: "history",
        startTime: 9.0,
        endTime: 21.0,
        sentences: [
            DocentScript(startTime: 9.0, text: "이 작품은 1503년부터 1519년 사이에 제작된 르네상스 시대의 걸작입니다."),
            DocentScript(startTime: 16.0, text: "모나리자의 신비로운 미소는 수많은 사람들을 매혹시켜 왔습니다.")
        ]
    ),
    DocentParagraph(
        id: "technique",
        startTime: 22.5,
        endTime: 37.0,
        sentences: [
            DocentScript(startTime: 22.5, text: "다 빈치가 사용한 스푸마토 기법은 윤곽선을 흐리게 처리하여"),
            DocentScript(startTime: 29.0, text: "몽환적인 분위기를 연출합니다."),
            DocentScript(startTime: 32.5, text: "그녀의 시선은 어디서 보든 관람객을 따라오는 것처럼 느껴집니다.")
        ]
    ),
    DocentParagraph(
        id: "details",
        startTime: 39.0,
        endTime: 53.0,
        sentences: [
            DocentScript(startTime: 39.0, text: "이것은 다 빈치의 정교한 원근법과 해부학적 지식이 결합된 결과입니다."),
            DocentScript(startTime: 46.0, text: "배경의 풍경 역시 주목할 만합니다."),
            DocentScript(startTime: 49.0, text: "좌우 비대칭의 산악 풍경은 신비로운 분위기를 더욱 강조합니다.")
        ]
    ),
    DocentParagraph(
        id: "museum",
        startTime: 55.5,
        endTime: 67.0,
        sentences: [
            DocentScript(startTime: 55.5, text: "모나리자는 현재 프랑스 루브르 박물관에 소장되어 있으며"),
            DocentScript(startTime: 61.5, text: "매년 수백만 명의 관람객이 찾는 세계에서 가장 유명한 그림입니다.")
        ]
    ),
    DocentParagraph(
        id: "conclusion",
        startTime: 68.0,
        endTime: 74.0,
        sentences: [
            DocentScript(startTime: 68.0, text: "이제 작품을 자세히 살펴보시며"),
            DocentScript(startTime: 71.0, text: "다 빈치의 천재성을 느껴보시기 바랍니다.")
        ]
    )
]
