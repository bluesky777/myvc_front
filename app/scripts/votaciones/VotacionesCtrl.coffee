'use strict'

angular.module("myvcFrontApp")

.controller('VotacionesCtrl', ['$scope', '$filter', '$http', 'resolved_user', 'App', 'toastr', ($scope, $filter, $http, resolved_user, App, toastr)->


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

	$scope.date = {dateOptions: { startingDay: 1 } }

	$scope.addAspiracion = ()->
		$scope.votacion.aspiraciones.push {aspiracion: '', abrev: ''}

	$scope.removeAspiracion = (indice)->
		$scope.votacion.aspiraciones.splice indice, 1


	$scope.addAspiracionEdit = (votacion_id)->
		$http.post('::aspiraciones/store', {votacion_id: votacion_id}).then((r)->
			toastr.success 'Aspiración creada.'
			$scope.votacionEdit.aspiraciones.push {id: r.data.id, aspiracion: '', abrev: ''}
		, (r2)->
			toastr.error 'No se pudo crear aspiración.'
		)


	$scope.updateAspiracionEdit = (aspiracion)->
		$http.put('::aspiraciones/update', aspiracion).then((r)->
			toastr.success 'Aspiración modificada.'
		, (r2)->
			toastr.error 'No se pudo modificar aspiración.'
		)


	$scope.removeAspiracionEdit = (aspiracion)->
		$http.delete('::aspiraciones/destroy/'+aspiracion.id).then((r)->
			toastr.success 'Aspiración eliminada.'
			$scope.votacionEdit.aspiraciones =  $filter('filter')($scope.votacionEdit.aspiraciones, {id: '!'+aspiracion.id})
		, (r2)->
			toastr.error 'No se pudo eliminar aspiración.'
		)



	$scope.editar = (row)->
		$scope.editing = true
		$scope.votacionEdit = row

	$scope.eliminar = (row)->
		$http.delete('::votaciones/destroy/'+row.id).then((r)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {id: '!'+row.id})
		, (r2)->
			toastr.error 'No se pudo eliminar.'
		)

	$scope.cambiarInAction = (row)->
		$http.put('::votaciones/set-in-action', {id: row.id, in_action: row.in_action}).then((r)->
			if row.in_action
				for vot in $scope.gridOptions.data
					if row.id != vot.id
						vot.in_action = false
			else
				row.in_action = false

			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo poner en acción.'
		)


	$scope.cambiarVotanProfes = (row)->
		$http.put('::votaciones/set-votan-profes', {id: row.id, votan_profes: row.votan_profes}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar votan profes.'
		)

	$scope.cambiarVotanAcudientes = (row)->
		$http.put('::votaciones/set-votan-acudientes', {id: row.id, votan_acudientes: row.votan_acudientes}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar votan acudientes.'
		)

	$scope.cambiarLocked = (row)->
		$http.put('::votaciones/set-locked', {id: row.id, locked: row.locked}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar bloqueo.'
		)

	$scope.cambiarPermisoVerResults = (row)->
		$http.put('::votaciones/set-permiso-ver-results', {id: row.id, can_see_results: row.can_see_results}).then((r)->
			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar el permiso.'
		)

	$scope.cambiarEventoActual = (row)->
		$http.put('::votaciones/set-actual', {id: row.id, actual: row.actual}).then((r)->
			if row.actual
				for vot in $scope.gridOptions.data
					if row.id != vot.id
						vot.actual = false
			else
				row.actual = false

			toastr.success 'Cambiado'
		, (r2)->
			toastr.error 'No se pudo volver actual.'
		)



	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	btActual = "==votaciones/botonEventoActual.tpl.html"
	btBloq = "==votaciones/botonEventoLocked.tpl.html"
	btProfes = "==votaciones/botonVotanProfes.tpl.html"
	btAcud = "==votaciones/botonVotanAcudientes.tpl.html"
	btAccion = "==votaciones/botonEventoInAction.tpl.html"
	btPermiso = "==votaciones/botonPermisoVerResults.tpl.html"

	$scope.gridOptions =
		enableSorting: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'id', displayName:'Id', width: 40, enableFiltering: false, enableCellEdit: false}
			{ name: 'edicion', displayName:'Edición', width: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombre', enableHiding: false, minWidth: 110 }
			{ field: 'locked', displayName: 'Bloqueado', cellTemplate: btBloq, minWidth: 80 }
			{ field: 'votan_profes', displayName: 'Profes votan', minWidth: 80, cellTemplate: btProfes }
			{ field: 'votan_acudientes', displayName: 'Acudientes votan', minWidth: 80, cellTemplate: btAcud }
			{ field: 'actual', displayName: 'Actual', cellTemplate: btActual, minWidth: 80}
			{ field: 'in_action', displayName: 'En acción', cellTemplate: btAccion, minWidth: 80 }
			{ field: 'can_see_results', displayName: 'Permiso', cellTemplate: btPermiso, minWidth: 80 }
			{ field: 'fecha_inicio', displayName:'Inicia', cellFilter: "date:mediumDate", type: 'date', minWidth: 80}
			{ field: 'fecha_fin', displayName: 'Termina', cellFilter: "date:mediumDate", type: 'date', minWidth: 80 }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue

					$http.put('::votaciones/update/'+rowEntity.id, rowEntity).then((r)->
						toastr.success 'Evento actualizado con éxito', 'Actualizado'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)

				$scope.$apply()
			)

	$http.get('::votaciones').then((data)->
		$scope.gridOptions.data = data.data;
	, (r2)->
		toastr.error 'Error trayendo los eventos.'
	)

	$scope.crear = ()->
		$http.post('::votaciones/store', $scope.votacion).then((r)->
			r = r.data
			if r.actual
				angular.forEach($scope.gridOptions.data, (value, key)->
					value.actual = 0
				)

			$scope.gridOptions.data.push r

		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

	$scope.guardar = ()->
		$http.post('::votaciones/update/'+$scope.votacionEdit.id, $scope.votacionEdit).then((r)->
			toastr.success 'Se hizo el put de la votación'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)


	return
])
