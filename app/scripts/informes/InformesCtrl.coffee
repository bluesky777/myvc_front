angular.module('myvcFrontApp')
.controller('InformesCtrl', ['$scope', '$http', '$state', '$stateParams', '$filter', 'App', 'AuthService', 'ProfesoresServ', 'alumnos', '$timeout', '$cookies', 'toastr', '$interval', 'DownloadServ', 'Upload', ($scope, $http, $state, $stateParams, $filter, App, AuthService, ProfesoresServ, alumnos, $timeout, $cookies, toastr, $interval, DownloadServ, Upload) ->

	AuthService.verificar_acceso()
	$scope.rowsAlum = []
	alumnos 		= alumnos.data
	$scope.$state 	= $state
	$scope.config 	= {
		periodos_a_calcular: 1  # de_usuario, de_colegio, todos
		mostrar_foto: true
		show_firma_rector: true
		show_rojos: true
		show_porcentajes: true
		show_firma_titular: true
		periodo_a_calcular: $scope.USER.numero_periodo
	}
	$scope.filtered_alumnos = alumnos
	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.datos = { grupo: '' }



	$http.put('::informes/datos').then((r)->
		r 											= r.data
		$scope.year_actual 			= r.year
		$scope.grupos 					= r.grupos
		$scope.profesores 			= r.profesores
		$scope.imgs_public 			= r.imagenes
		$scope.periodos_grupos 	= r.periodos_grupos

		if r.periodos_desactualizados
			$scope.periodos_desactualizados 	= r.periodos_desactualizados

		# Grupo seleccionado
		if $state.params.grupo_id
			$tempParam 				= parseInt($state.params.grupo_id)
			$scope.datos.grupo 		= $filter('filter')($scope.grupos, {id: $tempParam}, true)[0]
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: $tempParam}, true)

		# Profesor seleccionado
		if $state.params.profesor_id
			$tempParam 				= parseInt($state.params.profesor_id)
			$scope.datos.profesor 	= $filter('filter')($scope.profesores, {profesor_id: $tempParam}, true)[0]

		#$scope.$parent.bigLoader 	= false
	, (r2)->
		toastr.error 'No se pudo traer los profesores'
		#$scope.$parent.bigLoader 	= false
	)


	if localStorage.tipo_boletin
		$scope.tipo_boletin 				= localStorage.tipo_boletin

	if localStorage.tipo_boletin_final
		$scope.tipo_boletin_final 	= localStorage.tipo_boletin_final


	$scope.eligirTipo = (n)->
		localStorage.tipo_boletin 	= n
		$scope.tipo_boletin 				= n

	$scope.eligirTipoFinal = (n)->
		localStorage.tipo_boletin_final 	= n
		$scope.tipo_boletin_final 				= n


	$scope.range = (n)->
		return new Array(n);


	if $cookies.getObject 'config'
		$scope.config = $cookies.getObject 'config'
		#console.log '$scope.config', $scope.config
	else
		$scope.config.orientacion   = 'vertical'
		$scope.config.cant_imagenes = 7


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




	$scope.calcularGrupoPeriodo = (grupo, periodo)->

		grupo.desabilitado = true
		$http.put('::definitivas_periodos/calcular-grupo-periodo', {grupo_id: grupo.grupo_id, periodo_id: periodo.id, num_periodo: periodo.numero}).then((r)->
			toastr.success grupo.nombre + ' calculado con éxito'
			#grupo.desabilitado = false
		, (r2)->
			grupo.desabilitado = false
			toastr.error 'No se pudo calcular las definitivas del grupo ' + grupo.nombre + ', Per ' + periodo.numero
		)




	$scope.calcularPeriodo = (periodo)->

		$scope.porcentaje   = 0
		periodo.bloqueado   = true

		$scope.grupo_temp_calculado = true
		$scope.grupo_temp_indce     = 0

		$scope.intervalo = $interval(()->

			if $scope.grupo_temp_calculado

				$scope.grupo_temp_calculado = false
				grupo 							= periodo.grupos[$scope.grupo_temp_indce]
				$scope.porcentaje 	= parseInt(($scope.grupo_temp_indce+1) * 100 / periodo.grupos.length)

				$http.put('::definitivas_periodos/calcular-grupo-periodo', {grupo_id: grupo.grupo_id, periodo_id: periodo.id, num_periodo: periodo.numero}).then((r)->
					toastr.success grupo.nombre + ' calculado con éxito'
					$scope.grupo_temp_calculado = true
					$scope.grupo_temp_indce     = $scope.grupo_temp_indce + 1
					if $scope.grupo_temp_indce == periodo.grupos.length
						$interval.cancel($scope.intervalo)

				, (r2)->
					$scope.grupo_temp_calculado = true
					toastr.warning 'No se pudo calcular ' + grupo.nombre + ', Per ' + periodo.numero + '. Intentaremos de nuevo.'
				)

		, 20)



	$scope.verBoletinesGrupo = (tipo)->
		if tipo == '1' or tipo == 1
			tipo = ''
		$cookies.remove 'requested_alumnos'
		$cookies.remove 'requested_alumno'

		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return
		$scope.config.orientacion = 'vertical'
		$state.go 'panel.informes.boletines_periodo'+tipo, {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.USER.numero_periodo}, {reload: true}

	$scope.verBoletinesAlumnos = (tipo)->
		if tipo == '1' or tipo == 1
			tipo = ''
		if $scope.datos.selected_alumnos.length > 0
			$scope.config.orientacion = 'vertical'
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'panel.informes.boletines_periodo'+tipo, {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.USER.numero_periodo}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno o cargar boletines del grupo completo'


	$scope.verBoletinAlumno = (tipo)->
		if tipo == '1' or tipo == 1
			tipo = ''
		$cookies.remove 'requested_alumnos'
		if $scope.datos.selected_alumno
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$scope.config.orientacion = 'vertical'
			$interval ()->
				$state.go 'panel.informes.boletines_periodo'+tipo, {periodo_a_calcular: $scope.USER.numero_periodo}
			, 1, 1
		else
			toastr.warning 'Elige un alumno o carga el grupo completo'








	#######################
	# VARIOS
	#######################

	$scope.verNotasActualesAlumno = ()->
		$cookies.remove 'requested_alumno'
		if $scope.datos.selected_alumno
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$scope.config.orientacion = 'vertical'
			$interval ()->
				$state.go 'panel.informes.notas_actuales_alumnos', {periodo_a_calcular: $scope.USER.numero_periodo}
			, 1, 1


		else
			toastr.warning 'Debes seleccionar al menos un alumno'


	$scope.verNotasActualesAlumnos = ()->
		if $scope.datos.selected_alumnos.length > 0
			$scope.config.orientacion = 'vertical'
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'panel.informes.notas_actuales_alumnos', {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.USER.numero_periodo}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno'




	$scope.verNotasPerdidasActualesAlumno = ()->
		if $scope.datos.selected_alumno
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$scope.config.orientacion = 'vertical'
			$interval ()->
				$state.go 'panel.informes.notas_perdidas_actuales_alumnos', {periodo_a_calcular: $scope.USER.numero_periodo}
			, 1, 1


		else
			toastr.warning 'Debes seleccionar al menos un alumno'


	$scope.verNotasPerdidasActualesAlumnos = ()->
		if $scope.datos.selected_alumnos.length > 0
			$scope.config.orientacion = 'vertical'
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'panel.informes.notas_perdidas_actuales_alumnos', {grupo_id: $scope.datos.grupo.id, periodo_a_calcular: $scope.USER.numero_periodo}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno'


	$scope.verListadoDocentes = ()->
		$scope.config.orientacion = 'oficio_horizontal'
		$state.go 'panel.informes.listado_profesores'


	$scope.excelListadoDocentes = ()->
		DownloadServ.download('::excel-docentes/docentes/'+$scope.USER.year+'/'+$scope.USER.year_id, 'Listado docentes '+$scope.USER.year+'.xls')


	$scope.verCantAlumnosEnGrupos = ()->
		$scope.config.orientacion = 'vertical'
		$state.go 'panel.informes.ver_cant_alumnos_por_grupos'










	#######################
	# PLANILLAS
	#######################

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
		DownloadServ.download('::simat/alumnos', 'Alumnos con acudientes '+$scope.USER.year+'.xls')
		$state.go 'panel.informes.ver_simat', {reload: true}

	$scope.importarSimat = (file, errFiles)->
		$scope.f = file;
		$scope.errFile = errFiles && errFiles[0];
		if (file)
			file.upload = Upload.upload({
					url: App.Server + 'importar/algo/'+$scope.USER.year,
					data: {file: file}
			});

			file.upload.then( (response)->
					$timeout( ()->
							file.result = response.data;
					);
			,  (response)->
					if (response.status > 0)
							$scope.errorMsg = response.status + ': ' + response.data;
			, (evt)->
					file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
			);






	$scope.verObservadorVertical = ()->
		#DownloadServ.download('::simat/alumnos', 'Grupos alumnos.xls')
		if !$scope.datos.grupo.id
			toastr.warning 'Debes seleccionar el grupo'
			return

		$state.go 'panel.informes.ver_observador_vertical', {grupo_id: $scope.datos.grupo.id}, {reload: true}


	$scope.verObservadorVerticalTodos = ()->
		$state.go 'panel.informes.ver_observador_vertical_todos', {reload: true}


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

		datos = {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular};

		if $scope.tipo_boletin_final == 2 || $scope.tipo_boletin_final == '2'
			datos.year_selected = true

		$state.go 'panel.informes.boletines_finales', datos, {reload: true}


	$scope.verBoletinesFinalesAlumnos = ()->

		if $scope.datos.selected_alumnos.length > 0
			$cookies.putObject 'requested_alumnos', $scope.datos.selected_alumnos

			datos = {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}
			if $scope.tipo_boletin_final == 2 || $scope.tipo_boletin_final == '2'
				datos.year_selected = true

			$state.go 'panel.informes.boletines_finales', datos, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno o cargar boletines del grupo completo'


	$scope.verBoletinFinalAlumno = ()->

		if $scope.datos.selected_alumno
			$cookies.remove 'requested_alumnos'
			$cookies.putObject 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'panel.informes'
			$interval ()->
				datos = {grupo_id: $scope.datos.grupo.id, periodos_a_calcular: $scope.config.periodos_a_calcular}
				if $scope.tipo_boletin_final == 2 || $scope.tipo_boletin_final == '2'
					datos.year_selected = true

				$state.go 'panel.informes.boletines_finales', datos
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




