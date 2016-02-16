'use strict'

angular.module("myvcFrontApp")

.controller('VotacionesCtrl', ['$scope', '$filter', '$rootScope', 'RVotaciones', 'Restangular', 'resolved_user', 'App', 'toastr', ($scope, $filter, $rootScope, RVotaciones, Restangular, resolved_user, App, toastr)->


	$scope.data = {} # Para el popup del Datapicker
	$scope.editing = false
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.votacionEdit = {}

	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
		aspiraciones: [{aspiracion: '', abrev: ''}]
	}

	$scope.dateOptions = {
		startingDay: 1
	}

	$scope.addAspiracion = ()->
		$scope.votacion.aspiraciones.push {aspiracion: '', abrev: ''}

	$scope.removeAspiracion = (indice)->
		$scope.votacion.aspiraciones.splice indice, 1


	$scope.addAspiracionEdit = (votacion_id)->
		Restangular.one('aspiraciones/store').customPOST({votacion_id: votacion_id}).then((r)->
			toastr.success 'Aspiración creada.'
			$scope.votacionEdit.aspiraciones.push {id: r.id, aspiracion: '', abrev: ''}
		, (r2)->
			console.log 'No se pudo crear aspiración.', r2
		)
		

	$scope.updateAspiracionEdit = (aspiracion)->
		Restangular.one('aspiraciones/update').customPUT(aspiracion).then((r)->
			toastr.success 'Aspiración modificada.'
		, (r2)->
			console.log 'No se pudo modificar aspiración.', r2
		)
		

	$scope.removeAspiracionEdit = (aspiracion)->
		Restangular.one('aspiraciones/destroy').customDELETE(aspiracion.id).then((r)->
			toastr.success 'Aspiración eliminada.'
			$scope.votacionEdit.aspiraciones =  $filter('filter')($scope.votacionEdit.aspiraciones, {id: '!'+aspiracion.id})
		, (r2)->
			console.log 'No se pudo eliminar aspiración.', r2
		)
		


	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$scope.editing = true
		$scope.votacionEdit = row

	$scope.eliminar = (row)->
		Restangular.all('votaciones/destroy/'+row.id).remove().then((r)->
			console.log 'Se ha eliminado: ', r
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+row.id}) ;
		, (r2)->
			console.log 'No se pudo eliminar.', r2
		)

	$scope.cambiarInAction = (row)->
		Restangular.one('votaciones/set-in-action').customPUT({id: row.id, in_action: row.in_action}).then((r)->
			console.log 'Se ha cambiado: ', r
			if row.in_action 
				for vot in $scope.gridOptions.data
					if row.id != vot.id
						vot.in_action = false
			else 
				row.in_action = false
				
			toastr.success 'Cambiado'
		, (r2)->
			console.log 'No se pudo poner en acción.', r2
		)


	$scope.cambiarLocked = (row)->
		Restangular.one('votaciones/set-locked').customPUT({id: row.id, locked: row.locked}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			console.log 'No se pudo cambiar bloqueo.', r2
		)

	$scope.cambiarEventoActual = (row)->
		Restangular.one('votaciones/set-actual').customPUT({id: row.id, actual: row.actual}).then((r)->
			console.log 'Se ha vuelto actual: ', r
			if row.actual 
				for vot in $scope.gridOptions.data
					if row.id != vot.id
						vot.actual = false
			else 
				row.actual = false

			toastr.success 'Cambiado'
		, (r2)->
			console.log 'No se pudo volver actual.', r2
		)



	btGrid1 = '<a tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	btActual = "#{App.views}votaciones/botonEventoActual.tpl.html"
	btBloq = "#{App.views}votaciones/botonEventoLocked.tpl.html"
	btAccion = "#{App.views}votaciones/botonEventoInAction.tpl.html"

	$scope.gridOptions = 
		enableSorting: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'id', displayName:'Id', width: 40, enableFiltering: false, enableCellEdit: false}
			{ name: 'edicion', displayName:'Edición', width: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false, minWidth: 110 }
			{ field: 'locked', displayName: 'Bloqueado', maxWidth: 60, cellTemplate: btBloq, minWidth: 80 }
			{ field: 'actual', displayName: 'Actual', maxWidth: 60, cellTemplate: btActual, minWidth: 80}
			{ field: 'in_action', displayName: 'En acción', maxWidth: 60, cellTemplate: btAccion, minWidth: 80 }
			{ field: 'fecha_inicio', displayName:'Inicia', cellFilter: "date:mediumDate", type: 'date', width: 80}
			{ field: 'fecha_fin', displayName: 'Termina', cellFilter: "date:mediumDate", type: 'date', width: 80 }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue

					Restangular.one('votaciones/update', rowEntity.id).customPUT(rowEntity).then((r)->
						$scope.toastr.success 'Evento actualizado con éxito', 'Actualizado'
					, (r2)->
						$scope.toastr.error 'Cambio no guardado', 'Error'
						console.log 'Falló al intentar guardar: ', r2
					)

				$scope.$apply()
			)

	RVotaciones.getList().then((data)->
		$scope.gridOptions.data = data;
	, (r2)->
		console.log 'Error trayendo los eventos. ', r2
	)

	$scope.crear = ()->
		Restangular.all('votaciones/store').post($scope.votacion).then((r)->
			console.log 'Se hizo el post de la votación', r

			if r.actual
				angular.forEach($scope.gridOptions.data, (value, key)->
					value.actual = 0
				)
				
			$scope.gridOptions.data.push r

		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.guardar = ()->
		$scope.votacionEdit.put().then((r)->
			console.log 'Se hizo el put de la votación', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)


	return
])