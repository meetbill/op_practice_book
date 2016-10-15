# django_login
django
## flow chart
```
 +---------+      +---------+       +------------+                                
 | url.py  |----->| view.py |------>| templates  |
 | (Login) |      | (Login) |       | login.html |
 +---------+      +---------+       +------------+

 在登陆页输入账号密码后，通过认证函数进行认证，如果认证通过跳转到主页，否则重新登陆
```

## detailed
url.py
```
  url('^$','strap.view.LogIn'),
  url('^login/$','strap.view.LogIn'),         //login
  url('^index/$','strap.view.account_auth'),  //authentication
  url('^showDashboard/$','strap.view.show'),  //Go to the home page
    
```
view.py
```
  from django.http import HttpResponseRedirect, HttpResponse
  from django.shortcuts import render_to_response, render
  from django.contrib import auth
  import datetime
  def index(request):
      now = datetime.datetime.now()
      return render(request,'index.html')

  def LogIn(request):
      if request.user is not None:
          logout_view(request)
      return render(request,'login.html')

  def logout_view(request):
      user = request.user
      auth.logout(request)
      # Redirect to a success page.
      return HttpResponse("%s logged out!" % user)

  def account_auth(request):
      username = request.POST.get('username')
      password = request.POST.get('password')
      tri_user = auth.authenticate(username=username,password=password)
      if tri_user is not None:
      auth.login(request,tri_user)
      return HttpResponseRedirect('/showDashboard')
      else:
      return render_to_response('login.html',{'login_err':'Wrong username or password!'})

  def show(request):
      return render(request,'index.html')

```
templates
```
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge" />
      
      <title>Admin</title>
      <meta name="description" content="">
      <meta name="author" content="">
      
      <!-- http://davidbcalhoun.com/2010/viewport-metatag -->
      <meta name="HandheldFriendly" content="True">
      <meta name="MobileOptimized" content="320">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

      <!-- For Modern Browsers -->
      <link rel="shortcut icon" href="img/favicons/favicon.png">
      <!-- For everything else -->
      <link rel="shortcut icon" href="img/favicons/favicon.ico">
      <!-- For retina screens -->
      <link rel="apple-touch-icon-precomposed" sizes="114x114" href="img/favicons/apple-touch-icon-retina.png">
      <!-- For iPad 1-->
      <link rel="apple-touch-icon-precomposed" sizes="72x72" href="img/favicons/apple-touch-icon-ipad.png">
      <!-- For iPhone 3G, iPod Touch and Android -->
      <link rel="apple-touch-icon-precomposed" href="img/favicons/apple-touch-icon.png">
      
      <!-- iOS web-app metas -->
      <meta name="apple-mobile-web-app-capable" content="yes">
      <meta name="apple-mobile-web-app-status-bar-style" content="black">
      <!-- Add your custom home screen title: -->
      <meta name="apple-mobile-web-app-title" content="Jarvis">

      <!-- Startup image for web apps -->
      <link rel="apple-touch-startup-image" href="img/splash/ipad-landscape.png" media="screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:landscape)">
      <link rel="apple-touch-startup-image" href="img/splash/ipad-portrait.png" media="screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:portrait)">
      <link rel="apple-touch-startup-image" href="img/splash/iphone.png" media="screen and (max-device-width: 320px)">

      <link type="text/css" rel="stylesheet" href="/static/css/login.css"></link>
      <link type="text/css" rel="stylesheet" href="/static/bootstrap3/css/bootstrap.css"></link>
  </head>

  <body class="eternity-form scroll-animations-activated">
  <section data-panel="sixth" id="loginPage" class="colorBg6 colorBg dark active">
          <div class="container">
          <div class="login-form-section">
              <br>
              <br>
              <br>

              <div data-animation="bounceInLeft" class="forgot-password-section animated bounceInLeft">
                  <div class="section-title">
                     <h3>Login</h3>
                  </div>
                  
                  <div class="forgot-content">
                      <form method ="post" id="target" action="/index/">
                          <div class="textbox-wrap">
                              <div class="input-group">
                                 <span class="input-group-addon "><i
                                      class="glyphicon glyphicon-user"></i></span> <input type="text"
                                      placeholder="Username" name="username" class="form-control" required="required">
                              </div>
                          </div>
                          <div class="textbox-wrap">
                              <div class="input-group">
                                 <span class="input-group-addon "><i
                                      class="glyphicon glyphicon-lock"></i></span> <input type="password"
                                      placeholder="Password" name="password" class="form-control "
                                      required="required">
                              </div>
                          </div>
                          <div class="forget-form-action clearfix">
                             <button class="btn btn-success pull-right green-btn"
                                  type="submit">
                                  LogIn &nbsp; <i class="glyphicon glyphicon-chevron-right"></i>
                              </button>
                          </div>
                      </form>
                  </div>
              </div>
          </div>
          </div>
      </section>
      <script type="text/javascript" src="/static/js/jquery-1.9.1.js"></script>
      <script type="text/javascript" src="/static/bootstrap3/js/bootstrap.min.js"></script>

      <script type="text/javascript">
          $(function() {
              $(".form-control").focus(function() {
                  $(this).closest(".textbox-wrap").addClass("focused");
              }).blur(function() {
                  $(this).closest(".textbox-wrap").removeClass("focused");
              });

              if('{{login_err}}') {
                  var html = '<div data-animation-delay=".2s" data-animation="fadeInRightBig" class="login-form-links link1 animated fadeInRightBig"						style="animation-delay: 0.2s;"><h4 class="blue">{{login_err}}</h4></div>'
                  $('div.login-form-section').append(html);
              }
          });
      </script>
  </body>
  </html>
```
## django admin 密码重置

```
python manage.py shell


然后获取你的用户名，并且重设密码：
from django.contrib.auth.models import User 
user = User.objects.get(username='admin')
user.set_password('new_password')
user.save()
```
这样就可以使用新密码进行登陆了
