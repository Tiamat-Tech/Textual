/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2008 - 2010 Satoshi Nakagawa <psychs AT limechat DOT net>
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

NS_ASSUME_NONNULL_BEGIN

#define TXKeyReturnCode			0x24
#define TXKeyTabCode			0x30
#define TXKeySpacebarCode		0x31
#define TXKeyBackspaceCode		0x33
#define TXKeyEscapeCode			0x35
#define TXKeyEnterCode			0x4C
#define TXKeyHomeCode			0x73
#define TXKeyPageUpCode			0x74
#define TXKeyDeleteCode			0x75
#define TXKeyEndCode			0x77
#define TXKeyPageDownCode		0x79
#define TXKeyLeftArrowCode		0x7B
#define TXKeyRightArrowCode		0x7C
#define TXKeyDownArrowCode		0x7D
#define TXKeyUpArrowCode		0x7E

@protocol TLOKeyEventHandlerPrototype <NSObject>
@optional
- (void)setKeyHandlerTarget:(id)target;

- (void)registerSelector:(SEL)selector key:(NSUInteger)keyCode modifiers:(NSUInteger)modifiers;
- (void)registerSelector:(SEL)selector character:(UniChar)character modifiers:(NSUInteger)modifiers;
- (void)registerSelector:(SEL)selector characters:(NSRange)characterRange modifiers:(NSUInteger)modifiers;
@end

@interface TLOKeyEventHandler : NSObject <TLOKeyEventHandlerPrototype>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTarget:(id)target NS_DESIGNATED_INITIALIZER;

- (BOOL)processKeyEvent:(NSEvent *)event;
@end

NS_ASSUME_NONNULL_END
