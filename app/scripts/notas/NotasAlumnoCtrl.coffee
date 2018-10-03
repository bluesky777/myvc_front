angular.module('myvcFrontApp')
.controller('NotasAlumnoCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', 'alumnos', 'escalas', '$rootScope', '$filter', 'App', 'AuthService', 'Perfil', 'EscalasValorativasServ', '$cookies', ($scope, toastr, $http, $modal, $state, alumnos, escalas, $rootScope, $filter, App, AuthService, Perfil, EscalasValorativasServ, $cookies) ->

	AuthService.verificar_acceso()
	$scope.hasRoleOrPerm 	  = AuthService.hasRoleOrPerm
	alumnos 				        = alumnos.data

	if !alumnos == 'Sin alumnos'
		$scope.filtered_alumnos = alumnos

	$scope.perfilPath 		  = App.images+'perfil/'
	$scope.views			      = App.views
	$scope.datos			      = {grupo: ''}
	$scope.USER 			      = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.escalas 			    = escalas
	$scope.config 			    = {solo_notas_perdidas: true}


	if !$scope.hasRoleOrPerm(['alumno', 'acudiente'])
		$http.get('::grupos').then((r)->
			r = r.data
			$scope.grupos = r
		)
	else if $scope.hasRoleOrPerm(['alumno', 'acudiente'])
		console.log($scope.mis_acudidos);

	EscalasValorativasServ.escalas().then((r)->
		$scope.escalas = r
		$scope.escala_maxima = EscalasValorativasServ.escala_maxima()
	, (r2)->
		console.log 'No se trajeron las escalas valorativas', r2
	)



	$scope.verBoletin = ()=>

		for alumno in $scope.mis_acudidos
			if alumno.seleccionado == true

				if !alumno.pazysalvo
					toastr.info 'Lo sentimos. Debe estar a paz y salvo'
					return

				$cookies.putObject 'requested_alumno', [{ alumno_id: alumno.alumno_id, grupo_id: alumno.grupo_id }]

				$state.go 'panel.boletin_acudiente', {periodo_a_calcular: $scope.USER.numero_periodo}




	$scope.verMiBoletin = ()=>

			if !$scope.USER.pazysalvo
				toastr.info 'Lo sentimos. Debe estar a paz y salvo'
				return

			$cookies.putObject 'requested_alumno', [{ alumno_id: $scope.USER.persona_id, grupo_id: $scope.USER.grupo_id }]

			$state.go 'panel.boletin_acudiente', {periodo_a_calcular: $scope.USER.numero_periodo}





	$scope.cambiaNotaComport = (nota, periodo)->
		if $scope.datos.grupo.titular_id != $scope.USER.persona_id and !$scope.hasRoleOrPerm('admin')
			toastr.warning 'No eres el titular para cambiar comportamiento.'
			return

		if nota.id
			temp = nota.nota

			$http.put('::nota_comportamiento/update/'+nota.id, {nota: nota.nota}).then((r)->
				toastr.success 'Nota cambiada: ' + nota.nota
			, (r2)->
				toastr.error 'No pudimos guardar la nota ' + nota.nota
				nota.nota = temp
			)

		else
			temp              = {}
			temp.nota         = nota.nota
			temp.year_id      = periodo.year_id
			temp.alumno_id    = $scope.datos.selected_alumno.alumno_id
			temp.periodo_id   = periodo.id

			$http.put('::nota_comportamiento/crear', temp).then((r)->
				nota_temp 	= r.data.nota_comport
				nota.id 				= nota_temp.id
				nota.year_id 		= nota_temp.year_id
				nota.nombres 		= nota_temp.nombres
				nota.apellidos 	= nota_temp.apellidos
				nota.alumno_id 	= nota_temp.alumno_id
				nota.foto_id 		= nota_temp.foto_id
				nota.foto_nombre 	= nota_temp.foto_nombre
				nota.sexo 			= nota_temp.sexo
				nota.periodo_id = nota_temp.periodo_id

				toastr.success 'Nota creada: ' + nota.nota
			, (r2)->
				toastr.error 'No pudimos guardar la nota ' + temp.nota
				nota = temp
			)


	$scope.verNotasAlumno = (alumno_id, grupo_id)->

		if !alumno_id
			alumno_id = $scope.datos.selected_alumno.alumno_id

		if !grupo_id
			grupo_id  = $scope.datos.grupo.id

		$http.get('::notas/alumno/'+alumno_id+'/'+grupo_id).then((r)->
			r = r.data
			if r[0]
				$scope.alumno_traido = r[0]
				$scope.periodos_notas = r[0].periodos

				for asig in $scope.alumno_traido.notas_tercer_per
					nota_faltante       =  $scope.USER.nota_minima_aceptada * 4 - asig.nota_final_year*3
					asig.nota_faltante  = if nota_faltante <= 0 then '' else nota_faltante

			else
				$scope.periodos_notas = undefined
				toastr.warning 'Sin matrícula este año.'
		, (r2)->
			toastr.warning 'Lo sentimos, No se trajeron las notas'
		)


	$scope.seleccionarAcudido = (alumno)->

		if !alumno.pazysalvo
			toastr.info 'Lo sentimos. Debe estar a paz y salvo'
			return

		for alu in $scope.mis_acudidos
			alu.seleccionado = false
		alumno.seleccionado = true


		$http.get('::notas/alumno/'+alumno.alumno_id+'/'+alumno.grupo_id).then((r)->
			r = r.data
			if r[0]
				$scope.alumno_traido = r[0]
				$scope.periodos_notas = r[0].periodos

				for asig in $scope.alumno_traido.notas_tercer_per
					nota_faltante       =  $scope.USER.nota_minima_aceptada * 4 - asig.nota_final_year*3
					asig.nota_faltante  = if nota_faltante <= 0 then '' else nota_faltante

			else
				$scope.periodos_notas = undefined
				toastr.warning 'Sin matrícula este año.'
		, (r2)->
			toastr.warning 'Lo sentimos, No se trajeron las notas'
		)



	if $state.params.alumno_id
		if $scope.USER.tipo == 'Alumno'
			toastr.warning 'No puedes ver otras notas'
			return

		$scope.verNotasAlumno($state.params.alumno_id, $scope.USER.grupo_id)



	if $scope.USER.tipo == 'Alumno' and $scope.USER.pazysalvo
			$scope.verNotasAlumno($scope.USER.persona_id, $scope.USER.grupo_id)




	$scope.cambiaNotaDef = (asignatura, nota, nf_id, num_periodo)->

		if nota > $scope.escala_maxima.porc_final or nota == 'undefined' or nota == undefined
			toastr.error 'No puede ser mayor de ' + $scope.escala_maxima.porc_final, 'NO guardada', {timeOut: 8000}
			return

		if nf_id
			$http.put('::definitivas_periodos/update', {nf_id: nf_id, nota: nota}).then((r)->
				if !asignatura.manual
					asignatura.manual = 1
				toastr.success 'Cambiada: ' + nota
			, (r2)->
				if r2.status == 400
					toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
				else
					toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
			)
		else
			$http.put('::definitivas_periodos/update', {alumno_id: $scope.alumno_traido.alumno_id, nota: nota, asignatura_id: asignatura.asignatura_id, num_periodo: num_periodo }).then((r)->
				toastr.success 'Creada: ' + nota
				r = r.data[0]
				asignatura.nf_id          = r.id
				asignatura.recuperada     = 0
				asignatura.manual         = 1
			, (r2)->
				if r2.status == 400
					toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
				else
					toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
			)


	$scope.toggleNotaFinalRecuperada = (alumno, recuperada, nf_id)->
		$http.put('::definitivas_periodos/toggle-recuperada', {nf_id: nf_id, recuperada: recuperada}).then((r)->

			if recuperada and !alumno.manual
				alumno.manual = 1
				toastr.success 'Indicará que es recuperada, así que también será manual.'
			else if recuperada
				toastr.success 'Recuperada'
			else
				toastr.success 'No recuperada'
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
		)

	$scope.toggleNotaFinalManual = (alumno, manual, nf_id)->
		$http.put('::definitivas_periodos/toggle-manual', {nf_id: nf_id, manual: manual}).then((r)->

			if !manual and alumno.nota_final.recuperada
				alumno.nota_final.recuperada = false
				toastr.success 'Será automática y no recuperada.'
			else if manual
				toastr.success 'Nota manual.'
			else
				toastr.success 'Ahora la calculará el sistema.'
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
		)



	$scope.cambiaNota = (nota, otra)->
		$http.put('::notas/update/' + nota.id, {nota: nota.nota}).then((r)->
			r = r.data
			toastr.success 'Cambiada: ' + nota.nota
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
		)




	$scope.selectGrupo = (item)->
		if item
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: item.id}, true)
		else
			$scope.filtered_alumnos = alumnos

			$cookies.putObject 'requested_alumno', ''

		$scope.datos.selected_alumno = ''


])
