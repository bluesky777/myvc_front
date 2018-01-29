angular.module('myvcFrontApp')
.controller('InformesCtrl', ['$scope', '$http', '$state', '$stateParams', '$filter', 'App', 'AuthService', 'ProfesoresServ', 'alumnos', '$timeout', '$cookies', 'toastr', '$interval', 'DownloadServ', ($scope, $http, $state, $stateParams, $filter, App, AuthService, ProfesoresServ, alumnos, $timeout, $cookies, toastr, $interval, DownloadServ) ->

	AuthService.verificar_acceso()
	$scope.rowsAlum = []
	alumnos 		= alumnos.data
	$scope.$state 	= $state
	$scope.config 	= {
		periodos_a_calcular: 1  # de_usuario, de_colegio, todos
		mostrar_foto: true
		periodo_a_calcular: $scope.USER.numero_periodo
	}
	$scope.filtered_alumnos = alumnos
	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.datos = { grupo: '' }

	#console.log 'Parametros', $state.params



	$http.put('::informes/datos').then((r)->
		r 					= r.data
		$scope.year_actual 	= r.year
		$scope.grupos 		= r.grupos
		$scope.profesores 	= r.profesores
		$scope.imgs_public 	= r.imagenes

		# Grupo seleccionado
		if $state.params.grupo_id
			$tempParam 				= parseInt($state.params.grupo_id)
			$scope.datos.grupo 		= $filter('filter')($scope.grupos, {id: $tempParam}, true)[0]
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: $tempParam}, true)

		# Profesor seleccionado
		if $state.params.profesor_id
			$tempParam 				= parseInt($state.params.profesor_id)
			$scope.datos.profesor 	= $filter('filter')($scope.profesores, {profesor_id: $tempParam}, true)[0]

		$scope.$parent.bigLoader 	= false
	, (r2)->
		toastr.error 'No se pudo traer los profesores'
		$scope.$parent.bigLoader 	= false
	)



	$scope.range = (n)->
		return new Array(n);


	if $cookies.getObject 'config'
		$scope.config = $cookies.getObject 'config'
		#console.log '$scope.config', $scope.config
	else
		$scope.config.orientacion = 'vertical'


	if $cookies.getObject 'requested_alumnos'
		requ = $cookies.getObject 'requested_alumnos'

		if requ.length > 0

			founds = []
			angular.forEach requ, (value, key) ->
				found = $filter('filter')(alumnos, {alumno_id: value.alumno_id}, true)[0]
				founds.push found

			$scope.datos.selected_alumnos = founds
			#console.log 'Mas de uno: ', $scope.datos.selected_alumnos
		else
			$scope.datos.selected_alumno = requ[0]


	if $cookies.getObject 'requested_alumno'
		requ = $cookies.getObject 'requested_alumno'

		found = $filter('filter')(alumnos, {alumno_id: requ[0].alumno_id}, true)[0]
		$scope.datos.selected_alumno = found

	$scope.$watch 'config', (newVal, oldVal)->
		#console.log 'oldVal, newVal', oldVal, newVal
		$cookies.putObject 'config', newVal

		$scope.$broadcast 'change_config'

	, true

	$scope.selectTab = (tab)->
		$scope.config.informe_tab_actual = tab
		$cookies.putObject 'config', $scope.config




	$scope.putConfigCookie = ()->
		$cookies.putObject 'config', $scope.config





	$scope.verBoletinesGrupo = ()->
		$cookies.remove 'requested_alumnos'
		$cookies.remove 'requested_alumno'

		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return
		$scope.config.orientacion = 'vertical'
		$state.go 'panel.informes.boletines_periodo', {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.config.periodo_a_calcular}, {reload: true}

	$scope.verBoletinesAlumnos = ()->

		if $scope.datos.selected_alumnos.length > 0
			$scope.config.orientacion = 'vertical'
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'panel.informes.boletines_periodo', {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.config.periodo_a_calcular}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno o cargar boletines del grupo completo'


	$scope.verBoletinAlumno = ()->

		if $scope.datos.selected_alumno
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$scope.config.orientacion = 'vertical'
			$interval ()->
				$state.go 'panel.informes.boletines_periodo', {periodo_a_calcular: $scope.config.periodo_a_calcular}
			, 1, 1
		else
			toastr.warning 'Elige un alumno o carga el grupo completo'







	$scope.verPuestosPeriodo = ()->
		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return
		$scope.config.orientacion = 'vertical'
		$state.go 'panel.informes.puestos_grupo_periodo', {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}


	$scope.verPuestosYear = ()->
		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return
		$scope.config.orientacion = 'vertical'
		$state.go 'panel.informes.puestos_grupo_year', {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.config.periodo_a_calcular}





	$scope.verPlanillasGrupo = ()->
		if $scope.datos.grupo.id
			$scope.config.orientacion = 'oficio_horizontal'
			$state.go 'panel.informes.planillas_grupo', {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}, {reload: true}
		else
			toastr.warning 'Elige un grupo'


	$scope.verPlanillasProfe = ()->
		if $scope.datos.profesor
			$scope.config.orientacion = 'oficio_horizontal'
			$state.go 'panel.informes.planillas_profesor', {profesor_id: $scope.datos.profesor.profesor_id, periodos_a_calcular: $scope.config.periodos_a_calcular}, {reload: true}
		else
			toastr.warning 'Elige un profesor'

	$scope.verAusencias = ()->
		$state.go 'panel.informes.ver_ausencias', {periodos_a_calcular: $scope.config.periodos_a_calcular}, {reload: true}

	$scope.verSimat = ()->
		DownloadServ.download('::simat/alumnos', 'Grupos alumnos.xls')
		$state.go 'panel.informes.ver_simat', {reload: true}


	$scope.verPlanillasControlTardanzas = ()->
		$scope.config.orientacion = 'oficio_horizontal'
		$state.go 'panel.informes.control_tardanza_entrada', {reload: true}

	$scope.verNotasPerdidasProfesor = ()->
		if $scope.datos.profesor
			$scope.config.orientacion = 'carta_horizontal'
			$state.go 'panel.informes.notas_perdidas_profesor', {profesor_id: $scope.datos.profesor.profesor_id, periodo_a_calcular: $scope.config.periodo_a_calcular}, {reload: true}
		else
			toastr.warning 'Elige un profesor'


	$scope.verNotasPerdidasTodos = ()->
		$scope.config.orientacion = 'carta_horizontal'
		$state.go 'panel.informes.notas_perdidas_todos', {periodo_a_calcular: $scope.config.periodo_a_calcular}, {reload: true}



	$scope.selectGrupo = (item)->
		if item
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: item.id}, true)
		else
			$scope.filtered_alumnos = alumnos

			$cookies.putObject 'requested_alumno', ''
			$cookies.putObject 'requested_alumnos', ''


		$scope.datos.selected_alumnos = ''
		$scope.datos.selected_alumno = ''

	$scope.selectAlumnos = (item)->
		#console.log item

	$scope.selectAlumno = (item)->
		#console.log item


	$scope.$on 'cambia_descripcion', (event, descrip)->
		$scope.descripcion_informe = descrip


	$scope.pdfMaker = ()->

		docDefinition = {
			content: [
				['Este es un ejemplo de reporte en pdf'],
				{
					table: {
						headerRows: 1,
						widths: [ '*', 'auto', 100, '*' ],

						body: [
								[ 'No', 'Primero', 'Segundo', 'Tercero' ],
								[ '0', 'No me gusta!!', 'No queda bonito', 'FACILMENTE!' ],
								[ '1', { text: 'En negrita', bold: true }, 'Así que ', 'me mordió la vaca' ]
							]
					}
				}
			]
		}

		pdfMake.createPdf(docDefinition).open()














	$scope.verBoletinesFinalesGrupo = ()->
		$cookies.remove 'requested_alumnos'
		$cookies.remove 'requested_alumno'

		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return

		$state.go 'panel.informes.boletines_finales', {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}, {reload: true}


	$scope.verBoletinesFinalesAlumnos = ()->

		if $scope.datos.selected_alumnos.length > 0
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'panel.informes.boletines_finales', {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno o cargar boletines del grupo completo'


	$scope.verBoletinFinalAlumno = ()->

		if $scope.datos.selected_alumno
			$cookies.remove 'requested_alumnos'
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$interval ()->
				$state.go 'panel.informes.boletines_finales'
			, 1, 1
		else
			toastr.warning 'Elige un alumno o carga el grupo completo'



	$scope.verCertificadosEstudioGrupo = ()->

		$cookies.remove 'requested_alumnos'
		$cookies.remove 'requested_alumno'

		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return

		$state.go 'panel.informes.certificados_estudio', {grupo_id: $scope.datos.grupo.id}, {reload: true}


	$scope.verCertificadosEstudioAlumnos = ()->

		if $scope.datos.selected_alumnos.length > 0
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'panel.informes.certificados_estudio', {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno o cargar boletines del grupo completo'



	$scope.verCertificadosEstudioAlumno = ()->

		if $scope.datos.selected_alumno
			$cookies.remove 'requested_alumnos'
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$interval ()->
				$state.go 'panel.informes.certificados_estudio'
			, 1, 1
		else
			toastr.warning 'Elige un alumno o carga el grupo completo'







	# CALCULOS PARA DÍAS Y MESES
	$scope.meses = [
		{nombre: 'Enero'}
		{nombre: 'Febrero'}
		{nombre: 'Marzo'}
		{nombre: 'Abril'}
		{nombre: 'Mayo'}
		{nombre: 'Junio'}
		{nombre: 'Julio'}
		{nombre: 'Agosto'}
		{nombre: 'Septiembre'}
		{nombre: 'Octubre'}
		{nombre: 'Noviembre'}
		{nombre: 'Diciembre'}
	]

	$scope.numYearActual = $scope.USER.year

	DAYS_IN_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	getDaysInMonth = ( year, month )->
		if ((month == 1) and (year % 4 == 0) and ((year % 100 != 0) or (year % 400 == 0)))
			return 29
		else
			return DAYS_IN_MONTH[month]

	$scope.getAllDaysInMonth = (month)->

		num = getDaysInMonth($scope.numYearActual, month)
		r = []
		for i in [1..num]
			d = new Date($scope.numYearActual, parseInt(month), i)
			n = d.getDay()

			if n != 0 and n != 6
				r.push i

		return r

	# //





])



.filter('fechaHoraStringShort', ['$filter', ($filter)->
	(fecha_hora, created_at) ->

		if fecha_hora
			fecha_hora = new Date(fecha_hora)
			if isNaN(fecha_hora)
				fecha_hora = new Date(fecha_hora)
			else
				fecha_hora = new Date(created_at)

			fecha_hora = $filter('date')(fecha_hora, 'MMMdd H:mm')
			return fecha_hora

		else
			return ''


])




