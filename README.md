MPNotificationView
==================

An in-app notification view that mimics the iOS 6 notification views which appear above the status bar

###Features:

- Animation and layout similar to iOS 6 notifications
- Provides two `UILabels` and an `UIImageView`
- Simple API
- Enqueues multiple notifications and shows them with a default duration of 2 seconds.

###Screenshot:
![Example notification](https://dl.dropbox.com/u/361895/grumpy.png "Example Notification")



###Usage:

Simply use the following call to show a message and related detail text:

````
    [MPNotificationView notifyWithText:@"Grumpy wizards" andDetail:@"make a toxic brew for the jovial queen"];`
````

Or use the following call to add a thumbnail image and customize duration:

````
    [MPNotificationView notifyWithText:@"Moped Dog:"
                                detail:@"I have no idea what I'm doing..."
                                 image:[UIImage imageNamed:@"mopedDog.jpeg"]
                           andDuration:5.0];
````

###License:

Copyright (c) 2013 Engin Kurutepe - Moped Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
