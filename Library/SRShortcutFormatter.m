//
//  Copyright 2019 ShortcutRecorder Contributors
//  CC BY 3.0
//

#import "SRShortcutFormatter.h"
#import "SRShortcut.h"
#import "SRKeyCodeTransformer.h"
#import "SRModifierFlagsTransformer.h"


@implementation SRShortcutFormatter

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        _isKeyCodeLiteral = YES;
        _usesASCIICapableKeyboardInputSource = YES;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self)
    {
        _isKeyCodeLiteral = YES;
        _usesASCIICapableKeyboardInputSource = YES;
    }

    return self;
}

#pragma mark NSFormatter

- (NSString *)stringForObjectValue:(SRShortcut *)aShortcut
{
    if (![aShortcut isKindOfClass:SRShortcut.class])
        return nil;

    SRKeyCodeTransformer *keyTransformer = nil;

    if (self.isKeyCodeLiteral && self.usesASCIICapableKeyboardInputSource)
        keyTransformer = SRKeyCodeTransformer.sharedLiteralASCIITransformer;
    else if (self.isKeyCodeLiteral)
        keyTransformer = SRKeyCodeTransformer.sharedLiteralTransformer;
    else if (self.usesASCIICapableKeyboardInputSource)
        keyTransformer = SRKeyCodeTransformer.sharedSymbolicASCIITransformer;
    else
        keyTransformer = SRKeyCodeTransformer.sharedSymbolicTransformer;

    SRModifierFlagsTransformer *flagsTransformer = nil;

    if (self.areModifierFlagsLiteral)
        flagsTransformer = SRLiteralModifierFlagsTransformer.sharedTransformer;
    else
        flagsTransformer = SRSymbolicModifierFlagsTransformer.sharedTransformer;

    NSString *key = [keyTransformer transformedValue:@(aShortcut.keyCode)
                           withImplicitModifierFlags:nil
                               explicitModifierFlags:@(aShortcut.modifierFlags)];
    NSString *flags = [flagsTransformer transformedValue:@(aShortcut.modifierFlags)];
    return [NSString stringWithFormat:@"%@%@", flags, key];
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing _Nullable *)error
{
    return NO;
}

@end
