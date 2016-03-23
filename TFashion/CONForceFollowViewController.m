//
//  UIViewController+CONForceFollowViewController.m
//  Standout
//
//  Created by Seckin Can Sahin on 3/23/16.
//
//

#import "CONForceFollowViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TSMessages/TSMessageView.h>

@interface CONForceFollowViewController ()
-(void)addUser:(int)index;

@end

@implementation CONForceFollowViewController: UIViewController

int profileSize = 80;
int profileMarginX = 20;
int profileMarginY = 30;
int nameWidth = 120;
int nameHeight = 20;
int extraRow = 0;

NSArray *userIds;
NSArray *profileImageUrls;
NSArray *userNames;
NSArray *photoCounts;
NSArray *followerCounts;
NSArray *imageUrls;

UILabel *followingCountLabel;
UILabel *needToFollowCountLabel;

int followingCount = 0;

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    userIds = @[@"kdosKKjQDk",
                @"widsKweJds",
                @"dsakjWEzDs",
                @"suwjDSasEd",
                @"dolkDSaskld",
                @"skdjaWEjdks",
                @"SAkdhsadKi",
                @"sdkaOOdsdw",
                @"suwwDSasEd",
                @"euCPperKC5"];

    profileImageUrls = @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-f536811a-17ca-4dd6-9f7c-a0e176a5756b-tumblr_o3knbuyOry1v9dzgto4_400.jpg",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-758ec8c4-d3a3-4f1d-ad3d-96e10ac6938b-tumblr_o3jvd3ICop1qfahgfo1_500.jpg",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-f706e1e5-ca27-48d3-9a75-d004a4d23955-tumblr_o3kox9hueS1v9dd4yo1_500.png",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-817d4504-89f3-42af-a224-42faf8c6a993-tumblr_o39czn85ji1s0xfxyo1_400.jpg",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-2e449c23-c205-4908-88d9-6975c9242977-tumblr_o3ko91ppHW1rpkvqko1_500.jpg",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-4d54c0db-fe69-48f5-9b00-3d90684becd1-tumblr_o39nuzqoDb1r5wynfo1_500.jpg",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-98564113-de9e-4528-93c4-65f82a7b9c9b-tfss-a8f8d7f5-1b84-4d66-84ce-22ab8f5b0c2d-file",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-09fdc8e1-a83c-4be1-b043-e08f7883dd56-tumblr_o3koyvYwY01ujf74jo1_500.jpg",
                         @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-efbdd641-5185-40ce-a4c5-11f10aeb1470-tumblr_o3ko58Lj4Z1uubll8o1_500.jpg",
                         @"https://s3-us-west-1.amazonaws.com/standouthq/d532446baa28d7c241656deb81f4279e_file.bin"];

    userNames = @[@"Jennifer Larry",
                  @"Christina Brown",
                  @"Oona Ferrera",
                  @"Chryste Robertson",
                  @"Lorinda Pilbeam",
                  @"Moll Rowan",
                  @"Maria Holzgrefe",
                  @"Ddene Leyman",
                  @"Jacquetta Stevenson",
                  @"Gulsah Kandemir Yıldız"];

    photoCounts = @[@"3 Photos",
                  @"5 Photos",
                  @"6 Photos",
                  @"6 Photos",
                  @"3 Photos",
                  @"4 Photos",
                  @"4 Photos",
                  @"3 Photos",
                  @"3 Photos",
                  @"2 Photos"];

    followerCounts = @[@"12 Followers",
                    @"15 Followers",
                    @"6 Followers",
                    @"22 Followers",
                    @"31 Followers",
                    @"5 Followers",
                    @"7 Followers",
                    @"8 Followers",
                    @"9 Followers",
                    @"6 Followers"];

    imageUrls = @[@[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-e6bb8158-fc29-4677-9078-bc6d846f99ef-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-ccc40a48-bb0e-4412-afbc-521f56ce51b5-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-aa877709-99b5-4c4e-86e0-3e6b87c25e41-file",
                    @"",
                    @"",
                    @"",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-a5cb3e83-391d-4088-8ecd-488fe2faef3d-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-febe7ebb-8d64-4f76-ae12-85e9a4fbaf04-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-a92e8d7f-18ff-4d13-a39f-73d947f6b037-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-d440018c-290f-4648-ab95-5da8d3f83a23-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-5ae1bf7f-b8f0-4071-9523-18f4eb67a817-file",
                    @"",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-b7ad2023-378a-46d3-bb9e-09927b0f55e7-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-e7e3e9a1-810b-48fd-9902-48d38cb45e7e-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-984f3476-0219-4283-ae99-cd126b3f9fc3-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-fe566f90-fe08-4b00-883a-191d854ff123-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-173db1cc-741a-4dcc-8937-e8bab7c93373-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-d2c45815-2698-47b0-acf4-f4e005a02ec3-file",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-2cf8c320-60c1-423b-98e6-4ca6c3d165f0-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-64d0503a-f588-4e05-8bf2-f38c3ffa1186-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-d5871775-5666-47f6-bddd-08cdff309a78-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-ef3ea220-fe49-49c9-9ce8-e7e499ad3b9b-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-81b952ed-fedd-4ad4-8aa1-0b5674452e4f-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-6a2db23e-7274-4177-aa04-651e4fa4a74b-file",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-2cf8c320-60c1-423b-98e6-4ca6c3d165f0-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-a8f8d7f5-1b84-4d66-84ce-22ab8f5b0c2d-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-d892694f-ecba-48b2-a2a5-b8a257b97460-file",
                    @"",
                    @"",
                    @"",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-fa33d6f7-8205-416b-99ab-ea3958af6e4c-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-6a2b5e11-f579-4729-ab43-c75627cf7230-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-af331a7d-1cda-42e3-ab66-b110c827e119-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-b3f911d5-c3f4-470b-9705-7157d005da97-file",
                    @"",
                    @"",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-517104d9-f189-47bd-9383-90fd69ef8623-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-35a64504-0f9b-449d-a68d-6f6905a4dca0-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-3c964eef-84bd-42a2-8bb4-05cc8bcf09dc-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-fe4e6767-8d55-4435-93d5-7afca3eb418d-file",
                    @"",
                    @"",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-e2aea18f-3479-4270-8334-842c6a1029e6-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-3d4ae423-8a30-4ef6-aefa-309158f0d37a-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-97c9644c-2bc9-4f1b-96e3-902b3458e3ef-file",
                    @"",
                    @"",
                    @"",
                    @"",
                    @""],
                  @[@"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-d5871775-5666-47f6-bddd-08cdff309a78-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-ef3ea220-fe49-49c9-9ce8-e7e499ad3b9b-file",
                    @"http://files.parsetfss.com/b29d70e9-9999-4c06-8fc2-54a55bdde500/tfss-81b952ed-fedd-4ad4-8aa1-0b5674452e4f-file",
                    @"",
                    @"",
                    @"",
                    @"",
                    @""],
                  @[@"https://s3-us-west-1.amazonaws.com/seckinfvg/seckinfvg/3139d9e1-afc6-43ca-887a-5791749d2e3d.png",
                    @"https://s3-us-west-1.amazonaws.com/seckinfvg/seckinfvg/1005163b-d740-40d9-93a6-2d1628e8bf2f.png",
                    @"",
                    @"",
                    @"",
                    @"",
                    @"",
                    @""]];



    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.scrollEnabled=YES;
    self.scrollView.userInteractionEnabled=YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 2230);

    [self addUser:0];
    [self addUser:1];
    [self addUser:2];
    [self addUser:3];
    [self addUser:4];
    [self addUser:5];
    [self addUser:6];
    [self addUser:7];
    [self addUser:8];
    [self addUser:9];

