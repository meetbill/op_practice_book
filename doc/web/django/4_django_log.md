# django_log
django_log

## 1、将log封装成一个单独的app
```
[root@Linux mysite]# django-admin.py startapp log
[root@Linux mysite]# cd log
[root@Linux log]# ls
__init__.py  models.py  tests.py  views.py
```

## 2、编写log程序
```
curl -o BLog.py https://raw.githubusercontent.com/BillWang139967/MyPythonLib/master/log_utils/BLog/BLog.py
```
## 3、在本项目其他应用中的view.py中调用BLog
```
from django.shortcuts import render,render_to_response

from log.BLog import Log
# 是否在终端显示
debug=True
# 日志文件
logpath = "/tmp/test.log"
# 设置日志文件为5Mb时进行轮转，并且最多只保留个日志
logger = Log(logpath,level="debug",is_console=debug, mbs=5, count=5)

    
def face(request):
    logstr="########"
    logger.error(logstr)
    logger.info(logstr)
    logger.warn(logstr)
    return render_to_response('register.html',{})
```
## 4、测试

当在view.py中设置了终端显示时

![Screenshot](../../../images/django/BLog.jpg)

注:如果修改前django项目是运行的，那么当我们在程序中加入导入模块的程序时，需要重启下django应用，如果我们修改的程序不涉及导入模块部分，则不需要重启应用
