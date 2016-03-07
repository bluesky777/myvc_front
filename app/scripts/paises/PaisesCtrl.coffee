'use strict'

angular.module("myvcFrontApp")

.controller('PaisesCtrl', ['$scope', ($scope)->


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