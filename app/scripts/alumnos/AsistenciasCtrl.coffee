'use strict'

angular.module('myvcFrontApp')
.controller('AsistenciasCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$rootScope', '$filter', 'App', 'AuthService', '$timeout', 'EscalasValorativasServ', '$stateParams', 'NotasServ', ($scope, toastr, $http, $modal, $state, $rootScope, $filter, App, AuthService, $timeout, EscalasValorativasServ, $stateParams, NotasServ) ->

	AuthService.verificar_acceso()

	$scope.asignatura 	  = {}
	$scope.grupo_id       = $state.params.grupo_id
	$scope.datos 		      = {}
	$scope.perfilPath 	  = App.images+'perfil/'
	$scope.views 		      = App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.ausencia_edit 	= {} # Para editar en el popover
	$scope.tardanza_edit 	= {}
	$scope.alumno_aus_tard_edit 	= {}
	$scope.opts_picker 		= { minDate: new Date('1/1/2017'), showWeeks: false, startingDay: 0 }
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm

	$http.put('::asistencias/detailed', {con_grupos: true}).then((r)->
		$scope.alumnos      = r.data.alumnos
		$scope.grupos 			= r.data.grupos

		matr_grupo = 0

		if localStorage.matr_grupo
			matr_grupo = parseInt(localStorage.matr_grupo)

		for grupo in $scope.grupos
			if parseInt(grupo.id) == parseInt(matr_grupo)
				$scope.grupo = grupo
				$scope.traerAsistencias($scope.grupo)

	, (r2)->
		toastr.error 'No se pudo traer las notas con asignaturas.'
	)



	$scope.traerAsistencias = (grupo)->
		localStorage.matr_grupo = grupo.id

		$state.go('.', {grupo_id: grupo.id}, {notify: false});

		$http.put('::asistencias/detailed', {grupo_id: grupo.id, con_grupos: false}).then((r)->
			$scope.alumnos      = r.data.alumnos

			for alumno in $scope.alumnos
				for ausencia in alumno.ausencias
					ausencia.backup 		= ausencia.fecha_hora
					if ausencia.fecha_hora
						if ausencia.fecha_hora.replace
							ausencia.fecha_hora 	= new Date(ausencia.fecha_hora.replace(/-/g, '\/'))
					else
						ausencia.fecha_hora 	= new Date()

				for tarda in alumno.tardanzas
					tarda.backup 		= tarda.fecha_hora
					if tarda.fecha_hora
						if tarda.fecha_hora.replace
							tarda.fecha_hora 	= new Date(tarda.fecha_hora.replace(/-/g, '\/'))
					else
						tarda.fecha_hora 	= new Date()

		, (r2)->
			toastr.error 'No se pudo traer las asistencias.'
		)

		for grupo_t in $scope.grupos
			grupo_t.active = false

		grupo.active      = true
		$scope.grupo_id   = grupo.id
		$scope.grupo      = grupo



	$scope.seleccionarFila = (alumno)->
		for alum in $scope.alumnos
			alum.seleccionado = false
		alumno.seleccionado = true






	$scope.cambiaAusencia = (alumno)->

		# Si incrementó el número
		if alumno.ausencias_count > alumno.ausencias.length
			pedidas = alumno.ausencias_count - alumno.ausencias.length

			for pedida in [0..pedidas-1]
				datos =
					alumno_id: 			alumno.alumno_id
					entrada:        1
					tipo: 					'ausencia'
				# fecha_hora = new Date(numYearActual, parseInt($scope.dato.mes), dia)

				$http.post('::ausencias/store', datos).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.ausencias.push r
				, (r2)->
					toastr.warning 'No se pudo agregar ausencia.', 'Problema'
				)

		# Si bajó el número
		else if alumno.ausencias_count < alumno.ausencias.length
			pedidas = alumno.ausencias.length - alumno.ausencias_count

			for pedida in [0..pedidas-1]
				ausencia_id = alumno.ausencias[alumno.ausencias.length - pedida - 1].id

				$http.delete('::ausencias/destroy/' + ausencia_id).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.ausencias = $filter('filter')(alumno.ausencias, { id: '!'+r.id })
				, (r2)->
					toastr.warning 'No se pudo quitar ausencia.', 'Problema'
				)




	$scope.cambiaTardanza = (alumno)->

		if alumno.tardanzas_count > alumno.tardanzas.length
			pedidas = alumno.tardanzas_count - alumno.tardanzas.length

			for pedida in [0..pedidas-1]
				datos =
					alumno_id: 			alumno.alumno_id
					entrada:        1
					tipo: 					'tardanza'
				# fecha_hora = new Date(numYearActual, parseInt($scope.dato.mes), dia)

				$http.post('::ausencias/store', datos).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.tardanzas.push r
				, (r2)->
					toastr.warning 'No se pudo agregar tardanza.', 'Problema'
				)

		# Si bajó el número
		else if alumno.tardanzas_count < alumno.tardanzas.length
			pedidas = alumno.tardanzas.length - alumno.tardanzas_count

			for pedida in [0..pedidas-1]
				tardanza_id = alumno.tardanzas[alumno.tardanzas.length - pedida - 1].id

				$http.delete('::ausencias/destroy/' + tardanza_id).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.tardanzas = $filter('filter')(alumno.tardanzas, { id: '!'+r.id })
				, (r2)->
					toastr.warning 'No se pudo quitar tardanza.', 'Problema'
				)



	$scope.clickAusenciaObject = (ausencia, alumno)->
		ausencia.backup 		= ausencia.fecha_hora
		if ausencia.fecha_hora
			if ausencia.fecha_hora.replace
				ausencia.fecha_hora 	= new Date(ausencia.fecha_hora.replace(/-/g, '\/'))
		else
			ausencia.fecha_hora 	= new Date()
		$scope.ausencia_edit 	  = ausencia
		$scope.alumno_aus_tard_edit 	= alumno
		ausencia.isOpen = !ausencia.isOpen


	$scope.clickTardanzaObject = (tardanza, alumno)->
		tardanza.backup 		= tardanza.fecha_hora
		if tardanza.fecha_hora
			if tardanza.fecha_hora.replace
				tardanza.fecha_hora 	= new Date(tardanza.fecha_hora.replace(/-/g, '\/'))
		else
			tardanza.fecha_hora 	= new Date()
		$scope.tardanza_edit 	= tardanza
		$scope.alumno_aus_tard_edit 	= alumno
		tardanza.isOpen = !tardanza.isOpen



	$scope.guardarCambioAusencia = (ausencia)->
		datos =
			ausencia_id: ausencia.id
			fecha_hora: $filter('date')(ausencia.fecha_hora, 'yyyy-MM-dd HH:mm:ss')

		$http.put('::ausencias/guardar-cambios-ausencia', datos).then((r)->
			r 		= r.data
			#r.fecha_hora = new Date(r.fecha_hora)
			#alumno.tardanzas.push r
			$scope.ausencia_edit.isOpen = false
			$scope.tardanza_edit.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo agregar tardanza.', 'Problema'
		)


	$scope.cancelarCambioAusencia = (ausencia_edit)->
		ausencia_edit.isOpen = false
	$scope.cancelarCambioTardanza = (tardanza_edit)->
		tardanza_edit.isOpen = false

	$scope.eliminarAusencia = (ausencia, alumno_aus_tard_edit)->
		$http.delete('::ausencias/destroy/' + ausencia.id).then((r)->
			r 		= r.data
			alumno_aus_tard_edit.ausencias = $filter('filter')(alumno_aus_tard_edit.ausencias, { id: '!'+r.id })
			ausencia.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo quitar ausencia.', 'Problema'
		)

	$scope.eliminarTardanza = (tardanza, alumno_aus_tard_edit)->
		$http.delete('::ausencias/destroy/' + tardanza.id).then((r)->
			r 		= r.data
			alumno_aus_tard_edit.tardanzas = $filter('filter')(alumno_aus_tard_edit.tardanzas, { id: '!'+r.id })
			tardanza.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo quitar tardanza.', 'Problema'
		)







	$scope.showFrases = (alumno)->

		modalInstance = $modal.open({
			templateUrl: '==notas/showFrases.tpl.html'
			controller: 'ShowFrasesCtrl'
			size: 'lg'
			resolve:
				alumno: ()->
					alumno
				frases: ()->
					$http.get('::frases')
				asignatura: ()->
					$scope.asignatura
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (datos)->
			alumno.frases = datos.frases_asignatura
		(res)->
			console.log res
		)


	return
])





