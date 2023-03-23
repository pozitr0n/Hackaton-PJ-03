//
//  Cell.swift
//  EventViewer
//
//  Created by Raman Kozar on 11/03/2023.
//  Updated by Raman Kozar
//

import UIKit

class Cell: UITableViewCell {
    
    static let identifier = "cellID"
    
    let myLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        contentView.addSubview(myLabel)
        myLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(6)
        }
    }
}
