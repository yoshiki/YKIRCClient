#import <XCTest/XCTest.h>
#import "YKIRCMessage.h"

@interface YKIRCMessageTests : XCTestCase

@end

@implementation YKIRCMessageTests

- (void)testParseJoinMessage
{
    NSString *rawMessage = @":nick!~username@server JOIN :#test";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNotNil(message.user);
    XCTAssertNil(message.sender);
    XCTAssertEqualObjects(message.user.nick, @"nick");
    XCTAssertEqualObjects(message.user.name, @"username");
    XCTAssertEqualObjects(message.user.server, @"server");
    XCTAssertEqual(message.type, YKIRCMessageTypeJoin);
    XCTAssertEqualObjects(message.trail, @"#test");
}

- (void)testParsePartMessage
{
    NSString *rawMessage = @":nick!~username@server PART #test :Leaving...";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNotNil(message.user);
    XCTAssertNil(message.sender);
    XCTAssertEqualObjects(message.user.nick, @"nick");
    XCTAssertEqualObjects(message.user.name, @"username");
    XCTAssertEqualObjects(message.user.server, @"server");
    XCTAssertEqual(message.type, YKIRCMessageTypePart);
    XCTAssertEqualObjects(message.params[0], @"#test");
    XCTAssertEqualObjects(message.trail, @"Leaving...");
}

- (void)testPingMessage
{
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:@"PING 0"];
    XCTAssertNil(message.user);
    XCTAssertNil(message.sender);
    XCTAssertEqual(message.type, YKIRCMessageTypePing);
    XCTAssertEqualObjects(message.params[0], @"0");
}

- (void)testPrivateMessageForChannel
{
    NSString *rawMessage = @":nick!~username@server PRIVMSG #test :this is message";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNotNil(message.user);
    XCTAssertNil(message.sender);
    XCTAssertEqualObjects(message.user.nick, @"nick");
    XCTAssertEqualObjects(message.user.name, @"username");
    XCTAssertEqualObjects(message.user.server, @"server");
    XCTAssertEqual(message.type, YKIRCMessageTypePrivMsg);
    XCTAssertEqualObjects(message.params[0], @"#test");
    XCTAssertEqualObjects(message.trail, @"this is message");
}

- (void)testPrivateMessageForPrivate
{
    NSString *rawMessage = @":nick!~username@server PRIVMSG you :this is message";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNotNil(message.user);
    XCTAssertNil(message.sender);
    XCTAssertEqualObjects(message.user.nick, @"nick");
    XCTAssertEqualObjects(message.user.name, @"username");
    XCTAssertEqualObjects(message.user.server, @"server");
    XCTAssertEqual(message.type, YKIRCMessageTypePrivMsg);
    XCTAssertEqualObjects(message.params[0], @"you");
    XCTAssertEqualObjects(message.trail, @"this is message");
}

- (void)testNoticeMessageSimple
{
    NSString *rawMessage = @":sender NOTICE #channel :this is message";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNil(message.user);
    XCTAssertNotNil(message.sender);
    XCTAssertEqual(message.type, YKIRCMessageTypeNotice);
    XCTAssertEqualObjects(message.params[0], @"#channel");
    XCTAssertEqualObjects(message.trail, @"this is message");
}

- (void)testNoticeMessageNoPrefix
{
    NSString *rawMessage = @"NOTICE nick :this is message";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNil(message.user);
    XCTAssertEqual(message.type, YKIRCMessageTypeNotice);
    XCTAssertEqualObjects(message.params[0], @"nick");
    XCTAssertEqualObjects(message.trail, @"this is message");
}

- (void)testNumericalCommandMessage
{
    NSString *rawMessage = @":sender 999 nick :this is message";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNil(message.user);
    XCTAssertNotNil(message.self);
    XCTAssertEqual(message.type, YKIRCMessageTypeNumeric);
    XCTAssertEqualObjects(message.params[0], @"nick");
    XCTAssertEqualObjects(message.trail, @"this is message");
}

- (void)testUnknownCommandMessage
{
    NSString *rawMessage = @":sender UNKNOWN nick :this is message";
    YKIRCMessage *message = [[YKIRCMessage alloc] initWithMessage:rawMessage];
    XCTAssertNil(message.user);
    XCTAssertNotNil(message.self);
    XCTAssertEqual(message.type, YKIRCMessageTypeUnknown);
    XCTAssertEqualObjects(message.params[0], @"nick");
    XCTAssertEqualObjects(message.trail, @"this is message");
}

// :tiarra 001 clouder :Welcome to the Internet Relay Network clouder!username@203.104.128.122
// :tiarra 002 clouder :Your host is tiarra, running version 0.1+svn-38663M
// :tiarra 375 clouder :- tiarra Message of the Day -
// :tiarra 372 clouder :- - T i a r r a - :::version #0.1+svn-38663M:::
// :tiarra 372 clouder :- Copyright (c) 2008 Tiarra Development Team. All rights reserved.
// :tiarra 376 clouder :End of MOTD command.

// :tiarra 332 clouder #shibuya.pm@freenode :no Perl; use x86; # http://shibuya.pm.org/blosxom/techtalks/200904.html
// :tiarra 333 clouder #shibuya.pm@freenode fujiwara_______2!~fujiwara@49.212.134.220 1391402511
// :tiarra 353 clouder @ #shibuya.pm@freenode :junichiro_ cho46 hio_hp___
// :tiarra 366 clouder #shibuya.pm@freenode :End of NAMES list

@end
