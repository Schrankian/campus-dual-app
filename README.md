# Campus Dual Helper
Campus Dual Helper is an App designed to provide an alternative Interface to the Campus Dual web application. To achieve this, it uses Api Endpoints or just scrapes the website and parses it to get the necessary data.

# Important
This application gets the informations by impersonating the user and scraping the data from the official websites. Due to the nature of scraping, there could be (and probably are) a lot of edge case I haven't considered while writing this scraper. So keep in mind that bugs could occure, and if they do so, please write and github issue for it.

> Maintainer wanted: As i am currently in my 5th Semester i cannot maintain this scraper indefinetely, because my access to campus-dual may be cut off. So if you are interested please reach out to me.

# Prerequisites
- Flutter
- Some Android tools (Check flutter documentation)

# Installation
The newest Release can be found in the releases section of this repository. Simply download the apk and install it.

## Build from source
If you have all prerequisites, simply clone this repository and run `flutter build apk`. <br>
This should output an apk at *./build/app/outputs/apk/release/*

To sign this app, create the file *./android/key.properties* and enter the necessary information about you keystore into this file. If you don't know how to create one, look into [this](https://docs.flutter.dev/deployment/android#create-an-upload-keystore) Tutorial.

# Development
Make sure you have all Prerequisites, and in addition to that, either and Android device or an android emulator for development purposes.<br>
The connect the device and run `flutter run`. This should start an development server and launch the application on the connected device

# Contributing
To contribute to Campus Dual Helper, follow these steps:

- Fork this repository
- Create a branch: git checkout -b '<branch_name>'.
- Make your changes and commit them: git commit -m '<commit_message>'
- Push the changes: git push
- Create a pull request