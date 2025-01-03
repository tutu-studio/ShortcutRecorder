//
//  Copyright 2012 ShortcutRecorder Contributors
//  CC BY 4.0
//

#import <os/log.h>

#import "ShortcutRecorder/SRCommon.h"

#import "ShortcutRecorder/SRModifierFlagsTransformer.h"


@implementation SRModifierFlagsTransformer

- (id)init
{
    if (self.class == SRModifierFlagsTransformer.class)
        return (id)SRSymbolicModifierFlagsTransformer.sharedTransformer;
    else
        return [super init];
}

+ (id)sharedTransformer
{
    return SRSymbolicModifierFlagsTransformer.sharedTransformer;
}

+ (Class)transformedValueClass
{
    return NSString.class;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (NSString *)transformedValue:(NSNumber *)aValue layoutDirection:(NSUserInterfaceLayoutDirection)aDirection
{
    return nil;
}

- (id)transformedValue:(id)aValue
{
    return [self transformedValue:aValue layoutDirection:NSUserInterfaceLayoutDirectionLeftToRight];
}

@end


@implementation SRLiteralModifierFlagsTransformer

+ (SRLiteralModifierFlagsTransformer *)sharedTransformer
{
    static dispatch_once_t OnceToken;
    static SRLiteralModifierFlagsTransformer *Transformer = nil;
    dispatch_once(&OnceToken, ^{
        Transformer = [SRLiteralModifierFlagsTransformer new];
    });
    return Transformer;
}

#pragma mark NSValueTransformer

- (NSString *)transformedValue:(NSNumber *)aValue layoutDirection:(NSUserInterfaceLayoutDirection)aDirection
{
    if (![aValue isKindOfClass:NSNumber.class])
    {
        os_log_error(OS_LOG_DEFAULT, "#Error Invalid value for transformation");
        return nil;
    }

    NSEventModifierFlags flags = aValue.unsignedIntegerValue;
    NSMutableArray<NSString *> *flagsStringComponents = NSMutableArray.array;

    if (flags & NSEventModifierFlagControl)
        [flagsStringComponents addObject:SRLoc(@"Control")];

    if (flags & NSEventModifierFlagOption)
        [flagsStringComponents addObject:SRLoc(@"Option")];

    if (flags & NSEventModifierFlagShift)
        [flagsStringComponents addObject:SRLoc(@"Shift")];

    if (flags & NSEventModifierFlagCommand)
        [flagsStringComponents addObject:SRLoc(@"Command")];

    if (aDirection == NSUserInterfaceLayoutDirectionRightToLeft)
        return [[[flagsStringComponents reverseObjectEnumerator] allObjects] componentsJoinedByString:SRLoc(@"-")];
    else
        return [flagsStringComponents componentsJoinedByString:SRLoc(@"-")];
}

@end


@implementation SRSymbolicModifierFlagsTransformer

+ (SRSymbolicModifierFlagsTransformer *)sharedTransformer
{
    static dispatch_once_t OnceToken;
    static SRSymbolicModifierFlagsTransformer *Transformer = nil;
    dispatch_once(&OnceToken, ^{
        Transformer = [SRSymbolicModifierFlagsTransformer new];
    });
    return Transformer;
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (NSString *)transformedValue:(NSNumber *)aValue layoutDirection:(NSUserInterfaceLayoutDirection)aDirection
{
    if (![aValue isKindOfClass:NSNumber.class])
    {
        os_log_error(OS_LOG_DEFAULT, "#Error Invalid value for transformation");
        return nil;
    }

    NSEventModifierFlags flags = aValue.unsignedIntegerValue;
    NSMutableArray<NSString *> *flagsStringFragments = NSMutableArray.array;

    if (flags & NSEventModifierFlagControl)
        [flagsStringFragments addObject:SRModifierFlagStringControl];

    if (flags & NSEventModifierFlagOption)
        [flagsStringFragments addObject:SRModifierFlagStringOption];

    if (flags & NSEventModifierFlagShift)
        [flagsStringFragments addObject:SRModifierFlagStringShift];

    if (flags & NSEventModifierFlagCommand)
        [flagsStringFragments addObject:SRModifierFlagStringCommand];

    if (aDirection == NSUserInterfaceLayoutDirectionRightToLeft)
        return [[[flagsStringFragments reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    else
        return [flagsStringFragments componentsJoinedByString:@""];
}

- (NSNumber *)reverseTransformedValue:(NSString *)aValue
{
    if (![aValue isKindOfClass:NSString.class])
    {
        os_log_error(OS_LOG_DEFAULT, "#Error Invalid value for reverse transformation");
        return nil;
    }

    __block NSEventModifierFlags flags = 0;
    __block BOOL foundInvalidSubstring = NO;

    [aValue enumerateSubstringsInRange:NSMakeRange(0, aValue.length)
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
    {
        if ([substring isEqualToString:SRModifierFlagStringControl] && (flags & NSEventModifierFlagControl) == 0)
            flags |= NSEventModifierFlagControl;
        else if ([substring isEqualToString:SRModifierFlagStringOption] && (flags & NSEventModifierFlagOption) == 0)
            flags |= NSEventModifierFlagOption;
        else if ([substring isEqualToString:SRModifierFlagStringShift] && (flags & NSEventModifierFlagShift) == 0)
            flags |= NSEventModifierFlagShift;
        else if ([substring isEqualToString:SRModifierFlagStringCommand] && (flags & NSEventModifierFlagCommand) == 0)
            flags |= NSEventModifierFlagCommand;
        else
        {
            foundInvalidSubstring = YES;
            *stop = YES;
        }
    }];

    if (foundInvalidSubstring)
    {
        os_log_error(OS_LOG_DEFAULT, "#Error Invalid value for reverse transformation");
        return nil;
    }

    return @(flags);
}

@end
