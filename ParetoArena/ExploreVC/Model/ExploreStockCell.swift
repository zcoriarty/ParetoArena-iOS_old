//
//  ExploreStockCell.swift
//  Pareto
//
//  Created by Zachary Coriarty on 2/19/23.
//

import Foundation
import UIKit

class ExploreStockCell: UITableViewCell {
    @IBOutlet var stockSymbol: UILabel!
    
    @IBOutlet var stockCompany: UILabel!
    
    @IBOutlet var stockPer: UILabel!
    
    @IBOutlet var stockPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
