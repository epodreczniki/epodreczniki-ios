







#import <Foundation/Foundation.h>
#import "EPNoteLocation.h"

@interface EPNotesUtil : EPConfigurableObject

- (EPNoteLocation*) locationFromJson:(NSString*)json;

@end
