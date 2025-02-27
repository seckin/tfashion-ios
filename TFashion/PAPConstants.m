//
//  PAPConstants.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPConstants.h"

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kPAPLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification           = @"com.parse.Anypic.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PAPUtilityUserFollowingChangedNotification                      = @"com.parse.Anypic.utility.userFollowingChanged";
NSString *const PAPUtilityUserLikedUnlikedClothCallbackFinishedNotification     = @"com.parse.Anypic.utility.userLikedUnlikedClothCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"com.parse.Anypic.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"com.parse.Anypic.tabBarController.didFinishEditingPhoto";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Anypic.tabBarController.didFinishImageFileUploadNotification";
NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.parse.Anypic.photoDetailsViewController.userDeletedPhoto";
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotification  = @"com.parse.Anypic.photoDetailsViewController.userLikedUnlikedClothInDetailsViewNotification";
NSString *const PAPPhotoDetailsViewControllerUserCommentedOnClothNotification   = @"com.parse.Anypic.photoDetailsViewController.userCommentedOnClothInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedClothNotificationUserInfoLikedKey = @"liked";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPAPInstallationUserKey = @"user";

#pragma mark - Activity Class
// Class key
NSString *const kPAPActivityClassKey = @"Activity";

#pragma mark - Cloth Class
// Class key
NSString *const kPAPClothClassKey = @"Cloth";

// Field keys
NSString *const kPAPClothPhotoKey       = @"photo";

#pragma mark - Report Class
// Class key
NSString *const kPAPReportClassKey = @"Report";

// Field keys
NSString *const kPAPReportToUserKey       = @"toUser";
NSString *const kPAPReportFromUserKey     = @"fromUser";
NSString *const kPAPReportPhotoKey        = @"photo";


#pragma mark - ClothPiece Class
// Class key
NSString *const kPAPClothPieceClassKey = @"ClothPiece";

NSString *const kPAPClothPieceClothKey     = @"cloth";

// Field keys
NSString *const kPAPActivityTypeKey        = @"type";
NSString *const kPAPActivityFromUserKey    = @"fromUser";
NSString *const kPAPActivityClothKey       = @"cloth";
NSString *const kPAPActivityToUserKey      = @"toUser";
NSString *const kPAPActivityContentKey     = @"content";
NSString *const kPAPActivityPhotoKey       = @"photo";
NSString *const kPAPActivityCommentKey     = @"comment";

NSString *const kPAPTagTextKey             = @"text";
NSString *const kPAPTagTaggedObjectKey     = @"taggedObject";
NSString *const kPAPTagTypeKey             = @"type";
NSString *const kPAPTagActivityKey         = @"activity";


// Type values
NSString *const kPAPActivityTypeLike       = @"like";
NSString *const kPAPActivityTypeFollow     = @"follow";
NSString *const kPAPActivityTypeComment    = @"comment";
NSString *const kPAPActivityTypeJoined     = @"joined";
NSString *const kPAPActivityTypeMention    = @"mention";

NSString *const kPAPNotificationSettingTypeOff                  = @"off";
NSString *const kPAPNotificationSettingTypeFromPeopleIFollow    = @"fromPeopleIFollow";
NSString *const kPAPNotificationSettingTypeFromEveryone         = @"fromEveryone";

#pragma mark - User Class
// Field keys
NSString *const kPAPUserDisplayNameKey                          = @"displayName";
NSString *const kPAPUserFacebookIDKey                           = @"facebookId";
NSString *const kPAPUserPhotoIDKey                              = @"photoId";
NSString *const kPAPUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kPAPUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kPAPUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kPAPUserEmailKey                                = @"email";
NSString *const kPAPUserLocationKey                             = @"location";
NSString *const kPAPUserPhoneNumberKey                          = @"phoneNumber";
NSString *const kPAPUserObjectIdKey                             = @"objectId";
NSString *const kPAPUserAutoFollowKey                           = @"autoFollow";
NSString *const kPAPUserTwitterIDKey                            = @"twitterId";
NSString *const kPAPUserInstagramIDKey                          = @"instagramId";
NSString *const kPAPUserTumblrIDKey                             = @"tumblrId";
NSString *const kPAPUserDidUpdateUsernameKey                    = @"didUpdateUsername";
NSString *const kPAPUserNumPhotosKey                            = @"numPhotos";

#pragma mark - Photo Class
// Class key
NSString *const kPAPPhotoClassKey = @"Photo";

// Field keys
NSString *const kPAPPhotoPictureKey         = @"image";
NSString *const kPAPPhotoThumbnailKey       = @"thumbnail";
NSString *const kPAPPhotoCaptionKey         = @"caption";
NSString *const kPAPPhotoUserKey            = @"user";
NSString *const kPAPPhotoOpenGraphIDKey     = @"fbOpenGraphID";


#pragma mark - Cached Photo Attributes
// keys
NSString *const kPAPPhotoAttributesClothesKey              = @"clothes";

#pragma mark - Cached Cloth Attributes
// keys
NSString *const kPAPClothAttributesClothPiecesKey          = @"clothPieces";
NSString *const kPAPClothAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kPAPClothAttributesLikeCountKey            = @"likeCount";
NSString *const kPAPClothAttributesLikersKey               = @"likers";
NSString *const kPAPClothAttributesCommentCountKey         = @"commentCount";
NSString *const kPAPClothAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kPAPPushPayloadPayloadTypeKey          = @"p";
NSString *const kPAPPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPAPPushPayloadActivityTypeKey     = @"t";
NSString *const kPAPPushPayloadActivityLikeKey     = @"l";
NSString *const kPAPPushPayloadActivityCommentKey  = @"c";
NSString *const kPAPPushPayloadActivityFollowKey   = @"f";

NSString *const kPAPPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPAPPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPAPPushPayloadPhotoObjectIdKey    = @"pid";
NSString *const kPAPPushPayloadCommentObjectIdKey  = @"cid";

#pragma mark - User Defaults

NSString *const kDidUserCompletedIntro = @"didUserCompletedIntro";

#pragma mark - Social Account Types

NSString *const kSocialAccountTypeTwitter = @"twitter";
NSString *const kSocialAccountTypeInstagram = @"instagram";
NSString *const kSocialAccountTypeTumblr = @"tumblr";
NSString *const kSocialAccountTypeFacebook = @"facebook";
