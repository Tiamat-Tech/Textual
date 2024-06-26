/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2017, 2018 Codeux Software, LLC & respective contributors.
 *       Please see Acknowledgements.pdf for additional information.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Textual, "Codeux Software, LLC", nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

NS_ASSUME_NONNULL_BEGIN

@interface RCMProcessMain ()
@property (nonatomic, strong) IRCConnection *connection;
@property (nonatomic, strong) NSXPCConnection *serviceConnection;
@end

@implementation RCMProcessMain

- (instancetype)init
{
	[self doesNotRecognizeSelector:_cmd];

	return nil;
}

- (instancetype)initWithXPCConnection:(NSXPCConnection *)connection
{
	NSParameterAssert(connection != nil);

	if ((self = [super init])) {
		self.serviceConnection = connection;

		LogToConsoleSetDefaultSubsystemToMainBundle(@"General");

		return self;
	}

	return nil;
}

#pragma mark -
#pragma mark XPC Interface

- (void)openWithConfig:(IRCConnectionConfig *)config
{
	NSAssert((self.connection == nil),
		 @"Method invoked with connection already open");

	IRCConnection *connection = [[IRCConnection alloc] initWithConfig:config onConnection:self.serviceConnection];

	[connection open];

	self.connection = connection;
}

- (void)close
{
	NSAssert((self.connection != nil),
		 @"Method invoked without performing setup first");

	[self.connection close];
}

- (void)sendData:(NSData *)data
{
	[self sendData:data bypassQueue:NO];
}

- (void)sendData:(NSData *)data bypassQueue:(BOOL)bypassQueue
{
	NSAssert((self.connection != nil),
		 @"Method invoked without performing setup first");

	[self.connection sendData:data bypassQueue:bypassQueue];
}

- (void)exportSecureConnectionInformation:(NS_NOESCAPE RCMSecureConnectionInformationCompletionBlock)completionBlock
{
	NSAssert((self.connection != nil),
		 @"Method invoked without performing setup first");

	[self.connection exportSecureConnectionInformation:completionBlock error:NULL];
}

- (void)enforceFloodControl
{
	NSAssert((self.connection != nil),
		 @"Method invoked without performing setup first");

	[self.connection enforceFloodControl];
}

- (void)clearSendQueue
{
	NSAssert((self.connection != nil),
		 @"Method invoked without performing setup first");

	[self.connection clearSendQueue];
}

- (void)enableAppNap
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NSAppSleepDisabled" : @(NO)}];
}

- (void)disableAppNap
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NSAppSleepDisabled" : @(YES)}];
}

- (void)enableSuddenTermination
{
	[[NSProcessInfo processInfo] enableSuddenTermination];
}

- (void)disableSuddenTermination
{
	[[NSProcessInfo processInfo] disableSuddenTermination];
}

@end

NS_ASSUME_NONNULL_END
