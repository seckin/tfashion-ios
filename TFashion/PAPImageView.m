
#import "PAPImageView.h"

@interface PAPImageView ()

@property (nonatomic, strong) PFFile *currentFile;
@property (nonatomic, strong) NSString *url;

@end

@implementation PAPImageView

@synthesize currentFile,url;
@synthesize placeholderImage;

#pragma mark - PAPImageView

- (void) setFile:(PFFile *)file {
    NSString *substring = [file.url substringFromIndex:7];
    NSString *prefix = @"https://s3.amazonaws.com/";
    NSString *fileUrl = [prefix stringByAppendingString:substring];
    NSString *requestURL = fileUrl; // Save copy of url locally (will not change in block)
    [self setUrl:fileUrl]; // Save copy of url on the instance
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            if ([requestURL isEqualToString:self.url]) {
                [self setImage:image];
                [self setNeedsDisplay];
            }
        } else {
            NSLog(@"Error on fetching file");
        }
    }]; 
}

@end
