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

class TableViewController<Item>: UITableViewController {
    private let cellDescriptor: (Item) -> TableViewCellDescriptor

    var didSelect: (Item) -> Void = { _ in }
    
    init(style: UITableView.Style, cellDescriptor: @escaping (Item) -> TableViewCellDescriptor) {
        self.cellDescriptor = cellDescriptor
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
}
