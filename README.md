# Cordova ClassKit Plugin

Plugin to use Apple's [ClassKit](https://developer.apple.com/documentation/classkit/) framework in your Cordova apps. Manage and create [Contexts](https://developer.apple.com/documentation/classkit/advertising_your_app_s_assignable_content) and [Activities](https://developer.apple.com/documentation/classkit/recording_student_progress) and add [Activity Items](https://developer.apple.com/documentation/classkit/recording_additional_metrics_about_a_completed_task) to track the student's progress within the [Schoolwork](https://itunes.apple.com/us/app/schoolwork/id1355112526?ls=1&mt=8) App.

- [Prerequisites]()
- [Supported Platform(s)]()
- [Installation]()
- [API]()
    - [.initContextsFromXml(urlPrefix, success, error)]()
    - [.addContext(urlPrefix, context, success, error)]()
    - [.removeContexts(success, error)]()
    - [.removeContext(identifierPath, success, error)]()
    - [.beginActivity(identifierPath, asNew, success, error)]()
    - [.endActivity(success, error)]()
    - [.setProgressRange(fromStart, toEnd, success, error)]()
    - [.setProgress(progress, success, error)]()
    - [.setBinaryItem(binaryItem, success, error)]()
    - [.setScoreItem(scoreItem, success, error)]()
    - [.setQuantityItem(quantityItem, success, error)]()
- [Add Contexts to your App]()
    - [Static Contexts in XML File]()
    - [Dynamic Contexts]()
- [Deep Linking]()
- [Contributing]()
- [License]()

## Prerequisites

Only works with Xcode 9.4 and iOS 11.4. Your Provisioning Profile must include the ClassKit capability. Read more about how to [Request ClassKit Resources](https://developer.apple.com/contact/classkit/) in this [article](https://developer.apple.com/documentation/classkit/enabling_classkit_in_your_app). 
Also note that you can’t test ClassKit behavior in Simulator because Schoolwork isn’t available in that environment.

## Supported Platform(s)
- iOS

## Installation
1. ```cordova plugin add cordova-plugin-classkit```
2. Turn on ```ClassKit``` in Xcode's ```Capabilities``` tab

The code is written in Swift and the [Swift support plugin](https://github.com/akofman/cordova-plugin-add-swift-support) is configured as a dependency.

## API

### .initContextsFromXml(urlPrefix, success, error)
Init contexts defined in XML file `CCK-contexts.xml`

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `urlPrefix`          | `String`   |         | URL prefix to use for custom URLs to locate activities (deeplink).  |
| `success` | `Function` |         | Is called when the api successfully initializes the contexts from XML.               |
| `error`   | `Function` |         | Is called when the api encounters an error while initializing the contexts from XML. |

#### Example

```javascript
CordovaClassKit.initContextsFromXml(
  "myurlprefix://",
  () => {
    console.log('success');
  },
  e => {
    console.log("error:", e);
  }
);
```

`CCK-contexts.xml` (read [Add Contexts to your App]() for more infos about the XML file)
```xml
<root>
    <context
        title="Parent Title 1"
        type="2"
        displayOrder="1"
        topic="math"
        identifierPath="parent_title_one">
        <context
            title="Child 1 1"
            type="3"
            identifierPath="parent_title_one, child_one"></context>
        <context
            title="Child 1 2"
            type="3"
            identifierPath="parent_title_one, child_two">
            <context
                title="Quiz 1 2 1"
                type="8"
                identifierPath="parent_title_one, child_two, child_two_quiz"></context>
        </context>
    </context>
    <context
        title="Parent Title 2"
        type="2"
        displayOrder="0"
        topic="computerScienceAndEngineering"
        identifierPath="parent_title_two">
        <context
            title="Child 2 1"
            type="3"
            identifierPath="parent_title_two, child_two">
            <context
                title="Quiz 2 1 1"
                type="8"
                identifierPath="parent_title_two, child_two, child_one_quiz"></context>
        </context>
    </context>
</root>
```

### .addContext(urlPrefix, context, success, error)
Init context with identifier path

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `urlPrefix`          | `String`   |         | URL prefix to use for custom URLs to locate activities (deeplink).    
| `context`          | `Object`   |         | Context to initialize.                                     |
| `success` | `Function` |         | Is called when the api successfully initializes the context.               |
| `error`   | `Function` |         | Is called when the api encounters an error while initializing the context. |

All available `context` attributes:

| Attribute                      | Type     | Default                                                      | Description                                        |
| ------------------------------ | -------- | ------------------------------------------------------------ | -------------------------------------------------- |
| `identifierPath`  | `String[]` |  | Full identifier path from root, including the context identifier itself. |
| `title` | `String` |  | Title of the context. |
| `type` | `Number` |  | Optional. Type value for the context. |
| `topic` | `String` |  | Optional. Topic value of the context. |
| `displayOrder` | `Number` | `0` | Optional. Display order of the context. |

All available `type` values ([CLSContextType](https://developer.apple.com/documentation/classkit/clscontexttype)):

| Value | Type     |
|-------------|-----------
| `0`  | `CLSContextType.none` | 
| `1`  | `CLSContextType.app` (Reserved for the main app context) | 
| `2`  | `CLSContextType.chapter` | 
| `3`  | `CLSContextType.section` | 
| `4`  | `CLSContextType.level` | 
| `5`  | `CLSContextType.page` | 
| `6`  | `CLSContextType.task` | 
| `7`  | `CLSContextType.challenge` | 
| `8`  | `CLSContextType.quiz` | 
| `10`  | `CLSContextType.exercise` | 
| `11`  | `CLSContextType.lesson` | 
| `12`  | `CLSContextType.book` | 
| `13`  | `CLSContextType.game` | 
| `14`  | `CLSContextType.document` | 
| `15`  | `CLSContextType.audio` | 
| `16`  | `CLSContextType.video` | 

All available `topic` values ([CLSContextTopic](https://developer.apple.com/documentation/classkit/clscontexttopic?changes=_3)):

| Value | Type     |
|-------------|-----------
| `"math"`  | `CLSContextTopic.math` | 
| `"science"`  | `CLSContextTopic.science` | 
| `"literacyAndWriting"`  | `CLSContextTopic.literacyAndWriting` | 
| `"worldLanguage"`  | `CLSContextTopic.worldLanguage` | 
| `"socialScience"`  | `CLSContextTopic.socialScience` | 
| `"computerScienceAndEngineering"`  | `CLSContextTopic.computerScienceAndEngineering` | 
| `"artsAndMusic"`  | `CLSContextTopic.artsAndMusic` | 
| `"healthAndFitness"`  | `CLSContextTopic.healthAndFitness` | 

#### Example

```javascript
var context = {
  identifierPath: ["parent_id", "child_id", "my_context_identifier"],
  title: "My Context Title",
  type: 2,
  topic: "math",
  displayOrder: 1
};

CordovaClassKit.addContext(
  "myurlprefix://", context,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .removeContexts(success, error)
Remove all contexts

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `success` | `Function` |         | Is called when the api successfully removes all contexts.               |
| `error`   | `Function` |         | Is called when the api encounters an error while removing the contexts. |

#### Example

```javascript
CordovaClassKit.removeContexts(
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .removeContext(identifierPath, success, error)
Remove context with identifier path

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `identifierPath` | `String[]` |         | Full identifier path from root, including the context identifier itself. |
| `success` | `Function` |         | Is called when the api successfully removes the context.               |
| `error`   | `Function` |         | Is called when the api encounters an error while removing the context. |

#### Example

```javascript
CordovaClassKit.removeContext(
  ["parent_id", "child_id", "my_context_identifier"],
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .beginActivity(identifierPath, asNew, success, error)
Begin a new activity or restart an activity for a given context

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `identifierPath` | `String[]` |         | Full identifier path from root, including the context identifier itself.               |
| `asNew` | `Boolean` |     false    | Should a new activity be created (or an old activity be restarted).               |
| `success` | `Function` |         | Is called when the api successfully begins or restarts an activtiy.               |
| `error`   | `Function` |         | Is called when the api encounters an error while beginning or restarting an activity. |

#### Example

```javascript
CordovaClassKit.beginActivity(
  ["parent_id", "child_id", "my_context_identifier"], true,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .endActivity(success, error)
End the active activity

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `success` | `Function` |         | Is called when the api successfully ends the active activity.               |
| `error`   | `Function` |         | Is called when the api encounters an error while ending the active activity. |

#### Example

```javascript
CordovaClassKit.endActivity(
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .setProgressRange(fromStart, toEnd, success, error)
> Adds a progress range to the active given activity.
> [developer.apple.com](https://developer.apple.com/documentation/classkit/clsactivity/2953066-addprogressrange)

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `fromStart` | `Number` |         | The beginning of the new range to add. This should be fractional value between 0 and 1, inclusive.               |
| `toEnd` | `Number` |         | The end of the new range to add. This should be larger than the start value and less than or equal to one.     |
| `success` | `Function` |         | Is called when the api successfully adds a progress range.               |
| `error`   | `Function` |         | Is called when the api encounters an error while adding a progress range. |

#### Example

```javascript
CordovaClassKit.setProgressRange(
  0.0, 0.33,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .setProgress(progress, success, error)
> Adds a progress to the active given activity.
> [developer.apple.com](https://developer.apple.com/documentation/classkit/clsactivity/2953057-progress)

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `progress` | `Number` |         | A measure of progress through the task, given as a fraction in the range [0, 1]. |
| `success` | `Function` |         | Is called when the api successfully adds a progress.               |
| `error`   | `Function` |         | Is called when the api encounters an error while adding a progress. |

#### Example

```javascript
CordovaClassKit.setProgress(
  0.33,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .setBinaryItem(binaryItem, success, error)
> Adds activity information that is true or false, pass or fail, yes or no.
>
> Use an activity item of this type to indicate a binary condition, such as whether a student passed a test or failed it. Set the valueType property to specify how the binary condition should be reported to a teacher.
> [developer.apple.com](https://developer.apple.com/documentation/classkit/clsbinaryitem)

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `binaryItem` | `Object` |         | The binary item to add to the activity.               |
| `success` | `Function` |         | Is called when the api successfully adds a binary item.               |
| `error`   | `Function` |         | Is called when the api encounters an error while adding a binary item. |

All available `binaryItem` attributes:

| Attribute                      | Type     | Default                                                      | Description                                        |
| ------------------------------ | -------- | ------------------------------------------------------------ | -------------------------------------------------- |
| `identifier`  | `String` |  | A unique string identifier for the activity item. |
| `title` | `String` |  | A human readable name for the activity item. |
| `type` | `Number` |  | A type value for the activity item. |
| `isCorrect` | `Boolean` |  | The value that the binary activity item takes. |
| `isPrimaryActivityItem` | `Boolean` | false | Optional. Should the activity item be added as the primary activity item. |

All available `type` values ([CLSBinaryValueType](https://developer.apple.com/documentation/classkit/clsbinaryvaluetype)):

| Value | Type     |
|-------------|-----------
| `0`  | `CLSBinaryValueType.trueFalse` | 
| `1`  | `CLSBinaryValueType.passFail` | 
| `2`  | `CLSBinaryValueType.yesNo` | 

#### Example

```javascript
var binaryItem = {
  identifier: "binary_item_id",
  title: "My Binary Item 1",
  type: 0,
  isCorrect: true,
  isPrimaryActivityItem: false
};

CordovaClassKit.setBinaryItem(
  binaryItem,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .setScoreItem(scoreItem, success, error)
> Adds activity information that signifies a score out of a possible maximum.
>
> Use an activity item of this type to indicate the relative success in completing a task, like the number of correctly answered questions on a quiz.
> [developer.apple.com](https://developer.apple.com/documentation/classkit/clsscoreitem)

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `scoreItem` | `Object` |         | The score item to add to the activity.               |
| `success` | `Function` |         | Is called when the api successfully adds a score item.               |
| `error`   | `Function` |         | Is called when the api encounters an error while adding a score item. |

All available `scoreItem` attributes:

| Attribute                      | Type     | Default                                                      | Description                                        |
| ------------------------------ | -------- | ------------------------------------------------------------ | -------------------------------------------------- |
| `identifier`  | `String` |  | A unique string identifier for the activity item. |
| `title` | `String` |  | A human readable name for the activity item. |
| `score` | `Number` |  | The score earned during completion of a task. |
| `maxScore` | `Number` |  | The maximum possible score, against which the reported score should be judged. |
| `isPrimaryActivityItem` | `Boolean` | false | Optional. Should the activity item be added as the primary activity item. |

#### Example

```javascript
var scoreItem = {
  identifier: "total_score",
  title: "Total Score",
  score: 0.66,
  maxScore: 1.0,
  isPrimaryActivityItem: true
};

CordovaClassKit.setScoreItem(
  scoreItem,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

### .setQuantityItem(quantityItem, success, error)
> Activity information that signifies a quantity.
>
> Use an activity item of this type to associate a discrete value with a task. For example, you might use it to indicate how many times the user requested a hint while taking a quiz.
> [developer.apple.com](https://developer.apple.com/documentation/classkit/clsquantityitem)

#### Parameters

| Parameter        | Type       | Default | Description                                                   |
| ---------------- | ---------- | ------- | ------------------------------------------------------------- |
| `quantityItem` | `Object` |         | The quantity item to add to the activity.               |
| `success` | `Function` |         | Is called when the api successfully adds a quantity item.               |
| `error`   | `Function` |         | Is called when the api encounters an error while adding a quantity item. |

All available `quantityItem` attributes:

| Attribute                      | Type     | Default                                                      | Description                                        |
| ------------------------------ | -------- | ------------------------------------------------------------ | -------------------------------------------------- |
| `identifier`  | `String` |  | A unique string identifier for the activity item. |
| `title` | `String` |  | A human readable name for the activity item. |
| `quantity` | `Number` |  | A quantity associated with the task. |
| `isPrimaryActivityItem` | `Boolean` | false | Optional. Should the activity item be added as the primary activity item. |

#### Example

```javascript
var quantityItem = {
  identifier: "quantity_item_hints",
  title: "Hints",
  quantity: 8,
  isPrimaryActivityItem: false
};

CordovaClassKit.setQuantityItem(
  quantityItem,
  () => {
    console.log("success");
  },
  e => {
    console.log("error:", e);
  }
);
```

## Add Contexts to your App
> A context [...] represents an area within your app, such as a book chapter or a game level, that teachers can assign to students as tasks. You create a hierarchy of contexts to enable teachers to browse and assign your app’s content. You provide deep links to the content that the contexts represent to help teachers guide students to your content.
> [developer.apple.com](https://developer.apple.com/documentation/classkit/advertising_your_app_s_assignable_content)

There are two different types of contexts that you are able to initialize with this plugin: __static__ (you know your contexts beforehand) and __dynamic__ (you add contexts at run time).

### Static Contexts in XML File
If you have a lot of static contexts you want to add to your app you could either call [`addContext(context, success, error)`]() for every context or use a hierarchical XML representation of your contexts to initialize your contexts from calling [`initContextsFromXml(urlPrefix, success, error)`](). Latter will be more clear and structured (at least for me... that's the reason I added this option... ;-) ).
Therefore the plugin adds a `CCK-contexts.xml` file to your `Resources` folder in Xcode. The structure is as follows:

```xml
<root>
    <context identifierPath="parent_title_one"  title="Parent Title 1" type="2" displayOrder="1" topic="math">
        <context title="Child 1 1" type="3" identifierPath="parent_title_one, child_one"></context>
        <context title="Child 1 2" type="3" identifierPath="parent_title_one, child_two">
            <context title="Quiz 1 2 1" type="8" identifierPath="parent_title_one, child_two, child_two_quiz"></context>
        </context>
    </context>
    <context title="Parent Title 2" type="2" displayOrder="0" topic="computerScienceAndEngineering" identifierPath="parent_title_two">                
    ...
    </context>
    ...
</root>
```

You have to start with __exactly one__ root node `<root></root>`. Now, nest all your `<context></context>` nodes in here building a hierarchical representation of all your static contexts. All available `<context>`-tag attributes are:

| Attribute                      | Type     | Default                                                      | Description                                        |
| ------------------------------ | -------- | ------------------------------------------------------------ | -------------------------------------------------- |
| `identifierPath`  | `String[]` |  | Full identifier path from root, including the context identifier itself. |
| `title` | `String` |  | Title of the context. |
| `type` | `Number` |  | Optional. Type value for the context. |
| `topic` | `String` |  | Optional. Topic value of the context. |
| `displayOrder` | `Number` | `0` | Optional. Display order of the context. |

All available `type` values ([CLSContextType](https://developer.apple.com/documentation/classkit/clscontexttype)):

| Value | Type     |
|-------------|-----------
| `0`  | `CLSContextType.none` | 
| `1`  | `CLSContextType.app` (Reserved for the main app context) | 
| `2`  | `CLSContextType.chapter` | 
| `3`  | `CLSContextType.section` | 
| `4`  | `CLSContextType.level` | 
| `5`  | `CLSContextType.page` | 
| `6`  | `CLSContextType.task` | 
| `7`  | `CLSContextType.challenge` | 
| `8`  | `CLSContextType.quiz` | 
| `10`  | `CLSContextType.exercise` | 
| `11`  | `CLSContextType.lesson` | 
| `12`  | `CLSContextType.book` | 
| `13`  | `CLSContextType.game` | 
| `14`  | `CLSContextType.document` | 
| `15`  | `CLSContextType.audio` | 
| `16`  | `CLSContextType.video` | 

All available `topic` values ([CLSContextTopic](https://developer.apple.com/documentation/classkit/clscontexttopic?changes=_3)):

| Value | Type     |
|-------------|-----------
| `"math"`  | `CLSContextTopic.math` | 
| `"science"`  | `CLSContextTopic.science` | 
| `"literacyAndWriting"`  | `CLSContextTopic.literacyAndWriting` | 
| `"worldLanguage"`  | `CLSContextTopic.worldLanguage` | 
| `"socialScience"`  | `CLSContextTopic.socialScience` | 
| `"computerScienceAndEngineering"`  | `CLSContextTopic.computerScienceAndEngineering` | 
| `"artsAndMusic"`  | `CLSContextTopic.artsAndMusic` | 
| `"healthAndFitness"`  | `CLSContextTopic.healthAndFitness` | 

Edit the `CCK-contexts.xml` file directly in the `Resources` folder in Xcode. Within your application call [`initContextsFromXml(urlPrefix, success, error)`]() to init your contexts from `CCK-contexts.xml`.

### Dynamic Contexts
To dynamically add contexts to your application use [`addContext(context, success, error)`]().

## Deep Linking
As Apple's documentation states you should/have to "provide deep links to the content that the contexts represent to help teachers guide students to your content". [developer.apple.com](https://developer.apple.com/documentation/classkit/advertising_your_app_s_assignable_content)
The deep linking __is not part of this plugin__! Please use your 3rd party plugin of choice here, e.g. [Ionic Deeplinks Plugin](https://github.com/ionic-team/ionic-plugin-deeplinks) or [Branch](https://github.com/BranchMetrics/cordova-ionic-phonegap-branch-deep-linking).

## Contributing
This plugin needs testing! 

0. Test it
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
This software is released under the [Apache 2.0 License][apache2_license].
