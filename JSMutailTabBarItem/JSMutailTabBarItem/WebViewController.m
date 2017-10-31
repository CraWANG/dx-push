//
//  WebViewController.m
//  JS-OC
//
//  Created by zhen qi wang on 2017/10/17.
//  Copyright © 2017年 xujinkeji. All rights reserved.
//

#import "WebViewController.h"
#import <sys/utsname.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <CoreLocation/CoreLocation.h>

@protocol JSObjectDelegate <JSExport>

- (NSString *)getNetWork;

- (void)toast:(NSString *)str;

- (NSString *)getLocation;

- (NSString *)getDeviceId;

- (NSString *)getOsVersion;

- (NSString *)getDeviceTrademark;

- (void)jsNativeCallBack:(NSString *)name;

- (void)showMenuBar: (BOOL)flag;

- (void)sendMultiParamsP1: (NSString *)a P2: (NSString *)b P3: (NSString *)c;

@end

@interface WebViewController ()<UIWebViewDelegate,JSObjectDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (nonatomic, strong) JSContext *context;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) NSString *myLocation;

@end

@implementation WebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    NSURL *htmlURL = [NSURL URLWithString:@"http://10.29.72.243:8080/#/ios"];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    self.webView.backgroundColor = [UIColor clearColor];
    // UIWebView 滚动的比较慢，这里设置为正常速度
    //self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    //一进来先启动定位
    [self colLocaction];
}

- (void)sendMultiParamsP1:(NSString *)a P2:(NSString *)b P3:(NSString *)c {
    
}

- (void)showMenuBar:(BOOL)flag {
    dispatch_sync(dispatch_get_main_queue(), ^{
       [self.tabBarController.tabBar setHidden: !flag];
    });
}

- (void)jsNativeCallBack:(NSString *)name {
    if([name isEqualToString:@"jsFunction1Callback"]) {
        [self jsFunction1Callback];
    } else if([name isEqualToString:@"jsFunction2Callback"]) {
        [self jsFunction2Callback];
    } else {
        [self jsFunction3Callback];
    }
}

- (void)jsFunction1Callback {
    JSValue *shareCallBack = self.context[@"jsFunction1Callback"];
    [shareCallBack callWithArguments:nil];
}

- (void)jsFunction2Callback {
    JSValue *shareCallBack = self.context[@"jsFunction2Callback"];
    [shareCallBack callWithArguments:nil];
}

- (void)jsFunction3Callback {
        JSValue *shareCallBack = self.context[@"jsFunction3Callback"];
        [shareCallBack callWithArguments:nil];
}

///获取地理位置
- (NSString *)getLocation{
    return self.myLocation;
}
///获取设备id
- (NSString *)getDeviceId{
    return [[NSUUID UUID] UUIDString];
}
///获取系统版本
- (NSString *)getOsVersion {
    return [UIDevice currentDevice].systemVersion;
}
///获取手机品牌
- (NSString *)getDeviceTrademark {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString: systemInfo.machine encoding:NSUTF8StringEncoding];;
}
///获取网络情况
- (NSString *)getNetWork {
    
    UIApplication *app = [UIApplication sharedApplication];

    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    
    int type = 0;
    
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    NSDictionary * dict = @{@"0" : @"无网络",@"1" : @"2G网络",@"2" : @"3G网络",@"3" : @"4G网络",@"5" : @"WIFI"};
    return [dict valueForKey:[NSString stringWithFormat:@"%d",type]];
}

- (void)toast:(NSString *)str {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message: str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 定位
-(void)colLocaction{
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager  requestWhenInUseAuthorization];//请求授权
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 200.0f;
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog(@"请开启定位功能！");
    }
}
//定位代理方法
- (void)locationManager:(CLLocationManager *)manager
        didUpdateToLocation:(CLLocation *)newLocation
               fromLocation:(CLLocation *)oldLocation {
    
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
         if (array.count > 0) {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             //详细地址
             NSString *location = placemark.name;
             //拼接成最终的位置
             self.myLocation = [NSString stringWithFormat:@"%@%@",city,location];
         } else if (error == nil && [array count] == 0) {
             self.myLocation = @"No results were returned.";
         } else if (error != nil) {
             self.myLocation = @"An error occurred = %@";
         }
     }];
    //停止定位
    [manager stopUpdatingLocation];
}
// 定位失误时调用
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error:%@",error);
}

#pragma mark - private method
- (void)addCustomActions {
    
    self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    self.context[@"HostApp"] = self;

    //[context evaluateScript:@"HostApp=window.HostApp"];
    
    //[self getNetWorkWithContext: self.context];
}

- (void)getNetWorkWithContext:(JSContext *)context {
    context[@"getNetWork"] = ^() {
        NSLog(@"扫一扫啦");
    };
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self addCustomActions];
}

- (void)dealloc {
    
}

@end
