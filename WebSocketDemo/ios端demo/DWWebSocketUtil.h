//
//  DWWebSocketUtil.h
//  MOAC
//
//  Created by Dareway on 2017/9/27.
//  Copyright © 2017年 Dareway. All rights reserved.
//

#import "DWModel.h"

#define DWWebSocketOnlineNotification (@"DWWebSocketOnlineNotification")
#define DWWebSocketOnlineStatusKey (@"DWWebSocketOnlineStatusKey")
#define DWWebSocketCreateGroupSuccess (@"DWWebSocketCreateGroupSuccess")
#define DWWebSocketCreateGroupFail (@"DWWebSocketCreateGroupFail")
#define DWWebSocketSendSuccess (@"DWWebSocketSendSuccess")

@interface DWWebSocketUtil : DWModel

@property (nonatomic, assign) BOOL online;

///单例
+ (instancetype)standardWebSocketUtil;

///连接
- (void)connectWithUsername:(NSString *)username;
///断开
- (void)closeConnect;

///发送消息
- (void)sendIMMessage:(NSDictionary *)imMessage;
///创建群
- (void)createRoom:(NSString *)room;
///群成员变动
- (void)groupMemberChange:(NSString *)groupid empnolist:(NSString *)empnolist;
///解散群
- (void)deleteGroup:(NSString *)groupid;

@end
