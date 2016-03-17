
#import "PAPPhotoCell.h"
#import "CONImageOverlay.h"
#import "pop.h"
#import "PINCache.h"

@implementation PAPPhotoCell
@synthesize photo;
@synthesize photoButton;
@synthesize imageOverlay;
@synthesize clothOverlays;
@synthesize tagPopovers;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];

        self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.userInteractionEnabled = YES;

//        self.clothOverlays = [[NSMutableArray alloc] init];
        self.tagPopovers = [[NSMutableArray alloc] init];

        [self loadGestureRecognizers];

        [self.contentView addSubview:self.photoButton];
    }

    return self;
}

- (void)loadGestureRecognizers
{
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:doubleTapGesture];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
        __block NSArray *clothes;
        [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothesForPhoto:self.photo] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
            clothes = (NSArray *) tmpobj;

            for (int i = 0; i < [clothes count]; i++) {
                PFObject *cloth = [clothes objectAtIndex:i];
                __block NSArray *cloth_pieces;
                [[PINMemoryCache sharedCache] objectForKey:[PAPCache getKeyForClothPiecesForCloth:cloth] block:^(PINMemoryCache *cache, NSString *key, id tmpobj) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cloth_pieces = tmpobj;
                        if (cloth_pieces && cloth_pieces.count > 0 && [PAPUtility isLocationInsideCloth:location.x withY:location.y clothPieces:cloth_pieces]) {
                            self.imageOverlay = [[CONImageOverlay alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width)];
                            self.imageOverlay.cloth_pieces = cloth_pieces;

                            POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
                            animation.fromValue = @(0.0);
                            animation.toValue = @(0.40);

                            [self.imageOverlay pop_addAnimation:animation forKey:@"fadespring"];

                            [NSTimer scheduledTimerWithTimeInterval:0.2
                                                             target:self
                                                           selector:@selector(removeImageOverlay:)
                                                           userInfo:nil
                                                            repeats:NO];

                            [self.clothOverlays addObject:self.imageOverlay];
                            [self addSubview:self.imageOverlay];
                            [self.contentView setNeedsDisplay];

                            // we showed the flash above, now we need to save the like
                            [self saveUserLike:cloth];
                        }
                    });
                }];
            }
        }];
}

- (void)saveUserLike:(PFObject *)cloth {
    BOOL liked = YES; // assumption: user is probably liking this picture for the first time
    NSArray *likeUsers = [[PAPCache sharedCache] likersForCloth:cloth];
    for (PFUser *likeUser in likeUsers) {
        if ([[likeUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            liked = NO;
            break;
        }
    }

    if(!liked) {
        // user has already liked this picture before. we won't unlike here.
        return;
    }

    NSMutableSet *newLikeUsersSet = [NSMutableSet setWithCapacity:[likeUsers count]];

    for (PFUser *likeUser in likeUsers) {
        [newLikeUsersSet addObject:likeUser];
    }
    [newLikeUsersSet addObject:[PFUser currentUser]];
    [[PAPCache sharedCache] incrementLikerCountForCloth:cloth];
    [[PAPCache sharedCache] setClothIsLikedByCurrentUser:cloth liked:liked];

    [PAPUtility likeClothInBackground:cloth photo:self.photo block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotification object:cloth userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotificationUserInfoLikedKey]];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotification object:cloth userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:liked] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotificationUserInfoLikedKey]];
}

- (void) removeImageOverlay:(NSTimer*)theTimer {
    [self.imageOverlay removeFromSuperview];
    self.imageOverlay = nil;
    for(int i = 0 ; i < [self.clothOverlays count]; i++) {
        [[self.clothOverlays objectAtIndex:i] removeFromSuperview];
    }
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
    self.photoButton.frame = CGRectMake( 0.0f, 0.0f, self.bounds.size.width, self.bounds.size.width);
}

@end
