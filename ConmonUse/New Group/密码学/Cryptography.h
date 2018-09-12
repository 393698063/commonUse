//
//  Cryptography.h
//  ConmonUse
//
//  Created by jorgon on 03/09/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
@interface Cryptography : NSObject

#pragma mark - AES128
/**
 KeyGeneration
 */
static NSData * AES128PBKDF2KeyWithPassword( NSString *password,
                                            NSData *salt,
                                            NSError * __autoreleasing *error);
/**
 Encryption
 */
static NSData * AES128EncryptedDataWithData( NSData *data,
                                            NSString *password,
                                            NSData * __autoreleasing *salt,
                                            NSData * __autoreleasing *initializationVector, NSError * __autoreleasing *error);

/**
 Decryption
 */
static NSData * AES128DecryptedDataWithData( NSData *data,
                                            NSString *password,
                                            NSData *salt,
                                            NSData *initializationVector, NSError * __autoreleasing *error);
@end
