#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

captureLocalizedScreenshot("0-LandingScreen")
target.delay(1)
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()[0].tapWithOptions({tapOffset:{x:0.0, y:0.0}});
captureLocalizedScreenshot("1-Menu")
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.0, y:0.0}});
target.delay(1)
target.frontMostApp().navigationBar().buttons()[2].tap();
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
captureLocalizedScreenshot("2-Position")
target.delay(1)
target.frontMostApp().navigationBar().leftButton().tap();
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.0, y:0.00}});
target.delay(1)
target.frontMostApp().navigationBar().buttons()[1].tap();
target.delay(1)
target.frontMostApp().tabBar().buttons()[2].tap();
captureLocalizedScreenshot("3-Venues")
target.delay(1)
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.00, y:0.00}});
target.delay(1)
target.frontMostApp().navigationBar().leftButton().tap();
captureLocalizedScreenshot("4-Menu")
target.delay(1)
target.frontMostApp().tabBar().buttons()[1].tap();
captureLocalizedScreenshot("5-History")
