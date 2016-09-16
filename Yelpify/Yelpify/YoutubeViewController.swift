//
//  YoutubeViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/22/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//


import UIKit
import XLActionController

class YoutubeViewController: UIViewController {

    
    
        
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
        
    @IBAction func backButtonDidTouch(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
        
    
    @IBAction func Options(_ sender: UITapGestureRecognizer){
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Add to Watch Later", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Add to Playlist...", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Share...", image: UIImage(named: "yt-share-icon")!), style: .default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
        
    
           

}
