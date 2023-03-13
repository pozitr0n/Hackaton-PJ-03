//
//  Cell.swift
//  EventViewer
//
//  Created by Raman Kozar on 11/03/2023.
//

import UIKit

class Cell: UITableViewCell {
    
    static let identifier = "cellID"
    
    let myLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 45, width: 350, height: 40)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(myLabel)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
