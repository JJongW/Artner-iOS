import UIKit
import SnapKit
import Combine

final class SaveFolderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let folder: SaveFolderModel
    private var items: [SavedItem]
    private var cancellables = Set<AnyCancellable>()
    
    // LikeView 레이아웃을 준수하는 전용 View
    private let contentView = SaveFolderDetailView()
    
    init(folder: SaveFolderModel) {
        self.folder = folder
        self.items = folder.items
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = contentView
        view.backgroundColor = .black
        setupNavBar()
        setupBindings()
        setupTable()
        fetchFolderDetail()
    }
    
    private func setupNavBar() {
        contentView.navigationBar.setTitle(folder.name)
        contentView.backgroundColor = .black
        contentView.navigationBar.backgroundColor = .black
        contentView.navigationBar.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        contentView.navigationBar.backButton.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
        contentView.navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
    }
    
    private func setupBindings() {
        contentView.allButton.addTarget(self, action: #selector(filterChanged), for: .touchUpInside)
        contentView.artistButton.addTarget(self, action: #selector(filterChanged), for: .touchUpInside)
        contentView.artworkButton.addTarget(self, action: #selector(filterChanged), for: .touchUpInside)
        contentView.sortButton.addTarget(self, action: #selector(sortChanged), for: .touchUpInside)
    }
    
    private func setupTable() {
        let tv = contentView.tableView
        tv.dataSource = self
        tv.delegate = self
        tv.register(SaveDocentCell.self, forCellReuseIdentifier: "SaveDocentCell")
    }
    
    @objc private func filterChanged() {
        // 간단한 필터: 버튼 타이틀 기준으로 타입 필터링
        if contentView.artistButton.isTouchInside {
            items = folder.items.filter { $0.type == .artist }
        } else if contentView.artworkButton.isTouchInside {
            items = folder.items.filter { $0.type == .artwork }
        } else {
            items = folder.items
        }
        contentView.tableView.reloadData()
    }
    
    @objc private func sortChanged() {
        // 토글: 최신 순/오래된 순
        if contentView.sortButton.currentTitle == "최신순" {
            contentView.sortButton.setTitle("오래된순", for: .normal)
            items.sort { $0.savedDate < $1.savedDate }
        } else {
            contentView.sortButton.setTitle("최신순", for: .normal)
            items.sort { $0.savedDate > $1.savedDate }
        }
        contentView.tableView.reloadData()
    }
    
    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contentView.tableView.dequeueReusableCell(withIdentifier: "SaveDocentCell", for: indexPath) as! SaveDocentCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        cell.onRemove = { [weak self] in
            guard let self = self else { return }
            self.items.removeAll { $0.id == item.id }
            self.contentView.tableView.deleteRows(at: [indexPath], with: .automatic)
            ToastManager.shared.showSuccess("삭제되었습니다")
        }
        cell.onPlay = { [weak self] in
            guard let self = self else { return }
            // 오디오 스트림 다운로드 후 플레이어로 이동
            guard let jobId = item.jobId else {
                ToastManager.shared.showError("오디오 정보를 찾을 수 없습니다")
                return
            }
            ToastManager.shared.showLoading("오디오 불러오는 중")
            APIService.shared.streamAudio(jobId: jobId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    ToastManager.shared.hideCurrentToast()
                }, receiveValue: { [weak self] fileURL in
                    guard let self = self else { return }
                    var docent = self.buildDocent(from: item)
                    // fileURL로 재생하도록 주입
                    docent = Docent(id: docent.id, title: docent.title, artist: docent.artist, description: docent.description, imageURL: docent.imageURL, audioURL: fileURL, paragraphs: docent.paragraphs)
                    let vm = DIContainer.shared.makePlayerViewModel(docent: docent)
                    let vc = PlayerViewController(viewModel: vm, coordinator: AppCoordinator(window: UIApplication.shared.connectedScenes.compactMap{($0 as? UIWindowScene)?.windows.first}.first ?? UIWindow()))
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                .store(in: &self.cancellables)
        }
        return cell
    }
}

// MARK: - Networking
private extension SaveFolderDetailViewController {
    func fetchFolderDetail() {
        guard let folderIdInt = Int(folder.id) else { return }
        // 로딩 표시가 필요하면 여기에
        APIService.shared.getFolderDetail(id: folderIdInt)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let err) = completion { print("❌ 폴더 상세 조회 실패: \(err)"); ToastManager.shared.showError("폴더를 불러오지 못했습니다") }
            }, receiveValue: { [weak self] detail in
                guard let self = self else { return }
                // DTO → SavedItem 매핑
                self.items = detail.items.map { dto in
                    SavedItem(
                        id: String(dto.id),
                        jobId: dto.audioJobId ?? String(dto.id),
                        title: dto.name,
                        artistName: dto.artistName,
                        script: dto.script,
                        type: .artist,
                        savedDate: Self.parseDate(dto.savedAt),
                        thumbnailURL: dto.thumbnail
                    )
                }
                self.contentView.tableView.reloadData()
            })
            .store(in: &cancellables)
    }
    
    static func parseDate(_ str: String?) -> Date {
        guard let s = str else { return Date() }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df.date(from: s) ?? Date()
    }
}

