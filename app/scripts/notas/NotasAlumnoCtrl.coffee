angular.module('myvcFrontApp')
.controller('NotasAlumnoCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', 'alumnos', 'escalas', '$rootScope', '$filter', 'App', 'AuthService', 'Perfil', ($scope, toastr, $http, $modal, $state, alumnos, escalas, $rootScope, $filter, App, AuthService, Perfil) ->

	AuthService.verificar_acceso()
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
	alumnos = alumnos.data

	if !alumnos == 'Sin alumnos'
		$scope.filtered_alumnos = alumnos

	$scope.perfilPath = App.images + 'perfil/'
	$scope.datos = {grupo: ''}
	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.escalas = escalas
	$scope.config = {solo_notas_perdidas: true}


	if !$scope.hasRoleOrPerm(['alumno', 'acudiente'])
		$http.get('::grupos').then((r)->
			r = r.data
			$scope.grupos = r
		)



	$scope.verNotasAlumno = (alumno_id)->
		
		if !alumno_id
			alumno_id = $scope.datos.selected_alumno.alumno_id
		
		$http.get('::notas/alumno/'+alumno_id).then((r)->
			r = r.data
			if r[0]
				$scope.periodos = r[0].periodos
			else
				$scope.periodos = undefined
				toastr.warning 'Sin matrícula este año.'
		, (r2)->
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
		$http.put('::notas/update/' + nota.id, {nota: nota.nota}).then((r)->
			r = r.data
			toastr.success 'Cambiada: ' + nota.nota
		, (r2)->
			toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
		)




	$scope.selectGrupo = (item)->
		if item
			$scope.filtered_alumnos = $filter('filter')(alumnos, {grupo_id: item.id}, true)
		else
			$scope.filtered_alumnos = alumnos

			$cookieStore.put 'requested_alumno', ''

		$scope.datos.selected_alumno = ''


])