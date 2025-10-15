import UIKit
import Combine

final class RecordInputViewController: UIViewController {
    private let recordInputView = RecordInputView()
    private let viewModel = RecordInputViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    var onRecordSaved: ((RecordItemModel) -> Void)?
    var onDismiss: (() -> Void)?
    
    override func loadView() {
        self.view = recordInputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTextFieldDelegates()
        bindViewModel()
        setupActions()
    }
    
    private func setupNavigationBar() {
        recordInputView.navigationBar.onBackButtonTapped = { [weak self] in
            self?.dismissViewController()
        }
        recordInputView.navigationBar.didTapMenuButton = { [weak self] in
            self?.dismissViewController()
        }
        
        // X 아이콘 크기 설정 (24x24)
        let xImage = UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        )
        recordInputView.navigationBar.rightButton.setImage(xImage, for: .normal)
    }
    
    private func setupTextFieldDelegates() {
        recordInputView.exhibitionNameTextField.delegate = self
        recordInputView.museumNameTextField.delegate = self
        recordInputView.visitDateTextField.delegate = self
        
        // 텍스트 변경 감지
        recordInputView.exhibitionNameTextField.addTarget(self, action: #selector(exhibitionNameChanged), for: .editingChanged)
        recordInputView.museumNameTextField.addTarget(self, action: #selector(museumNameChanged), for: .editingChanged)
        recordInputView.visitDateTextField.addTarget(self, action: #selector(visitDateChanged), for: .editingChanged)
    }
    
    private func bindViewModel() {
        // 버튼 활성화 상태 바인딩
        viewModel.$isRecordButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.recordInputView.updateRecordButtonState(isEnabled: isEnabled)
            }
            .store(in: &cancellables)
        
        // 글자 수 카운터 바인딩
        viewModel.$exhibitionNameCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.recordInputView.updateCounter(
                    self?.recordInputView.exhibitionNameCounter ?? UILabel(),
                    current: count,
                    max: self?.viewModel.maxExhibitionNameLength ?? 50
                )
            }
            .store(in: &cancellables)
        
        viewModel.$museumNameCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.recordInputView.updateCounter(
                    self?.recordInputView.museumNameCounter ?? UILabel(),
                    current: count,
                    max: self?.viewModel.maxMuseumNameLength ?? 30
                )
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        recordInputView.recordButton.addTarget(self, action: #selector(didTapRecord), for: .touchUpInside)
        
        // 이미지 추가 제스처 추가
        let imageAddTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImageAdd))
        recordInputView.imageAddStackView.addGestureRecognizer(imageAddTapGesture)
        recordInputView.imageAddStackView.isUserInteractionEnabled = true
        
        // 이미지 삭제 버튼 액션 추가 - 다양한 터치 이벤트 로그
        recordInputView.imageDeleteButton.addTarget(self, action: #selector(didTapImageDelete), for: .touchUpInside)
        recordInputView.imageDeleteButton.addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        recordInputView.imageDeleteButton.addTarget(self, action: #selector(didTouchUpOutside), for: .touchUpOutside)
        recordInputView.imageDeleteButton.addTarget(self, action: #selector(didTouchCancel), for: .touchCancel)
        
        print("📸 [RecordInputViewController] 이미지 삭제 버튼 액션 등록 완료")
        print("📸 [RecordInputViewController] 버튼 상태 - isHidden: \(recordInputView.imageDeleteButton.isHidden), isUserInteractionEnabled: \(recordInputView.imageDeleteButton.isUserInteractionEnabled)")
    }
    
    // MARK: - Actions
    
    @objc private func exhibitionNameChanged(_ textField: UITextField) {
        viewModel.updateExhibitionName(textField.text ?? "")
    }
    
    @objc private func museumNameChanged(_ textField: UITextField) {
        viewModel.updateMuseumName(textField.text ?? "")
    }
    
    @objc private func visitDateChanged(_ textField: UITextField) {
        viewModel.updateVisitDate(textField.text ?? "")
    }
    
    @objc private func didTapRecord() {
        guard viewModel.isRecordButtonEnabled else { return }
        
        // RecordItemModel 생성
        let recordItem = RecordItemModel(
            exhibitionName: viewModel.inputModel.exhibitionName,
            museumName: viewModel.inputModel.museumName,
            visitDate: viewModel.inputModel.visitDate,
            selectedImage: viewModel.inputModel.selectedImage
        )
        
        print("📝 [RecordInputViewController] 새로운 전시 기록 생성: \(recordItem.exhibitionName)")
        
        // 성공 Toast 표시
        ToastManager.shared.showSuccess("전시 기록이 저장되었습니다.")
        
        // 화면 닫기 및 데이터 전달
        dismissViewController()
        onRecordSaved?(recordItem)
    }
    
    @objc private func didTapImageAdd() {
        showImagePicker()
    }
    
    private func showImagePicker() {
        let alert = UIAlertController(title: "이미지 선택", message: "이미지를 선택해주세요", preferredStyle: .actionSheet)
        
        // 갤러리에서 선택
        alert.addAction(UIAlertAction(title: "갤러리", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        // 취소
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad에서는 popover로 표시
        if let popover = alert.popoverPresentationController {
            popover.sourceView = recordInputView.imageAddStackView
            popover.sourceRect = recordInputView.imageAddStackView.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("📸 [RecordInputViewController] 이미지 선택기 사용 불가")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func didTapImageDelete() {
        print("📸 [RecordInputViewController] X 버튼 클릭됨! (touchUpInside)")
        // 이미지 삭제
        viewModel.updateImage(nil)
        recordInputView.showSelectedImage(nil)
        print("📸 [RecordInputViewController] 이미지 삭제 완료")
    }
    
    @objc private func didTouchDown() {
        print("📸 [RecordInputViewController] X 버튼 터치 다운!")
    }
    
    @objc private func didTouchUpOutside() {
        print("📸 [RecordInputViewController] X 버튼 터치 업 아웃사이드!")
    }
    
    @objc private func didTouchCancel() {
        print("📸 [RecordInputViewController] X 버튼 터치 캔슬!")
    }
    
    private func dismissViewController() {
        onDismiss?()
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension RecordInputViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 포커스 상태로 테두리 색상 변경
        if textField == recordInputView.museumNameTextField || textField == recordInputView.visitDateTextField {
            recordInputView.updateTextFieldFocus(textField, isFocused: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 포커스 해제 상태로 테두리 색상 변경
        if textField == recordInputView.museumNameTextField || textField == recordInputView.visitDateTextField {
            recordInputView.updateTextFieldFocus(textField, isFocused: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case recordInputView.exhibitionNameTextField:
            recordInputView.museumNameTextField.becomeFirstResponder()
        case recordInputView.museumNameTextField:
            recordInputView.visitDateTextField.becomeFirstResponder()
        case recordInputView.visitDateTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        // 글자 수 제한 체크
        switch textField {
        case recordInputView.exhibitionNameTextField:
            return viewModel.isExhibitionNameValid(newText)
        case recordInputView.museumNameTextField:
            return viewModel.isMuseumNameValid(newText)
        default:
            return true
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension RecordInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            print("📸 [RecordInputViewController] 이미지 선택 실패")
            return
        }
        
        // 선택된 이미지를 ViewModel에 저장하고 View에 표시
        viewModel.updateImage(image)
        recordInputView.showSelectedImage(image)
        
        print("📸 [RecordInputViewController] 이미지 선택 완료")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        print("📸 [RecordInputViewController] 이미지 선택 취소")
    }
}
