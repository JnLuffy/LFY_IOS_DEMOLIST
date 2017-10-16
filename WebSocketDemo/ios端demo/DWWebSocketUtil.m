//
//  DWWebSocketUtil.m
//  MOAC
//
//  Created by Dareway on 2017/9/27.
//  Copyright © 2017年 Dareway. All rights reserved.
//

#import "DWWebSocketUtil.h"
#import "SRWebSocket.h"
#import "DWNetUtil+WebSocket.h"
#import "DWMD5.h"
#import "DWTopAlert.h"
#import <Reachability/Reachability.h>
#import <AudioToolbox/AudioToolbox.h>
#import <JPUSHService.h>

@interface DWWebSocketUtil () <SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *socket;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) NSString *username;

///提示框
@property (nonatomic, strong) UIWindow *topAlertWindow;
@property (nonatomic, strong) LHMessageModel *showModel;

@property (nonatomic, strong) Reachability *reachability;
@end

@implementation DWWebSocketUtil

static DWWebSocketUtil *util = nil;
+ (instancetype)standardWebSocketUtil {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[DWWebSocketUtil alloc] init];
        util.online = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:util selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
        util.reachability = [Reachability reachabilityForInternetConnection];
        [util.reachability startNotifier];
    });
    return util;
}

- (void)dealloc {
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)networkStateChange {
    if (self.socket) {
        [self closeConnect];
        pltError(@"网络变换，进行重连");
        self.online = NO;
        [self endPing];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectWithUsername:self.username];
        });
    }
}

- (void)setOnline:(BOOL)online {
    _online = online;
    [[NSNotificationCenter defaultCenter] postNotificationName:DWWebSocketOnlineNotification object:nil userInfo:@{DWWebSocketOnlineStatusKey : @(online)}];
}

///连接
- (void)connectWithUsername:(NSString *)username {
    if (DWCheckNull(username)) {
        return;
    }
    pltRight([NSString stringWithFormat:@"连接websocket:%@", DWCheckString(username)]);
    self.online = NO;
    self.username = username;
    [self closeConnect];
    
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[DWSystemConfigUtil standardUtil] supplyWebSocketUrl]]]];
    self.socket.delegate = self;
    
    [self.socket open];
}

///断开
- (void)closeConnect {
    self.online = NO;
    if (self.socket) {
        pltRight(@"断开websocket连接");
        self.socket.delegate = nil;
        [self.socket close];
    }
    [self endPing];
}

///发送消息
- (void)sendIMMessage:(NSDictionary *)imMessage {
    [self sendOperation:imMessage];
}

///创建群
- (void)createRoom:(NSString *)room {
    NSDictionary *msg = @{@"messagehead" : @"createqun",
                          @"roomname" : DWCheckString(room)};
    [self sendOperation:msg];
}

///群成员变动
- (void)groupMemberChange:(NSString *)groupid empnolist:(NSString *)empnolist {
    NSDictionary *msg = @{@"messagehead" : @"delperfromgroup",
                          @"qunid" : DWCheckString(groupid),
                          @"empnolist" : DWCheckString(empnolist)};
    [self sendOperation:msg];
}

///解散群
- (void)deleteGroup:(NSString *)groupid {
    NSDictionary *msg = @{@"messagehead" : @"disbandgroup",
                          @"qunid" : DWCheckString(groupid)};
    [self sendOperation:msg];
}

///开始心跳
- (void)startPing {
    [self endPing];
    self.timer = PltTimerCommonModes(10, self, @selector(sendPing), nil);
}

///发送心跳
- (void)sendPing {
    NSDictionary *message = @{@"messagehead" : @"heartbeat"};
    [self sendOperation:message];
}

///停止心跳
- (void)endPing {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

///发送回执
- (void)sendHzkey:(NSString *)hzkey {
    NSDictionary *param = @{@"messagehead" : @"answer",
                            @"hzkey" : DWCheckString(hzkey)};
    [self sendOperation:param];
}

///发送内容
- (void)sendOperation:(NSDictionary *)operation {
    pltWarning([NSString stringWithFormat:@"发送消息%@", operation]);
    NSData *data = [NSJSONSerialization dataWithJSONObject:operation options:NSJSONWritingPrettyPrinted error:nil];
    [self.socket send:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    pltRight(@"websocket连接成功");
    [self startPing];
    
    NSDictionary *message = @{@"messagehead" : @"logon",
                              @"empno" : DWCheckString(self.username),
                              @"resource" : @"iOS"};
    [self sendOperation:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    pltError([NSString stringWithFormat:@"websocket断开：%@", error]);
    self.online = NO;
    [self endPing];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self connectWithUsername:self.username];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    pltError([NSString stringWithFormat:@"websocket关闭：%@", reason]);
    self.online = NO;
    [self endPing];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self connectWithUsername:self.username];
    });
}


- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSDictionary *messageDic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if (messageDic == nil) {
        return;
    }
    pltRight([NSString stringWithFormat:@"收到消息：%@", messageDic]);
    NSString *emit = DWCheckString([messageDic objectForKey:@"emit"]);
    if ([emit isEqualToString:@"AlreadyLogon"]) {
        //登录成功
        self.online = YES;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([messageDic objectForKey:@"time"]) {
            long time = [[messageDic objectForKey:@"time"] longValue];
            time = [[NSDate date] timeIntervalSince1970] * 1000 - time;
            [ud setObject:@(time) forKey:@"DWWebSocketTime"];
            [ud synchronize];
        }
    } else if ([emit isEqualToString:@"liaotian"]) {
        //聊天消息
        NSString *hzkey = [messageDic objectForKey:@"hzkey"];
        if (DWCheckNull(hzkey) == YES) {
            //回执不存在，前台生成key，并发送回执，处理消息
            hzkey = [DWMD5 md5:[[NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970])] stringByAppendingString:DWCheckString([DWUserUtil currentUser].empno)]];
        } else {
            if ([[DWIMDBUtil standardDBUtil] checkHzkey:hzkey] == YES) {
                //回执已处理，发送回执，不处理消息(此时的key是在处理完消息之后，网络原因造成key没有发送)
                [self sendHzkey:hzkey];
                return;
            } else {
                //回执未处理，发送回执，处理消息
                //Do Nothing
            }
        }
        NSDictionary *messageData = messageDic[@"data"];
        //增加了groupname字段，无需请求网络或数据库查询
        [self handleFetchMessage:messageData withHzkey:hzkey];
        /*
        if ([messageData[@"type"] isEqualToString:@"group"]) {
            //群聊
            [[self class] getGroupNameWithGroupId:messageData[@"id"] success:^(NSString *groupname) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:messageData];
                [dic setObject:groupname forKey:@"groupname"];
                [self handleFetchMessage:dic withHzkey:hzkey];
            }];
        } else {
            //单聊
            [self handleFetchMessage:messageData withHzkey:hzkey];
        }
         */
    } else if ([emit isEqualToString:@"delperfromgroup"]) {
        //有人退出群
        NSString *groupId = [NSString stringWithFormat:@"%@", DWCheckString(messageDic[@"qunid"])];
        NSString *empnolist = DWCheckString(messageDic[@"empnolist"]);
        if ([DWVCManager sharedManager].imVC &&
            [[DWVCManager sharedManager].imVC.presenter.chatId isEqualToString:groupId]) {
            [[DWVCManager sharedManager].imVC memberQuit:empnolist];
        }
    } else if ([emit isEqualToString:@"disbandgroup"]) {
        //群被解散
        NSString *groupId = [NSString stringWithFormat:@"%@", DWCheckString(messageDic[@"qunid"])];
        if ([DWVCManager sharedManager].imVC &&
            [[DWVCManager sharedManager].imVC.presenter.chatId isEqualToString:groupId]) {
            [[DWVCManager sharedManager].imVC groupDismiss];
        }
    } else if ([emit isEqualToString:@"createqun"]) {
        //创建群结果
        NSString *result = DWCheckString(messageDic[@"result"]);
        PltLast(^{
            if ([result isEqualToString:@"success"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:DWWebSocketCreateGroupSuccess object:nil userInfo:@{DWWebSocketCreateGroupSuccess : DWCheckString(messageDic[@"roomname"])}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:DWWebSocketCreateGroupFail object:nil userInfo:nil];
            }
        });
    } else if ([emit isEqualToString:@"clientreply"]) {
        ///发送消息成功
        NSString *clhzkey = DWCheckString(messageDic[@"clhzkey"]);
        PltLast(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DWWebSocketSendSuccess object:nil userInfo:@{DWWebSocketSendSuccess : clhzkey}];
            [[DWIMDBUtil standardDBUtil] updateSendStateWithClhzkey:clhzkey messageState:MessageDeliveryState_Delivered];
        });
    }
}

