# Live Questions iOS App

![256 png](https://user-images.githubusercontent.com/738853/205069300-7551a459-ed94-4c5e-80f1-36d3cb5b3066.jpeg)

Live Questions is an iOS app that demonstrates the ease of using Booster as a backend solution.

You can download the app on your iPhone or iPad to see the app in action and experience the power of using [**Booster**](http://docs.booster.cloud) as a backend solution.


[![Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917](https://user-images.githubusercontent.com/738853/209131093-b58894d9-4ef9-47aa-be76-84e4a9abb86f.svg)](https://apps.apple.com/en/app/live-questions-ask-anything/id1659446314)


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




## Quick Start

Here are some steps you can follow to download and open the project.

```
$ git clone https://github.com/theam/livequestions-iOS.git
$ cd livequestions-iOS/LiveQuestions
$ open LiveQuestions.xcodeproj
```

Note: This project uses Swift Package Manager for its dependencies, so they will be automatically downloaded when you open the project in Xcode.

**[IMPORTANT]**
To be able to run the application on a simulator or device from Xcode, you will need to sign up for an account on [Auth0](https://auth0.com) and create your own application to authenticate users. Follow steps 1 and 4 of the Auth0 tutorial to set up your own authentication for the project, see [here](https://auth0.com/docs/quickstart/native/ios-swift/interactive). For more detailed instructions on how to use Auth0 with your iOS application, you can also check out our [tutorial](https://medium.com/@juanSagasti/f2eda6463c40).



## Architecture

In this application, we utilized **SwiftUI** to create the user interface, **Auth0** for user authentication and authorization, and **Booster** as the backend solution. We use GraphQL for communication between the client and server, allowing us to perform queries, mutations, and establish subscriptions to keep the app synchronized with the server.

<img width="800" alt="Live Questions Diagram" src="https://user-images.githubusercontent.com/738853/205601819-3a132fed-1ed0-4883-adb0-51d6dd05a36d.png">


## Articles
[From iOS Dev to full-stack in no time with Booster 🚀](https://medium.com/@juanSagasti/f2eda6463c40)

[Scalable Low-Code backends with Booster](https://medium.com/@juanSagasti/scalable-low-code-backends-with-booster-a32b9386dd27)

## License

Live Questions is released under the [MIT License](License).
