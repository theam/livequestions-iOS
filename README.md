# Live Questions iOS App

![256 png](https://user-images.githubusercontent.com/738853/205069300-7551a459-ed94-4c5e-80f1-36d3cb5b3066.jpeg)

Live Questions is an universal iOS app that shows how easy it is to use [**Booster framework**](http://docs.booster.cloud) as the Backend solution.

This application allows you to ask questions about a specific topic that a host created. When you create a topic, you can share it with your friends and they can ask or like others questions.

You can download the application from an iPhone or iPad and check for yourself how the app works.

![https://apps.apple.com/us/app/pickbit-record-audio-share/id1593890437](https://user-images.githubusercontent.com/738853/205076607-b4e92c7c-3164-44d6-9909-13f01bc747dc.svg)




## Quick Start

Here are some steps you can follow to download and open the project.

```
$ git clone https://github.com/theam/livequestions-iOS.git
$ cd livequestions-iOS/LiveQuestions
$ open LiveQuestions.xcodeproj
```

This project uses Swift Package Manager for it's dependencies, so after you open the project all dependencies will be automatically downloaded.

**[IMPORTANT]**
If you want to be able to run this application on a simulator or device from Xcode, you will need to sign up on [Auth0](https://auth0.com) and create your own application to authenticate users with your client id and domain. You should only need to do the steps 1 & 4 from this [tutorial](https://auth0.com/docs/quickstart/native/ios-swift/interactive).


## Architecture

For this application we created the UI with **SwiftUI**, user authentication and authorization with **Auth0**, and for our backend we are using **Booster**. The comunication between client and server is done through GraphQL, which means we will perform queries, mutations and have subscriptions to keep our app in sync with the server.


<img width="800" alt="Live Questions Diagram" src="https://user-images.githubusercontent.com/738853/205601819-3a132fed-1ed0-4883-adb0-51d6dd05a36d.png">


## License

Live Questions is released under the [MIT License](License).
