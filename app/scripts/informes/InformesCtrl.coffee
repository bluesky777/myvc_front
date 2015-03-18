angular.module('myvcFrontApp')
.controller('InformesCtrl', ['$scope', 'Restangular', '$state', '$stateParams', '$rootScope', '$filter', 'App', 'AuthService', 'GruposServ', 'alumnos', '$timeout', '$cookieStore', 'toastr', ($scope, Restangular, $state, $stateParams, $rootScope, $filter, App, AuthService, GruposServ, alumnos, $timeout, $cookieStore, toastr) ->

	AuthService.verificar_acceso()
	$scope.rowsAlum = [] 
	$scope.config = {}
	$scope.filtered_alumnos = alumnos
	$scope.perfilPath = App.images + 'perfil/'

	$scope.datos = {grupo: ''}

	#console.log 'Parametros', $state.params

	GruposServ.getGrupos().then((r)->
		$scope.grupos = r

		$tempParam = parseInt($state.params.grupo_id)

		if $state.params.grupo_id
			$scope.datos.grupo = $filter('filter')($scope.grupos, {id: $tempParam}, true)[0]
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: $tempParam}, true)
			console.log 'Cambiamos a ', $scope.datos.grupo
	
	)

	if $cookieStore.get 'config'
		$scope.config = $cookieStore.get 'config'
		$scope.informe_tab_actual_boletines = if $scope.config.informe_tab_actual=='boletines' then true else false
		$scope.informe_tab_actual_puestos = if $scope.config.informe_tab_actual=='puestos' then true else false
		#console.log '$scope.config', $scope.config
	else
		$scope.config.orientacion = 'vertical'


	if $cookieStore.get 'requested_alumnos'
		requ = $cookieStore.get 'requested_alumnos'

		if requ.length > 0

			founds = []
			angular.forEach requ, (value, key) ->
				found = $filter('filter')(alumnos, {alumno_id: value.alumno_id}, true)[0]
				founds.push found

			$scope.datos.selected_alumnos = founds
			#console.log 'Mas de uno: ', $scope.datos.selected_alumnos
		else
			$scope.datos.selected_alumno = requ[0]


	if $cookieStore.get 'requested_alumno'
		requ = $cookieStore.get 'requested_alumno'
		console.log 'requested_alumno inicial', requ

		found = $filter('filter')(alumnos, {alumno_id: requ[0].alumno_id}, true)[0]
		$scope.datos.selected_alumno = found

	$scope.$watch 'config', (newVal, oldVal)->
		#console.log 'oldVal, newVal', oldVal, newVal
		$cookieStore.put 'config', newVal

		$scope.$broadcast 'change_config'
		
	, true

	$scope.selectTab = (tab)->
		$scope.config.informe_tab_actual = tab
		$cookieStore.put 'config', $scope.config
		$scope.informe_tab_actual_boletines = if tab=='boletines' then true else false
		$scope.informe_tab_actual_puestos = if tab=='puestos' then true else false

	$scope.verBoletinesGrupo = ()->
		$cookieStore.remove 'requested_alumnos'
		$cookieStore.remove 'requested_alumno'
		
		$state.go 'informes.boletines_periodo', {grupo_id: $scope.datos.grupo.id}, {reload: true}

	$scope.verBoletinesAlumnos = ()->
		console.log '$scope.datos.selected_alumnos ', $scope.datos.selected_alumnos
		if $scope.datos.selected_alumnos.length > 0
			$cookieStore.put 'requested_alumnos', $scope.datos.selected_alumnos
			$state.go 'informes.boletines_periodo', {grupo_id: $scope.datos.grupo.id}, {reload: true}
		else
			toastr.warning 'Debes seleccionar al menos un alumno o cargar boletines del grupo completo'


	$scope.verBoletinAlumno = ()->
		console.log '$scope.datos.selected_alumno', $scope.datos.selected_alumno
		if $scope.datos.selected_alumno
			$cookieStore.put 'requested_alumno', [$scope.datos.selected_alumno]
			$state.go 'informes.boletines_periodo', {}, {reload: true}
		else
			toastr.warning 'Elige un alumno o carga el grupo completo'


	$scope.verPuestosPeriodo = ()->
		console.log $scope.datos.grupo
		$state.go 'informes.puestos_grupo_periodo', {grupo_id: $scope.datos.grupo.id}, {reload: true}


	$scope.verPuestosYear = ()->
		console.log $scope.datos.grupo
		$state.go 'informes.puestos_grupo_year', {grupo_id: $scope.datos.grupo.id}, {reload: true}


	$scope.selectGrupo = (item)->
		if item
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: item.id}, true)
		else
			$scope.filtered_alumnos = alumnos

			$cookieStore.put 'requested_alumno', ''
			$cookieStore.put 'requested_alumnos', ''


		$scope.datos.selected_alumnos = ''
		$scope.datos.selected_alumno = ''

	$scope.selectAlumnos = (item)->
		console.log item

	$scope.selectAlumno = (item)->
		console.log item


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

	
])