#import "SnapshotHelper.js"

var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["Personal data"].tapWithOptions({tapOffset:{x:0.44, y:0.40}});
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].textFields()[0].textFields()[0].setValue("Александр");
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].textFields()[0].textFields()[0].setValue("79163074477");
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].textFields()[0].textFields()[0].setValue("balaban.alexander@gmail.com");
target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.09, y:0.27}});

target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["Меню"].tapWithOptions({tapOffset:{x:0.39, y:0.75}});
captureLocalizedScreenshot('0-Menu');

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].buttons()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].buttons()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot('1-Position');

target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.09, y:0.27}});
target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.09, y:0.27}});

captureLocalizedScreenshot('2-Order');
target.frontMostApp().mainWindow().scrollViews()[0].dragInsideWithOptions({startOffset:{x:0.46, y:0.37}, endOffset:{x:0.46, y:0.15}});
target.frontMostApp().mainWindow().scrollViews()[0].switches()[1].setValue(1);
target.dragFromToForDuration({x:138.50, y:263.50}, {x:133.50, y:60.50}, 0.7);
target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Place order"].tap();
target.delay(8);
captureLocalizedScreenshot('3-OrderStatus');

target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.06, y:0.05}});
captureLocalizedScreenshot('4-Orders');
