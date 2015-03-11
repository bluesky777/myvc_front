angular.module("myvcFrontApp")

.controller('BitacoraCtrl', ['$scope', '$rootScope', '$state', 'Restangular', 'RAlumnos', 'RPaises', 'RCiudades', ($scope, $rootScope, $state, Restangular, RAlumnos, RPaises, RCiudades)->
	$scope.data = {} # Para el popup del Datapicker
])