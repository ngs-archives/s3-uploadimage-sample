#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface AmazonS3Client (uploadImage)

- (void)uploadImage:(UIImage *)image
       withFilename:(NSString *)filename
           inBucket:(NSString *)bucket
            success:(void (^)(S3Response *response, NSURL *URL))success
            failure:(void (^)(NSError *error))failure;

- (void)uploadImage:(UIImage *)image
      thumbnailSize:(CGSize)thumbnailSize
       withFilename:(NSString *)filename
           inBucket:(NSString *)bucket
            success:(void (^)(S3Response *response, NSURL *URL, NSURL *thumbnailURL))success
            failure:(void (^)(NSError *error))failure;

@end
