angular.module('myvcFrontApp')
.controller('NotasAlumnoCtrl', ['$scope', 'toastr', 'Restangular', '$modal', '$state', 'alumnos', 'GruposServ', 'ProfesoresServ', 'escalas', '$rootScope', '$filter', 'App', 'AuthService', 'Perfil', ($scope, toastr, Restangular, $modal, $state, alumnos, GruposServ, ProfesoresServ, escalas, $rootScope, $filter, App, AuthService, Perfil) ->

	AuthService.verificar_acceso()

	if !alumnos == 'Sin alumnos'
		$scope.filtered_alumnos = alumnos

	$scope.perfilPath = App.images + 'perfil/'
	$scope.datos = {grupo: ''}
	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.escalas = escalas
	$scope.config = {solo_notas_perdidas: true}


	if !$scope.hasRoleOrPerm(['alumno', 'acudiente'])
		GruposServ.getGrupos().then((r)->
			$scope.grupos = r
		)




	ProfesoresServ.contratos().then((r)->
		$scope.profesores = r
	, (r2)->
		console.log 'No se pudo traer los profesores: ', r2
	)


	$scope.verNotasAlumno = (alumno_id)->
		
		if !alumno_id
			alumno_id = $scope.datos.selected_alumno.alumno_id
		
		Restangular.one('notas/alumno/'+alumno_id).getList().then((r)->
			$scope.periodos = r[0].periodos
			console.log '$scope.periodos', $scope.periodos
		, (r2)->
			console.log 'No se puedo traer las notas', r2
			toastr.warning 'Lo sentimos, No se trajeron las notas'
		)


	if $state.params.alumno_id
		if $scope.USER.tipo == 'Alumno'
			toastr.warning 'No puedes ver otras notas'
			return

		$scope.verNotasAlumno($state.params.alumno_id)



	if $scope.USER.tipo == 'Alumno' and $scope.USER.pazysalvo
			$scope.verNotasAlumno($scope.USER.persona_id)





	$scope.cambiaNota = (nota, otra)->
		console.log nota, otra
		Restangular.one('notas/update', nota.id).customPUT({nota: nota.nota}).then((r)->
			toastr.success 'Cambiada: ' + nota.nota
			console.log 'Cuando la nota cambia, el objeto nota: ', nota
		, (r2)->
			console.log 'No pudimos guardar la nota ', nota
			toastr.error 'No pudimos guardar la nota ' + nota.nota
		)




	$scope.selectGrupo = (item)->
		if item
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: item.id}, true)
		else
			$scope.filtered_alumnos = alumnos

			$cookieStore.put 'requested_alumno', ''

		$scope.datos.selected_alumno = ''


])