// MARK: - Docent Builder
private extension SaveFolderDetailViewController {
    func buildDocent(from item: SavedItem) -> Docent {
        let fullText = item.script ?? ""
        let sentences: [String] = fullText
            .components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { s in s.hasSuffix(".") ? s : s + "." }
        var current: TimeInterval = 0
        let avg: TimeInterval = 5
        let paragraphs: [DocentParagraph] = sentences.enumerated().map { idx, s in
            let start = current
            current += avg
            let script = DocentScript(startTime: start, text: s)
            return DocentParagraph(id: "p-\(item.id)-\(idx)", startTime: start, endTime: current, sentences: [script])
        }
        return Docent(
            id: item.id.hashValue,
            title: item.title,
            artist: item.artistName ?? "",
            description: String(fullText.prefix(200)),
            imageURL: item.thumbnailURL ?? "",
            audioURL: nil,
            paragraphs: paragraphs
        )
    }
}

// MARK: - Cell
private final class SaveDocentCell: UITableViewCell {
    var onRemove: (() -> Void)?
    var onPlay: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 16, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        return lb
    }()
    private let artistLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.5)
        return lb
    }()
    private let savedAtLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.3)
        return lb
    }()
    private let saveIcon: UIButton = {
        let b = UIButton(type: .system)
        // 저장된 항목인 디테일뷰에서는 채워진 아이콘 사용
        b.setImage(UIImage(named: "ic_save_filled")?.withRenderingMode(.alwaysTemplate), for: .normal)
        b.tintColor = UIColor(hex: "#FF7C27")
        return b
    }()
    private let playButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("도슨트 재생", for: .normal)
        b.setTitleColor(UIColor(hex: "#AAC6FF").withAlphaComponent(0.6), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        b.backgroundColor = UIColor(hex: "#2D3965")
        b.layer.cornerRadius = 6
        b.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return b
    }()
    private let separator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(savedAtLabel)
        contentView.addSubview(saveIcon)
        contentView.addSubview(playButton)
        contentView.addSubview(separator)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualTo(saveIcon.snp.leading).offset(-8)
        }
        saveIcon.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
        }
        savedAtLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(20)
        }
        playButton.snp.makeConstraints { make in
            make.centerY.equalTo(savedAtLabel)
            make.trailing.equalToSuperview().inset(20)
        }
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        saveIcon.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(item: SavedItem) {
        titleLabel.text = item.title
        artistLabel.text = item.artistName ?? ""
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        savedAtLabel.text = df.string(from: item.savedDate)
        saveIcon.tintColor = UIColor(hex: "#FF7C27")
    }
    
    @objc private func removeTapped() { onRemove?() }
    @objc private func playTapped() { onPlay?() }
}


