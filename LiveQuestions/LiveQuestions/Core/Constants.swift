import Foundation

let TestUser = User(id: "testUserId", username: "supermario", displayName: "Super Mario", blockedUserIds: [], blockedQuestionIds: [])

let TestOpenTopic = Topic(id: "testTopicId",
                          title: "This is an awesome topic!",
                          createdAt: Date(),
                          expiration: Date().addingTimeInterval(3000),
                          status: .open,
                          host: TestUser,
                          questionsCount: 77,
                          hasJoined: true,
                          isMine: true)

let TestClosedTopic = Topic(id: "testTopicId2",
                            title: "This topic was awesome, but it is closed now!",
                            createdAt: Date(),
                            expiration: Date().addingTimeInterval(3000),
                            status: .closed,
                            host: TestUser,
                            questionsCount: 77,
                            hasJoined: true,
                            isMine: true)

let TestUnansweredQuestion = Question(id: "testQuestionId",
                                      text: "This is an amazing question waiting for an answer",
                                      status: .unanswered,
                                      likes: ["id1", "id2"],
                                      creator: TestUser,
                                      isAnonymous: false,
                                      createdAt: Date(),
                                      isMine: true)

let TestAnsweredQuestion = Question(id: "testQuestionId",
                                    text: "This is an amazing question already answered",
                                    status: .answered,
                                    likes: ["id1", "id2"],
                                    creator: TestUser,
                                    isAnonymous: false,
                                    createdAt: Date(),
                                    isMine: true)
