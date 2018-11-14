//
//  SynthViewController.swift
//  SimpleSequencer
//
//  Created by Joshua Escribano on 5/6/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import Foundation
import UIKit

/**
    ViewController to manage UI for synth engine settings.
    This includes:
        - Volume envelope attack, decay, sustain, release (ADSR) settings
        - FX settings like reverb, delay, etc...
 */
class SynthViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    init() {
        super.init(nibName: "SynthViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    func commonInit() {
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
        addContentPages()
        pageControl.addTarget(self, action: #selector(didChangePage), for: .valueChanged)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 2
    }
    
    func addContentPages() {
        // Programmatically setup the scrollview's content pages
        let ADSRView = SynthADSRView()
        let fxView = SynthFXView()
        ADSRView.translatesAutoresizingMaskIntoConstraints = false
        fxView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ADSRView)
        contentView.addSubview(fxView)
        NSLayoutConstraint.activate([
                ADSRView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                ADSRView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
                ADSRView.topAnchor.constraint(equalTo: contentView.topAnchor),
                ADSRView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            fxView.leftAnchor.constraint(equalTo: ADSRView.rightAnchor),
            fxView.widthAnchor.constraint(equalTo: ADSRView.widthAnchor),
            fxView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            fxView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
        view.layoutIfNeeded()
    }
    
    @objc func didChangePage() {
        let currentPage: CGFloat = CGFloat(pageControl?.currentPage ?? 0)
        let x = currentPage * scrollView.frame.width
        scrollView.contentOffset = CGPoint(x: x, y: 0)
    }
    
}

extension SynthViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
}

extension SynthViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