//    [TSMessage showNotificationWithTitle:@"Follow 5 people so that your feed won't be like the backyard of a meth addict" type:TSMessageNotificationTypeSuccess];
    NSDate *date = [NSDate date];
    NSTimeInterval seconds = trunc([date timeIntervalSinceReferenceDate] + 5);
    [TSMessage showNotificationInViewController:self
                                          title:@"Follow 5 people"
                                       subtitle:@"so your feed won't be like the backyard of a meth addict"
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:seconds
                                       callback:nil
                                    buttonTitle:@"OK"
                                 buttonCallback:^{
                                     NSLog(@"User tapped the button");
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];

    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor greenColor];//[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0f];
    footerView.opaque = YES;
    footerView.frame = CGRectMake(0,[[UIScreen mainScreen] bounds].size.height - 40,[[UIScreen mainScreen] bounds].size.width, 40);
    followingCountLabel = [[UILabel alloc] init];
    followingCountLabel.text = @"Following: 0";
    followingCountLabel.frame = CGRectMake(20.0f, 10.0f, 120.0f, 20.0f);
//    followingCount.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:followingCountLabel];

    needToFollowCountLabel = [[UILabel alloc] init];
    needToFollowCountLabel.text = @"Follow: 5 more";
    needToFollowCountLabel.frame = CGRectMake(180.0f, 10.0f, 120.0f, 20.0f);
