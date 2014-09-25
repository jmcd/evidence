#import "ConventionalDateFormatter.h"
#import "Evidence.h"
#import "Notifications.h"

@implementation Notifications {
}
+ (void)scheduleNotificationForEvidence:(Evidence *)evidence {
    NSNumber *delayInMinutes = (NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationDelay"];
    NSTimeInterval delay = delayInMinutes.integerValue * 60;

    NSDate *createdOnDateTime = evidence.createdOnDateTime;
    NSDate *fireDate = [createdOnDateTime dateByAddingTimeInterval:delay];

    ConventionalDateFormatter *conventionalDateFormatter = [[ConventionalDateFormatter alloc] init];
    NSString *alertBody = [NSString stringWithFormat:@"%@. %@", evidence.type, [conventionalDateFormatter longStringFromDate:evidence.createdOnDateTime]];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.alertBody = alertBody;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{@"objectID" : ((NSManagedObject *) evidence).objectID.URIRepresentation.absoluteString};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
@end