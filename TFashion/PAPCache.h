//
//  PAPCache.h
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAPCache : NSObject

+ (id)sharedCache;
+ (NSString *)getKeyForClothesForPhoto:(PFObject *)photo;
+ (NSString *)getKeyForClothPiecesForCloth:(PFObject *)cloth;

- (void)clear;
- (void)setAttributesForCloth:(PFObject *)cloth likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (void)setClothesForPhoto:(PFObject *)photo clothes:(NSArray *)clothes;
- (void)setClothPiecesForCloth:(PFObject *)cloth clothPieces:(NSArray *)clothPieces;
- (NSDictionary *)attributesForCloth:(PFObject *)cloth;
- (NSNumber *)likeCountForCloth:(PFObject *)cloth;
- (NSNumber *)commentCountForCloth:(PFObject *)cloth;
- (NSArray *)likersForCloth:(PFObject *)cloth;
- (NSArray *)commentersForCloth:(PFObject *)cloth;
- (NSArray *)clothesForPhoto:(PFObject *)photo;
- (NSArray *)clothPiecesForCloth:(PFObject *)cloth;
// *** TODO: remove these 4 and their uses (or change their uses to clothes where applicable)
- (void)setClothIsLikedByCurrentUser:(PFObject *)cloth liked:(BOOL)liked;
- (BOOL)isClothLikedByCurrentUser:(PFObject *)cloth;
- (void)incrementLikerCountForCloth:(PFObject *)cloth;
- (void)decrementLikerCountForCloth:(PFObject *)cloth;
- (void)incrementCommentCountForCloth:(PFObject *)cloth;
- (void)decrementCommentCountForCloth:(PFObject *)cloth;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)photoCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;


@end
