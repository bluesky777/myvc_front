'use strict'

angular.module("myvcFrontApp")

.controller('CiudadesCtrl', ['$scope', 'toastr', '$http', ($scope, toastr, $http)->

	$scope.bigLoader = true


	$scope.gridOptions = 
		enableSorting: true,
		columnDefs: [
			{ field: 'ciudad' }
			{ field: 'pais_id' }
			{ field: 'id' }
		]
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	#$scope.gridOptions.data = data;

	return
])