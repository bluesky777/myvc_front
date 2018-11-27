angular.module('myvcFrontApp')

.controller('NotasPerdidasProfesorCtrl',['$scope', 'App', 'Perfil', 'grupos', '$state', '$stateParams', ($scope, App, Perfil, grupos, $state, $stateParams)->
	$scope.grupos             = grupos.data
	$scope.periodo_a_calcular = $stateParams.periodo_a_calcular

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'

	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])



.controller('NotasPerdidasTodosCtrl',['$scope', 'App', 'Perfil', 'profesores', '$state', '$stateParams', ($scope, App, Perfil, profesores, $state, $stateParams)->
	$scope.profesores         = profesores.data
	$scope.periodo_a_calcular = $stateParams.periodo_a_calcular

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'

	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])




.controller('VerAusenciasCtrl',['$scope', 'App', 'Perfil', 'grupos_ausencias', '$state', ($scope, App, Perfil, grupos_ausencias, $state)->
	$scope.grupos_ausencias = grupos_ausencias.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Ausencias y tardanzas a la institución '

])





.controller('VerSimatCtrl',['$scope', 'App', 'Perfil', 'grupos_simat', '$state', ($scope, App, Perfil, grupos_simat, $state)->
	$scope.grupos_simat = grupos_simat.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Listado SIMAT '

])



.controller('ListasPersonalizadasCtrl',['$scope', 'App', 'Perfil', 'grupos_simat', '$state', ($scope, App, Perfil, grupos_simat, $state)->
	$scope.grupos_simat_copy = grupos_simat.data
	$scope.grupos_simat = grupos_simat.data

	$scope.USER                 = Perfil.User()
	$scope.perfilPath           = App.images+'perfil/'
	$scope.titulo_listado 			= {}
	$scope.show_documento       = true
	$scope.columnas             = 2

	$scope.columnasArray = new Array($scope.columnas)

	hay = localStorage.txt_titulo_listado
	if hay
		$scope.titulo_listado.texto = hay
	else
			$scope.titulo_listado.texto = "<b>LISTADO DE ALUMNOS</b><br>"

	$scope.cambia_texto_informativo = ()->
		localStorage.txt_titulo_listado = $scope.titulo_listado.texto

	$scope.cambiaColumnas = (col)->
		#nuevos = new Array(num)
		$scope.columnasArray = new Array(col)
		###
		for nue in nuevos
			elem = {texto: '' }
			columnasArray.push(nue)
		###

		localStorage.txt_titulo_listado = $scope.titulo_listado.texto

	$scope.getNumber = (num)->
		return new Array(num)

	$scope.todos = ()->
		$scope.grupos_simat = $scope.grupos_simat_copy



	$scope.selectGrupo = (item)->
		for grupo in $scope.grupos_simat_copy
			if grupo.id == item.id
				$scope.grupos_simat = [grupo]




	$scope.$emit 'cambia_descripcion', 'Listas personalizadas '

])





.controller('VerObservadorVerticalCtrl',['$scope', 'App', 'Perfil', 'grupos_observador', '$state', ($scope, App, Perfil, grupos_observador, $state)->
	$scope.grupos_observador = grupos_observador.data

	$scope.editor_options =
		allowedContent: true,
		entities: false


	$scope.onEditorReady = ()->
		console.log 'Editor listo'

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'


	$scope.$emit 'cambia_descripcion', 'Observador del alumno '

])



.controller('PlanillasAusenciasAcudientesCtrl',['$scope', 'App', 'Perfil', 'grupos_acud', '$state', ($scope, App, Perfil, grupos_acud, $state)->
	$scope.grupos_acud  = grupos_acud.data.grupos_acud
	$scope.year         = grupos_acud.data.year

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'
	$scope.fecha_hoy  = new Date();
	$scope.texto_informativo = {}


	hay = localStorage.txt_informativo_asist_padres
	if hay
		$scope.texto_informativo.texto = hay
	else
			$scope.texto_informativo.texto = "<b>PLANILLA ASISTENCIA ASAMBLEA DE PADRES</b><br>"

	$scope.cambia_texto_informativo = ()->
		localStorage.txt_informativo_asist_padres = $scope.texto_informativo.texto



	$scope.editor_options =
		allowedContent: true,
		entities: false


	for grup in $scope.grupos_acud
		grup.alumnos_temp = grup.alumnos

		if grup.alumnos_temp.length < 31
			grup.alumnos1 = grup.alumnos_temp

		else if grup.alumnos_temp.length < 61
			grup.alumnos1 = grup.alumnos_temp.splice(0, 30)
			grup.alumnos2 = grup.alumnos_temp.splice(0, 30)

		else if asign.alumnos_temp.length < 91
			grup.alumnos1 = grup.alumnos_temp.splice(0, 30)
			grup.alumnos2 = grup.alumnos_temp.splice(0, 30)
			grup.alumnos3 = grup.alumnos_temp.splice(0, 30)




	$scope.$emit 'cambia_descripcion', 'Planilla de asistencia de padres '

])







.directive('compile', ($compile, $timeout)->
	return {
		restrict: 'A',
		link: (scope,elem,attrs)->
			$timeout(()->
				$compile(elem.contents())(scope);
			);
	}
)


