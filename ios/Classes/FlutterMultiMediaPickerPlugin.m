#import "FlutterMultiMediaPickerPlugin.h"
#import <flutter_multimedia_picker/flutter_multimedia_picker-Swift.h>

@implementation FlutterMultiMediaPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMultiMediaPickerPlugin registerWithRegistrar:registrar];
}
@end
