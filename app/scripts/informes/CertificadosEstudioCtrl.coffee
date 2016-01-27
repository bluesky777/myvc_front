angular.module("myvcFrontApp")

.controller('CertificadosEstudioCtrl', ['$scope', 'App', '$rootScope', '$state', 'alumnosDat', 'escalas', 'Restangular', '$modal', '$filter', 'AuthService', '$cookieStore', '$http', '$sce', ($scope, App, $rootScope, $state, alumnos, escalas, Restangular, $modal, $filter, AuthService, $cookieStore, $http, $sce)->
	
	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	$scope.requested_alumnos = $cookieStore.get 'requested_alumnos'
	$scope.requested_alumno = $cookieStore.get 'requested_alumno'

	
	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'


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
	###

	Restangular.one('certificados-estudio/certificado-grupo', 10).withHttpConfig({responseType: 'blob'}).get({}, {"X-Auth-Token": 'token'}).then((response)->
		console.log response
		url = (window.URL or window.webkitURL).createObjectURL(response);
		window.open(url);
	);


])