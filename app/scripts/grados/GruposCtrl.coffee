'use strict'

angular.module('myvcFrontApp')
.controller('GruposCtrl', ['$scope', '$filter', '$state', 'grados', 'profesores', '$uibModal', 'App', 'Restangular', 'toastr', ($scope, $filter, $state, grados, profesores, $modal, App, Restangular, toastr) ->

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	$scope.grados = grados
	$scope.profesores = profesores

	$scope.editar = (row)->
		$state.go('panel.grupos.editar', {grupo_id: row.id})

	$scope.eliminar = (row)->
		
		modalInstance = $modal.open({
			templateUrl: App.views + 'grados/removeGrupo.tpl.html'
			controller: 'RemoveGrupoCtrl'
			resolve: 
				grupo: ()->
					row
		})
		modalInstance.result.then( (grupo)->
			$scope.grupos = $filter('filter')($scope.grupos, {id: '!'+grupo.id})
			$scope.gridOptions.data = $scope.grupos
		)


	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	btGrid3 = '<a uib-tooltip="Listado de alumnos" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ui-sref="panel.listalumnos({grupo_id: row.entity.id})"><i class="fa fa-users "></i></a>'
	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'orden', type: 'number', maxWidth: 60 }
			{ name: 'edicion', displayName:'Edición', maxWidth: 80, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2 + btGrid3, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false }
			{ field: 'abrev', displayName:'Abreviatura', maxWidth: 50, enableSorting: false }
			{ field: 'titular_id', displayName: 'Titular', editDropdownOptionsArray: profesores, cellFilter: 'mapProfesores:grid.appScope.profesores', editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'profesor_id', editDropdownValueLabel: 'nombres' }
			{ field: 'grado_id', displayName: 'Grado', editDropdownOptionsArray: grados, cellFilter: 'mapGrado:grid.appScope.grados', editableCellTemplate: 'ui-grid/dropdownEditor', editDropdownIdLabel: 'id', editDropdownValueLabel: 'nombre' }
			# { name: 'nn', displayName: '', maxWidth: 20, enableSorting: false, enableFiltering: false }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
					dato = 
						abrev:		rowEntity.abrev
						grado_id:	rowEntity.grado_id
						nombre:		rowEntity.nombre
						orden:		rowEntity.orden
						titular_id:	rowEntity.titular_id
						id:			rowEntity.id

					Restangular.one('grupos/update').customPUT(dato).then((r)->
						toastr.success 'Grupo actualizado con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)
				$scope.$apply()
			)

	Restangular.one('grupos').getList().then((data)->
		$scope.grupos = data
		$scope.gridOptions.data = $scope.grupos;
	)

	$scope.$on 'grupocreado', (ev, grupo)->
		$scope.grupos.push grupo
		$scope.gridOptions.data = $scope.grupos;
	
	return
])

.filter('mapGrado', ['$filter', ($filter)->

	return (input, grados)->
		if not input
			return 'Elija...'
		else
			grad = $filter('filter')(grados, {id: input})[0]
			return  grad.nombre
])



.controller('RemoveGrupoCtrl', ['$scope', '$uibModalInstance', 'grupo', 'Restangular', 'toastr', ($scope, $modalInstance, grupo, Restangular, toastr)->
	$scope.grupo = grupo

	$scope.ok = ()->

		Restangular.all('grupos/destroy/'+grupo.id).remove().then((r)->
			toastr.success 'Grupo '+grupo.nombre+' eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al grupo.', 'Problema'
		)
		$modalInstance.close(grupo)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])