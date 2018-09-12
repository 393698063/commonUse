//
//  AES128ViewController.m
//  ConmonUse
//
//  Created by jorgon on 03/09/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

/*
    Advanced Encryption Standard（高级加密标准）
 
    2006年，高级加密标准已然成为对称密钥加密中最流行的算法之一
 */

#import "AES128ViewController.h"
#import <CommonCrypto/CommonCrypto.h>

@interface AES128ViewController ()

@end

@implementation AES128ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - KeyGeneration
/*
 NSAssert/NSCAssert 两者的差别通过定义可以看出来,
 前者是适合于Objective-C的方法,_cmd 和 self 与运行时有关.
 后者是适用于C的函数.
 NSParameterAssert/NSCparameterAssert两者的区别也是前者适用于Objective-C的方法,
 后者适用于C的函数.
 
 NSAssert/NSCAssert 和 NSParameterAssert/NSCparameterAssert 的区别是前者是所有断言,
 后者只是针对参数是否存在的断言,
 所以可以先进行参数的断言,确认参数是正确的,再进行所有的断言,确认其他原因
 */
static NSData * AES128PBKDF2KeyWithPassword( NSString *password,
                                            NSData *salt,
                                            NSError * __autoreleasing *error)
{
    NSCParameterAssert(password);
    NSCParameterAssert(salt);
    NSMutableData * mutableDerivedKey = [NSMutableData dataWithLength:kCCKeySizeAES128];

    CCCryptorStatus  status = CCKeyDerivationPBKDF(kCCPBKDF2,
                                                   [password UTF8String],
                                                   [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                   [salt bytes],
                                                   [salt length],
                                                   kCCPRFHmacAlgSHA1,
                                                   1024,
                                                   [mutableDerivedKey mutableBytes],
                                                   kCCKeySizeAES128);
    NSData *derivedKey = nil;
    if (status != kCCSuccess) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@""
                                                code:status
                                            userInfo:nil];
        }
    } else {
        derivedKey = [NSData dataWithData:mutableDerivedKey]; }
    return derivedKey;
}

#pragma mark - Encryption
static NSData * AES128EncryptedDataWithData( NSData *data,
                                            NSString *password,
                                            NSData * __autoreleasing *salt,
                                            NSData * __autoreleasing *initializationVector, NSError * __autoreleasing *error)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-result"

    NSCParameterAssert(initializationVector);
    NSCParameterAssert(salt);
    uint8_t *saltBuffer = malloc(8);
    SecRandomCopyBytes(kSecRandomDefault,
                       8,
                       saltBuffer);
    *salt = [NSData dataWithBytes:saltBuffer length:8];
    NSData *key = AES128PBKDF2KeyWithPassword(password, *salt, error);
    uint8_t *initializationVectorBuffer = malloc(kCCBlockSizeAES128);
    SecRandomCopyBytes(kSecRandomDefault,kCCBlockSizeAES128,
                       initializationVectorBuffer);
#pragma clang diagnostic pop
    *initializationVector = [NSData dataWithBytes:initializationVector
                                           length:kCCBlockSizeAES128];
    size_t size = [data length] + kCCBlockSizeAES128;
    void *buffer = malloc(size);
    size_t numberOfBytesEncrypted = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt,kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding,
                                     [key bytes],
                                     [key length],
                                     [*initializationVector  bytes],
                                     [data bytes],
                                     [data length],
                                     buffer,
                                     size,
                                     &numberOfBytesEncrypted);
    NSData *encryptedData = nil; if (status != kCCSuccess) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@""
                                                code:status
                                            userInfo:nil];
        }
    } else {
        encryptedData = [[NSData alloc] initWithBytes:buffer
                                               length:numberOfBytesEncrypted];
        
    }
    return encryptedData;
}

//Decryption
static NSData * AES128DecryptedDataWithData( NSData *data,
                                            NSString *password,
                                            NSData *salt,
                                            NSData *initializationVector, NSError * __autoreleasing *error)
{
    NSData *key = AES128PBKDF2KeyWithPassword(password, salt, error);
    size_t size = [data length] + kCCBlockSizeAES128; void *buffer = malloc(size);
    size_t numberOfBytesDecrypted = 0; CCCryptorStatus status =
    CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
            kCCOptionPKCS7Padding,
            [key bytes],
            [key length], [initializationVector bytes], [data bytes],
            [data length],
            buffer,
            size, &numberOfBytesDecrypted);
    NSData *encryptedData = nil; if (status != kCCSuccess) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:@""
                                                code:status
                                            userInfo:nil];
        }
    } else {
        encryptedData = [[NSData alloc] initWithBytes:buffer
                                               length:numberOfBytesDecrypted];
    }
    return encryptedData;
    
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
