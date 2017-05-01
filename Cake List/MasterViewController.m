//
//  MasterViewController.m
//  Cake List
//
//  Created by Stewart Hart on 19/05/2015.
//  Copyright (c) 2015 Stewart Hart. All rights reserved.
//

#import "MasterViewController.h"
#import "CakeCell.h"
#import <CommonCrypto/CommonDigest.h>

@interface MasterViewController ()
@property (strong, nonatomic) NSArray *objects;
@property (strong, nonatomic) NSString *dataPath;
@end

@implementation MasterViewController

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Create temp folder
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    self.dataPath = [documentsDirectory stringByAppendingPathComponent:@"/CakeList"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:self.dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    [self getData];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CakeCell *cell = (CakeCell*)[tableView dequeueReusableCellWithIdentifier:@"CakeCell"];
    
    NSDictionary *object = self.objects[indexPath.row];
    cell.titleLabel.text = object[@"title"];
    cell.descriptionLabel.text = object[@"desc"];
 
    //Calculate md5 value from image URL
    NSString *hash = [self md5:object[@"image"]];
    NSString *imageFile = [self.dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", hash]];
    NSData *data;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFile]) {
        NSURL *aURL = [NSURL URLWithString:object[@"image"]];
        data = [NSData dataWithContentsOfURL:aURL];
        //First time loaded so save it to cache
        [data writeToFile:imageFile atomically:TRUE];
    } else {
        //Load it from cache
        data = [NSData dataWithContentsOfFile:imageFile];
    }
    
    //Pass the image to the cell
    UIImage *image = [UIImage imageWithData:data];
    [cell.cakeImageView setImage:image];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getData{
    
    NSURL *url = [NSURL URLWithString:@"https://gist.githubusercontent.com/hart88/198f29ec5114a3ec3460/raw/8dd19a88f9b8d24c23d9960f3300d0c917a4f07c/cake.json"];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSError *jsonError;
    id responseData = [NSJSONSerialization
                       JSONObjectWithData:data
                       options:kNilOptions
                       error:&jsonError];
    if (!jsonError){
        self.objects = responseData;
        [self.tableView reloadData];
    } else {
    }
    
}

@end
