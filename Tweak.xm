static NSString *const identifier = @"com.dgh0st.reachoffset";
static NSString *const kIsEnabled = @"isEnabled";
static NSString *const kYOffSet = @"y";
static NSString *const kTapsRequired = @"taps";
static NSString *const kMaxInterval = @"interval";
static NSString *const kKeepAlive = @"keepAlive";
static NSString *const kOffsetChange =  @"offsetChange";
static NSString *const kIsYEnabled = @"isOffsetEnabled";
static NSString *const kIsTapsEnabled = @"isTapsEnabled";
static NSString *const kIsMaxIntervalEnabled = @"isIntervalEnabled";
static NSString *const kIsTimeOffsetEnabled = @"isTimeOffsetEnabled";
static NSString *const kIsReverseTimeEnabled = @"isReverseTimeEnabled";
static NSString *const kIsKeepAliveEnabled = @"isKeepAliveEnabled";
static NSString *const kIsKeepAliveUnlimited = @"isKeepAliveUnlimited";
static NSString *const kIsOffsetChanging = @"isOffsetChanging";

static CGFloat origOffset = 0.5f;
static CGFloat yOffset = 0.5f;
static CGFloat maxInterval = 0.75f;

static void PreferencesChanged() {
	CFPreferencesAppSynchronize(CFSTR("com.dgh0st.reachoffset"));
}

static BOOL boolValueForKey(NSString *key){
	NSNumber *result = (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	BOOL temp = result ? [result boolValue] : NO;
	[result release];
	return temp;
}

static CGFloat doubleValueForKey(NSString *key, CGFloat defaultValue){
	NSNumber *result = (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	CGFloat temp = result ? [result doubleValue] : defaultValue;
	[result release];
	return temp;
}

static NSInteger intValueForKey(NSString *key, NSInteger defaultValue){
	NSNumber *result= (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	NSInteger temp = result ? [result intValue] : defaultValue;
	[result release];
	return temp;
}

%hook SBReachabilitySettings
-(NSInteger)numberOfTapsForTapTrigger{
	if(boolValueForKey(kIsEnabled) && boolValueForKey(kIsTapsEnabled)){
		return intValueForKey(kTapsRequired, 2);
	}
	return %orig;
}
-(CGFloat)yOffsetFactor{
	if(boolValueForKey(kIsEnabled)){
		if(boolValueForKey(kIsYEnabled)){
			if(origOffset != doubleValueForKey(kYOffSet, 0.5f)){
				yOffset = doubleValueForKey(kYOffSet, 0.5f);
				origOffset = yOffset;
			}
		}
		if(yOffset < 0.0f){
			yOffset = 0.1f;
		} else if(yOffset > 1.0f){
			yOffset = 0.9f;
		}
		return yOffset;
	}
	return %orig;
}
-(CGFloat)tapToTapMaxInterval{
	maxInterval = %orig;
	if(boolValueForKey(kIsEnabled) && boolValueForKey(kIsMaxIntervalEnabled)){
		maxInterval = doubleValueForKey(kMaxInterval, 1.0f);
	}
	return maxInterval;
}
-(CGFloat)reachabilityInteractiveKeepAlive{
	if(boolValueForKey(kIsEnabled) && boolValueForKey(kIsKeepAliveEnabled)){
		return boolValueForKey(kIsKeepAliveUnlimited) ? MAXFLOAT : doubleValueForKey(kKeepAlive, 5.0f);
	}
	return %orig;
}
-(CGFloat)reachabilityDefaultKeepAlive{
	if(boolValueForKey(kIsEnabled) && boolValueForKey(kIsKeepAliveEnabled)){
		return boolValueForKey(kIsKeepAliveUnlimited) ? MAXFLOAT : doubleValueForKey(kKeepAlive, 5.0f);
	}
	return %orig;
}
%end

%hook SBReachabilityManager
+(BOOL)reachabilitySupported{
	return YES;
}
-(void)_toggleReachabilityModeWithRequestingObserver:(id)arg1 {
	if(boolValueForKey(kIsEnabled) && boolValueForKey(kIsOffsetChanging)){
		yOffset += doubleValueForKey(kOffsetChange, 0.05);
		if(yOffset > 1.0f){
			yOffset -= 1.0f;
		}
	}
	%orig;
}
-(void)triggerDidTriggerReachability:(id)arg1 {
	if(boolValueForKey(kIsEnabled) && boolValueForKey(kIsTimeOffsetEnabled)){
		NSTimeInterval interval;
		NSTimer *timer;
		if([[[arg1 class] description] isEqual:@"SBReachabilityTapTrigger"]){
			timer = MSHookIvar<NSTimer *>(arg1, "_tapToTapExpirationTimer");
		} else {
			timer = MSHookIvar<NSTimer *>(arg1, "_fingerOnMesaTimer");
		}
		interval = [[timer fireDate] timeIntervalSinceNow];
		if(interval < 0.0f){
			interval *= -1;
		} else if(interval == 0.0f){
			interval = yOffset * maxInterval;
		}
		if(boolValueForKey(kIsReverseTimeEnabled)){
			interval = maxInterval - interval;
		}
		yOffset = interval/maxInterval;
	}
	%orig;
}
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
				    NULL,
				    (CFNotificationCallback)PreferencesChanged,
				    CFSTR("com.dgh0st.reachoffset/settingschanged"),
				    NULL,
				    CFNotificationSuspensionBehaviorDeliverImmediately);
}
