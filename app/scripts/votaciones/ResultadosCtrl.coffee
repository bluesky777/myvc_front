angular.module("myvcFrontApp")

.controller('ResultadosCtrl', ['$scope', '$filter', 'Restangular', 'App', '$state', '$modal', '$window', ($scope, $filter, Restangular, App, $state, $modal, $window)->


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}


	Restangular.one('votaciones/actual').get().then((r)->
		$scope.votacion = r
	)

	###
	$scope.gridOptions = 
		enableSorting: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'aspiracion', displayName: 'Aspiración' }
			{ field: 'abrev', displayName: 'Abreviatura'}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
	###
	Restangular.one('votos/show').get().then((r)->
		#$scope.gridOptions.data = r;
		$scope.aspiraciones = r
		console.log $scope.aspiraciones
	, (r2)->
		console.log 'Error trayendo las votaciones. ', r2
	)



	return
])
