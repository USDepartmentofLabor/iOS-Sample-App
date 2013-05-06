//
//  MasterViewController.h
//  SDKSample2
//
//  Created by the U.S. Deparment of Labor
//  Code available in the public domain
//

#import <UIKit/UIKit.h>
#import "GOVDataRequest.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <GOVDataRequestDelegate>{
    
    NSArray *arrayOfResults;
    NSDictionary *dictionaryOfResults;
    
    GOVDataRequest *dataRequest;
    
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (nonatomic, retain)NSArray *arrayOfResults;
@property (nonatomic, retain)GOVDataRequest *dataRequest;
@property (nonatomic, retain)NSDictionary *dictionaryOfResults;

-(void)govDataRequest:(GOVDataRequest *)request didCompleteWithError:(NSString *)error;
-(void)govDataRequest:(GOVDataRequest *)request didCompleteWithResults:(NSArray *)resultsArray;
-(void)govDataRequest:(GOVDataRequest *)request didCompleteWithDictionaryResults:(NSArray *)resultsDictionary;


@end
