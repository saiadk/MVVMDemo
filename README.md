# RSS Feeds Demo


This application downloads and displays "top 50 iOS Apps" feeds from iTunes RSS API.

This sample code uses the following things:

1. Collection view in list / grid layout. Allows to switch without reloading entire collection view.

2. Downloads feed's artwork image asynchrously in background mode with URLSession's downloadTask / dataTask API.

3. Allow user to refresh the feeds with a refresh bar button item on left.

3. Maintains a cache to store images downloaded with URL as key and uses already downloaded images from cache instead of downloading everytime.

4. Uses new Codable protocol for JSON parsing and creating model objects.

5. Uses MVVM architecture pattern. Also uses other patterns viz. Delegation, Singleton.

6. Uses ProtocolExtensions in creating request generator types.

7. Created 2 reusable components NetworkManager and ImageDownloadOperation.

8. Unit tests view model objects.

9. Used clsorues, value types, reference types, extensions, trailing closures, compositions.