//    needToFollowCount.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:needToFollowCountLabel];

    UILabel *boundary = [[UILabel alloc] init];
    boundary.frame = CGRectMake(160.0f, 0.0f, 1.0f, 40.0f);
    boundary.backgroundColor = [UIColor blackColor];
    [footerView addSubview:boundary];
    [self.view addSubview:footerView];
}

- (void)addUser:(int)index {
    BOOL increaseExtraRow = NO;
    int infoMarginX = profileMarginX + profileSize + 10;

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.center = self.view.center;
    imageView.alpha = 1.0;
    [imageView sd_setImageWithURL:[NSURL URLWithString:profileImageUrls[index]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
    imageView.frame = CGRectMake(profileMarginX, profileMarginY + 200 * index + 75 * extraRow, profileSize, profileSize);
    [self.scrollView addSubview:imageView];

    UILabel *profileName = [[UILabel alloc] init];
    profileName.text = userNames[index];
    [profileName setFont:[UIFont fontWithName:@"Gotham-Book" size:16]];
    profileName.frame = CGRectMake(infoMarginX, profileMarginY + 200 * index + 75 * extraRow, nameWidth * 2, nameHeight);
    [self.scrollView addSubview:profileName];

    UILabel *followerCount = [[UILabel alloc] init];
    followerCount.text = followerCounts[index];
    [followerCount setFont:[UIFont fontWithName:@"Gotham-Light" size:13]];
    followerCount.frame = CGRectMake(infoMarginX, profileMarginY + nameHeight + 200 * index + 75 * extraRow, nameWidth, nameHeight);
    [self.scrollView addSubview:followerCount];

    UILabel *photoCount = [[UILabel alloc] init];
    photoCount.text = photoCounts[index];
    [photoCount setFont:[UIFont fontWithName:@"Gotham-Light" size:13]];
    photoCount.frame = CGRectMake(infoMarginX, profileMarginY + 2 * nameHeight + 200 * index + 75 * extraRow, nameWidth, nameHeight);
    [self.scrollView addSubview:photoCount];

    UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    followButton.tag = index;
    followButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:12.0f];
    followButton.titleEdgeInsets = UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 10.0f);

    CGSize size = CGSizeMake(200, 200);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor colorWithRed:247.0f / 255.0f green:50.0f / 255.0f blue:103.0f / 255.0f alpha:1.0f] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *followButtonActiveStateBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [followButton setBackgroundImage:followButtonActiveStateBackgroundImage forState:UIControlStateSelected];

    FAKFoundationIcons *plusIcon = [FAKFoundationIcons plusIconWithSize:12.0f];
    [plusIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    [followButton setImage:[plusIcon imageWithSize:CGSizeMake(12.0f, 12.0f)] forState:UIControlStateNormal];
    FAKFoundationIcons *checkIcon = [FAKFoundationIcons checkIconWithSize:12.0f];
    [checkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    [followButton setImage:[checkIcon imageWithSize:CGSizeMake(12.0f, 12.0f)]
                  forState:UIControlStateSelected];
    [followButton setTitle:@"Follow"
                  forState:UIControlStateNormal];
    [followButton setTitle:@"Following"
                  forState:UIControlStateSelected];
    [followButton setTitleColor:[UIColor blackColor]
                       forState:UIControlStateNormal];
    [followButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateSelected];
    [followButton addTarget:self action:@selector(didTapFollowButton:)
           forControlEvents:UIControlEventTouchUpInside];

    followButton.clipsToBounds = YES;
    followButton.layer.cornerRadius = 5.0f;
    followButton.layer.borderWidth = (0.5f / [UIScreen mainScreen].scale);
    followButton.layer.borderColor = [UIColor blackColor].CGColor;
    followButton.frame = CGRectMake(200, profileMarginY + 25 + 200 * index + 75 * extraRow, 95, 25);
    [self.scrollView addSubview:followButton];

    if(imageUrls[index][0] && [imageUrls[index][0] length] != 0) {
        UIImageView *profileView = [[UIImageView alloc] init];
        profileView.center = self.view.center;
        profileView.frame = CGRectMake(12, 120 + 200 * index + 75 * extraRow, 70, 70);
        profileView.alpha = 1.0;
        [profileView sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][0]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView];
    }
    if(imageUrls[index][1] && [imageUrls[index][1] length] != 0) {
        UIImageView *profileView2 = [[UIImageView alloc] init];
        profileView2.center = self.view.center;
        profileView2.frame = CGRectMake(87, 120 + 200 * index + 75 * extraRow, 70, 70);
        profileView2.alpha = 1.0;
        [profileView2 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][1]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView2];
    }
    if(imageUrls[index][2] && [imageUrls[index][2] length] != 0) {
        UIImageView *profileView3 = [[UIImageView alloc] init];
        profileView3.center = self.view.center;
        profileView3.frame = CGRectMake(162, 120 + 200 * index + 75 * extraRow, 70, 70);
        profileView3.alpha = 1.0;
        [profileView3 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][2]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView3];
    }
    if(imageUrls[index][3] && [imageUrls[index][3] length] != 0) {
        UIImageView *profileView4 = [[UIImageView alloc] init];
        profileView4.center = self.view.center;
        profileView4.frame = CGRectMake(237, 120 + 200 * index + 75 * extraRow, 70, 70);
        profileView4.alpha = 1.0;
        [profileView4 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][3]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView4];
    }
    if(imageUrls[index][4] && [imageUrls[index][4] length] != 0) {
        UIImageView *profileView5 = [[UIImageView alloc] init];
        profileView5.center = self.view.center;
        profileView5.frame = CGRectMake(12, 195 + 200 * index + 75 * extraRow, 70, 70);
        profileView5.alpha = 1.0;
        [profileView5 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][4]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView5];
        increaseExtraRow = YES;
    }
    if(imageUrls[index][5] && [imageUrls[index][5] length] != 0) {
        UIImageView *profileView6 = [[UIImageView alloc] init];
        profileView6.center = self.view.center;
        profileView6.frame = CGRectMake(87, 195 + 200 * index + 75 * extraRow, 70, 70);
        profileView6.alpha = 1.0;
        [profileView6 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][5]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView6];
        increaseExtraRow = YES;
    }
    if(imageUrls[index][6] && [imageUrls[index][6] length] != 0) {
        UIImageView *profileView7 = [[UIImageView alloc] init];
        profileView7.center = self.view.center;
        profileView7.frame = CGRectMake(162, 195 + 200 * index + 75 * extraRow, 70, 70);
        profileView7.alpha = 1.0;
        [profileView7 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][6]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView7];
        increaseExtraRow = YES;
    }
    if(imageUrls[index][7] && [imageUrls[index][7] length] != 0) {
        UIImageView *profileView8 = [[UIImageView alloc] init];
        profileView8.center = self.view.center;
        profileView8.frame = CGRectMake(237, 195 + 200 * index + 75 * extraRow, 70, 70);
        profileView8.alpha = 1.0;
        [profileView8 sd_setImageWithURL:[NSURL URLWithString:imageUrls[index][7]] placeholderImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [self.scrollView addSubview:profileView8];
        increaseExtraRow = YES;
    }

    if(increaseExtraRow) {
        extraRow++;
    }

    // Add a bottomBorder.
    CALayer *bottomBorder = [CALayer layer];

    bottomBorder.frame = CGRectMake(20.0f, 210.0f + 200.0f * index + 75 * extraRow, self.view.frame.size.width - 40, 1.0f);

    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;

    [self.scrollView.layer addSublayer:bottomBorder];

}


