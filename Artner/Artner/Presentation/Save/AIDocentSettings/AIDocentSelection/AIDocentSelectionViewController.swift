//
//  AIDocentSelectionViewController.swift
//  Artner
//
//  AI 도슨트 선택 모달 - 3가지 AI 중 선택

import UIKit

final class AIDocentSelectionViewController: UIViewController {

    // MARK: - Properties
    private let contentView = AIDocentSelectionView()
    private var currentPersonal: String
    private var selectedPersonal: String
    private var cellViews: [AIDocentCellView] = []

    /// 저장 완료 시 선택된 personal 값을 전달하는 콜백
    var onSave: ((String) -> Void)?

    // MARK: - Init
    init(currentPersonal: String) {
        self.currentPersonal = currentPersonal
        self.selectedPersonal = currentPersonal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCells()
        setupActions()
    }

    // MARK: - Setup

    private func setupCells() {
        cellViews = AIDocentSettingsViewModel.availableAITypes.map { aiType in
            let cell = AIDocentCellView(aiType: aiType)
            cell.setSelected(aiType.personal == selectedPersonal)

            // 탭 제스처 추가
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCell(_:)))
            cell.addGestureRecognizer(tap)
            cell.isUserInteractionEnabled = true

            contentView.stackView.addArrangedSubview(cell)
            return cell
        }
    }

    private func setupActions() {
        contentView.closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        contentView.saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapCell(_ gesture: UITapGestureRecognizer) {
        guard let tappedCell = gesture.view as? AIDocentCellView else { return }
        selectedPersonal = tappedCell.aiType.personal

        // 모든 셀 선택 해제 후 탭된 셀만 선택
        cellViews.forEach { $0.setSelected($0.aiType.personal == selectedPersonal) }
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapSave() {
        onSave?(selectedPersonal)
        dismiss(animated: true)
    }
}
