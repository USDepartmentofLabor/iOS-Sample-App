//
//  DetailViewController.h
//  SDKSample2
//
//  Created by the U.S. Deparment of Labor
//  Code available in the public domain
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
