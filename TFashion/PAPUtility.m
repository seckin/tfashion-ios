//
//  PAPUtility.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPUtility.h"
#import "UIImage+ResizeAdditions.h"

@implementation PAPUtility


#pragma mark - PAPUtility
#pragma mark Like Photos

+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
        [likeActivity setObject:kPAPActivityTypeLike forKey:kPAPActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kPAPPhotoUserKey] forKey:kPAPActivityToUserKey];
        [likeActivity setObject:photo forKey:kPAPActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kPAPPhotoUserKey]];
        likeActivity.ACL = likeACL;

        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
            }

            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];

        }];
    }];

}

+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryExistingLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    [queryExistingLikes whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }

            // refresh cache
            PFQuery *query = [PAPUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                            [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment]) {
                            [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[PAPCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];

        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];  
}


#pragma mark Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    NSLog(@"Processing profile picture of size: %@", @(newProfilePictureData.length));
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];

    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];

    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);

    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];
                [[PFUser currentUser] saveInBackground];
            }
        }];
    }
    NSLog(@"Processed profile picture");
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    // Check that PFUser has valid fbid that matches current FBSessions userId
    NSString *facebookId = [user objectForKey:kPAPUserFacebookIDKey];
    return (facebookId && facebookId.length > 0 && [facebookId isEqualToString:[[[PFFacebookUtils session] accessTokenData] userID]]);
}

+ (BOOL)userHasValidTwitterData:(PFUser *)user {
    NSString *twitterId = [user objectForKey:kPAPUserTwitterIDKey];
    return (twitterId && twitterId.length > 0);
}

+ (BOOL)userHasValidInstagramData:(PFUser *)user {
    NSString *instagramId = [user objectForKey:kPAPUserInstagramIDKey];
    return (instagramId && instagramId.length > 0);
}

+ (BOOL)userHasValidTumblrData:(PFUser *)user {
    NSString *tumblrId = [user objectForKey:kPAPUserTumblrIDKey];
    return (tumblrId && tumblrId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kPAPUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"AvatarPlaceholderBig.png"];
}

#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:kPAPActivityTypeFollow forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [PAPUtility followUserEventually:user block:completionBlock];
        [[PAPCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey equalTo:user];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey containedIn:users];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[PAPCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryComments whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];

    return query;
}

+ (PFQuery *)queryForActivitiesOnPhotoForCloth:(PFObject *)photo cloth:(PFObject *)cloth cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryLikes whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kPAPActivityClothKey equalTo:cloth];
    [queryLikes whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeLike];

    PFQuery *queryComments = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [queryComments whereKey:kPAPActivityPhotoKey equalTo:photo];
    [queryComments whereKey:kPAPActivityClothKey equalTo:cloth];
    [queryComments whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];

    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityPhotoKey];
    [query includeKey:kPAPActivityClothKey];

    return query;
}

#pragma mark Clothes

+ (PFQuery *)queryForClothesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryClothes = [PFQuery queryWithClassName:kPAPClothClassKey];
    [queryClothes whereKey:kPAPClothPhotoKey equalTo:photo];
    [queryClothes setCachePolicy:cachePolicy];

    return queryClothes;
}

#pragma mark ClothPieces

+ (PFQuery *)queryForClothPiecesOfCloth:(PFObject *)cloth cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryClothPieces = [PFQuery queryWithClassName:kPAPClothPieceClassKey];
    NSLog(@"creating cloth pieces query for %@", cloth.objectId);
    [queryClothPieces whereKey:kPAPClothPieceClothKey equalTo:cloth];
    [queryClothPieces setCachePolicy:cachePolicy];

    return queryClothPieces;
}

+ (BOOL)isLocationInsideCloth:(CGFloat)x withY:(CGFloat)y clothPieces:(NSArray *)clothPieces {

    float scale = 320.0 / 560.0;
//    NSArray *cloth_pieces = [clothData objectForKey:@"cloth_pieces"];
    if([clothPieces count] == 0) {
        return NO;
    }

    bool is_inside = false;
    for(int i = 0; i < [clothPieces count]; i++) {
        PFObject *cloth_piece = [clothPieces objectAtIndex:i];
        NSMutableArray *boundary_points = [cloth_piece objectForKey:@"boundary_points"];

        // Step 1: test bounding box and vertex equality
        int _coordinateCount = [boundary_points count];
        CGFloat minLatitude = 10000.0f, minLongitude = 10000.0f, maxLatitude = -10000.0f, maxLongitude = -10000.0f;
        for (int index = 0; index < _coordinateCount; index++) {
            if ((CGFloat) [boundary_points[index][1] floatValue] * scale == y && (CGFloat) [boundary_points[index][0] floatValue] * scale == x) {
                return YES;
            }

            if ((CGFloat) [boundary_points[index][0] floatValue] * scale < minLatitude) {
                minLatitude = (CGFloat) [boundary_points[index][0] floatValue] * scale;
            }
            if ((CGFloat) [boundary_points[index][1] floatValue] * scale < minLongitude) {
                minLongitude = (CGFloat) [boundary_points[index][1] floatValue] * scale;
            }
            if ((CGFloat) [boundary_points[index][0] floatValue] * scale > maxLatitude) {
                maxLatitude = (CGFloat) [boundary_points[index][0] floatValue] * scale;
            }
            if ((CGFloat) [boundary_points[index][1] floatValue] * scale > maxLongitude) {
                maxLongitude = (CGFloat) [boundary_points[index][1] floatValue] * scale;
            }
        }
        if (x < minLatitude || x > maxLatitude || y < minLongitude || y > maxLongitude) {
            continue;
        }

        // Step 2: cast two rays in "random" directions
        // For a ray going straight to the right, loop through each side;
        // the coordinate lat must be between the points on the side
        // and the coordinate long must be less than where the ray intersection would be
        // If we pass through a different number of sides (mod 2) in different directions, we're starting on an edge. That's inside.
        NSInteger sidesCrossedMovingRight = 0;
        NSInteger sidesCrossedMovingLeft = 0;
        NSInteger previousIndex = _coordinateCount - 1;
        for (int index = 0; index < _coordinateCount; index++) {
            CGFloat firstCoordinateX = (CGFloat) [boundary_points[previousIndex][0] floatValue] * scale;
            CGFloat firstCoordinateY = (CGFloat) [boundary_points[previousIndex][1] floatValue] * scale;
            CGFloat secondCoordinateX = (CGFloat) [boundary_points[index][0] floatValue] * scale;
            CGFloat secondCoordinateY = (CGFloat) [boundary_points[index][1] floatValue] * scale;

            if ((firstCoordinateX <= x && x < secondCoordinateX) ||
                    (secondCoordinateX <= x && x < firstCoordinateX)) {
                if (y <= (secondCoordinateY - firstCoordinateY) * (x - firstCoordinateX) / (secondCoordinateX - firstCoordinateX) + firstCoordinateY) {
                    sidesCrossedMovingRight++;
                }
                if (y >= (secondCoordinateY - firstCoordinateY) * (x - firstCoordinateX) / (secondCoordinateX - firstCoordinateX) + firstCoordinateY) {
                    sidesCrossedMovingLeft++;
                }
            }
            previousIndex = index;
        }
        is_inside = is_inside || sidesCrossedMovingLeft % 2 == 1 || sidesCrossedMovingLeft % 2 != sidesCrossedMovingRight % 2;
        if(is_inside) {
            return is_inside;
        }
    }
    return is_inside;
}


@end
