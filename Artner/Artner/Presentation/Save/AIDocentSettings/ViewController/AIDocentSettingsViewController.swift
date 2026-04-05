//
//  AIDocentSettingsViewController.swift
//  Artner
//
//  AI 도슨트 설정 화면 — AI 유형 + 슬라이더 말하기 설정(길이/속도/난이도) 바인딩

import UIKit
import Combine

final class AIDocentSettingsViewController: UIViewController {

    // MARK: - Properties
    private let contentView = AIDocentSettingsView()
    private let viewModel: AIDocentSettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    /// 저장 완료 시 (personal, lengthDisplayName, speedDisplayName, difficultyDisplayName) 전달
    var onSave: ((String, String, String, String) -> Void)?

    // MARK: - Init
    init(viewModel: AIDocentSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func loadView() { self.view = contentView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupActions() {
        contentView.backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        contentView.aiCellButton.addTarget(self, action: #selector(didTapAICell), for: .touchUpInside)
        contentView.resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        contentView.saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        contentView.lengthRow.slider.addTarget(self, action: #selector(lengthSliderChanged(_:)), for: .valueChanged)
        contentView.speedRow.slider.addTarget(self, action: #selector(speedSliderChanged(_:)), for: .valueChanged)
        contentView.difficultyRow.slider.addTarget(self, action: #selector(difficultySliderChanged(_:)), for: .valueChanged)
    }

    private func bindViewModel() {
        // AI 유형 이름
        viewModel.$displayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in self?.contentView.aiNameLabel.text = name }
            .store(in: &cancellables)

        // 슬라이더 값 → UI 동기화
        viewModel.$lengthIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.contentView.lengthRow.slider.value = index
            }
            .store(in: &cancellables)

        viewModel.$speedIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.contentView.speedRow.slider.value = index
            }
            .store(in: &cancellables)

        viewModel.$difficultyIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.contentView.difficultyRow.slider.value = index
            }
            .store(in: &cancellables)

        // AI 변경 시 프로필 이미지(썸네일) 업데이트
        viewModel.$selectedPersonal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] personal in
                AIDocentSettingsViewModel.thumbnail(for: personal) { [weak self] image in
                    self?.contentView.aiProfileImageView.image = image
                }
            }
            .store(in: &cancellables)

        // 현재값 레이블 (오렌지)
        viewModel.$lengthDisplayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in self?.contentView.lengthRow.valueLabel.text = value }
            .store(in: &cancellables)

        viewModel.$speedDisplayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in self?.contentView.speedRow.valueLabel.text = value }
            .store(in: &cancellables)

        viewModel.$difficultyDisplayName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in self?.contentView.difficultyRow.valueLabel.text = value }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAICell() {
        let selectionVC = AIDocentSelectionViewController(currentPersonal: viewModel.selectedPersonal)
        selectionVC.onSave = { [weak self] personal in self?.viewModel.selectAI(personal: personal) }
        presentBottomSheet(selectionVC)
    }

    @objc private func didTapReset() {
        viewModel.resetSpeakingSettings()
    }

    @objc private func didTapSave() {
        // TODO: PUT API 연동 — selectedLengthApiValue / selectedSpeedApiValue / selectedDifficultyApiValue 전송
        print("💾 저장: 길이=\(viewModel.selectedLengthApiValue), 속도=\(viewModel.selectedSpeedApiValue), 난이도=\(viewModel.selectedDifficultyApiValue)")
        onSave?(viewModel.selectedPersonal, viewModel.lengthDisplayName, viewModel.speedDisplayName, viewModel.difficultyDisplayName)
        ToastManager.shared.showSuccess("설정이 저장되었습니다")
        navigationController?.popViewController(animated: true)
    }

    @objc private func lengthSliderChanged(_ slider: UISlider) {
        let snapped = Int(slider.value.rounded())
        slider.value = Float(snapped)
        viewModel.setLength(index: snapped)
    }

    @objc private func speedSliderChanged(_ slider: UISlider) {
        let snapped = Int(slider.value.rounded())
        slider.value = Float(snapped)
        viewModel.setSpeed(index: snapped)
    }

    @objc private func difficultySliderChanged(_ slider: UISlider) {
        let snapped = Int(slider.value.rounded())
        slider.value = Float(snapped)
        viewModel.setDifficulty(index: snapped)
    }

    // MARK: - Helpers

    /// AI 도슨트 선택 모달 — 좌우 full-width, 세로 화면의 75%
    private func presentBottomSheet(_ vc: UIViewController) {
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    context.maximumDetentValue * 0.75
                }
                sheet.detents = [customDetent]
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = false
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }
}
