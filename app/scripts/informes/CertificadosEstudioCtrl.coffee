angular.module("myvcFrontApp")

.controller('CertificadosEstudioCtrl', ['$scope', '$state', 'alumnosDat', 'escalas', '$cookies', '$stateParams', '$http', 'toastr', ($scope, $state, alumnos, escalas, $cookies, $stateParams, $http, toastr)->

	$scope.grupo          = alumnos[0]
	$scope.year           = alumnos[1]
	$scope.alumnos        = alumnos[2]
	$scope.escalas_val    = alumnos[3]
	

	$scope.$stateParams 	= $stateParams

	$scope.escalas        = escalas

	$scope.config             = $cookies.getObject 'config'
	$scope.requested_alumnos  = $cookies.getObject 'requested_alumnos'
	$scope.requested_alumno   = $cookies.getObject 'requested_alumno'


	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'

	$scope.cambia_contador_certificados = (contador, year_id, col)->
		console.log(contador, year_id)
		$http.put('::bolfinales/cambiar-'+col, {contador: contador, year_id: year_id} ).then((r)->
			toastr.success 'Contador guardado'
		, (r2)->
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.espaciado = false
	if alumnos[2].length > 0
		if alumnos[2][0].asignaturas.length < 13
			$scope.espaciado = true
			
	
	for alum in alumnos[2]
		for area in alum.areas
			for asign in area.asignaturas
				for recupera in alum.recuperaciones
					if asign.asignatura_id == recupera.asignatura_id
						if $scope.year.show_subasignaturas_en_finales or $scope.year.cant_asignatura_pierde_year or area.asignaturas.length==1
							recupera.mostrar_en_certificado = true
							
						
			


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo


	###
		$http.get('http://localhost/myvc_server/public/certificados-estudio/certificado-grupo/10', { responseType: 'arraybuffer' })
			.success((response)->
				file = new Blob([response], { type: 'application/pdf' })
				fileURL = URL.createObjectURL(file);
				$scope.pdfContent = $sce.trustAsResourceUrl(fileURL);
			)
			.error((r2)->
				console.log 'Pailaaassss', r2
			);


	$http.get('certificados-estudio/certificado-grupo/10', {}, {responseType: 'blob', "X-Auth-Token": 'token'}).then((response)->
		console.log response
		url = (window.URL or window.webkitURL).createObjectURL(response);
		window.open(url);
	);
	###

])
