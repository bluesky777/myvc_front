angular.module('myvcFrontApp')
.controller('UserCtrl', ['$scope', '$http', '$state', 'AuthService', 'Perfil', 'App', 'perfilactual', '$filter', ($scope, $http, $state, AuthService, Perfil, App, perfilactual, $filter) ->

	username = $state.params.username
	$scope.perfilactual = perfilactual
	$scope.companieros = []
	$scope.profesores = []
	$scope.materias = []
	$scope.canConfig = false
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
	$scope.perfilPath = App.images+'perfil/'

	$scope.setImagenPrincipal()

	if $scope.USER.user_id == $scope.perfilactual.user_id
		$scope.canConfig = true



	$scope.setImagenPrincipal = ()->
		ini = App.images+'perfil/'

		imgUsuario = $scope.perfilactual.imagen_nombre
		imgOficial = $scope.perfilactual.foto_nombre
		
		pathUsu = ini + imgUsuario
		pathOfi = ini + imgOficial
		
		$scope.imagenPrincipal = pathUsu
		$scope.imagenOficial = pathOfi

	traerDatos = ()->
		$http.get('::perfiles/profesormispersonas').then((r)->
			r = r.data
			$scope.perfilactual = r[0]
			$scope.setImagenPrincipal()
		,(r2)->
			toastr.error 'No se pudo traer el usuario'
			return $state.transitionTo 'panel'
		)


	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.perfilactual.pais_doc is 'undefined'
				$scope.perfilactual.pais_doc = $item
				$scope.paisDocSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.perfilactual.departamento_doc is 'undefined'
				$scope.perfilactual.departamento_doc = $item
				$scope.departDocSeleccionado($item)
		)

	$scope.paisDocSelecionado = ($item, $model)->
		
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departDocSeleccionado = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$http.get('::paises').then((r)->
		$scope.paises = r.data
	)

	$http.get('::tiposdocumento').then (r)->
		$scope.tipos_doc = r.data
		# ARREGLO PAIS DE NACIMIENTO
		if $scope.perfilactual.tipo_doc
			tipo_temp = $filter('filter')($scope.tipos_doc, {id: $scope.perfilactual.tipo_doc})
			if tipo_temp.length > 0
				$scope.perfilactual.tipo_doc = tipo_temp[0]

	


	# ARREGLO PAIS DE NACIMIENTO
	if $scope.perfilactual.ciudad_nac == null
		$scope.perfilactual.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
		$scope.paisNacSelect($scope.perfilactual.pais_nac, $scope.perfilactual.pais_nac)
	else
		$http.get('::ciudades/datosciudad/'+$scope.perfilactual.ciudad_nac).then (r2)->
			$scope.paises = r2.data.paises
			$scope.departamentosNac = r2.departamentos
			$scope.ciudadesNac = r2.ciudades
			$scope.perfilactual.pais_nac = r2.pais
			$scope.perfilactual.departamento_nac = r2.departamento
			$scope.perfilactual.ciudad_nac = r2.ciudad

		$http.get('::ciudades/datosciudad/'+$scope.perfilactual.ciudad_doc).then (r2)->
			$scope.paises = r2.data.paises
			$scope.departamentos = r2.departamentos
			$scope.ciudades = r2.ciudades
			$scope.perfilactual.pais_doc = r2.pais
			$scope.perfilactual.departamento_doc = r2.departamento
			$scope.perfilactual.ciudad_doc = r2.ciudad

	


	
	$scope.nameToShow = ()->
		if $scope.perfilactual.tipo == 'Usu'
			return $scope.perfilactual.username.toUpperCase()
		else
			return $scope.perfilactual.nombres + ' ' + $scope.perfilactual.apellidos

])