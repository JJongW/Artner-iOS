import UIKit
import Combine

final class RecordInputViewController: UIViewController {
    private let recordInputView = RecordInputView()
    private let viewModel: RecordInputViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var onRecordSaved: ((RecordItemModel) -> Void)?
    var onDismiss: (() -> Void)?
    
    // MARK: - Date Picker
    // 날짜 선택을 위한 UIDatePicker (년/월/일 선택)
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        
        // iOS 13.4 이상: 다크 모드 스타일 설정
        if #available(iOS 13.4, *) {
            picker.overrideUserInterfaceStyle = .dark
        }
        
        // 최대 날짜는 오늘, 최소 날짜는 과거 10년
        picker.maximumDate = Date()
        let calendar = Calendar.current
        if let minDate = calendar.date(byAdding: .year, value: -10, to: Date()) {
            picker.minimumDate = minDate
        }
        
        return picker
    }()
    
    // Date Picker의 툴바 (완료/취소 버튼)
    private lazy var datePickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .black // 다크 스타일
        toolbar.isTranslucent = false
        toolbar.barTintColor = UIColor(hex: "#222222") // 배경색 #222222
        toolbar.tintColor = UIColor(hex: "#FF7C27") // 버튼 색상
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(datePickerDoneButtonTapped))
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(datePickerCancelButtonTapped))
        
        toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)
        
        return toolbar
    }()
    
    init() {
        self.viewModel = DIContainer.shared.makeRecordInputViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        // 날짜 입력 필드에 UIDatePicker 설정
        // DatePicker를 inputView로 설정하여 키보드 대신 날짜 선택기 표시
        recordInputView.visitDateTextField.inputView = datePicker
        recordInputView.visitDateTextField.inputAccessoryView = datePickerToolbar
        
        // DatePicker 값 변경 감지
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
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
    
    // MARK: - Date Picker Actions
    
    /// DatePicker 값 변경 시 호출
    /// 날짜를 YYYY-MM-DD 형식의 문자열로 변환하여 TextField에 표시
    @objc private func datePickerValueChanged() {
        let selectedDate = datePicker.date
        let formattedDate = formatDateToString(selectedDate)
        recordInputView.visitDateTextField.text = formattedDate
        viewModel.updateVisitDate(formattedDate)
    }
    
    /// DatePicker 완료 버튼 탭
    /// 선택한 날짜를 확정하고 키보드(DatePicker)를 닫음
    @objc private func datePickerDoneButtonTapped() {
        let selectedDate = datePicker.date
        let formattedDate = formatDateToString(selectedDate)
        recordInputView.visitDateTextField.text = formattedDate
        viewModel.updateVisitDate(formattedDate)
        recordInputView.visitDateTextField.resignFirstResponder()
    }
    
    /// DatePicker 취소 버튼 탭
    /// 날짜 선택을 취소하고 키보드(DatePicker)를 닫음
    @objc private func datePickerCancelButtonTapped() {
        recordInputView.visitDateTextField.resignFirstResponder()
    }
    
    /// Date를 "YYYY-MM-DD" 형식의 문자열로 변환
    /// API에서 요구하는 날짜 형식으로 포맷팅 (예: "2025-10-23")
    /// - Parameter date: 변환할 Date 객체
    /// - Returns: "YYYY-MM-DD" 형식의 문자열
    private func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    @objc private func didTapRecord() {
        guard viewModel.isRecordButtonEnabled else { return }
        
        print("📝 [RecordInputViewController] 전시 기록 저장 시작")
        
        // API를 통해 실제 데이터 저장
        viewModel.saveRecord()
        
        // RecordItemModel 생성 (콜백용)
        let recordItem = RecordItemModel(
            exhibitionName: viewModel.inputModel.exhibitionName,
            museumName: viewModel.inputModel.museumName,
            visitDate: viewModel.inputModel.visitDate,
            selectedImage: viewModel.inputModel.selectedImage
        )
        
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
        // 날짜 입력 필드는 DatePicker를 통해서만 값을 설정하므로 직접 입력 불가
        if textField == recordInputView.visitDateTextField {
            return false
        }
        
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
