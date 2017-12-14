'use strict'

angular.module("myvcFrontApp")

.controller('CiudadesCtrl', ['$scope', 'toastr', '$http', 'paises', '$filter', ($scope, toastr, $http, paises, $filter)->

	$scope.creandociudad 		= false
	$scope.creandodepartamento 	= false
	$scope.creandopais 			= false

	$scope.crearciudad 			= {nuevo_depart: false }
	$scope.modificando_depart 	= false
	$scope.crearpais 			= { }

	$scope.departamentos 		= []
	$scope.paises 				= paises.data

	$scope.crearciudad.pais 	= $filter('filter')($scope.paises, { id: 1 })[0]

	$scope.paisSeleccionado = (pais, departamento)->
		#$http.put('::ciudades/departamentos-by-id', {params: {pais_id: pais.id} }).then((r)->
		$http.put('::ciudades/departamentos-by-id', {pais_id: pais.id}).then((r)->
			$scope.departamentos = r.data.departamentos

			if $scope.modificando_depart
				$scope.crearciudad.depart = $filter('filter')($scope.departamentos, {departamento: departamento}, true)[0]
				$scope.departamentoSeleccionado $scope.crearciudad.depart
				$scope.modificando_depart = false
		, ()->
			toastr.error 'No se pudo traer las ciudades.'
		)
	
	$scope.paisSeleccionado($scope.crearciudad.pais)
		

	$scope.departamentoSeleccionado = (depart, modelo)->
		$http.get('::ciudades/by-departamento', {params: {departamento: depart.departamento} }).then((r)->
			$scope.ciudades = r.data
		, ()->
			toastr.error 'No se pudo traer las ciudades.'
		)



	$scope.crearCiudad = ()->
		$scope.creandociudad = true

	$scope.crearDepartamento = ()->
		$scope.creandodepartamento = true

	$scope.crearPais = ()->
		$scope.creandopais = true

	$scope.guardarCiudad = ()->

		$http.post('::ciudades/guardarciudad', $scope.crearciudad ).then( (r)->
			toastr.success 'Creado correctamente: ' + r.data.ciudad
			$scope.ciudades.push r.data
			$scope.creandociudad = false
			$scope.crearciudad = {}
			$scope.guardar = true

			$http.get('::paises').then((r)->
			$scope.paises = r.data
			$scope.crearciudad.pais = $filter('filter')($scope.paises, { id: 1 })[0]
			$scope.paisSeleccionado($scope.crearciudad.pais)
			

			, (r2)->
				toastr.error 'No se pudo traer las ciudades.'
			)
		, (r2)->
			toastr.error 'No se pudo crear', 'Error'
		)

	$scope.guardarPais = ()->

		$http.post('::paises/guardar', $scope.crearpais ).then( (r)->
			toastr.success 'Creado correctamente: ' + r.data.paisnuevo
			$scope.paises.push r.data
			$scope.paisSeleccionado($scope.crearciudad.pais)
				
		, (r2)->
			toastr.error 'No se pudo crear', 'Error'
		)

	$scope.actualizarCiudad = (ciudad)->
		$http.put('::ciudades/actualizar-ciudad', ciudad).then( (r)->
			toastr.success 'Actualizado: ' + ciudad.ciudad
			ciudad.editandoCiudad = false
		, (r2)->
			toastr.error 'No se pudo actualizar', 'Error'
		)

	$scope.actualizarDepartamento = (ciudad)->
		$http.put('::ciudades/actualizar-departamento', ciudad).then( (r)->
			toastr.success 'Actualizado: ' + ciudad.departamento
			ciudad.editandoDepart = false
			pais = $scope.crearciudad.pais

			$scope.modificando_depart = true
			$scope.paisSeleccionado(pais, ciudad.departamento)

		, (r2)->
			toastr.error 'No se pudo actualizar', 'Error'
		)
	$scope.actualizarPais = (pais)->
		$http.put('::paises/actualizar', pais).then( (r)->
			toastr.success 'Actualizado: ' + pais.pais
			pais.editandoPais = false
			pais.editandoAbrev = false
		

		, (r2)->
			toastr.error 'No se pudo actualizar', 'Error'
		)

	$scope.eliminarUsuario = (usu)->
		
		$http.delete('::usuarios/eliminar/' + usu.id).then( (r)->
			$scope.usuarios = $filter('filter')($scope.usuarios, {id: '!'+usu.id})
		, (r2)->
			console.log 'No se pudo eliminar producto', r2
		)

	

	$scope.editarUsuario = (usu)->
		$scope.editando = true
		$scope.usuarioActualizar = usu
		# Configuramos el tipo para el SELECT2
		tipo = $filter('filter')($scope.tipos_doc, {tipo: $scope.usuarioActualizar.doc_tipo}, true)
				
		if tipo.length > 0
			tipo = tipo[0]
		else
			tipo = $scope.tipos_doc[0]
		
		$scope.usuarioActualizar.doc_tipo = tipo

		
		# Configuramos la ciudad nac 

		if $scope.usuarioActualizar.ciudad_nac == null
			$scope.usuarioActualizar.pais = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisSeleccionado($scope.usuarioActualizar.pais, $scope.usuarioActualizar.pais)
		else
			$http.get('::ciudades/datosciudad/'+$scope.usuarioActualizar.ciudad_nac).then (r2)->
				$scope.paises = r2.data.paises
				$scope.departamentosNac = r2.departamentos
				$scope.ciudadesNac = r2.ciudades
				$scope.usuarioActualizar.pais = r2.pais
				$scope.usuarioActualizar.depart_nac = r2.departamento
				$scope.usuarioActualizar.ciudad_nac = r2.ciudad

	

	return
])