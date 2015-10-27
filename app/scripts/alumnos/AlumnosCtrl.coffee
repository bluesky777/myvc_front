'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'RAlumnos', 'Restangular', 'uiGridConstants', 'GruposServ', '$modal', '$filter', 'AuthService', ($scope, App, $rootScope, $state, $interval, RAlumnos, Restangular, uiGridConstants, GruposServ, $modal, $filter, AuthService)->

	AuthService.verificar_acceso()

	$scope.bigLoader = true
	$scope.dato = {}
	$scope.dato.mostrartoolgrupo = true
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid

	stop = $interval( ()->
		$scope.bigLoader = false
	, 1000)

	$scope.dato.grupo = ''
	GruposServ.getGrupos().then((r)->
		$scope.grupos = r

	)

	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row

		modalInstance = $modal.open({
			templateUrl: App.views + 'alumnos/removeAlumno.tpl.html'
			controller: 'RemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					row
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
			console.log 'Resultado del modal: ', alum
		)

	$scope.matricularUno = (row)->
		if not $scope.dato.grupo.id
			$scope.toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = {alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id}
		
		console.log 'Argumentos: ', datos

		Restangular.all('matriculas/matricularuno/'+datos.alumno_id+'/'+datos.grupo_id).post().then((r)->
			console.log 'Matriculado. ', r
			row.matricula_id = r.id
			row.grupo_id = r.grupo_id
			row.nombregrupo = $scope.dato.grupo.nombre
			row.abrevgrupo = $scope.dato.grupo.abrev
			row.actual = 1
			$scope.toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			console.log 'Falla al matricularlo. ', r2
			$scope.toastr.error 'No se pudo matricular el alumno.', 'Error'

		)


	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		Restangular.one('alumnos/update', fila.alumno_id).customPUT(fila).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.pazysalvo = !fila.pazysalvo
			$scope.toastr.error 'Cambio no guardado', 'Error'
			console.log 'Falló al intentar guardar: ', r2
		)
		

	$scope.resetPass = (row)->
		console.log 'Presionado para resetear pass: ', row

		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve: 
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			console.log 'Resultado del modal: ', user
		)




	$scope.eliminarMatricula = (row)->
		console.log row

		Restangular.all('matriculas/destroy/'+row.matricula_id).remove().then((r)->
			console.log 'Desmatriculado. ', r
			row.currentyear = 0
			$scope.toastr.success 'Alumno desmatriculado'
			return row
		, (r2)->
			console.log 'No se pudo desmatricular.', r2
			$scope.toastr.error 'No se pudo desmatricular', 'Problema'
		)

	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	btMatricular = "#{App.views}directives/botonesMatricular.tpl.html"
	btPazysalvo = "#{App.views}directives/botonesPazysalvo.tpl.html"
	btUsuario = "#{App.views}directives/botonesResetPassword.tpl.html"


	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'alumno_id', displayName:'Id', width: 50, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'no_matricula', maxWidth: 50, enableSorting: false, enableColumnMenu: false }
			{ name: 'edicion', displayName:'Edición', width: 60, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'nombres', 
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false }
			{ field: 'apellidos', filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ field: 'sexo', width: 60 }
			{ field: 'abrevgrupo', displayName: 'Grupo', enableCellEdit: false, cellTemplate: btMatricular, filter: {
					condition: uiGridConstants.filter.CONTAINS,
					placeholder: 'Ej: 8A'
				}, 
			}
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario }
			# { field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date'}
			{ field: 'deuda', displayName: 'Deuda', cellTemplate: btPazysalvo }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				console.log 'Fila editada, ', rowEntity, ' Column:', colDef, ' newValue:' + newValue + ' oldValue:' + oldValue ;
				
				if newValue != oldValue

					if colDef.field == "sexo"
						if newValue == 'M' or newValue == 'F'
							# Es correcto...
							Restangular.one('alumnos/update', rowEntity.alumno_id).customPUT(rowEntity).then((r)->
								$scope.toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
							, (r2)->
								$scope.toastr.error 'Cambio no guardado', 'Error'
								console.log 'Falló al intentar guardar: ', r2
							)
						else
							$scope.toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
					else

						Restangular.one('alumnos/update', rowEntity.alumno_id).customPUT(rowEntity).then((r)->
							$scope.toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
						, (r2)->
							$scope.toastr.error 'Cambio no guardado', 'Error'
							console.log 'Falló al intentar guardar: ', r2
						)

				$scope.$apply()
			)

	
	RAlumnos.getList().then((data)->
		$scope.gridOptions.data = data;
	)

	$scope.borrar = (alum)->
		alum.delete().then((r)->
			console.log 'Eliminado con éxito', r
			$scope.toastr.success 'El alumno fue eliminado', 'Éxito'
		, (r)->
			console.log 'No se pudo eliminar', r, alum
			$scope.toastr.error 'No se pudo eliminar el alumno', 'Error'
		)


	$scope.$on 'alumnoguardado', (data, alum)->
		$scope.gridOptions.data.push alum

	return
])

.controller('RemoveAlumnoCtrl', ['$scope', '$modalInstance', 'alumno', 'Restangular', 'toastr', ($scope, $modalInstance, alumno, Restangular, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		Restangular.all('alumnos/destroy/'+alumno.alumno_id).remove().then((r)->
			toastr.success 'Alumno eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al alumno.', 'Problema'
			console.log 'Error eliminando alumno: ', r2
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

