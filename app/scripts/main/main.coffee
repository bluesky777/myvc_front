'use strict'

angular.module("myvcFrontApp")

.controller('MainCtrl', ['$scope', '$window', '$interval', ($scope, $window, $interval)->

	console.log 'A cambiar desde main'
	$window.location.href = 'http://localhost/myvc/public';

	return
])