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
    let viewModel: SidebarViewModel
    private var cancellables = Set<AnyCancellable>()
    // 사이드바 닫기 delegate
    weak var delegate: SidebarViewControllerDelegate?
    
    // MARK: - Initialization
    init(viewModel: SidebarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() { self.view = sidebarView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatButtons()
        setupSliders()
        setupBottomMenu()
        setupSkeletonUI()
        bindViewModel()
        
        // 초기 로딩 상태 설정
        sidebarView.updateLoadingState(isLoading: true, isAISettingsLoading: true)
        
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
            let count = i < viewModel.stats.count ? viewModel.stats[i].count : 0
            btn.configure(icon: UIImage(systemName: iconName), title: title, count: count)
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
        let menuTitles = ["이용약관", "개인정보 처리방침", "의견 남기기", "버전 정보"]
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
            
            // 컨테이너에 추가
            containerView.addSubview(btn)
            
            if i == 3 { // 버전 정보
                // 버전 텍스트
                let versionLabel = UILabel()
                versionLabel.text = "v.0.0.0"
                versionLabel.textColor = UIColor.white.withAlphaComponent(0.6)
                versionLabel.font = UIFont.systemFont(ofSize: 16)
                
                containerView.addSubview(versionLabel)
                
                // 레이아웃 설정
                btn.snp.makeConstraints {
                    $0.leading.centerY.equalToSuperview()
                    $0.trailing.equalTo(versionLabel.snp.leading).offset(-8)
                }
                versionLabel.snp.makeConstraints {
                    $0.trailing.equalToSuperview()
                    $0.centerY.equalToSuperview()
                }
            } else {
                // 화살표
                let arrow = UIImageView(image: UIImage(named: "ic_arrow"))
                arrow.tintColor = UIColor.white.withAlphaComponent(0.7)
                
                containerView.addSubview(arrow)
                
                // 레이아웃 설정
                btn.snp.makeConstraints {
                    $0.leading.centerY.equalToSuperview()
                    $0.trailing.equalTo(arrow.snp.leading).offset(-8)
                }
                arrow.snp.makeConstraints {
                    $0.trailing.equalToSuperview()
                    $0.centerY.equalToSuperview()
                    $0.width.height.equalTo(24)
                }
            }
            
            containerView.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            
            sidebarView.bottomMenuStackView.addArrangedSubview(containerView)
            
            // 마지막이 아니면 separator 추가
            if i < menuTitles.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
                separator.snp.makeConstraints { $0.height.equalTo(1) }
                sidebarView.bottomMenuStackView.addArrangedSubview(separator)
            }
        }
        
        // 하단 divider 추가
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        sidebarView.bottomMenuStackView.addArrangedSubview(bottomDivider)
        bottomDivider.snp.makeConstraints { $0.height.equalTo(1) }
        
        let spacer = UIView()
        sidebarView.bottomMenuStackView.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { $0.height.equalTo(43) }
        
        // 회원 탈퇴 | 로그아웃 추가
        let accountContainer = UIView()
        let withdrawButton = UIButton(type: .system)
        let logoutButton = UIButton(type: .system)
        let verticalDivider = UIView()
        
        withdrawButton.setTitle("회원 탈퇴", for: .normal)
        withdrawButton.setTitleColor(UIColor(red: 0.62, green: 0.61, blue: 0.61, alpha: 1.0), for: .normal) // #9e9c9c
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(UIColor(red: 0.62, green: 0.61, blue: 0.61, alpha: 1.0), for: .normal) // #9e9c9c
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        verticalDivider.backgroundColor = UIColor(red: 0.62, green: 0.61, blue: 0.61, alpha: 1.0) // #9e9c9c
        
        accountContainer.addSubview(withdrawButton)
        accountContainer.addSubview(verticalDivider)
        accountContainer.addSubview(logoutButton)
        
        withdrawButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.equalTo(verticalDivider.snp.leading)
        }
        
        verticalDivider.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(8)
        }
        
        logoutButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.leading.equalTo(verticalDivider.snp.trailing)
        }
        
        accountContainer.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.equalTo(150)
        }
        
        sidebarView.bottomMenuStackView.addArrangedSubview(accountContainer)
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
        
        // AI 설정 데이터 바인딩
        viewModel.$lengthValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.sidebarView.lengthValueLabel.text = value
                self?.sidebarView.updateAISettingsSpacing()
            }
            .store(in: &cancellables)
        
        viewModel.$speedValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.sidebarView.speedValueLabel.text = value
                self?.sidebarView.updateAISettingsSpacing()
            }
            .store(in: &cancellables)
        
        viewModel.$difficultyValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.sidebarView.difficultyValueLabel.text = value
                self?.sidebarView.updateAISettingsSpacing()
            }
            .store(in: &cancellables)
        
        // 로딩 상태 바인딩
        bindLoadingStates()
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
    
    // MARK: - Skeleton UI Setup
    
    private func setupSkeletonUI() {
        sidebarView.setupSkeletonUI()
    }
    
    // MARK: - Loading State Binding
    
    private func bindLoadingStates() {
        // 대시보드 로딩 상태 바인딩
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.sidebarView.updateLoadingState(
                    isLoading: isLoading,
                    isAISettingsLoading: self?.viewModel.isAISettingsLoading ?? true
                )
            }
            .store(in: &cancellables)
        
        // AI 설정 로딩 상태 바인딩
        viewModel.$isAISettingsLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAISettingsLoading in
                self?.sidebarView.updateLoadingState(
                    isLoading: self?.viewModel.isLoading ?? true,
                    isAISettingsLoading: isAISettingsLoading
                )
            }
            .store(in: &cancellables)
    }
} 
