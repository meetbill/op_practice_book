# django_bootstrap
django
<h2 name="2">settings</h2>
神奇的 Python 内部变量 __file__ ,该变量被自动设置为代码所在的Python 模块文件名.
```
import os.path
TEMPLATE_DIRS = (
    os.path.join(os.path.dirname(__file__), 'templates').replace('\\','/'),
)
```
or

```
import os.path
SITE_ROOT = os.path.abspath(os.path.dirname(__file__))

STATIC_ROOT = os.path.join(SITE_ROOT,'static')
STATICFILES_DIRS = (
    # Don't forget to use absolute paths, not relative paths.
    ("css", os.path.join(STATIC_ROOT,'css')),
    ("js", os.path.join(STATIC_ROOT,'js')),
    ("img", os.path.join(STATIC_ROOT, 'img')),
    ("font", os.path.join(STATIC_ROOT, 'font')),
    ("liger", os.path.join(STATIC_ROOT, 'liger')),
    ("bootstrap3", os.path.join(STATIC_ROOT, 'bootstrap3')),
)
TEMPLATE_DIRS = (
    os.path.join(SITE_ROOT,'templates'),
)
```
<h2 name="2">bootstrap</h2>
Bootstrap的使用一般有两种方法。一种是引用在线的Bootstrap的样式，一种是将Bootstrap下载到本地进行引用。
使用本地的Bootstrap

下载Bootstrap到本地进行解压，解压完成，你将得到一个Bootstrap目录，结构如下：

```
[root@Linux bootstrap-3.3.5-dist]# tree 
.
├── css
│   ├── bootstrap.css
│   ├── bootstrap.css.map
│   ├── bootstrap.min.css
│   ├── bootstrap-theme.css
│   ├── bootstrap-theme.css.map
│   └── bootstrap-theme.min.css
├── fonts
│   ├── glyphicons-halflings-regular.eot
│   ├── glyphicons-halflings-regular.svg
│   ├── glyphicons-halflings-regular.ttf
│   ├── glyphicons-halflings-regular.woff
│   └── glyphicons-halflings-regular.woff2
└── js
    ├── bootstrap.js
    ├── bootstrap.min.js
    └── npm.js
```
本地调用如下：
```
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Hello Bootstrap</title>
        <!-- Bootstrap core CSS -->
        <link
            href="./bootstrap-3.3.5-dist/css/bootstrap.min.css" rel="stylesheet">
        <style type='text/css'>
            body {
                background-color: #CCC;
            }
        </style>
    </head>
    <body>
        <h1>hello Bootstrap<h1>
    </body>
</html>
```
