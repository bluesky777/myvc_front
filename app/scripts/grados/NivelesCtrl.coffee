'use strict'

angular.module('myvcFrontApp')
.controller 'NivelesCtrl', ['$scope', '$filter', '$rootScope', '$state', '$interval', 'RNiveles', ($scope, $filter, $rootScope, $state, $interval, RNiveles) ->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.niveles.editar', {nivel_id: row.id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row
		row.remove().then((r)->
			$scope.niveles = $filter('filter')($scope.niveles, {id: '!'+r.id})
			$scope.gridOptions.data = $scope.niveles
		, (r)->
			console.log 'No se pudo eliminar', r
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'orden', type: 'number', maxWidth: 50, enableSorting: false }
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false, enableCellEditOnFocus: true }
			{ field: 'abrev', displayName:'Abreviatura', enableCellEditOnFocus: true }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					rowEntity.put().then((r)->
						$scope.toastr.success 'Nivel actualizado con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)

	

	RNiveles.getList().then((data)->
		$scope.niveles = data
		$scope.gridOptions.data = $scope.niveles
	)
	return
]
