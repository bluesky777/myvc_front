'use strict'

angular.module("myvcFrontApp")

.controller('AspiracionesCtrl', ['$scope', '$filter', '$rootScope', 'RAspiraciones', 'Restangular', ($scope, $filter, $rootScope, RAspiraciones, Restangular)->

	$scope.editing = false
	$scope.$scope = $scope # Para getExternalScopes de ui-Grid
	$scope.aspiracionEdit = {}

	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$scope.editing = true
		$scope.aspiracionEdit = row

	$scope.eliminar = (row)->
		row.remove().then((r)->
			console.log 'Se ha eliminado: ', r
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+r.id})
		, (r2)->
			console.log 'No se pudo eliminar.', r2
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="getExternalScopes().editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="getExternalScopes().eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	
	$scope.gridOptions = 
		enableSorting: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'aspiracion', displayName: 'Aspiración' }
			{ field: 'abrev', displayName: 'Abreviatura'}
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	RAspiraciones.getList().then((data)->
		$scope.gridOptions.data = data;
	, (r2)->
		console.log 'Error trayendo las aspiraciones. ', r2
	)
	Restangular.one('votaciones/actual').get().then((r)->
		$scope.votacion = r
	)

	$scope.crear = ()->
		$scope.aspiracion.votacion_id = $scope.votacion.id
		RAspiraciones.post($scope.aspiracion).then((r)->
			console.log 'Se hizo el post de la votación', r
			$scope.gridOptions.data.push r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.guardar = ()->
		$scope.aspiracionEdit.put().then((r)->
			console.log 'Se hizo el put de la aspiración. ', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)


	return
])
