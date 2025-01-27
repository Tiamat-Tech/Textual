/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2010 - 2018 Codeux Software, LLC & respective contributors.
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

#import "GCDAsyncSocketExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GCDAsyncSocket (GCDsyncSocketExtensions)

+ (instancetype)socketWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq socketQueue:(dispatch_queue_t)sq
{
	return [[self alloc] initWithDelegate:aDelegate delegateQueue:dq socketQueue:sq];
}

- (tls_protocol_version_t)tlsNegotiatedProtocol
{
	__block SSLProtocol protocol;

	dispatch_block_t block = ^{
TEXTUAL_IGNORE_DEPRECATION_BEGIN
		OSStatus status = SSLGetNegotiatedProtocolVersion(self.sslContext, &protocol);
TEXTUAL_IGNORE_DEPRECATION_END

#pragma unused(status)
	};

	[self performBlock:block];

	return [RCMSecureTransport protocolTypeFromDeprecated:protocol];
}

- (tls_ciphersuite_t)tlsNegotiatedCipherSuite
{
	__block SSLCipherSuite cipher;

	dispatch_block_t block = ^{
TEXTUAL_IGNORE_DEPRECATION_BEGIN
		OSStatus status = SSLGetNegotiatedCipher(self.sslContext, &cipher);
TEXTUAL_IGNORE_DEPRECATION_END

#pragma unused(status)
	};

	[self performBlock:block];

	/* This can be easily cast because they refer to the same code points. */
	return (tls_ciphersuite_t)cipher;
}

- (SecTrustRef)tlsTrustRef
{
	__block SecTrustRef trust;

	dispatch_block_t block = ^{
TEXTUAL_IGNORE_DEPRECATION_BEGIN
		OSStatus status = SSLCopyPeerTrust(self.sslContext, &trust);
TEXTUAL_IGNORE_DEPRECATION_END

#pragma unused(status)
	};

	[self performBlock:block];

	return trust;
}

- (nullable NSArray<NSData *> *)tlsCertificateChainData
{
	SecTrustRef trustRef = self.tlsTrustRef;

	if (trustRef == NULL) {
		return nil;
	}

	return [RCMSecureTransport certificatesInTrust:trustRef];
}

- (nullable NSString *)tlsPolicyName
{
	SecTrustRef trustRef = self.tlsTrustRef;

	if (trustRef == NULL) {
		return nil;
	}

	return [RCMSecureTransport policyNameInTrust:trustRef];
}

@end

NS_ASSUME_NONNULL_END
