'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'uiGridConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $rootScope, $state, $interval, uiGridConstants, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	$scope.bigLoader = true
	$scope.dato = {}
	$scope.dato.mostrartoolgrupo = true
	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid
	$scope.perfilPath = App.images+'perfil/'



	$scope.dato.grupo = ''
	$http.get('::grupos').then((r)->
		$scope.grupos = r.data
	)

	$scope.editar = (row)->
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/removeAlumno.tpl.html'
			controller: 'RemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					row
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
		)

	$scope.matricularUno = (row)->
		if not $scope.dato.grupo.id
			toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = {alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id}
		
		$http.post('::matriculas/matricularuno/'+datos.alumno_id+'/'+datos.grupo_id).then((r)->
			r = r.data
			row.matricula_id = r.id
			row.grupo_id = r.grupo_id
			row.nombregrupo = $scope.dato.grupo.nombre
			row.abrevgrupo = $scope.dato.grupo.abrev
			row.actual = 1
			toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

		)


	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		$http.put('::alumnos/update/' + fila.alumno_id, fila).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.pazysalvo = !fila.pazysalvo
			toastr.error 'Cambio no guardado', 'Error'
		)
		

	$scope.resetPass = (row)->
		
		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve: 
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			#console.log 'Resultado del modal: ', user
		)




	$scope.eliminarMatricula = (row)->

		$http.delete('::matriculas/destroy/'+row.matricula_id).then((r)->
			row.currentyear = 0
			toastr.success 'Alumno desmatriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo desmatricular', 'Problema'
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	btMatricular = "==directives/botonesMatricular.tpl.html"
	btPazysalvo = "==directives/botonesPazysalvo.tpl.html"
	btUsuario = "==directives/botonesResetPassword.tpl.html"


	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'alumno_id', displayName:'Id', width: 50, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'no_matricula', maxWidth: 50, enableSorting: false, enableColumnMenu: true }
			{ name: 'edicion', displayName:'Edición', width: 60, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'nombres', minWidth: 80,
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false }
			{ field: 'apellidos', minWidth: 80, filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ field: 'sexo', width: 60 }
			{ field: 'abrevgrupo', displayName: 'Grupo', enableCellEdit: false, cellTemplate: btMatricular, minWidth: 150, filter: {
					condition: uiGridConstants.filter.CONTAINS,
					placeholder: 'Ej: 8A'
				}, 
			}
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, minWidth: 150 }
			# { field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date'}
			{ field: 'deuda', displayName: 'Deuda', cellTemplate: btPazysalvo, minWidth: 150 }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue

					if colDef.field == "sexo"
						if newValue == 'M' or newValue == 'F'
							# Es correcto...
							$http.put('::alumnos/update/'+rowEntity.alumno_id, rowEntity).then((r)->
								toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
							, (r2)->
								toastr.error 'Cambio no guardado', 'Error'
							)
						else
							toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
					else

						$http.put('::alumnos/update/'+rowEntity.alumno_id, rowEntity).then((r)->
							toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
						, (r2)->
							toastr.error 'Cambio no guardado', 'Error'
						)

				$scope.$apply()
			)

	
	$http.get('::alumnos').then((r)->
		$scope.gridOptions.data = r.data;
	)


	$scope.$on 'alumnoguardado', (data, alum)->
		$scope.gridOptions.data.push alum

	return
])

.controller('RemoveAlumnoCtrl', ['$scope', '$uibModalInstance', 'alumno', '$http', 'toastr', ($scope, $modalInstance, alumno, $http, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		$http.delete('::alumnos/destroy/'+alumno.alumno_id).then((r)->
			toastr.success 'Alumno enviado a la papelera.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
