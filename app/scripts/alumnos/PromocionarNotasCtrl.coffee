'use strict'

angular.module("myvcFrontApp")

.controller('PromocionarNotasCtrl', ['$scope', 'App', '$rootScope', '$state', '$timeout', 'uiGridConstants', 'uiGridEditConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $rootScope, $state, $timeout, uiGridConstants, uiGridEditConstants, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	#$scope.$parent.bigLoader			= true
	$scope.dato 						= {}
	$scope.gridScope 					= $scope # Para getExternalScopes de ui-Grid
	$scope.views 						= App.views
	$scope.perfilPath 		  	      	= App.images+'perfil/'
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm




	$scope.dato.grupo = ''
	$http.get('::grupos').then((r)->
		matr_grupo = 0

		if localStorage.matr_grupo
			matr_grupo = parseInt(localStorage.matr_grupo)

		$scope.grupos 		= r.data

		for grupo in $scope.grupos
			if parseInt(grupo.id) == parseInt(matr_grupo)
				$scope.dato.grupo = grupo
				$scope.selectGrupo($scope.dato.grupo)

	)


	$scope.selectGrupo = (grupo)->
		$scope.dato               = {}
		localStorage.matr_grupo   = grupo.id
		$scope.dato.grupo 		    = grupo

		for grup in $scope.grupos
			grup.active = false

		grupo.active = true

		$http.put("::alumnos/de-grupo/"+grupo.id).then((r)->
			$scope.alumnos = r.data.alumnos

			alumno_seleccionado_id = 0

			if localStorage.matr_grupo
				alumno_seleccionado_id = parseInt(localStorage.alumno_seleccionado_id)

			for alum in $scope.alumnos
				if parseInt(alum.id) == alumno_seleccionado_id
					$scope.dato.selected_alumno = alum
					$scope.selectAlumno($scope.dato.selected_alumno)

		)

	$scope.selectAlumno = (alumno)->
		localStorage.alumno_seleccionado_id   = alumno.id
		$scope.dato.periodo_id = undefined

		$http.put("::alumnos/years-con-notas", {alumno_id: alumno.id}).then((r)->
			$scope.years_notas = r.data.years
			$scope.years_dest = r.data.years_dest
		)


	$scope.eligirPanelNotas = (panel)->
		$scope.dato.panel_index = panel




	$scope.eligirPeriodoNotas = (grupo, periodo, num_year, panel_indice)->

		$scope.dato.periodo_id = periodo.id

		$http.put("::notas/alumno-periodo-grupo", {alumno_id: $scope.dato.selected_alumno.id, periodo_id: periodo.id, grupo_id: grupo.grupo_id}).then((r)->
			if panel_indice == 1
				$scope.datos_origen = {grupo: grupo, periodo: periodo, num_year: num_year}
				$scope.notas_origen = r.data.notas
			else
				# Aquí, grupo es year en realidad con los datos del grupo
				$scope.datos_destino = {grupo: grupo, periodo: periodo, num_year: num_year}
				$scope.notas_destino = r.data.notas
		)


	$scope.pasarNota = (asignatura)->
		if $scope.pasando_nota
			return
		else
			$scope.pasando_nota = true

		for asignat in $scope.notas_destino.asignaturas
			if asignat.asignatura_id == asignatura.asignatura_id

				if asignat.nf_id
					$scope.asign_temp = asignatura

					$http.put('::definitivas_periodos/update', {nf_id: asignat.nf_id, nota: asignatura.nota_asignatura, num_periodo: $scope.datos_destino.periodo.numero }).then((r)->

						for asignatu in $scope.notas_destino.asignaturas
							if asignatu.asignatura_id == $scope.asign_temp.asignatura_id
								asignatu.nota_asignatura   = $scope.asign_temp.nota_asignatura
								asignatu.manual            = 1

								$timeout( ()->
									$scope.$apply()
								)

						toastr.success 'Cambiada: ' + asignatura.nota_asignatura
						$scope.pasando_nota = false
					, (r2)->
						$scope.pasando_nota = false
						if r2.status == 400
							toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
						else
							toastr.error 'No pudimos guardar la nota ' + asignatura.nota_asignatura, '', {timeOut: 8000}
					)
				else
						$http.put('::definitivas_periodos/update', {alumno_id: $scope.dato.selected_alumno.id, nota: asignatura.nota_asignatura, asignatura_id: asignatura.asignatura_id, num_periodo: $scope.datos_destino.periodo.numero }).then((r)->
							toastr.success 'Creada: ' + asignatura.nota_asignatura
							r = r.data[0]

							for asignatu in $scope.notas_destino.asignaturas
								if asignatu.asignatura_id == r.asignatura_id
									asignatu.nf_id         					= r.id
									asignatu.nota_asignatura        = r.nota
									asignatu.manual 								= 1
									asignatu.recuperada 						= 0
									$scope.pasando_nota = false

									$timeout( ()->
										$scope.$apply()
									)

						, (r2)->
							$scope.pasando_nota = false
							if r2.status == 400
								toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
							else
								toastr.error 'No pudimos guardar la nota ' + asignatura.nota_asignatura, '', {timeOut: 8000}
						)





	$scope.agregarAcudiente = (rowAlum)->
		delete $rootScope.acudiente_cambiar

		modalInstance = $modal.open({
			templateUrl: '==alumnos/newAcudienteModal.tpl.html'
			controller: 'NewAcudienteModalCtrl'
			resolve:
				alumno: ()->
					rowAlum
				paises: ()->
					$scope.paises
				tipos_doc: ()->
					$scope.tipos_doc
				parentescos: ()->
					$scope.parentescos
		})
		modalInstance.result.then( (acud)->
			rowAlum.subGridOptions.data.splice(rowAlum.subGridOptions.data.length-1, 0, acud)
		, ()->
			# nada
		)



	return
])
