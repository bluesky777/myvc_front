'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresCtrl', ['$scope', '$rootScope', 'RProfesores', 'Restangular', '$interval', '$state', ($scope, $rootScope, RProfesores, Restangular, $interval, $state)->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	
	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.profesores.editar', {profe_id: row.id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row
		$state.go('panel.profesores.eliminar', {profe_id: row.id})


	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'fecha_nac', displayName: 'Nacimiento'  }
			{ field: 'user_id', displayName: 'Usuario', enableCellEdit: false }
			{ field: 'facebook'  }
			{ field: 'celular' }
		]
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					Restangular.one('profesores/update', rowEntity.id).customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Profesor actualizado con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)

	
	RProfesores.getList().then((data)->
		$scope.gridOptions.data = data;
	)

	$scope.$on 'profesorcreado', (data, prof)->
		$scope.gridOptions.data.push prof
		console.log $scope.gridOptions.data

	return
])