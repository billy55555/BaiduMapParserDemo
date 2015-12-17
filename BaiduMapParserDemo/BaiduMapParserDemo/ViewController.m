//
//  ViewController.m
//  BaiduMapParserDemo
//
//  Created by Junan on 15/12/17.
//  Copyright © 2015年 zdj. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface ViewController ()<BMKGeoCodeSearchDelegate> {
    BMKGeoCodeSearch *_searcher;
    NSInteger successTimes;
    NSInteger failTimes;

    NSInteger finshedTimes;

    NSArray *companysArray;
    NSMutableArray *companyOperateArray;

    NSMutableArray *resultArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    successTimes = 0;
    failTimes = 0;
    finshedTimes = 0;
    
    companysArray = [[NSArray alloc] init];
    companyOperateArray = [[NSMutableArray alloc] init];
    resultArray = [[NSMutableArray alloc] init];
    
    //初始化检索对象
    _searcher =[[BMKGeoCodeSearch alloc] init];
    _searcher.delegate = self;
}

- (IBAction)btnClick:(id)sender {
    [self readTxt];
    [self doTask];
}

-(void)viewWillDisappear:(BOOL)animated
{
    _searcher.delegate = nil;
}

- (void) doTask {
    if ([companyOperateArray count] > 0) {
        BMKGeoCodeSearchOption *bmkSearchOption = [[BMKGeoCodeSearchOption alloc] init];
        bmkSearchOption.city= @"杭州市";
        bmkSearchOption.address = [NSString stringWithFormat:@"%@", [companyOperateArray firstObject]];
//        bmkSearchOption.city= @"北京市";
//        bmkSearchOption.address = @"海淀区上地10街10号";
        
        //发起正向地理编码
        BOOL flag = [_searcher geoCode:bmkSearchOption];
        if (flag) {
//            NSLog(@"geo检索发送成功");
        } else {
            NSLog(@"geo检索发送失败 finshTimes = %zi", finshedTimes);
        }
    } else {
        // 输出内容到结果文件
        [self writeTxt];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BMKGeoCodeSearchDelegate
/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {

        BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoCodeSearchOption.reverseGeoPoint = result.location;
        
        // 发起反向地理编码检索
        BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
        if (flag) {
//            NSLog(@"反geo检索发送成功");
        } else {
            NSLog(@"反geo检索发送失败= %zi", finshedTimes);
        }
    }
    else {
        
        [resultArray addObject:@"正向地理编码回调结果失败"];
        
        [companyOperateArray removeObjectAtIndex:0];
        
        finshedTimes++;
        NSLog(@"抱歉，正向地理编码回调结果失败= %zi", finshedTimes);
        
        [self doTask];
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        
        //通过BMKGeoCodeSearch对象处理搜索结果
        [resultArray addObject:result.address];
        
        [companyOperateArray removeObjectAtIndex:0];
        
        finshedTimes++;
        NSLog(@"ReGeo: success! %zi", finshedTimes);
//        NSLog(@"----result.address: %@", result.address);
//        NSLog(@"----result.addressDetail.street: %@.%@", result.addressDetail.streetName, result.addressDetail.streetNumber);
        
        [self doTask];
    } else {
        NSLog(@"抱歉，反向地理编码回调结果失败= %zi", finshedTimes);
        [resultArray addObject:@"反向地理编码回调结果失败"];
        
        [companyOperateArray removeObjectAtIndex:0];
        
        finshedTimes++;
        
        [self doTask];
    }
}

#pragma mark - Private Method
- (void)readTxt {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"company" ofType:@"txt"];
    
    NSError *error;
    companysArray = [[NSString stringWithContentsOfFile:filePath
                                               encoding:NSUTF8StringEncoding
                                                  error:&error]
                     componentsSeparatedByString:@"\r"];
    companyOperateArray = [[NSMutableArray alloc] initWithArray:companysArray];
}

- (void)writeTxt {
    NSString *filePath = @"/Users/junan/Desktop/result/baidu_result.txt";
    
    NSString *content = @"";
    for (NSString *temp in resultArray ) {
        content = [content stringByAppendingString: temp];
        content = [content stringByAppendingString: @"\r"];
    }
    
    //文件不存在会自动创建，文件夹不存在则不会自动创建会报错
    NSError *error;
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"导出失败:%@",error);
    }else{
        NSLog(@"导出成功");
    }
}
@end
