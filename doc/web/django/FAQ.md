# django_learn
django
(1)Django 表单提交出现 CSRF verification failed. Request aborted
```
  由于我们创建一个POST表单（它具有修改数据的作用），所以我们需要小心跨站点请求伪造。
  谢天谢地，你不必太过担心，因为Django已经拥有一个用来防御它的非常容易使用的系统。
  简而言之，所有针对内部URL的POST表单都应该使用{% csrf_token %}模板标签。
  [templates-form]
  {% csrf_token %}

  [View]
  return render_to_response(’polls/detail.html’, {’poll’: p},
                    context_instance=RequestContext(request))
```
