'use strict'

angular.module('myvcFrontApp')
.controller('DefinitivasPeriodosCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$rootScope', '$filter', 'App', 'asignaturas_definitivas', 'AuthService', '$timeout', 'EscalasValorativasServ', ($scope, toastr, $http, $modal, $state, $rootScope, $filter, App, asignaturas_definitivas, AuthService, $timeout, EscalasValorativasServ) ->

	AuthService.verificar_acceso()


	$scope.asignatura 	= {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos 		  = {}
	$scope.UNIDAD 		= $scope.USER.unidad_displayname
	$scope.SUBUNIDAD 	= $scope.USER.subunidad_displayname
	$scope.UNIDADES 	= $scope.USER.unidades_displayname
	$scope.SUBUNIDADES 	= $scope.USER.subunidades_displayname
	$scope.perfilPath 	= App.images+'perfil/'
	$scope.views 		= App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.opts_picker 		= { minDate: new Date('1/1/2017'), showWeeks: false, startingDay: 0 }
	$scope.dato       = { asignatura: {} }
	$scope.ocultando_ausencias 	= true

	$scope.escala_maxima = EscalasValorativasServ.escala_maxima()

	$scope.$parent.bigLoader 	= false


	$scope.selectAsignatura = (asignatura)->
		localStorage.asignatura_id_def  = asignatura.asignatura_id
		$scope.dato.asignatura 		      = asignatura

		for asignat in $scope.asignaturas
			asignat.active = false

		asignatura.active = true



	if asignaturas_definitivas == 'Sin alumnos'
		toastr.warning 'No parece que tengas acceso'
		$state.go 'panel'
	$scope.asignaturas = asignaturas_definitivas.data
	asignatura_id_def = 0



	if $scope.USER.is_superuser
		if $scope.asignaturas.length == 0
			toastr.warning 'Profesor no tiene asignaturas'
		else
			$scope.dato.asignatura.nombres_profesor = $scope.asignaturas[0].nombres_profesor




	if localStorage.asignatura_id_def
			asignatura_id_def = parseInt(localStorage.asignatura_id_def)

	for asignat in $scope.asignaturas
		if parseInt(asignat.asignatura_id) == parseInt(asignatura_id_def)
			$scope.dato.asignatura = asignat
			$scope.selectAsignatura($scope.dato.asignatura)


	#####################################################################
	######################      NOTAS       #############################
	#####################################################################


	$scope.cambiaNotaDef = (alumno, nota, nf_id)->

		if nota > $scope.escala_maxima.porc_final or nota == 'undefined' or nota == undefined
			toastr.error 'No puede ser mayor de ' + $scope.escala_maxima.porc_final, 'NO guardada', {timeOut: 8000}
			return
		$http.put('::definitivas_periodos/update', {nf_id: nf_id, nota: nota}).then((r)->
			toastr.success 'Cambiada: ' + nota
		, (r2)->
			toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
		)



	$scope.toggleNotaRecuperada = (alumno, recuperada, nf_id, periodo)->
		$http.put('::definitivas_periodos/toggle-recuperada', {nf_id: nf_id, recuperada: recuperada}).then((r)->
			if recuperada and !alumno['manual_'+periodo]
				alumno['manual_'+periodo] = 1
				toastr.success 'Indicará que es recuperada, así que también será manual.'
			else if recuperada
				toastr.success 'Recuperada'
			else
				toastr.success 'No recuperada'
		, (r2)->
			toastr.error 'No pudimos guardar la recuperación.', {timeOut: 8000}
		)

	$scope.toggleNotaManual = (alumno, manual, nf_id, periodo)->

		$http.put('::definitivas_periodos/toggle-manual', {nf_id: nf_id, manual: manual}).then((r)->
			if !manual and alumno['recuperada_'+periodo]
				alumno['recuperada_'+periodo] = 0
				toastr.success 'Será automática y no recuperada.'
			else if manual
				toastr.success 'Nota manual.'
			else
				toastr.success 'Ahora la calculará el sistema.'
		, (r2)->
			toastr.error 'No pudimos guardar la recuperación.', {timeOut: 8000}
		)



	$scope.promedioTotalDef = (alu)->

		promedio 						= (alu.nota_final_per1 + alu.nota_final_per2 + alu.nota_final_per3 + alu.nota_final_per4) / 4
		alu.nota_requerida 	= 0
		alu.total_definit 	= 0

		if promedio < $scope.nota_minima_aceptada
			alu.nota_requerida = $filter('number')($scope.nota_minima_aceptada - promedio, 0)

		alu.total_definit 	= parseFloat($filter('number')(promedio, 1))

		return alu.total_definit;





	#####################################################################
	##############   AUSENCIAS Y TARDANZAS   ############################
	#####################################################################

	$scope.toggleAusencias = ()->
		$scope.ocultando_ausencias 			= !$scope.ocultando_ausencias
		localStorage.ocultando_ausencias 	= $scope.ocultando_ausencias

	$scope.cambiaAusencia = (alumno)->

		# Si incrementó el número
		if alumno.ausencias_count > alumno.ausencias.length
			pedidas = alumno.ausencias_count - alumno.ausencias.length

			for pedida in [0..pedidas-1]
				datos =
					alumno_id: 			alumno.alumno_id
					asignatura_id: 		$scope.asignatura_id
					cantidad_ausencia: 	1
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
					asignatura_id: 		$scope.asignatura_id
					cantidad_tardanza: 	1
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
			ausencia.fecha_hora 	= new Date(ausencia.fecha_hora)
		else
			ausencia.fecha_hora 	= new Date()
		$scope.ausencia_edit 	  = ausencia
		$scope.alumno_aus_tard_edit 	= alumno
		ausencia.isOpen = !ausencia.isOpen


	$scope.clickTardanzaObject = (tardanza, alumno)->
		tardanza.backup 		= tardanza.fecha_hora
		if tardanza.fecha_hora
			tardanza.fecha_hora 	= new Date(tardanza.fecha_hora)
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
			alumno.tardanzas.push r
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




	return
])


