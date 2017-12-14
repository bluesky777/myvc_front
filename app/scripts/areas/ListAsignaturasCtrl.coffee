angular.module('myvcFrontApp')
.controller 'ListAsignaturasCtrl', ['$scope', '$http', 'toastr', '$state', '$cookies', '$rootScope', 'AuthService', 'App', 'resolved_user', ($scope, $http, toastr, $state, $cookies, $rootScope, AuthService, App, resolved_user) ->
	
	$scope.$parent.bigLoader 	= true

	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.GENERO_UNI = $scope.USER.genero_unidad
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.GENERO_SUB = $scope.USER.genero_subunidad
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname

	$scope.views = App.views + 'areas/' # La uso en jade

	$scope.profesor = {}

	if $state.params.profesor_id

		$scope.profesor_id = true
		
		$http.get('::asignaturas/listasignaturas/'+$state.params.profesor_id).then((r)->
			$scope.asignaturas = r.data.asignaturas
			$scope.profesor = r.data.info_profesor
			$scope.gruposcomportamientos = r.data.grados_comp
			$scope.$parent.bigLoader 	= false

		, (r2)->
			toastr.error 'No se pudo traer las asignaturas'
			$scope.$parent.bigLoader 	= false
		)


	else
		$http.get('::asignaturas/listasignaturas').then((r)->
			$scope.asignaturas 				= r.data.asignaturas
			$scope.gruposcomportamientos 	= r.data.grados_comp
			$scope.$parent.bigLoader 		= false
		, (r2)->
			toastr.error 'No se pudo traer tus asignaturas'
			$scope.$parent.bigLoader 	= false
		)


	$scope.open = (asignatura)->
		$state.go 'panel.unidades', {asignatura_id: asignatura.asignatura_id}


]

