'use strict'

angular.module('myvcFrontApp')

.controller('ApplicationController', ['$scope', ($scope)->

	$scope.isLoginPage = false


	Date.prototype.yyyymmdd = ()->
		mm = this.getMonth() + 1; # getMonth() is zero-based
		dd = this.getDate();

		return [this.getFullYear(),
					( if mm>9 then '' else '0') + mm,
					( if dd>9 then '' else '0') + dd
				].join('-');
		 

])