///处理接收消息
- (void)handleFetchMessage:(NSDictionary *)messageData withHzkey:(NSString *)hzkey {
    BOOL voiceAndShake = YES;
    
    LHMessageModel *messageModel = [LHMessageModel coversionToModel:messageData withHzkey:hzkey];
    messageModel.status = MessageDeliveryState_Delivered;
    if (messageModel == nil) {
        return;
    }
    if ([DWVCManager sharedManager].imVC && [[DWVCManager sharedManager].imVC.presenter.chatId isEqualToString:messageModel.chatId]) {
        messageModel.isRead = YES;
        [[DWIMDBUtil standardDBUtil] saveMessage:messageModel];
        [[DWVCManager sharedManager].imVC.presenter fetchMessage:messageModel];
    } else {
        if (messageModel.isSender == YES) {
            ///收到自己从电脑上发来的消息
            messageModel.isRead = YES;
            [[DWIMDBUtil standardDBUtil] saveMessage:messageModel];
            
            voiceAndShake = NO;
        } else {
            messageModel.isRead = NO;
            [[DWIMDBUtil standardDBUtil] saveMessage:messageModel];
            //展示提示框
            [self showTopAlert:messageModel];
        }
        
        //发出未读消息通知
        PltLast(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DWChatUnreadChangeNoti object:nil];
        });
    }
    
    if (voiceAndShake == YES) {
        [self playVoiceAndShake];
    }
    
    //发送回执
    [self sendHzkey:hzkey];
}


#pragma mark - 弹框

- (void)showTopAlert:(LHMessageModel *)model {
    [self hideTopAlertWithAnimation:NO];
    self.topAlertWindow = [[DWTopAlert alloc] initWithTitle:DWCheckString(model.chatName) subTitle:[model getMessageShowStr]];
    [UIView animateWithDuration:0.75 animations:^{
        self.topAlertWindow.frame = CGRectMake(0, 0, self.topAlertWindow.plt_width, self.topAlertWindow.plt_height);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideTopAlertWithAnimation:YES];
    });
    self.showModel = model;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChatVC:)];
    [self.topAlertWindow addGestureRecognizer:tap];
}

- (void)hideTopAlertWithAnimation:(BOOL)animation {
    if (self.topAlertWindow) {
        if (animation) {
            NSTimeInterval time = animation == YES ? 0.75 : 0;
            [UIView animateWithDuration:time animations:^{
                self.topAlertWindow.frame = CGRectMake(self.topAlertWindow.plt_x, -self.topAlertWindow.plt_height, self.topAlertWindow.plt_width, self.topAlertWindow.plt_height);
            } completion:^(BOOL finished) {
                [self.topAlertWindow resignKeyWindow];
                self.topAlertWindow = nil;
            }];
        } else {
            [self.topAlertWindow resignKeyWindow];
            self.topAlertWindow = nil;
        }
    }
}

- (void)showChatVC:(UITapGestureRecognizer *)gr {
    [self hideTopAlertWithAnimation:NO];
    if ([DWVCManager sharedManager].imVC) {
        if ([DWVCManager sharedManager].imVC.presentedViewController) {
            [[DWVCManager sharedManager].imVC.presentedViewController dismissViewControllerAnimated:NO completion:^{
                [[DWVCManager sharedManager].imVC dismissViewControllerAnimated:NO completion:^{
                    [self showNewChatWithAnimation:NO];
                }];
            }];
        } else {
            [[DWVCManager sharedManager].imVC dismissViewControllerAnimated:NO completion:^{
                [self showNewChatWithAnimation:NO];
            }];
        }
    } else {
        [self showNewChatWithAnimation:YES];
    }
    
}

- (void)showNewChatWithAnimation:(BOOL)animation {
    if ([DWVCManager sharedManager].tabBarController) {
        if ([DWVCManager sharedManager].tabBarController.presentedViewController) {
            [[DWVCManager sharedManager].tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                DWNavigationController *nc = [DWIMVC imNavigationControllerWithChatId:self.showModel.chatId chatName:self.showModel.chatName chatAvatar:self.showModel.chatAvatar groupChat:self.showModel.isChatGroup];
                [[DWVCManager sharedManager].tabBarController presentViewController:nc animated:animation completion:nil];
            }];
        } else {
            DWNavigationController *nc = [DWIMVC imNavigationControllerWithChatId:self.showModel.chatId chatName:self.showModel.chatName chatAvatar:self.showModel.chatAvatar groupChat:self.showModel.isChatGroup];
            [[DWVCManager sharedManager].tabBarController presentViewController:nc animated:animation completion:nil];
        }
    }
}

#pragma mark - 获取名称
+ (void)getGroupNameWithGroupId:(NSString *)groupId success:(void(^)(NSString *groupname))success {
    if (success) {
        NSString *groupname = [[DWIMDBUtil standardDBUtil] selectGroupNameWithChatId:groupId];
        if (groupname) {
            //数据库中有保存
            success(groupname);
        } else {
            //网络查询
            [DWNetUtil getGroupnameWithGroupId:groupId success:^(NSString *groupname) {
                success(groupname);
            }];
        }
    }
}


#pragma mark - 播放声音和震动
- (void)playVoiceAndShake {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"msgTritone" ofType:@"caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
