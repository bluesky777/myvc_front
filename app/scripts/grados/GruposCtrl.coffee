'use strict'

angular.module('myvcFrontApp')
.controller 'GruposCtrl', ['$scope', '$filter', '$rootScope', '$state', '$interval', 'RGrupos', ($scope, $filter, $rootScope, $state, $interval, RGrupos) ->

	$scope.$scope = $scope # Para getExternalScopes de ui-Grid

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.grupos.editar', {grupo_id: row.id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row
		row.remove().then((r)->
			$scope.grupos = $filter('filter')($scope.grupos, {id: '!'+r.id})
			$scope.gridOptions.data = $scope.grupos
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
			{ field: 'abreviatura', maxWidth: 50, enableSorting: false }
			{ field: 'orden', type: 'number' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	RGrupos.getList().then((data)->
		$scope.grupos = data
		$scope.gridOptions.data = $scope.grupos;
	)
	
	return
]
