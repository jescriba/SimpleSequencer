//
//  SynthFXView.swift
//  SimpleSequencer
//
//  Created by joshua on 11/10/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

class SynthFXView: UIView {
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit() {
        let view = loadXib()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        tableView.tableFooterView = nil
        tableView.separatorStyle = .none
//        tableView.register(SynthFXTableViewCell.self, forCellReuseIdentifier: "SynthFXTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SynthFXTableViewCell")
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
}


extension SynthFXView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return FXEngine.numberOfFX
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SynthFXTableViewCell", for: indexPath)
        cell.textLabel?.text = "test"
//        FXPresenter.present(fxCell: cell, for: indexPath)
        return cell
    }
}
