//
//  TestTableViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/1/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {
    
    let googleClient = GooglePlacesAPIClient()
    
    var businessShown: [Bool] = []
    var businessObjects: [Business] = [Business(name: "Fresh Brothers", address: "1616 San Miguel Dr", imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/UIBKCAVDSdx8u-Qyrl2Xfg/ms.jpg", photoRef: "CmRdAAAAvwm52TM1oZ1v8gtwOC7DxhJjEPCL1R9IDLptTSqhT-1bVwyXZqaPIZKN2m4xqWbMdUfb3Q-IBaVMb16daG_0_WRl8KWssOU9dcd3DCYht_xd2_icEvFJo579bTJV7kjLEhA9I5PcIh0DD74Tvlb2KezIGhSu-YfA2nTKTGqAr8dsf6FSPWOfsg"),
        Business(name: "Newport Coast First Class Pizza", address: "21117 Newport Coast Dr", imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/4v3Dgx8xp4aMi6qTDgoGoQ/ms.jpg", photoRef: "CmRdAAAAsVyiakROPdNouYulqiU0ZrW05rPwStdWyAOt-L3BGwdsKeyN6k68St-cJYO23vhMl1Mz3u5643Ku_PNYKdWZ1bjH4-poSAS5hBdbnGa-_yQYqpEbOaltX-JDIVFYmPjSEhBCmfIQVNxz7hXHCtzIC2IgGhScfCUnxQL46A0CVaBohMwI-__dNw"),
        Business(name: "MOD Pizza", address: "3965 Alton Pkwy", imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/S7FCA2wKpcrIkrwGBMQjqQ/ms.jpg", photoRef: "CmRdAAAAtQBVhS7B4OvE328cyxa6xdQchDdaeu_xG1UuJX3l4CASAzJ6IJfKxA5MmNiV438sUz7IbKSihSFAToSHOamQV10s4N-DdD452to8NYqXouxPhFWF2Gv4PAnB0OwXlqmVEhAiPochFgLm4DxBbMNOFss5GhSSt0ZrlJwe8ECDq1SDus5Lzqoi0Q"),
        Business(name: "Flippin\' Pizza", address: "17933 MacArthur Blvd", imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/Xg79VF1ykG0fJtgBN4S6Eg/ms.jpg", photoRef: "CmRdAAAAfWFuv7Jfn5IXxvcHNvW2tZV_6Ob9CJ0luk4wNwzf-zo5y9CkOOHGzSRY0VIsRj3zfct_mCXoIvw2Fmvk8jplhiImbXZwr6GJVmcp5zSI0Ik23imhX5w6_AOxGSHE6duzEhB04QulijAnzJqbyQADKl9vGhRVMsRxXKCUUgtNwZcxfGiNuEhDlw"),
        Business(name: "Ray\'s Pizza", address: "4199 Campus Dr", imageURL: "https://s3-media3.fl.yelpcdn.com/bphoto/-wJiuGzFsoTVHNMQJ61EFg/ms.jpg", photoRef: ""),
        Business(name: "Gina\'s Pizza & Pastaria", address: "4533 Campus Dr", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/iwMENoQgJQpzzz9EYuRr-w/ms.jpg", photoRef: "CmRdAAAAo4_76ETE0s6WtMwJzCDZngDRWMiR-7hcCRD1vl-8bJgSOg_-P82fHQPnakTcIyVIqN99-fl3cUcyxzzDqqCAryGe06LI-tIdNVb9s_dI-Fs0Y24Gt5PT6nPnyu2xl1kDEhCRYcvXzWcwS5ynm4QgVe-4GhT_Zg8l5JQgi7UjFZL74RRyIjWP1g"),
        Business(name: "Johnny\'s Real New York Pizza", address: "1320 Bison Ave", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/CKNBaIFhYBlXpL4t1nnsdw/ms.jpg", photoRef: ""),
        Business(name: "Mad Pie", address: "19530 Jamboree Rd", imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/EDiGA6scvADOYik8X21Zbw/ms.jpg", photoRef: ""),
        Business(name: "Ameci Pizza & Pasta", address: "18068 Culver Dr", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/FYB2xHH5RjbSog17RaJgZg/ms.jpg", photoRef: "CmRdAAAADzxIZmrD3rIQvIkc1l_TLlWi9xELRRVByj38K7WH6IYA_9Dbd91lQ_QHcsxXqGg2ZO_JanR-mfGc9PWEPjQq0Y75SA_A_Oc9UlBUCo7KUXl9UMizI0AlE4JuJrLtI2q4EhCnqufSOf6dVA8TxUIQkau4GhRENmEZGoqe5bgiQ7U54p3D3CLO4A"),
        Business(name: "Zpizza", address: "17655 Harvard Ave", imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/mSOq2BRqVkZPHLUzWmosAA/ms.jpg", photoRef: "CmRdAAAAD0L9v5-KsZ2vq40mvg_C1wcfPoMZyccMnhphr1llB6C27f1CzovOH8kOYQqRKlZutwt17rHz27YG4rEr2GeiFMojf-5lUhoZNX0beLM3QtxO_5GtT3X7rLGDD0rGL7R_EhDp2PqyMYSJrcUB9SQAO1r9GhSh3AJeo24vF7kksMA5bJV0XZsa_A"),
        Business(name: "Zpizza", address: "2549 Eastbluff Dr", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/Y0qWJU2qvrUqeN1s6jrqBg/ms.jpg", photoRef: "CmRdAAAAD0L9v5-KsZ2vq40mvg_C1wcfPoMZyccMnhphr1llB6C27f1CzovOH8kOYQqRKlZutwt17rHz27YG4rEr2GeiFMojf-5lUhoZNX0beLM3QtxO_5GtT3X7rLGDD0rGL7R_EhDp2PqyMYSJrcUB9SQAO1r9GhSh3AJeo24vF7kksMA5bJV0XZsa_A")]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...10{
            self.businessShown.append(false)
        }
        
        for business in businessObjects{
            googleClient.getImageFromPhotoReference(business.businessPhotoReference, completion: { (photo, error) -> Void in
                business.setPhoto(photo)
            })
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TestTableViewCell", forIndexPath: indexPath) as! TestTableViewCell
        cell.tag = indexPath.row
        
        let business = businessObjects[indexPath.row]
        
        if businessShown[indexPath.row] == false{
            self.getImageFromPhotoReference(business.businessPhotoReference) { (photo, error) -> Void in
                if cell.tag == indexPath.row{
                    cell.backgroundImage.image = photo
                }
            }
        }
        cell.businessNameLabel.text = business.businessName
        
        businessShown[indexPath.row] = true
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
