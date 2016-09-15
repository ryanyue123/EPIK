//
//  YoutubeActionController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/22/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation

#if XLACTIONCONTROLLER_EXAMPLE
import XLActionController
#endif
import UIKit
import XLActionController

open class YoutubeCell: ActionCell {
    
    open lazy var animatableBackgroundView: UIView = { [weak self] in
        let view = UIView(frame: self?.frame ?? CGRect.zero)
        view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.40)
        return view
        }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize() {
        actionTitleLabel?.textColor = UIColor(white: 0.098, alpha: 1.0)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.addSubview(animatableBackgroundView)
        selectedBackgroundView = backgroundView
    }
    
    open override var highlighted: Bool {
        didSet {
            if highlighted {
                animatableBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                animatableBackgroundView.frame = CGRect(x: 0, y: 0, width: 30, height: frame.height)
                animatableBackgroundView.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
                
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    guard let me  = self else {
                        return
                    }
                    
                    me.animatableBackgroundView.frame = CGRect(x: 0, y: 0, width: me.frame.width, height: me.frame.height)
                    me.animatableBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.08)
                }) 
            } else {
                animatableBackgroundView.backgroundColor = animatableBackgroundView.backgroundColor?.withAlphaComponent(0.0)
            }
        }
    }
}


open class YoutubeActionController: ActionController<YoutubeCell, ActionData, UICollectionReusableView, Void, UICollectionReusableView, Void> {
    
    public override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        settings.behavior.hideOnScrollDown = false
        settings.animation.scale = nil
        settings.animation.present.duration = 0.6
        settings.animation.dismiss.duration = 0.6
        settings.animation.dismiss.offset = 30
        settings.animation.dismiss.options = .CurveLinear
        
        cellSpec = .NibFile(nibName: "YoutubeCell", bundle: NSBundle(forClass: YoutubeCell.self), height: { _  in 46 })
        
        onConfigureCellForAction = { cell, action, indexPath in
            cell.setup(action.data?.title, detail: action.data?.subtitle, image: action.data?.image)
            cell.alpha = action.enabled ? 1.0 : 0.5
            
            UIView.animateWithDuration(0.30) {
            }
        }
    }
    
    override open func dismissView(_ presentedView: UIView, presentingView: UIView, animationDuration: Double, completion: ((_ completed: Bool) -> Void)?) {
        onWillDismissView()
        let animationSettings = settings.animation.dismiss
        let upTime = 0.1
        UIView.animateWithDuration(upTime, delay: 0, options: .CurveEaseIn, animations: { [weak self] in
            self?.collectionView.frame.origin.y -= 10
            }, completion: { [weak self] (completed) -> Void in
                UIView.animateWithDuration(animationDuration - upTime,
                    delay: 0,
                    usingSpringWithDamping: animationSettings.damping,
                    initialSpringVelocity: animationSettings.springVelocity,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: { [weak self] in
                        presentingView.transform = CGAffineTransformIdentity
                        self?.performCustomDismissingAnimation(presentedView, presentingView: presentingView)
                    },
                    completion: { [weak self] finished in
                        self?.onDidDismissView()
                        completion?(completed: finished)
                    })
            })
    }
}
