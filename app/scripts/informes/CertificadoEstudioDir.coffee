angular.module('myvcFrontApp')

.directive('certificadoEstudioDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "#{App.views}informes/certificadoEstudioDir.tpl.html"
	scope: 
		grupo: "="
		year: "="
		alumno: "="
		config: "="
		escalas: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

		scope.USER = Perfil.User()
		scope.USER.nota_minima_aceptada = parseInt(scope.USER.nota_minima_aceptada)
		scope.perfilPath = App.images+'perfil/'

		#console.log scope.config.orientacion
])







