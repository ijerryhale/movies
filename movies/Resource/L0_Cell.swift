//
//  L0_Cell.swift
//  movies
//
//  Created by Jerry Hale on 3/28/18.
//  Copyright © 2018 jhale. All rights reserved.
//

import UIKit

protocol SectionHeaderDelegate {
    func toggleSectionIsExpanded(_ header: L0_Cell, section: Int)
}

class L0_Cell: UITableViewHeaderFooterView
{
	var delegate: SectionHeaderDelegate?
    var section: Int = 0

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(reuseIdentifier: String?)
    { super.init(reuseIdentifier: reuseIdentifier)

	}
}
