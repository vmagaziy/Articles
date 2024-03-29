import UIKit

struct TableViewCellDescriptor {
    let cellClass: UITableViewCell.Type
    let reuseIdentifier: String
    let configure: (UITableViewCell) -> Void
    
    init<Cell: UITableViewCell>(reuseIdentifier: String, configure: @escaping (Cell) -> Void) {
        self.cellClass = Cell.self
        self.reuseIdentifier = reuseIdentifier
        self.configure = { cell in
            guard let cell = cell as? Cell else { fatalError() }
            configure(cell)
        }
    }
}

struct TableViewSection<Item> {
    var title: String?
    var items: [Item]
    init(title: String?, items: [Item]) {
        self.title = title
        self.items = items
    }
}

enum TableViewSource<Item> {
    case unknown
    case loading
    case failure(Error)
    case items([Item])
    case sections([TableViewSection<Item>])
}

class TableViewController<Item>: UITableViewController {
    private let cellDescriptor: (Item) -> TableViewCellDescriptor
    private var reuseIdentifiers: Set<String> = []

    var didSelect: (Item) -> Void = { _ in }
    var didReload: (() -> Void)? // called on retry when failure
    var didRequestRefresh: ((_ completion: @escaping () -> Void) -> Void)? // if set, a refresh control is added to the table view; closure is executed when pull to refresh is initiated and `completion` closure is to be executed when refresh is finished

    init(style: UITableView.Style, cellDescriptor: @escaping (Item) -> TableViewCellDescriptor) {
        self.cellDescriptor = cellDescriptor
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var source: TableViewSource<Item> = .unknown {
        didSet {
            guard isViewLoaded else { return }
            
            switch source {
            case .unknown:
                fatalError("Invalid transition to unknown state")
            case .loading:
                refreshControl = nil
                navigationItem.rightBarButtonItem = nil
                tableView.separatorStyle = .none
                
                let activityIndicatorView = UIActivityIndicatorView(style: .gray)
                activityIndicatorView.startAnimating()
                tableView.backgroundView = activityIndicatorView
            case .failure(let error):
                refreshControl = nil
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
                tableView.separatorStyle = .none
                
                let label = UILabel()
                label.text = error.localizedDescription
                label.font = UIFont.preferredFont(forTextStyle: .title1)
                label.numberOfLines = 0
                label.adjustsFontForContentSizeCategory = true
                label.textAlignment = .center
                
                tableView.backgroundView = label
            case .items, .sections:
                if didRequestRefresh != nil && refreshControl == nil {
                    let refreshControl = UIRefreshControl()
                    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
                    self.refreshControl = refreshControl
                }
                
                navigationItem.rightBarButtonItem = nil
                tableView.separatorStyle = .singleLine
                tableView.backgroundView = nil
            }
    
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch source {
        case .unknown, .loading, .items, .failure: return 1
        case .sections(let sections): return sections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch source {
        case .unknown, .loading, .failure: return 0
        case .items(let items): return items.count
        case .sections(let sections): return sections[section].items.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch source {
        case .unknown, .loading, .failure, .items: return nil
        case .sections(let sections): return sections[section].title
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let descriptor = cellDescriptor(item(for: indexPath))
        
        if !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
            tableView.register(descriptor.cellClass, forCellReuseIdentifier: descriptor.reuseIdentifier)
            reuseIdentifiers.insert(descriptor.reuseIdentifier)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
        
        descriptor.configure(cell)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(item(for: indexPath))
    }
    
    private func item(for indexPath: IndexPath) -> Item {
        switch source {
        case .unknown, .loading, .failure:
            fatalError("Not to be requested for this state")
        case .items(let items):
            return items[indexPath.row]
        case .sections(let sections):
            let section = sections[indexPath.section]
            return section.items[indexPath.row]
        }
    }
    
    @objc private func reload() {
        didReload?()
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        didRequestRefresh? {
            self.refreshControl?.endRefreshing()
        }
    }

}
