//
//  DropdownTableViewController.swift
//  Pareto
//
//  Created by Zachary Coriarty on 2/17/23.
//

import Foundation
import UIKit

class DropdownTableViewCell: UIViewController {
    
    // Data for the table view
    var sections = ["Section 1", "Section 2", "Section 3"]
    var rows = [["Row 1", "Row 2", "Row 3"],
                ["Row 4", "Row 5", "Row 6"],
                ["Row 7", "Row 8", "Row 9"]]
    
    // Array to keep track of expanded section indices
    var expandedSections: Set<Int> = []

    // Table view
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        // Button to add new dropdown
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add Dropdown", for: .normal)
        addButton.addTarget(self, action: #selector(addDropdown), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Layout
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20).isActive = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc func addDropdown() {
        // Add new section and rows
        let newSectionIndex = sections.count
        sections.append("Section \(newSectionIndex + 1)")
        rows.append(["Row \(newSectionIndex * 3 + 1)", "Row \(newSectionIndex * 3 + 2)", "Row \(newSectionIndex * 3 + 3)"])
        
        // Update table view
        tableView.insertSections(IndexSet(integer: newSectionIndex), with: .automatic)
    }
}

extension DropdownTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? rows[section].count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = rows[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        headerView.backgroundColor = .lightGray
        
        // Add label to header view
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: headerView.frame.width - 60, height: headerView.frame.height))
        label.text = sections[section]
        headerView.addSubview(label)
        
        // Add button to header view
        let button = UIButton(type: .system)
        button.frame = CGRect(x: headerView.frame.width - 40, y: 0, width: 40, height: headerView.frame.height)
        button.setTitle(expandedSections.contains(section) ? "▲" : "▼", for: .normal)
        button.addTarget(self, action: #selector(toggleSection(sender:)), for: .touchUpInside)
        button.tag = section
        headerView.addSubview(button)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    @objc func toggleSection(sender: UIButton) {
        let section = sender.tag
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            expandedSections.insert(section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

