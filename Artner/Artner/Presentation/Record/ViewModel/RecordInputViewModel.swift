import Foundation
import UIKit
import Combine

struct RecordInputModel {
    var exhibitionName: String = ""
    var museumName: String = ""
    var visitDate: String = ""
    var selectedImage: UIImage?
    
    var isValid: Bool {
        return !exhibitionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !museumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !visitDate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

final class RecordInputViewModel: ObservableObject {
    @Published var inputModel = RecordInputModel()
    @Published var isRecordButtonEnabled = false
    @Published var exhibitionNameCount = 0
    @Published var museumNameCount = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    let maxExhibitionNameLength = 50
    let maxMuseumNameLength = 30
    
    init() {
        bind()
    }
    
    private func bind() {
        // 전시 이름 변경 감지
        $inputModel
            .map { $0.exhibitionName.count }
            .assign(to: \.exhibitionNameCount, on: self)
            .store(in: &cancellables)
        
        // 미술관 이름 변경 감지
        $inputModel
            .map { $0.museumName.count }
            .assign(to: \.museumNameCount, on: self)
            .store(in: &cancellables)
        
        // 버튼 활성화 상태 업데이트
        $inputModel
            .map { $0.isValid }
            .assign(to: \.isRecordButtonEnabled, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Input Methods
    
    func updateExhibitionName(_ text: String) {
        if text.count <= maxExhibitionNameLength {
            inputModel.exhibitionName = text
        }
    }
    
    func updateMuseumName(_ text: String) {
        if text.count <= maxMuseumNameLength {
            inputModel.museumName = text
        }
    }

    func updateVisitDate(_ text: String) {
        inputModel.visitDate = text
    }
    
    func updateImage(_ image: UIImage?) {
        inputModel.selectedImage = image
    }
    
    // MARK: - Validation Methods
    
    func isExhibitionNameValid(_ text: String) -> Bool {
        return text.count <= maxExhibitionNameLength
    }
    
    func isMuseumNameValid(_ text: String) -> Bool {
        return text.count <= maxMuseumNameLength
    }
    
    // MARK: - Record Methods
    
    func saveRecord() {
        guard inputModel.isValid else { return }
        
        // TODO: 실제 저장 로직 구현
        print("📝 [RecordInputViewModel] 전시 기록 저장:")
        print("  - 전시 이름: \(inputModel.exhibitionName)")
        print("  - 미술관 이름: \(inputModel.museumName)")
        print("  - 방문 날짜: \(inputModel.visitDate)")
        print("  - 이미지: \(inputModel.selectedImage != nil ? "있음" : "없음")")
        
        // 저장 후 초기화
        resetForm()
    }
    
    func resetForm() {
        inputModel = RecordInputModel()
    }
}
