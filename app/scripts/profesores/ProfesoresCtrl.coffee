'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresCtrl', ['$scope', '$rootScope', 'RProfesores', 'Restangular', '$interval', '$state', 'App', '$filter', ($scope, $rootScope, RProfesores, Restangular, $interval, $state, App, $filter)->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.current_year = $scope.USER.year_id
	$scope.mostrandoTodos = false
	
	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.profesores.editar', {profe_id: row.id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row
		$state.go('panel.profesores.eliminar', {profe_id: row.id})


	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	btGrid3 = "#{App.views}profesores/botonContratar.tpl.html"

	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'id', displayName:'Id', maxWidth: 50, enableFiltering: false, enableCellEdit: false}
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ name: 'contrato', displayName:'Contrato', maxWidth: 75, enableSorting: false, enableFiltering: false, cellTemplate: btGrid3, enableCellEdit: false}
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'fecha_nac', displayName: 'Nacimiento'  }
			{ field: 'username', displayName: 'Usuario', enableCellEdit: false }
			{ field: 'facebook'  }
			{ field: 'celular' }
		]
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
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
		console.log 'profesorcreado, ', data, prof
		$scope.gridOptions.data.push prof
		console.log $scope.gridOptions.data

	$scope.mostrarTodos = ()->
		$scope.mostrandoTodos = true

	$scope.ocultarTodos = ()->
		$scope.mostrandoTodos = false

	$scope.quitarContrato = (contrato_id)->
		Restangular.one('contratos/destroy/' + contrato_id).customDELETE().then((r)->
			$scope.toastr.success 'Quitado de este año ' + $scope.USER.year.year

			$scope.gridCurrentOptions.data = $filter('filter')($scope.gridCurrentOptions.data, {contrato_id: '!'+contrato_id})
			
			actual = $filter('filter')($scope.gridOptions.data, {contrato_id: contrato_id})[0]
			actual.year_id = null
		, (r2)->
			console.log 'No se pudo contratar', r2
			$scope.toastr.error 'No se pudo agregar el profesor al presente año', 'Problema'
		)

	$scope.contratar = (row)->
		Restangular.one('contratos').customPOST({profesor_id: row.id}).then((r)->
			$scope.toastr.success row.nombres + ' contratado para este año'

			$scope.gridCurrentOptions.data.push r[0]

			actual = $filter('filter')($scope.gridOptions.data, {contrato_id: row.contrato_id})[0]
			actual.year_id = $scope.current_year
			actual.contrato_id = r[0].contrato_id
		, (r2)->
			console.log 'No se pudo contratar'
			$scope.toastr.error 'No se pudo agregar el profesor al presente año', 'Problema'
		)


	btGridQuitar = '<a tooltip="Quitar de año actual" tooltip-placement="left" class="btn btn-default btn-xs shiny danger" ng-click="grid.appScope.quitarContrato(row.entity.contrato_id)"><i class="fa fa-times "></i></a>'

	$scope.gridCurrentOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'id', displayName:'Id', maxWidth: 50, enableFiltering: false, enableCellEdit: false}
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGridQuitar, enableCellEdit: false}
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'fecha_nac', displayName: 'Nacimiento'  }
			{ field: 'username', displayName: 'Usuario', enableCellEdit: false }
			{ field: 'facebook'  }
			{ field: 'celular' }
		]
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue
					Restangular.one('profesores/update', rowEntity.profesor_id).customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Profesor actualizado con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)

	Restangular.all('contratos').getList().then((r)->
		$scope.gridCurrentOptions.data = r
	, (r2)->
		console.log 'No se pudo traer los profesores contrados. ', r2
		$scope.toastr.error 'No se trajeron los profesores contratados'
	)
	

	return
])


