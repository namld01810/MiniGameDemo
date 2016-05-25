//
//  SOAPHandler.h
//  BDLive
//
//  Created by Khanh Le on 12/11/14.
//  Copyright (c) 2014 Khanh Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Common/xs_common_inc.h"


@protocol SOAPHandlerDelegate <NSObject>

@optional
-(void)onSoapError:(NSError *)error;
-(void)onSoapDidFinishLoading:(NSData *)data;
-(void)onAutoSoapDidFinishLoading:(NSData *)data;
-(void)onPhongDoDidFinishLoading:(NSData *)data type:(NSUInteger)type;

@end


@interface SOAPHandler : NSObject
{
    NSMutableData *webData;
    NSMutableString *soapResults;
}
-(void) sendSOAPRequestRegistration:(NSString*)soapMessage soapAction:(NSString*)soapAction;
-(void) sendSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction;
-(void) sendAutoSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction;
-(void) sendPhongDoSOAPRequest:(NSString*)soapMessage soapAction:(NSString*)soapAction type:(NSUInteger)type;
@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableString *soapResults;
@property(nonatomic, strong) id<SOAPHandlerDelegate> delegate;

@end