- (void)didTapFollowButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSLog(@"didTapFollowButton %@", userIds[button.tag]);
//    var userId = sender.tag;
//    NSString *userId = @"fsMSHlP4Dt";
    PFQuery *query = [PFUser query];
    PFUser *user = (PFUser *)[query getObjectWithId:userIds[button.tag]];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self shouldToggleFollowUser:sender user:user];
    }];
}

- (void)shouldToggleFollowUser: (UIButton *)button user:(PFUser *)user {
    NSLog(@"user: %@", user);
    PFUser *cellUser = user;
    if ([button isSelected]) {
        // Unfollow
        followingCount--;
        NSString *str1 = @"Following: ";
        NSString *str2 = [@(followingCount) stringValue];
        followingCountLabel.text = [str1 stringByAppendingString:str2];
        str1 = @"Follow ";
        str2 = [@(5 - followingCount) stringValue];
        NSString *str3 = @" more";
        needToFollowCountLabel.text = [[str1 stringByAppendingString:str2] stringByAppendingString:str3];
        button.selected = NO;
        [PAPUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        followingCount++;
        NSString *str1 = @"Following: ";
        NSString *str2 = [@(followingCount) stringValue];
        followingCountLabel.text = [str1 stringByAppendingString:str2];
        str1 = @"Follow ";
        str2 = [@(5 - followingCount) stringValue];
        NSString *str3 = @" more";
        needToFollowCountLabel.text = [[str1 stringByAppendingString:str2] stringByAppendingString:str3];
        button.selected = YES;
        [PAPUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                button.selected = NO;
            }
        }];
    }
    if(followingCount == 5) {
        // proceed
        [[[UIApplication sharedApplication] keyWindow].rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
