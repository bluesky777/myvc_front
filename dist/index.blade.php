<!doctype html> <html class="no-js"> <head> <meta charset="utf-8"> <title></title> <script type="text/javascript">FileAPI = {
        debug: true,
        //forceLoad: true, html5: false //to debug flash in HTML5 browsers
        //wrapInsideDiv: true, //experimental for fixing css issues
        //only one of jsPath or jsUrl.
        //jsPath: '/js/FileAPI.min.js/folder/', 
        //jsUrl: 'yourcdn.com/js/FileAPI.min.js',

        //only one of staticPath or flashUrl.
        //staticPath: '/flash/FileAPI.flash.swf/folder/'
        //flashUrl: 'yourcdn.com/js/FileAPI.flash.swf'
    };</script> <meta name="description" content=""> <meta name="viewport" content="width=device-width"> <!-- Place favicon.ico and apple-touch-icon.png in the root directory --> 
    {{ HTML::style('styles/vendor.f0ccca83.css'); }} 
    {{ HTML::style('styles/main.479431c5.css'); }} <!--Fonts--> <!--<link href="http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,400,600,700,300" rel="stylesheet" type="text/css">
    -->  <body ng-app="myvcFrontApp"> <!--[if lt IE 7]>
      <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
    <![endif]--> <!-- Site or application content  <div login-dialog ng-if="!isLoginPage"></div>--> <div ng-controller="ApplicationController"> <div ui-view="principal"></div> </div> <!-- Google Analytics: change UA-XXXXX-X to be your site's ID --> <!--<script>
       (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
       (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
       m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
       })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

       ga('create', 'UA-XXXXX-X');
       ga('send', 'pageview');
    </script>
    --> <!--[if lt IE 9]>
    <script src="scripts/oldieshim.76f279db.js"></script>
    <![endif]--> {{ HTML::script('scripts/vendor.304accdb.js'); }}{{ HTML::script('scripts/scripts.9edb816d.js'); }}<script src="http://code.angularjs.org/1.0.8/i18n/angular-locale_es-es.js"></script>  