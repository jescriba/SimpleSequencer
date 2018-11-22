//
//  ContainerViewController.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 4/28/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit
import SVGKit

/// MenuItem representing pages that can be navigated to from the menu
enum MenuItem: Int {
    case sequencer, synth, samples, settings, help
    
    func description() -> String {
        switch self {
        case .sequencer:
            return "sequencer"
        case .synth:
            return "synth"
        case .samples:
            return "samples"
        case .settings:
            return "settings"
        case .help:
            return "help"
        }
    }
    
    /**
        Get all the available menu items
        Returns: [MenuItem] for all available pages
    */
    static func all() -> [MenuItem] {
        return [.sequencer, .synth, .samples, .settings, .help]
    }
}

/// Container for menu and content view controllers. Manages toolbar view as well.
class ContainerViewController: UIViewController {
    @IBOutlet weak var tempoSlider: CustomSlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    private var isPlaying = false {
        didSet {
            guard isViewLoaded else { return }
            
            AudioEngine.shared.isPlaying = isPlaying
            
            if isPlaying {
                playButton.setImage(UIImage.fromSVG(named: "stop"), for: .normal)
                playButton.tintColor = .customRed
            } else {
                playButton.setImage(UIImage.fromSVG(named: "play"), for: .normal)
                playButton.tintColor = .customGreen
            }
        }
    }
    fileprivate let menuItems: [MenuItem] = [.sequencer, .synth, .samples, .settings, .help]
    private var viewControllers = [UIViewController]()
    private var hasOpenMenu = true
    private var selectedViewController: UIViewController! {
        didSet {
            // Navigate to view controller
            if let v = oldValue {
                v.willMove(toParent: nil)
                v.view.removeFromSuperview()
                v.removeFromParent()
            }
            
            addChild(selectedViewController)
            selectedViewController.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(selectedViewController.view)
            NSLayoutConstraint.activate([
                selectedViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                selectedViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                selectedViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                selectedViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
            selectedViewController.didMove(toParent: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf  = self
        AudioEngine.shared.delegates.append(weakSelf)
        menuButton.setImage(UIImage.fromSVG(named: "hamburger"), for: .normal)
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuTableViewCell")
        menuTableView.backgroundColor = .lightPurple
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.tableFooterView = UIView()
        contentBackgroundView.layer.shadowColor = UIColor.black.cgColor
        contentBackgroundView.layer.shadowOpacity = 1
        contentBackgroundView.layer.shadowRadius = 2
        tempoLabel.adjustsFontSizeToFitWidth = true
        tempoSlider.delegate = self
        tempoSlider.maxValue = AudioEngine.maxTempo
        tempoSlider.minValue = AudioEngine.minTempo
        tempoSlider.value = AudioEngine.shared.tempo
        
        viewControllers = [
            SequencerViewController(),
            SynthViewController(),
            SamplesViewController(),
            SettingsViewController(),
            HelpViewControler()
        ]
        selectedViewController = viewControllers.first
        isPlaying = false
    }
    
    func navigateTo(menuItem: MenuItem) {
        guard menuItem.rawValue < viewControllers.count else { return }
        
        selectedViewController = viewControllers[menuItem.rawValue]
    }
    
    @IBAction func didTapMenu(_ sender: Any?) {
        if hasOpenMenu {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.menuLeadingConstraint.constant = -1 * self.menuTableView.bounds.width
                self.view.layoutIfNeeded()
            }, completion: nil)
            hasOpenMenu = false
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.menuLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
            hasOpenMenu = true
        }
    }
    
    @IBAction func didTogglePlay(_ sender: Any) {
        if isPlaying {
            isPlaying = false
        } else {
            isPlaying = true
        }
    }
    
    /**
        Shake gesture behavior. Used for clearing sequencer state
    */
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            AudioEngine.shared.sequencer.clear()
        }
    }
}

extension ContainerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath)
        cell.backgroundColor = .lightPurple
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .whitePurple
        cell.selectedBackgroundView = backgroundView
        
        cell.textLabel?.text = menuItems[indexPath.row].description()
        cell.textLabel?.textColor = .solidPurple
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 23)
        return cell
    }
}


extension ContainerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateTo(menuItem: MenuItem.all()[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        didTapMenu(nil)
    }
}

extension ContainerViewController: AudioEngineDelegate {
    func didUpdatePlaying(_ isPlaying: Bool) {}

    func didUpdateTempo(_ tempo: Double) {
        tempoLabel.text = String(format: "%.1f", tempo)
    }
}

extension ContainerViewController: CustomSliderDelegate {
    func valueDidChange(newValue: Double, tag: Int) {
        AudioEngine.shared.tempo = newValue
    }
}
