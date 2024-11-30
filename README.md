# Campus Dual Helper
Campus Dual Helper is an App designed to provide an alternative Interface to the Campus Dual web application. To achieve this, it uses Api Endpoints or just scrapes the website and parses it to get the necessary data.

<a href='https://play.google.com/store/apps/details?id=net.fabianschuster.campus_dual_android&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width="300"/></a>

# Important
This application gets the informations by impersonating the user and scraping the data from the official websites. Due to the nature of scraping, there could be (and probably are) a lot of edge cases I haven't considered while writing this scraper. So keep in mind that bugs could occur, and if they do so, please write an Github issue for it.

> Maintainer wanted: As i am currently in my 5th Semester I cannot maintain this scraper indefinitely, because my access to campus-dual may be cut off. So, if you are interested, please reach out to me.

# Prerequisites
- Flutter
- Some Android tools (Check flutter documentation)

# Installation
The newest Release can be found in the releases section of this repository. Simply download the apk and install it.

## Build from source
If you have all the prerequisites, simply clone this repository and run `flutter build apk`. <br>
This should output an apk at *./build/app/outputs/apk/release/*

To sign this app, create the file *./android/key.properties* and enter the necessary information about your keystore into this file. If you don't know how to create one, look into [this](https://docs.flutter.dev/deployment/android#create-an-upload-keystore) Tutorial.

# Development
Make sure you have all the Prerequisites, and in addition to that, either an Android device or an android emulator for development purposes.<br>
Then connect to the device and run `flutter run`. This should start a development server and launch the application on the connected device.

# Contributing
To contribute to Campus Dual Helper, follow these steps:

- Fork this repository
- Create a branch: git checkout -b '<branch_name>'.
- Make your changes and commit them: git commit -m '<commit_message>'
- Push the changes: git push
- Create a pull request
