//
//  SettingsViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-30.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//
import UIKit
import LocalAuthentication

class SettingsViewController : UITableViewController, CustomTitleView {

    init(sections: [String], rows: [String: [Setting]], optionalTitle: String? = nil) {
        self.sections = sections
        if UserDefaults.isBiometricsEnabled {
            self.rows = rows
        } else {
            var tempRows = rows
            let biometricsLimit = LAContext.biometricType() == .face ? S.Settings.faceIdLimit : S.Settings.touchIdLimit
            tempRows["Manage"] = tempRows["Manage"]?.filter { $0.title != biometricsLimit }
            self.rows = tempRows
        }
        customTitle = optionalTitle ?? S.Settings.title
        titleLabel.text = optionalTitle ?? S.Settings.title
        super.init(style: .plain)
    }

    private let sections: [String]
    private let rows: [String: [Setting]]
    private let cellIdentifier = "CellIdentifier"
    let titleLabel = UILabel(font: .customMedium(size: 26.0), color: C.Colors.text)
    let customTitle: String

    override func viewDidLoad() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 48.0))
        headerView.backgroundColor = C.Colors.background
        headerView.addSubview(titleLabel)
        titleLabel.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: C.padding[2], bottom: 0, right: 0))
        tableView.register(SeparatorCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = C.Colors.background
        addCustomTitle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var indexPaths: [IndexPath] = []
        sections.enumerated().forEach { i, key in
            rows[key]?.enumerated().forEach { j, setting in
                if setting.accessoryText != nil {
                    indexPaths.append(IndexPath(row: j, section: i))
                }
            }
        }
        tableView.backgroundColor = C.Colors.background
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[sections[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
            cell.textLabel?.text = setting.title
            cell.textLabel?.font = .customBody(size: 16.0)
            cell.textLabel?.textColor = C.Colors.text
            cell.backgroundColor = C.Colors.background
            
            if setting.switchViewMode {
                let switchView = UISwitch()
//                switchView.tintColor = UIColor.blueGradientEnd
                switchView.onTintColor = UIColor.da.darkSkyBlue
                switchView.isOn = setting.initialSwitchValue
                switchView.valueChanged = { () in setting.callback(switchView.isOn) }
                cell.accessoryView = switchView
            } else {
                let label = UILabel(font: .customMedium(size: 14.0), color: C.Colors.greyBlue)
                label.text = setting.accessoryText?()
                label.sizeToFit()
                cell.accessoryView = label
            }

        }
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        view.backgroundColor = C.Colors.background
        let label = UILabel(font: .customMedium(size: 14.0), color: UIColor.white)
        view.addSubview(label)
        switch sections[section] {
        case "Wallet":
            label.text = S.Settings.wallet
        case "Manage":
            label.text = S.Settings.manage
        default:
            label.text = ""
        }
        let separator = UIView()
        separator.backgroundColor = C.Colors.greyBlue
        view.addSubview(separator)
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])

        label.constrain([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            label.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -4.0) ])

        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let setting = rows[sections[indexPath.section]]?[indexPath.row] {
            if !setting.switchViewMode {
                setting.callback(true)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollForCustomTitle(yOffset: scrollView.contentOffset.y)
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDraggingForCustomTitle(yOffset: targetContentOffset.pointee.y)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}