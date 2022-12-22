# Live Questions iOS App

![256 png](https://user-images.githubusercontent.com/738853/205069300-7551a459-ed94-4c5e-80f1-36d3cb5b3066.jpeg)

Live Questions is an iOS app that demonstrates the ease of using Booster as a backend solution.


## Features

Live Questions is an excellent companion tool for live events, keynotes, and Q&A sessions!

As host of a live event, you can:
- Create a topic to collect all the questions from the public in an organized way. You will see the question list grow in real time!
- Share the topic link or show the QR code so only the event participants can join the topic. 
- Mark questions as answered in real-time when you answer them in real life.
- Sort the question list to see the most liked or recent ones at the top.
- Close the topic when the event is finished or let it expire automatically.
- Edit or delete your topics.

As a participant in a live event, you can:
- Join a topic with a link or a QR code and start adding your questions to the topic!
- Ask anonymously if you prefer.
- Like others' questions so the host can easily prioritize the most liked ones during the session.
- Edit or delete your question.


You can download the app on your iPhone or iPad to see the app in action and experience the power of using [**Booster**](http://docs.booster.cloud) as a backend solution.

![https://apps.apple.com/en/app/live-questions-ask-anything/id1659446314](https://user-images.githubusercontent.com/738853/205076607-b4e92c7c-3164-44d6-9909-13f01bc747dc.svg)



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
