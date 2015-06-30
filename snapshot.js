#import "SnapshotHelper.js"

var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["Представьтесь, пожалуйста"].tapWithOptions({tapOffset:{x:0.44, y:0.40}});
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].textFields()[0].textFields()[0].setValue("Александр");
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].textFields()[0].textFields()[0].setValue("79163074477");
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].textFields()[0].textFields()[0].setValue("balaban.alexander@gmail.com");
target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.09, y:0.27}});

target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["Меню"].tapWithOptions({tapOffset:{x:0.39, y:0.75}});
captureLocalizedScreenshot('0-Menu');

target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.90, y:0.19}});
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.90, y:0.24}});
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot('1-Position');

target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.09, y:0.27}});
target.frontMostApp().navigationBar().tapWithOptions({tapOffset:{x:0.09, y:0.27}});

captureLocalizedScreenshot('2-Order');
target.frontMostApp().mainWindow().scrollViews()[0].dragInsideWithOptions({startOffset:{x:0.46, y:0.37}, endOffset:{x:0.46, y:0.15}});
target.frontMostApp().mainWindow().scrollViews()[0].switches()[1].setValue(1);
target.frontMostApp().mainWindow().scrollViews()[0].dragInsideWithOptions({startOffset:{x:0.45, y:0.62}, endOffset:{x:0.45, y:0.39}});
target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Заказать"].tap();
captureLocalizedScreenshot('3-OrderStatus');
target.delay(3);

target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.06, y:0.05}});
captureLocalizedScreenshot('4-Orders');
