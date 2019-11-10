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

enum TableViewSource<Item> {
    case unknown
    case loading
    case failure(Error)
    case items([Item])
}

class TableViewController<Item>: UITableViewController {
    private let cellDescriptor: (Item) -> TableViewCellDescriptor
    private var reuseIdentifiers: Set<String> = []

    var didSelect: (Item) -> Void = { _ in }
    var didReload: (() -> Void)? // called on retry when failure

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
                navigationItem.rightBarButtonItem = nil
                
                tableView.separatorStyle = .none
                
                let activityIndicatorView = UIActivityIndicatorView(style: .gray)
                activityIndicatorView.startAnimating()
                tableView.backgroundView = activityIndicatorView
            case .failure(let error):
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
                tableView.separatorStyle = .none
                
                let label = UILabel()
                label.text = error.localizedDescription
                label.font = UIFont.preferredFont(forTextStyle: .title1)
                label.numberOfLines = 0
                label.adjustsFontForContentSizeCategory = true
                label.textAlignment = .center
                
                tableView.backgroundView = label
            case .items:
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch source {
        case .unknown, .loading, .failure: return 0
        case .items(let items): return items.count
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
        }
    }
    
    @objc private func reload() {
        didReload?()
    }
}
