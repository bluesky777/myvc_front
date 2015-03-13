angular.module('myvcFrontApp')
.controller('InformesCtrl', ['$scope', 'Restangular', '$state', '$stateParams', '$rootScope', '$filter', 'App', 'AuthService', 'GruposServ', '$timeout', ($scope, Restangular, $state, $stateParams, $rootScope, $filter, App, AuthService, GruposServ, $timeout) ->

	AuthService.verificar_acceso()
	$scope.rowsAlum = [] 
	$scope.orientacion = 'vertical'

	$scope.datos = {grupo: ''}


	GruposServ.getGrupos().then((r)->
		$scope.grupos = r

		$tempParam = parseInt($state.params.grupo_id)

		if $state.params.grupo_id
			$scope.datos.grupo = $filter('filter')($scope.grupos, {id: $tempParam}, true)[0]
			console.log 'Cambiamos a ', $scope.datos.grupo

	
	)

	$scope.verBoletines = ()->
		console.log $scope.datos.grupo
		$state.go 'informes.boletines_periodo', {grupo_id: $scope.datos.grupo.id}, {reload: true}


	$scope.selectGrupo = (item)->
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