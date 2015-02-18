'use strict'

angular.module('myvcFrontApp')
.controller 'GradosCtrl', ['$scope', '$filter', '$rootScope', '$state', '$interval', 'RGrados', ($scope, $filter, $rootScope, $state, $interval, RGrados) ->

	$scope.$scope = $scope # Para getExternalScopes de ui-Grid

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.grados.editar', {grado_id: row.id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row
		row.remove().then((r)->
			$scope.grados = $filter('filter')($scope.grados, {id: '!'+r.id})
			$scope.gridOptions.data = $scope.grados
		, (r)->
			console.log 'No se pudo eliminar', r
		)


	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="getExternalScopes().editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="getExternalScopes().eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false }
			{ field: 'abrev', displayName:'abreviatura', maxWidth: 50, enableSorting: false }
			{ field: 'orden', type: 'number' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	RGrados.getList().then((data)->
		$scope.grados = data
		$scope.gridOptions.data = $scope.grados;
	)
	return
]
