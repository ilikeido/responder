//
//  NickNameVC.h
//  responder
//
//  Created by ilikeido on 15/7/27.
//  Copyright (c) 2015年 ilikeido. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NickNameVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tf_nickname;

@property(nonatomic,strong) NSString *deviceName;

@end
