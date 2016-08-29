//
// Please report any problems with this app template to contact@estimote.com
//

#import "ViewController.h"
#import <EstimoteSDK/EstimoteSDK.h>

static const NSInteger kTestPeriod = 10; //seconds
static const NSTimeInterval kExpectedBeaconRangePeriod = 1; //seconds
static const NSTimeInterval kAllowedBeaconRangePeroidSkew = 0.2; //seconds

@interface ViewController () <ESTSecureBeaconManagerDelegate>

@property (nonatomic, strong) ESTSecureBeaconManager *beaconManager;
@property (nonatomic, strong) NSTimer* startRangingTimer;
@property (nonatomic, strong) NSTimer* stopRangingTimer;
@property (nonatomic, strong) NSDate* lastRangeTime;

@end

@implementation ViewController

+ (NSUUID *)beaconUUID {
    // TODO: Enter the UUID of your beacons here
    return [[NSUUID alloc] initWithUUIDString:@"@"<#Beacon UUID#>""];
}

+ (NSString *)beaconRegionIdentifier {
    NSString *bundleIdentifier = [NSBundle bundleForClass:self].bundleIdentifier;
    return [NSString stringWithFormat:@"%@.%@", bundleIdentifier, @"pairing-beacon-region"];
}

+ (CLBeaconRegion *)beaconRegion {
    CLBeaconRegion *region =
    [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconUUID
                                       identifier:self.beaconRegionIdentifier];
    region.notifyEntryStateOnDisplay = YES;
    return region;
}

- (void)viewDidLoad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.beaconManager = [ESTSecureBeaconManager new];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
    [self.beaconManager startMonitoringForRegion:[self.class beaconRegion]];
}

- (void)startRanging {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.beaconManager startRangingBeaconsInRegion:[self.class beaconRegion]];
    [self stopStartRangingTimer];
    [self startStopRangingTimer];
}

- (void)stopRanging {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.beaconManager stopRangingBeaconsInRegion:[self.class beaconRegion]];
    [self stopStopRangingTimer];
    [self startStartRangingTimer];
}

- (void)startStartRangingTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.startRangingTimer) {
        self.startRangingTimer = [NSTimer scheduledTimerWithTimeInterval:kTestPeriod target:self selector:@selector(startRanging) userInfo:nil repeats:YES];
    }
}

- (void)startStopRangingTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.stopRangingTimer) {
        self.stopRangingTimer = [NSTimer scheduledTimerWithTimeInterval:kTestPeriod target:self selector:@selector(stopRanging) userInfo:nil repeats:YES];
    }
}

- (void)stopStartRangingTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.startRangingTimer) {
        [self.startRangingTimer invalidate];
        self.startRangingTimer = nil;
    }
}

- (void)stopStopRangingTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.stopRangingTimer) {
        [self.stopRangingTimer invalidate];
        self.stopRangingTimer = nil;
    }
}


- (void)beaconManager:(id)manager didRangeBeacons:(NSArray<ESTBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"didRangeBeacons: %@", beacons);
    if (self.lastRangeTime) {
        NSTimeInterval timeSinceLastRange = [[NSDate date]timeIntervalSinceDate:self.lastRangeTime];
        if (ABS(timeSinceLastRange - kExpectedBeaconRangePeriod) > kAllowedBeaconRangePeroidSkew) {
            NSLog(@"Warning: Erronous time between ranging calls! (%.2f seconds)", timeSinceLastRange);
        }
    }
    self.lastRangeTime = [NSDate date];
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self startStartRangingTimer];
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self stopRanging];
    [self stopStopRangingTimer];
    [self stopStartRangingTimer];
}

- (void)beaconManager:(id)manager didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
}

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
}

@end
