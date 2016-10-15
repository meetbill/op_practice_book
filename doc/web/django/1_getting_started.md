# getting_started
django

Django 里是模型（Model）、模板(Template)和视图（Views）， Django 也被称为 MTV框架 。在 MTV 开发模式中：
* M 代表模型（Model），即数据存取层。 该层处理与数据相关的所有事务：如何存取、如何验证有效
* T 代表模板(Template)，即表现层。 该层处理与表现相关的决定：如何在页面或其他类型文档中进行显示。
* V 代表视图（View），即业务逻辑层。 该层包含存取模型及调取恰当模板的相关逻辑。可以把它看作模型与模板之间的桥梁。

![Screenshot](../../../images/django/django.png)

我个人理解：可以把Template看作是含有变量的字符串，View调用模板时，就是将变量传给Template的字符串，并将页面显示出来，具体如何显示不是咱们要关心的事，咱们只需要将变量传递给template即可
