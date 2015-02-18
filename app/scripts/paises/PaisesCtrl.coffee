'use strict'

angular.module("myvcFrontApp")

.controller('PaisesCtrl', ['$scope', '$rootScope', '$interval', ($scope, $rootScope, $interval)->

	$scope.bigLoader = true

	stop = $interval( ()->
		$scope.bigLoader = false
	, 1000)

	$scope.gridOptions = 
		enableSorting: true,
		columnDefs: [
			{ field: 'pais' }
			{ field: 'abreviación' }
			{ field: 'id' }
		]
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	#$scope.gridOptions.data = data;

	return
])