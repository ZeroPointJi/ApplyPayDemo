//
//  ViewController.m
//  ApplyPayDemo_Zero
//
//  Created by 诺心ios on 16/6/27.
//  Copyright © 2016年 Zero. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h> // 用户绑定银行卡的信息
#import <PassKit/PKPaymentAuthorizationViewController.h> // Apple Pay的展示控件

@interface ViewController () <PKPaymentAuthorizationViewControllerDelegate>

/** 支持的卡片类型 */
@property (nonatomic, strong) NSArray *supportNewworks;

@end

@implementation ViewController

- (NSArray *)supportNewworks
{
    if (!_supportNewworks) {
        // 此处只是模拟卡片, 真实卡片需要获取
        self.supportNewworks = [NSArray arrayWithObjects:PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkChinaUnionPay, nil];
    }
    
    return _supportNewworks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self canMakePay]) {
        CGRect scrrenFrame = [UIScreen mainScreen].bounds;
        CGFloat scrrenW = scrrenFrame.size.width;
        
        UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        payButton.frame = CGRectMake(100, 100, scrrenW - 200, 50);
        [payButton setTitle:@"Apply Pay" forState:UIControlStateNormal];
        [payButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [payButton setBackgroundColor:[UIColor blackColor]];
        [payButton addTarget:self action:@selector(setupRequest) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:payButton];
    }
    
}

// 是否能使用 Apply Pay
- (BOOL)canMakePay
{
    // 判断当前设备是否支持 Apply Pay
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"当前设备部支持 Apply Pay" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    #warning 当真机调试时 如果这里canMakePaymentsUsingNetworks不能通过，表示手机的钱包（wallet）还没有开通，开通后，添加一张卡，就可以使用
    // 判断是否有绑定支持的卡片
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks: self.supportNewworks]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"没有绑定任何支持类型的卡片, 请绑定" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

// 配置支付请求
- (void)setupRequest
{
    // 创建请求
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    // 创建商品
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"诺心食品有限公司" amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
    
    // 设置请求
    request.paymentSummaryItems = @[item]; // 商品信息
    request.countryCode = @"CN"; // 国家
    request.currencyCode = @"CNY"; // 金额显示格式
    request.supportedNetworks = _supportNewworks; // 支持的支付方式
    request.merchantIdentifier = @"merchant.lecakeApplePay";
    request.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityEMV; // 支持的交易处理协议
    
    // 创建支付界面
    PKPaymentAuthorizationViewController *paymentSheet = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    if (paymentSheet) {
        [self presentViewController:paymentSheet animated:YES completion:nil];
        // 设置代理
        paymentSheet.delegate = self;
    }
}

#pragma mark -- PKPaymentAuthorizationViewControllerDelegate --

// 支付成功后, 苹果服务器返回信息回调
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    // 支付凭证, 发给服务器验证支付是否真实有效
    //PKPaymentToken *paymentToken = payment.token;
    //PKContact *billingContact = payment.billingContact; //账单信息
    //PKContact *shippingContact = payment.shippingContact; //送货信息
    //PKShippingMethod *shippingMethod = payment.shippingMethod; //商品信息
    
    // 等待服务器返回结果后, 再进行系统 block 调用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 模拟服务器通信
        completion(PKPaymentAuthorizationStatusSuccess);
    });
}

// 支付完成回调
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
