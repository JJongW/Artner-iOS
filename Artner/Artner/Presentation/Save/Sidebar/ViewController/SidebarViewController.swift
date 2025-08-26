//
//  SidebarViewController.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//
//  Clean Architecture: View/ViewModel 분리, 액션/바인딩 담당

import UIKit
import Combine
import SnapKit

// 사이드바 닫기 delegate 프로토콜
protocol SidebarViewControllerDelegate: AnyObject {
    func sidebarDidRequestClose()
    func sidebarDidRequestShowLike() // 좋아요 이동 요청
    func sidebarDidRequestShowSave() // 저장 이동 요청
    func sidebarDidRequestShowUnderline() // 밑줄 이동 요청
    func sidebarDidRequestShowRecord() // 전시기록 이동 요청
}

final class SidebarViewController: UIViewController {
    let sidebarView = SidebarView()
    let viewModel = SidebarViewModel()
    private var cancellables = Set<AnyCancellable>()
    // 사이드바 닫기 delegate
    weak var delegate: SidebarViewControllerDelegate?

    override func loadView() { self.view = sidebarView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatButtons()
        setupSliders()
        setupBottomMenu()
        bindViewModel()
        sidebarView.closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        sidebarView.easyModeSwitch.addTarget(self, action: #selector(didToggleEasyMode), for: .valueChanged)
    }

    private func setupStatButtons() {
        let statTypes: [(SidebarStat.StatType, String, String)] = [
            (.like, "좋아요", "heart"),
            (.save, "저장", "bookmark"),
            (.underline, "밑줄", "pencil"),
            (.record, "전시기록", "doc.text")
        ]
        sidebarView.statStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, (type, title, iconName)) in statTypes.enumerated() {
            let btn = SidebarStatButton()
            btn.configure(icon: UIImage(systemName: iconName), title: title, count: viewModel.stats[i].count)
            btn.tag = i
            btn.addTarget(self, action: #selector(didTapStatButton(_:)), for: .touchUpInside)
            sidebarView.statStackView.addArrangedSubview(btn)
        }
    }

    private func setupSliders() {
        sidebarView.fontSizeSlider.minimumValue = 1
        sidebarView.fontSizeSlider.maximumValue = 10
        sidebarView.fontSizeSlider.value = viewModel.fontSize
        sidebarView.fontSizeSlider.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        sidebarView.lineSpacingSlider.minimumValue = 1
        sidebarView.lineSpacingSlider.maximumValue = 10
        sidebarView.lineSpacingSlider.value = viewModel.lineSpacing
        sidebarView.lineSpacingSlider.addTarget(self, action: #selector(lineSpacingChanged), for: .valueChanged)
    }

    private func setupBottomMenu() {
        let menuTitles = ["이용약관", "개인정보 처리방침", "의견 남기기", "버전 정보 v.0.0.0"]
        sidebarView.bottomMenuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (i, title) in menuTitles.enumerated() {
            // 메뉴 버튼과 화살표를 담을 컨테이너
            let containerView = UIView()
            
            // 메뉴 버튼
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.contentHorizontalAlignment = .left
            btn.tag = i
            btn.addTarget(self, action: #selector(didTapBottomMenu(_:)), for: .touchUpInside)
            
            // 화살표
            let arrow = UIImageView(image: UIImage(named: "ic_arrow"))
            arrow.tintColor = UIColor.white.withAlphaComponent(0.7)
            
            // 컨테이너에 추가
            containerView.addSubview(btn)
            containerView.addSubview(arrow)
            
            // 레이아웃 설정
            btn.snp.makeConstraints {
                $0.leading.centerY.equalToSuperview()
                $0.trailing.equalTo(arrow.snp.leading).offset(-8)
            }
            arrow.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-20)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
            
            // 컨테이너 높이 설정 (16pt 간격 확보)
            containerView.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            
            sidebarView.bottomMenuStackView.addArrangedSubview(containerView)
            
            // 마지막이 아니면 separator 추가
            if i < menuTitles.count {
                let separator = UIView()
                separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                separator.snp.makeConstraints { $0.height.equalTo(1) }
                sidebarView.bottomMenuStackView.addArrangedSubview(separator)
            }
        }
    }

    private func bindViewModel() {
        viewModel.$userName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.sidebarView.nameLabel.text = name + " 님"
            }
            .store(in: &cancellables)
        viewModel.$stats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                for (i, stat) in stats.enumerated() {
                    if let btn = self?.sidebarView.statStackView.arrangedSubviews[i] as? SidebarStatButton {
                        btn.countLabel.text = "\(stat.count)"
                    }
                }
            }
            .store(in: &cancellables)
        viewModel.$fontSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.sidebarView.fontSizeSlider.value = value
            }
            .store(in: &cancellables)
        viewModel.$lineSpacing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.sidebarView.lineSpacingSlider.value = value
            }
            .store(in: &cancellables)
        viewModel.$easyMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.sidebarView.easyModeSwitch.isOn = isOn
            }
            .store(in: &cancellables)
    }

    @objc private func didTapStatButton(_ sender: SidebarStatButton) {
        // 통계 버튼별 화면 이동/로직 처리
        switch sender.tag {
        case 0:
            print("좋아요 이동 요청")
            delegate?.sidebarDidRequestShowLike() // 좋아요 이동 요청
        case 1:
            delegate?.sidebarDidRequestShowSave() // 저장 이동 요청
        case 2:
            delegate?.sidebarDidRequestShowUnderline() // 밑줄 이동 요청
        case 3:
            delegate?.sidebarDidRequestShowRecord() // 전시기록 이동 요청
        default: break
        }
    }
    @objc private func fontSizeChanged() {
        viewModel.fontSize = sidebarView.fontSizeSlider.value
    }
    @objc private func lineSpacingChanged() {
        viewModel.lineSpacing = sidebarView.lineSpacingSlider.value
    }
    @objc private func didToggleEasyMode() {
        viewModel.easyMode = sidebarView.easyModeSwitch.isOn
    }
    @objc private func didTapBottomMenu(_ sender: UIButton) {
        switch sender.tag {
        case 0: print("이용약관 이동")
        case 1: print("개인정보 처리방침 이동")
        case 2: print("의견 남기기 이동")
        case 3: print("버전 정보")
        default: break
        }
    }

    @objc private func didTapClose() {
        // 기존: dismiss(animated: true)
        // 변경: delegate를 통해 닫기 요청 전달 (실제 닫기는 컨테이너가 담당)
        delegate?.sidebarDidRequestClose()
    }
} 
