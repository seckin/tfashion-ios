//
//  PAPUtility.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

@interface PAPUtility : NSObject

+ (void)likeClothInBackground:(PFObject *)cloth photo:(PFObject *)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikeClothInBackground:(PFObject *)cloth block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasValidTwitterData:(PFUser *)user;
+ (BOOL)userHasValidInstagramData:(PFUser *)user;
+ (BOOL)userHasValidTumblrData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;
+ (UIImage *)defaultProfilePicture;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForActivitiesOnCloth:(PFObject *)cloth cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForClothesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy;
+ (PFQuery *)queryForClothPiecesOfCloth:(PFObject *)cloth cachePolicy:(PFCachePolicy)cachePolicy;

+ (BOOL)isLocationInsideCloth:(CGFloat)x withY:(CGFloat)y clothPieces:(NSArray *)clothPieces;

@end

