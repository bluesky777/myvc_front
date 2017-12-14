'use strict'

angular.module("myvcFrontApp")


.controller('NewAcudienteModalCtrl', ['$scope', 'App', '$uibModalInstance', 'alumno', 'paises', 'tipos_doc', 'parentescos', '$http', 'toastr', ($scope, App, $modalInstance, alumno, paises, tipos_doc, parentescos, $http, toastr)->
	$scope.alumno 				= alumno
	$scope.paises 				= paises
	$scope.parentescos 			= parentescos
	$scope.datos 				= {}
	$scope.tipos_doc 			= tipos_doc
	$scope.crearTabSelected 	= false
	$scope.selectTabSelected 	= true
	$scope.perfilPath 			= App.images+'perfil/'
	$scope.acudiente 	= {
		sexo:	'M'
	}

	$scope.acudientes = [  ]


	$scope.acudiente.parentesco = $scope.parentescos[0]


	$scope.selectCrearTab = ()->
		$scope.crearTabSelected 	= true
		$scope.selectTabSelected 	= false

	$scope.selectSelectTab = ()->
		$scope.crearTabSelected 	= false
		$scope.selectTabSelected 	= true



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	$scope.$on('modal.closing', (event, reason, closed)->

		switch (reason)
			when "backdrop click", "escape key press"
				if (!confirm('¿Seguro que quiere cerrar sin guardar acudiente?')) 
					event.preventDefault();

			

	)


	$scope.refreshAcudientes = (termino)->
		if termino
			$http.put('::acudientes/buscar', { termino: termino } ).then((r)->
				$scope.acudientes = r.data
			, (r2)->
				toastr.warning 'No se pudo encontrar nada.', 'Problema'
			)

	$scope.selectAcudiente = ($item)->
		if termino
			$http.put('::acudientes/buscar', { termino: termino } ).then((r)->
				$scope.acudientes = r.data
			, (r2)->
				toastr.warning 'No se pudo encontrar nada.', 'Problema'
			)


	
	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.acudiente.pais_doc is 'undefined'
				for un_pais in $scope.paises
					if un_pais.id == $item.id
						$scope.acudiente.pais_doc = un_pais
				$scope.paisSelecionado(un_pais)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/pordepartamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.acudiente.departamento_doc is 'undefined'
				$scope.acudiente.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSelecionado = ($item, $model)->
		
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departSeleccionado = ($item)->
		$http.get("::ciudades/pordepartamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$scope.dateOptions = 
		formatYear: 'yy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = $scope.alumno.estrato + 1


	$scope.crearAcudiente = ()->
		
		$scope.acudiente.alumno_id = alumno.alumno_id

		$http.post('::acudientes/crear', $scope.acudiente ).then((r)->
			toastr.success 'Acudiente creado con éxito.'
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo crear al alumno.', 'Problema'
		)
		$modalInstance.close()


	$scope.seleccionarAcudiente = ()->
		
		$http.post('::acudientes/seleccionar-parentesco', $scope.acudiente ).then((r)->
			toastr.success 'Acudiente seleccionado.'
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo seleccionar.', 'Problema'
		)
		$modalInstance.close()


])