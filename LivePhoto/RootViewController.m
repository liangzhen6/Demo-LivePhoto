//
//  RootViewController.m
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/23.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#import "PhotoLibrary.h"
@interface RootViewController ()
@property(nonatomic,copy)NSString *path;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)action:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            {//默认
                NSString * path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
                ViewController * VC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
                VC.originVideoPath = path;
                [self.navigationController pushViewController:VC animated:YES];
            }
            break;
        case 1:
            {//相册选择
                [self handleChoosePhoto];
            }
            break;
        default:
            break;
    }
}

- (void)handleChoosePhoto {
    if ([PhotoLibrary photoLibraryIsAuth]) {
        //已授权
        [[PhotoLibrary sharePhotoLibrary] chooseVideoFromPhotoLibraryResult:^(NSURL *path, BOOL success) {
            if (success) {
                //选择成功
                [self handlePath:path];
            }
        }];
    } else {
        UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"App需要访问你的相册才能将数据写入相册，现在去设置开启权限。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"不写入了" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"现在去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
            }
        }];
        [alertCon addAction:cancel];
        [alertCon addAction:action];
        [self.navigationController presentViewController:alertCon animated:YES completion:nil];
    }
}
//处理share Extension 传递过来的数据
- (void)handleShareExtensionWithPath:(NSString *)groupPath {
    NSFileManager * manger = [NSFileManager defaultManager];
    NSURL * group_url = [manger containerURLForSecurityApplicationGroupIdentifier:@"group.com.livephoto"];
    NSURL *fileUrl = [group_url URLByAppendingPathComponent:groupPath];
    
    [self handlePath:fileUrl];
}
- (void)handlePath:(NSURL *)path {
    NSString * lastPading = [[[path absoluteString] componentsSeparatedByString:@"/"] lastObject];
    NSString * originPath = [self getFilePathWithKey:lastPading];
    //保存在document 下
    [[NSFileManager defaultManager] copyItemAtURL:path toURL:[NSURL fileURLWithPath:originPath] error:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    ViewController * VC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    VC.originVideoPath = originPath;
    [self.navigationController pushViewController:VC animated:YES];
}

/**
 获取沙盒路径
 
 @param key eg. im.jpg vo.mov
 @return 返回路径
 */
- (NSString *)getFilePathWithKey:(NSString *)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    return [documentDirectory stringByAppendingPathComponent:key];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
