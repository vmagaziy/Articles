import UIKit

class TableViewController<Item>: UITableViewController {
    var didSelect: (Item) -> Void = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
}
