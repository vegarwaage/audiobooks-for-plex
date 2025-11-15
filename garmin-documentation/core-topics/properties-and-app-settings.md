# Properties and App Settings - Connect IQ Documentation

## Overview

The Properties and App Settings system in Connect IQ enables developers to store and manage application configuration, user preferences, and persistent data across app sessions.

## Key Features

- **User Preferences**: Store customizable settings that users can modify
- **App Configuration**: Maintain application-level settings
- **Data Persistence**: Retain information between app launches
- **Device Compatibility**: Works across compatible Garmin devices

## Implementation Approaches

### Properties System
Properties allow your application to maintain state and user preferences. These persist on the device and survive app restarts.

### App Settings
Settings provide a framework for users to customize app behavior through configuration interfaces available on compatible devices or through companion mobile apps.

## Storage Considerations

- Data persists in device storage
- Settings survive app updates (in most cases)
- Users can reset or modify settings through device interfaces
- Companion apps may offer additional configuration options

## Best Practices

1. **Sensible Defaults**: Provide reasonable default values for all settings
2. **Clear Organization**: Group related settings logically
3. **User Control**: Allow users to modify settings easily
4. **Documentation**: Clearly explain what each setting controls
5. **Performance**: Minimize frequent read/write operations to storage

## Integration Points

- Mobile SDK (Android/iOS) for remote configuration
- Device settings interfaces
- Companion app controls
- Web service integration for cloud-based preferences

## Related Topics

- [Persisting Data](/connect-iq/core-topics/persisting-data/)
- [Application and System Modules](/connect-iq/core-topics/application-and-system-modules/)
- [Communicating with Mobile Apps](/connect-iq/core-topics/communicating-with-mobile-apps/)
