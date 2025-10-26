import Foundation
import UIKit
import Combine

// MARK: - NotificationCenter 확장
extension Notification.Name {
    static let recordDidCreate = Notification.Name("recordDidCreate")
}

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
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UseCase Dependencies
    private let createRecordUseCase: CreateRecordUseCase
    
    let maxExhibitionNameLength = 50
    let maxMuseumNameLength = 30
    
    init(createRecordUseCase: CreateRecordUseCase) {
        self.createRecordUseCase = createRecordUseCase
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
        
        isLoading = true
        
        // 이미지를 Base64로 변환 (최적화된 압축) - 이미지가 없으면 nil 전달
        let imageBase64 = inputModel.selectedImage?.jpegData(compressionQuality: 0.7)?.base64EncodedString()
        
        createRecordUseCase.execute(
            visitDate: inputModel.visitDate,
            name: inputModel.exhibitionName,
            museum: inputModel.museumName,
            note: "", // TODO: 노트 필드 추가 시 사용
            image: imageBase64
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ [RecordInputViewModel] 전시기록 저장 실패: \(error)")
                    // Toast 에러 메시지 표시 (배경: #222222, 아이콘: #FC5959)
                    ToastManager.shared.showError("전시기록 저장에 실패했습니다.")
                }
            },
            receiveValue: { [weak self] record in
                print("📝 [RecordInputViewModel] 전시기록 저장 완료: \(record.displayTitle)")
                // Toast 성공 메시지 표시 (배경: #222222, 아이콘: #FF7C27)
                ToastManager.shared.showSuccess("전시기록이 저장되었습니다.")
                // 전시기록 목록 새로고침 (NotificationCenter 사용)
                NotificationCenter.default.post(name: .recordDidCreate, object: record)
                self?.resetForm()
            }
        )
        .store(in: &cancellables)
    }
    
    func resetForm() {
        inputModel = RecordInputModel()
    }
}
