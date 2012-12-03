#import "AmazonS3Client+uploadImage.h"
#import "UIImage+shrinking.h"

@implementation AmazonS3Client (uploadImage)

static dispatch_queue_t _s3_request_operation_processing_queue;
static dispatch_queue_t s3_request_operation_processing_queue() {
  if (_s3_request_operation_processing_queue == NULL) {
    _s3_request_operation_processing_queue = dispatch_queue_create("com.example.s3-request.processing", 0);
  }
  return _s3_request_operation_processing_queue;
}

- (void)uploadImage:(UIImage *)image
       withFilename:(NSString *)filename
           inBucket:(NSString *)bucket
            success:(void (^)(S3Response *response, NSURL *URL))success
            failure:(void (^)(NSError *error))failure {
  NSString * uploadFilename = [NSString stringWithFormat:@"%@.jpg", filename];
  dispatch_async(s3_request_operation_processing_queue(), ^{
    @try {
      NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.7)];
      S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:uploadFilename inBucket:bucket];
      [por setContentType:@"image/jpeg"];
      [por setData:imageData];
      [por setCannedACL:[S3CannedACL publicRead]];
      S3PutObjectResponse *res = [self putObject:por];
      dispatch_async(dispatch_get_main_queue(), ^{
        if(success)
          success(res, [[NSURL URLWithString:por.host] URLByAppendingPathComponent:uploadFilename]);
      });
    }
    @catch (NSException *exception) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = [NSError errorWithDomain:@"com.example.s3-request.error" code:400 userInfo:exception.userInfo];
        if(failure)
          failure(error);
      });
    }
  });
}

- (void)uploadImage:(UIImage *)image
      thumbnailSize:(CGSize)thumbnailSize
       withFilename:(NSString *)filename
           inBucket:(NSString *)bucket
            success:(void (^)(S3Response *response, NSURL *URL, NSURL *thumbnailURL))success
            failure:(void (^)(NSError *error))failure {
  [self uploadImage:image
       withFilename:filename
           inBucket:bucket
            success:^(S3Response *response, NSURL *thumbnailURL) {
              [self uploadImage:[image imageByShrinkingWithSize:thumbnailSize]
                   withFilename:[filename stringByAppendingString:@"_thumb"]
                       inBucket:bucket
                        success:^(S3Response *response, NSURL *URL) {
                          success(response, URL, thumbnailURL);
                        }
                        failure:failure];
            }
            failure:failure];
}

@end