//
//  TEViewController.m
//  S3Test
//
//  Created by Atsushi Nagase on 12/3/12.
//  Copyright (c) 2012 LittleApps Inc. All rights reserved.
//

#import "TEViewController.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import "AmazonS3Client+uploadImage.h"
#import "S3Credentials.h"

@interface TEViewController ()

@end

@implementation TEViewController

- (IBAction)openCamera:(id)sender {
  UIImagePickerController *pv = [[UIImagePickerController alloc] init];
  if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
    [pv setSourceType:UIImagePickerControllerSourceTypeCamera];
  } else {
    [pv setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  }
  [pv setDelegate:self];
  [self presentViewController:pv animated:YES completion:NULL];
}

#pragma mark - UIImagePickerViewDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [picker dismissViewControllerAnimated:YES completion:^{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *filename = [NSString stringWithFormat:@"test/%@", [formatter stringFromDate:[NSDate date]]];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:kAWSAccessKey withSecretKey:kAWSSecretKey];
    [s3 uploadImage:image
      thumbnailSize:CGSizeMake(100, 100)
       withFilename:filename
           inBucket:@"littleapps"
            success:^(S3Response *response, NSURL *URL, NSURL *thumbnailURL) {
              NSLog(@"URL: %@\nThumbnail URL: %@", URL.absoluteString, thumbnailURL.absoluteString);
            }
            failure:^(NSError *error) {
              NSLog(@"Error: %@", error.localizedDescription);
            }];
  }];
}

@end
